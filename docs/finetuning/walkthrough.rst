======================================================
Fine-Tuning Walkthrough: VoxCPM 2 on LibriSpeech
======================================================

A complete walkthrough: data preparation → training → inference, using the publicly available `LibriSpeech <https://www.openslr.org/12>`_ corpus. The same workflow applies to any comparable speech dataset — just swap the data-preparation step for your own source.

----

Prerequisites
=============

Hardware
--------

Rough estimates with ``batch_size=16`` and ``max_batch_tokens=8192`` on VoxCPM 2. Actual usage depends on audio length and accumulation steps.

.. list-table::
   :widths: 40 30 30
   :header-rows: 1

   * - Setup
     - SFT (full fine-tuning)
     - LoRA
   * - Single GPU
     - ~40 GB VRAM
     - ~20 GB VRAM
   * - DDP — additional per-card overhead
     - +~10 GB
     - +~10 GB

.. note::

   **DDP extra memory** comes from a per-GPU gradient bucket for ``allreduce`` communication (≈ all trainable params × 4 bytes) plus NCCL buffers. If you hit OOM in DDP, reduce ``batch_size`` or ``max_batch_tokens``.

Software
--------

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - Dependency
     - Requirement
   * - Python
     - 3.10 or 3.11
   * - PyTorch
     - 2.5.0+ (CUDA build matching your driver)
   * - CUDA driver
     - 12.0+
   * - Disk space
     - ~30 GB for ``train-clean-100``; ~5 GB for checkpoints

.. code-block:: bash

   pip install -e .

----

Step 1 — Download LibriSpeech
==============================

.. code-block:: bash

   # train-clean-100  (~6.3 GB compressed, ~30 GB extracted)
   wget https://www.openslr.org/resources/12/train-clean-100.tar.gz
   tar -xzf train-clean-100.tar.gz

The extracted directory layout:

.. code-block:: text

   LibriSpeech/
   └── train-clean-100/
       └── {speaker_id}/
           └── {chapter_id}/
               ├── {speaker_id}-{chapter_id}-{utt_id}.flac
               └── {speaker_id}-{chapter_id}.trans.txt   # "UTT_ID TRANSCRIPT" per line

----

Step 2 — Build the JSONL Manifest
==================================

The training script expects a **JSONL manifest** — one JSON object per line with at minimum an ``audio`` path and a ``text`` transcript.

Save the script below as ``scripts/prepare_librispeech_manifest.py`` and run it once:

.. code-block:: python

   import json
   from pathlib import Path

   LIBRISPEECH_ROOT = Path("/path/to/LibriSpeech/train-clean-100")
   OUTPUT_PATH      = Path("examples/librispeech_train.jsonl")
   MAX_SAMPLES      = 1000

   entries = []
   for trans_file in sorted(LIBRISPEECH_ROOT.rglob("*.trans.txt")):
       speaker_chapter_dir = trans_file.parent
       with open(trans_file, encoding="utf-8") as f:
           for line in f:
               line = line.strip()
               if not line:
                   continue
               utt_id, text = line.split(" ", 1)
               audio_path = speaker_chapter_dir / f"{utt_id}.flac"
               if audio_path.exists():
                   entries.append({"audio": str(audio_path), "text": text.capitalize()})
               if MAX_SAMPLES and len(entries) >= MAX_SAMPLES:
                   break
       if MAX_SAMPLES and len(entries) >= MAX_SAMPLES:
           break

   OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
   with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
       for entry in entries:
           f.write(json.dumps(entry, ensure_ascii=False) + "\n")

   print(f"Wrote {len(entries):,} entries → {OUTPUT_PATH}")

.. code-block:: bash

   python scripts/prepare_librispeech_manifest.py

The resulting manifest looks like:

.. code-block:: json

   {"audio": "/path/to/LibriSpeech/train-clean-100/103/1240/103-1240-0000.flac", "text": "Chapter one missus rachel lynde is surprised ..."}
   {"audio": "/path/to/LibriSpeech/train-clean-100/103/1240/103-1240-0001.flac", "text": "That had its source away back in the woods of the old cuthbert place ..."}

.. note::

   **Why** ``text.capitalize()`` **instead of leaving ALL-CAPS?** VoxCPM's pre-training corpus uses sentence-cased text. Feeding ALL-CAPS transcripts can degrade text adherence at inference time. ``str.capitalize()`` is a simple heuristic; a proper truecasing model gives better results for production use.

----

Step 3a — Full Fine-Tuning (SFT)
=================================

Full fine-tuning updates **all model parameters**. Best for large datasets or significant domain shifts where LoRA capacity is insufficient.

Config file
-----------

Save as ``conf/librispeech_full.yaml``:

.. code-block:: yaml

   pretrained_path: /path/to/VoxCPM2-1B/          # directory with config.json + model.safetensors
   train_manifest:  examples/librispeech_train.jsonl
   val_manifest:    examples/librispeech_val.jsonl  # strongly recommended — enables early stopping

   sample_rate:        48000   # VoxCPM 2 native rate; FLAC 16 kHz is resampled automatically
   batch_size:         2
   grad_accum_steps:   8       # effective bs = batch_size × grad_accum_steps = 16
   num_workers:        8

   num_iters:          62      # ~1 epoch for 1,000 clips at effective bs=16; adjust per your dataset
   max_steps:          62
   log_interval:       10
   valid_interval:     62
   save_interval:      62

   learning_rate:  1.0e-5      # ~10× smaller than LoRA to avoid catastrophic forgetting
   weight_decay:   0.01
   warmup_steps:   6           # ≈ 10 % of num_iters
   max_batch_tokens: 8192      # filters out clips whose token count > max_batch_tokens // batch_size

   save_path:   checkpoints/librispeech_full
   tensorboard: checkpoints/librispeech_full/logs

   lambdas:
     loss/diff: 1.0
     loss/stop: 1.0

Launch
------

.. code-block:: bash

   # Single GPU
   python scripts/train_voxcpm_finetune.py --config_path conf/librispeech_full.yaml

   # Multi-GPU (4×)
   CUDA_VISIBLE_DEVICES=0,1,2,3 torchrun --nproc_per_node=4 \
       scripts/train_voxcpm_finetune.py --config_path conf/librispeech_full.yaml

You can also fill in ``CONFIG_PATH``, ``TRAIN_MANIFEST``, and ``BATCH_SIZE`` at the top of ``run_train.sh`` and run ``bash run_train.sh``.

----

Step 3b — LoRA Fine-Tuning
===========================

LoRA freezes the base model and trains only a small set of low-rank delta matrices. **Recommended as the default starting point.**

Config file
-----------

Save as ``conf/librispeech_lora.yaml``:

.. code-block:: yaml

   pretrained_path: /path/to/VoxCPM2-1B/
   train_manifest:  examples/librispeech_train.jsonl
   val_manifest:    examples/librispeech_val.jsonl

   sample_rate:        48000
   batch_size:         2
   grad_accum_steps:   8       # effective bs = 16
   num_workers:        8

   num_iters:          62      # ~1 epoch for 1,000 clips at effective bs=16
   max_steps:          62
   log_interval:       10
   valid_interval:     62
   save_interval:      62

   learning_rate:  1.0e-4
   weight_decay:   0.01
   warmup_steps:   6           # ≈ 10 % of num_iters
   max_batch_tokens: 8192

   save_path:   checkpoints/librispeech_lora
   tensorboard: checkpoints/librispeech_lora/logs

   lambdas:
     loss/diff: 1.0
     loss/stop: 1.0

   lora:
     enable_lm:   true
     enable_dit:  true    # critical for voice quality — do not disable
     enable_proj: false
     r:     8             # r=8 for speaker adaptation; r=32–64 for new languages
     alpha: 16
     dropout: 0.0

Launch
------

.. code-block:: bash

   python scripts/train_voxcpm_finetune.py --config_path conf/librispeech_lora.yaml

----

Step 4 — Monitor Training
==========================

.. code-block:: bash

   tensorboard --logdir checkpoints/librispeech_full/logs
   # or
   tensorboard --logdir checkpoints/librispeech_lora/logs

Metrics to watch
----------------

.. list-table::
   :widths: 20 80
   :header-rows: 1

   * - Metric
     - Healthy pattern
   * - ``loss/diff``
     - Decreases steadily; flattens as convergence approaches
   * - ``loss/stop``
     - Drops quickly in the first 100–200 steps, then stays low
   * - ``grad_norm``
     - Stays roughly in the 0.3–2.0 range; occasional spikes are fine
   * - ``lr``
     - Cosine warm-up then decay
   * - ``val/loss``
     - Tracks training loss; **stop if it rises while train loss keeps falling**

When to stop
------------

**1–2 epochs is almost always enough** for TTS fine-tuning. The best checkpoint is often not the final one.

- Use ``valid_interval: 50`` and ``save_interval: 50`` for rollback options.
- Pick the checkpoint where ``val/loss`` was lowest.
- If you do not have a val manifest, evaluate a handful of checkpoints in the convergence zone with the inference script and pick the best-sounding one.

.. warning::

   If ``val/loss`` starts rising while ``train/loss`` keeps falling, **stop immediately** and roll back. This is the classic overfitting signature for TTS models: the model will start ignoring input text and generate the same voice pattern regardless of what you type.

----

Step 5 — Inference
==================

SFT checkpoint
--------------

.. code-block:: bash

   # Standard TTS
   python scripts/test_voxcpm_ft_infer.py \
       --ckpt_dir checkpoints/librispeech_full/latest \
       --text "She walked slowly along the quiet avenue, listening to the wind." \
       --output output_full.wav

   # Voice cloning (pass a reference clip and its exact transcript)
   python scripts/test_voxcpm_ft_infer.py \
       --ckpt_dir checkpoints/librispeech_full/latest \
       --text "She walked slowly along the quiet avenue, listening to the wind." \
       --prompt_audio examples/reference_speaker.wav \
       --prompt_text  "Exact transcript of the reference audio." \
       --output output_full_cloned.wav

LoRA checkpoint
---------------

.. code-block:: bash

   python scripts/test_voxcpm_lora_infer.py \
       --lora_ckpt checkpoints/librispeech_lora/latest \
       --text "She walked slowly along the quiet avenue, listening to the wind." \
       --output output_lora.wav

To batch-evaluate and compare multiple checkpoints:

.. code-block:: bash

   for ckpt in checkpoints/librispeech_lora/step_*/; do
       python scripts/test_voxcpm_lora_infer.py \
           --lora_ckpt "$ckpt" \
           --text "Evaluation sentence." \
           --output "eval_$(basename $ckpt).wav"
   done

----

Troubleshooting
===============

Out-of-memory (OOM)
--------------------

LibriSpeech clips vary in duration (2 s – 35 s). ``max_batch_tokens`` already filters the longest ones. If OOM persists, try:

.. code-block:: yaml

   # Option 1 — smaller batch with same effective size
   batch_size:       8
   grad_accum_steps: 2

   # Option 2 — tighter token budget
   max_batch_tokens: 4096

Loss does not decrease
-----------------------

- Verify that audio paths in the manifest are correct and all files are readable.
- LibriSpeech FLAC files are 16 kHz; keep ``sample_rate: 48000`` — the dataloader resamples automatically for VoxCPM 2.
- Check that transcripts are sentence-cased, not ALL-CAPS.

Generated audio ignores input text
-----------------------------------

Classic overfitting symptom. Roll back to an earlier checkpoint:

.. code-block:: bash

   ls checkpoints/librispeech_full/   # find a step before divergence

   python scripts/test_voxcpm_ft_infer.py \
       --ckpt_dir checkpoints/librispeech_full/step_0001000 \
       --text "Test sentence." \
       --output test.wav

For future runs: always provide a ``val_manifest``, use ``valid_interval: 50``, and stop when ``val/loss`` turns upward. Keeping training within 1–3 epochs generally avoids this problem entirely.
