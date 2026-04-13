==============================
Fine-Tuning Guide
==============================

This guide covers how to fine-tune VoxCPM with two approaches: LoRA (parameter-efficient) and full fine-tuning. Both use the same training script and data format.

----

Environment & Resources
=======================

Software
--------

.. list-table::
   :widths: 25 75
   :header-rows: 1

   * - Dependency
     - Version
   * - Python
     - 3.10–3.11 recommended for training
   * - PyTorch
     - 2.5.0+
   * - CUDA
     - 12.0+
   * - safetensors
     - recommended (falls back to ``.bin`` / ``.ckpt`` if unavailable)

Additional Python packages used by the training script: ``tensorboardX``, ``argbind``, ``transformers`` (for the cosine scheduler), ``librosa`` (for validation mel spectrograms).

Hardware
--------

.. list-table::
   :widths: 30 35 35
   :header-rows: 1

   * - Setup
     - LoRA
     - Full Fine-Tuning
   * - VoxCPM 1.5 (750M)
     - ~12 GB VRAM
     - ~24 GB VRAM
   * - VoxCPM 2 (2B)
     - ~20 GB VRAM
     - ~40 GB VRAM

These are rough estimates with ``batch_size=16`` and ``max_batch_tokens=8192``. Actual usage depends on audio length and accumulation steps. If you hit OOM, see :doc:`./faq`.

Multi-GPU training is supported via ``torchrun``:

.. code-block:: sh

   CUDA_VISIBLE_DEVICES=0,1,2,3 torchrun --nproc_per_node=4 \
       scripts/train_voxcpm_finetune.py --config_path your_config.yaml

----

Data Preparation
================

Format
------

Training data is a JSONL manifest file with one sample per line:

.. code-block:: json

   {"audio": "path/to/audio1.wav", "text": "Transcript of audio 1."}
   {"audio": "path/to/audio2.wav", "text": "Transcript of audio 2.", "ref_audio": "path/to/audio1.wav"}
   {"audio": "path/to/audio3.wav", "text": "Optional fields.", "duration": 3.5, "dataset_id": 1}

.. list-table::
   :widths: 20 15 65
   :header-rows: 1

   * - Field
     - Required
     - Description
   * - ``audio``
     - Yes
     - Path to audio file (WAV recommended)
   * - ``text``
     - Yes
     - Transcript matching the audio content
   * - ``ref_audio``
     - No
     - Path to a reference audio clip from the **same speaker**. It is used as speaker-conditioning context for voice cloning, so it does not need to be an unseen sample. In practice, ``ref_audio`` is typically another clip randomly sampled from the same speaker / timbre as the target audio. When present, the training sequence is constructed as ``[103, ref_feats, 104, text, 101, audio_feats, 102]``, teaching the model to clone the speaker's voice from the reference. Loss is only computed on the target audio segment.
   * - ``duration``
     - No
     - Duration in seconds; speeds up length filtering
   * - ``dataset_id``
     - No
     - Integer ID for multi-dataset mixing (default: 0)

See ``examples/train_data_example.jsonl`` in the repository for a reference.

.. tip::

   **Mixing ref_audio and non-ref_audio samples** — We recommend that 30–50% of your training samples include ``ref_audio``, so the model retains both zero-shot and reference-based voice cloning abilities. A simple strategy is to randomly choose another clean recording from the same speaker as ``ref_audio`` for each target sample.

Audio requirements
------------------

- **Format:** WAV is recommended. Other formats supported by torchaudio also work.
- **Sample rate:** The dataloader automatically resamples to the target model's rate, so you do not need to pre-resample. The ``sample_rate`` in your training config must match the AudioVAE **encoder** input rate:

  - VoxCPM 1.0: 16kHz
  - VoxCPM 1.5: 44.1kHz
  - VoxCPM 2: 16kHz (the encoder operates at 16kHz; the decoder outputs 48kHz)

- **Duration:** 3–30 seconds per clip is the practical sweet spot. Very short clips (< 1s) produce unstable results. Very long clips increase VRAM usage and may be filtered out by ``max_batch_tokens``.

Preprocessing tips
------------------

- **Trim trailing silence** to < 0.5 seconds. Long trailing silence is one of the most common causes of "generation doesn't stop" after fine-tuning.
- **Normalize volume** if your recordings have inconsistent levels.
- **Clean transcripts:** Ensure the text matches the audio exactly. Mismatched text degrades both cloning quality and text adherence.
- **Remove noisy samples.** The model is sensitive to background noise in training data.

Choosing your path
------------------

Your data size and goal determine which fine-tuning approach to use:

.. list-table::
   :widths: 30 20 50
   :header-rows: 1

   * - Goal
     - Data Size
     - Recommended Approach
   * - Clone a single speaker
     - 5–50 clips
     - :ref:`lora-finetuning` — fast, low VRAM
   * - Adapt to a domain or style
     - 50–500 clips
     - :ref:`lora-finetuning` — with higher rank (``r=32–64``)
   * - Add a new language
     - 500+ hours
     - :ref:`full-finetuning` — mix with some Chinese/English data to reduce forgetting
   * - Large-scale customization
     - 1000+ clips
     - :ref:`full-finetuning`

**LoRA vs Full Fine-Tuning at a glance:**

In internal benchmarks on single-speaker cloning, LoRA (``r=32``) achieved approximately 98% of the speaker similarity of full fine-tuning, while using roughly half the VRAM and producing checkpoint files that are orders of magnitude smaller. LoRA is the recommended starting point for most tasks. Results may vary with different datasets and goals.

----

.. _lora-finetuning:

LoRA Fine-Tuning
================

LoRA trains a small number of additional parameters (typically < 1% of the model) while keeping the base model frozen. It is the recommended starting point for most fine-tuning tasks.

Training
--------

**Configuration**

Create a YAML config file. Here is an example for VoxCPM 2:

.. code-block:: yaml

   pretrained_path: /path/to/VoxCPM2/
   train_manifest: /path/to/train.jsonl
   val_manifest: /path/to/val.jsonl   # optional, leave empty to skip validation

   sample_rate: 16000        # AudioVAE encoder input rate (NOT the 48kHz output rate)
   out_sample_rate: 48000    # AudioVAE decoder output rate; only used at inference, not during training
   batch_size: 16
   grad_accum_steps: 1
   num_workers: 2
   num_iters: 1000
   log_interval: 10
   valid_interval: 500
   save_interval: 500

   learning_rate: 0.0001
   weight_decay: 0.01
   warmup_steps: 100
   max_steps: 1000
   max_batch_tokens: 8192

   save_path: /path/to/checkpoints/lora
   tensorboard: /path/to/logs/lora

   lambdas:
     loss/diff: 1.0
     loss/stop: 1.0

   lora:
     enable_lm: true
     enable_dit: true
     enable_proj: false
     r: 32
     alpha: 32
     dropout: 0.0

.. tip::

   For VoxCPM 1.5, change ``sample_rate`` to ``44100`` and ``pretrained_path`` to your VoxCPM 1.5 checkpoint. The ``sample_rate`` must always match the AudioVAE encoder input rate in ``config.json`` — **not** the output rate. The training script auto-detects the model architecture from ``config.json``.

**LoRA parameters explained**

.. list-table::
   :widths: 20 40 40
   :header-rows: 1

   * - Parameter
     - Description
     - Recommended
   * - ``enable_lm``
     - Apply LoRA to the language model (base LM + residual LM)
     - ``true``
   * - ``enable_dit``
     - Apply LoRA to the diffusion transformer
     - ``true`` (essential for voice quality)
   * - ``enable_proj``
     - Apply LoRA to projection layers between LM and DiT
     - ``false`` for most cases
   * - ``r``
     - LoRA rank — higher means more capacity
     - 32 for speaker cloning, 64 for style/language adaptation
   * - ``alpha``
     - Scaling factor (``scaling = alpha / r``)
     - Usually ``r`` or ``2*r``. Adjust to control LoRA influence strength.
   * - ``dropout``
     - Dropout on LoRA layers
     - ``0.0`` unless overfitting

**Launch**

.. code-block:: sh

   # Single GPU
   python scripts/train_voxcpm_finetune.py --config_path conf/your_lora_config.yaml

   # Multi-GPU
   CUDA_VISIBLE_DEVICES=0,1,2,3 torchrun --nproc_per_node=4 \
       scripts/train_voxcpm_finetune.py --config_path conf/your_lora_config.yaml

**LoRA WebUI**

VoxCPM also provides a Gradio UI that wraps LoRA training and inference in one place:

.. code-block:: sh

   python lora_ft_webui.py

Monitoring
----------

Training logs to TensorBoard. Start the viewer with:

.. code-block:: sh

   tensorboard --logdir /path/to/logs/lora

**What to watch**

.. list-table::
   :widths: 20 80
   :header-rows: 1

   * - Metric
     - What it tells you
   * - ``loss/diff``
     - Diffusion loss — should steadily decrease, then flatten
   * - ``loss/stop``
     - Stop prediction loss — should stabilize early and stay low
   * - ``grad_norm``
     - Gradient magnitude — spikes may indicate bad samples or too high a learning rate
   * - ``lr``
     - Learning rate curve — cosine decay with warmup, useful to verify your schedule

If a validation manifest is provided, the script also logs ``val/loss`` and generates sample audio + mel spectrograms in TensorBoard at each ``valid_interval``.

**When to stop**

- **Use epochs as a rough guide.** For single-speaker cloning, 1–3 epochs are usually sufficient. Going beyond that often hurts rather than helps — overfitting in TTS fine-tuning can emerge very early.
- ``loss/diff`` plateaus and no longer decreases meaningfully.
- Generated audio in TensorBoard sounds good on your target voice/style.
- If the model starts ignoring input text (generating the same audio regardless of text), you have overfit — roll back to an earlier checkpoint.

.. tip::

   Validation loss does not always correlate perfectly with perceptual quality. Save multiple checkpoints around the convergence zone and evaluate them with actual inference to pick the best one.

**Checkpoint structure**

.. code-block:: text

   checkpoints/lora/
   ├── step_0000500/
   │   ├── lora_weights.safetensors
   │   ├── lora_config.json
   │   ├── optimizer.pth
   │   ├── scheduler.pth
   │   └── training_state.json
   ├── step_0001000/
   │   └── ...
   └── latest -> step_0001000/

Training automatically resumes from ``latest/`` if it exists. The signal handler also saves a checkpoint on ``SIGTERM`` / ``SIGINT`` so you don't lose progress on interruption.

Inference
---------

**CLI**

.. code-block:: sh

   python scripts/test_voxcpm_lora_infer.py \
       --lora_ckpt /path/to/checkpoints/lora/step_0002000 \
       --text "Hello from the fine-tuned model." \
       --output output.wav


**Python API**

.. code-block:: python

   from voxcpm import VoxCPM

   model = VoxCPM.from_pretrained(
       "openbmb/VoxCPM2",
       lora_weights_path="/path/to/checkpoints/lora/latest",
   )

   wav = model.generate(text="Hello from the fine-tuned model.")

**Hot-swapping LoRA at runtime**

You can load, unload, and switch LoRA weights without restarting the model:

.. code-block:: python

   # Load a LoRA
   model.load_lora("/path/to/lora_a")

   # Disable LoRA temporarily (base model only)
   model.set_lora_enabled(False)

   # Re-enable
   model.set_lora_enabled(True)

   # Switch to a different LoRA
   model.unload_lora()
   model.load_lora("/path/to/lora_b")

All hot-swap operations are compatible with ``torch.compile``.

----

.. _full-finetuning:

Full Fine-Tuning
================

Full fine-tuning updates all model parameters. Use it when LoRA does not provide enough capacity — typically for new languages or large-scale customization with 500+ clips.

Training
--------

**Configuration**

.. code-block:: yaml

   pretrained_path: /path/to/VoxCPM2/
   train_manifest: /path/to/train.jsonl
   val_manifest: /path/to/val.jsonl

   sample_rate: 16000        # AudioVAE encoder input rate (NOT the 48kHz output rate)
   out_sample_rate: 48000    # AudioVAE decoder output rate; only used at inference, not during training
   batch_size: 16
   grad_accum_steps: 1
   num_workers: 2
   num_iters: 1000
   log_interval: 10
   valid_interval: 500
   save_interval: 500

   learning_rate: 0.00001    # 10x smaller than LoRA
   weight_decay: 0.01
   warmup_steps: 100
   max_steps: 1000
   max_batch_tokens: 8192

   save_path: /path/to/checkpoints/full
   tensorboard: /path/to/logs/full

   lambdas:
     loss/diff: 1.0
     loss/stop: 1.0

Note the ``lora`` key is absent — this tells the script to do full fine-tuning.

**Key differences from LoRA**

- ``learning_rate`` should be ~10x smaller (``1e-5`` vs ``1e-4``) to avoid catastrophic forgetting.
- VRAM usage is significantly higher because all parameters require gradients.
- Checkpoints are larger (full model weights vs. LoRA delta only).

**Launch**

.. code-block:: sh

   # Single GPU
   python scripts/train_voxcpm_finetune.py --config_path conf/your_full_config.yaml

   # Multi-GPU
   CUDA_VISIBLE_DEVICES=0,1,2,3 torchrun --nproc_per_node=4 \
       scripts/train_voxcpm_finetune.py --config_path conf/your_full_config.yaml

Monitoring
----------

Same TensorBoard metrics as LoRA (``loss/diff``, ``loss/stop``, ``grad_norm``, ``lr``, validation audio).

Full fine-tuning is more prone to overfitting than LoRA. In practice, full fine-tuning often reaches its optimum within 1–2 epochs — continuing beyond that can degrade quality. Pay extra attention to:

- **Validation loss diverging from training loss** — a sign of overfitting. Stop and use the last checkpoint before divergence.
- **Text being ignored** — the most common overfitting symptom. Keep ``training_cfg_rate=0.1`` (do not set it to 0) and ``weight_decay=0.01``. Monitor checkpoints at each ``save_interval``.
- **Smaller datasets overfit faster.** With fewer training samples, the optimal checkpoint may appear within a few hundred steps.
- **New language fine-tuning:** Mix in some Chinese/English data (e.g. 10–20%) to reduce forgetting of the original capabilities.
- **More data does not always mean better results.** Beyond a certain point, adding more data yields diminishing returns; focus on data quality and diversity instead.

**Checkpoint structure**

.. code-block:: text

   checkpoints/full/
   ├── step_0000500/
   │   ├── model.safetensors
   │   ├── config.json
   │   ├── audiovae.pth
   │   ├── tokenizer.json
   │   ├── tokenizer_config.json
   │   ├── special_tokens_map.json
   │   ├── optimizer.pth
   │   ├── scheduler.pth
   │   └── training_state.json
   └── latest -> step_0000500/

Each checkpoint is a complete model directory that can be loaded directly.

Inference
---------

**CLI**

.. code-block:: sh

   python scripts/test_voxcpm_ft_infer.py \
       --ckpt_dir /path/to/checkpoints/full/step_0002000 \
       --text "Hello from the fine-tuned model." \
       --output output.wav

   # With voice cloning
   python scripts/test_voxcpm_ft_infer.py \
       --ckpt_dir /path/to/checkpoints/full/latest \
       --text "Cloned voice with full fine-tuning." \
       --prompt_audio reference.wav \
       --prompt_text "Exact transcript of reference.wav" \
       --output cloned.wav

**Python API**

The checkpoint directory is a complete model — load it directly:

.. code-block:: python

   from voxcpm import VoxCPM

   model = VoxCPM.from_pretrained("/path/to/checkpoints/full/latest")
   wav = model.generate(text="Hello from the fine-tuned model.")

----

For common training issues (OOM, runaway generation, poor LoRA performance, checkpoint errors), see :doc:`./faq`.
