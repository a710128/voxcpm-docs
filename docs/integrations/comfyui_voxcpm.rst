========================
ComfyUI-VoxCPM
========================

ComfyUI-VoxCPM is a full-featured ComfyUI custom node for VoxCPM, with TTS, voice cloning, and **in-node LoRA training** support.

- Repo: `wildminder/ComfyUI-VoxCPM <https://github.com/wildminder/ComfyUI-VoxCPM>`_

It wraps VoxCPM into ComfyUI's visual node-based workflow, allowing users to integrate speech synthesis into their generation pipelines.

.. note::
    For a lighter alternative with auto-transcription, see :doc:`comfyui_voxcpmtts`.

.. list-table:: Supported VoxCPM Versions
   :widths: 30 70
   :header-rows: 0

   * - VoxCPM 1.0 (0.5B)
     - ✅ Supported (``openbmb/VoxCPM-0.5B``, 16 kHz)
   * - VoxCPM 1.5
     - ✅ Supported (``openbmb/VoxCPM1.5``, 44.1 kHz)
   * - VoxCPM 2
     - ❌ Not supported

Features
--------

* Supports both **VoxCPM 1.5** (44.1 kHz, ~800M params) and **VoxCPM-0.5B** (16 kHz, ~640M params)
* Auto-download models to ``ComfyUI/models/tts/VoxCPM/``
* **LoRA inference and training** directly in ComfyUI:

  - ``VoxCPM Train Config`` — configure training hyperparameters
  - ``VoxCPM Dataset Maker`` — prepare fine-tuning data
  - ``VoxCPM LoRA Trainer`` — run LoRA fine-tuning within ComfyUI

* All generation parameters exposed as node inputs
* Built-in denoiser (ZipEnhancer) disabled by default to keep dependencies light
* Multi-device support: **CUDA**, **CPU**, **MPS** (Apple Silicon), **DirectML**, **HIP** (AMD ROCm, if available)

Prerequisites
-------------

* `ComfyUI <https://github.com/comfyanonymous/ComfyUI>`_ installed and running
* PyTorch with appropriate backend (CUDA, MPS, etc.)
* Model weights: `openbmb/VoxCPM1.5 <https://huggingface.co/openbmb/VoxCPM1.5>`_ or `openbmb/VoxCPM-0.5B <https://huggingface.co/openbmb/VoxCPM-0.5B>`_ (auto-downloaded)

Installation
------------

* Via ComfyUI Manager: search for ``ComfyUI-VoxCPM`` and install.

Manual installation:

.. code-block:: bash

    cd ComfyUI/custom_nodes/
    git clone https://github.com/wildminder/ComfyUI-VoxCPM.git
    pip install -r ComfyUI-VoxCPM/requirements.txt
    # Restart ComfyUI

Models are auto-downloaded on first use.

Basic usage
-----------

Text-to-Speech
^^^^^^^^^^^^^^

1. Add a **VoxCPM TTS** node from the ``audio/tts`` category
2. Connect ``text`` input with the target text to synthesize
3. Adjust ``cfg_value``, ``inference_timesteps``, and ``device`` as needed
4. Connect output to a ``Save Audio`` or ``Preview Audio`` node

Voice cloning
^^^^^^^^^^^^^

1. Add a **Load Audio** node and load your reference audio
2. Connect it to the ``prompt_audio`` input of the VoxCPM TTS node
3. Provide the **verbatim transcript** in ``prompt_text`` (not a description — must match the reference audio exactly)
4. Enter the target text to synthesize in ``text``

.. tip::
    For high-quality voice clones, use clear reference audio (5–15 seconds) and ensure ``prompt_text`` is an accurate transcript.

LoRA fine-tuning
^^^^^^^^^^^^^^^^

1. Add ``VoxCPM Train Config`` → ``VoxCPM Dataset Maker`` → ``VoxCPM LoRA Trainer`` nodes
2. Configure your training data and hyperparameters
3. Run the workflow to train a LoRA adapter
4. Load the trained LoRA from ``models/loras`` (use the refresh button and ``lora_name`` dropdown)

See ``readme-lora-training.md`` in the repository for detailed training instructions.

Parameters
----------

.. list-table::
   :widths: 25 75
   :header-rows: 1

   * - Parameter
     - Description
   * - ``model_name``
     - Select VoxCPM 1.5 or 0.5B
   * - ``cfg_value``
     - Classifier-free guidance scale (default: 2.0; higher = closer to prompt, may reduce quality)
   * - ``inference_timesteps``
     - LocDiT diffusion steps (default: 10; higher = better quality, slower)
   * - ``device``
     - ``cuda`` / ``cpu`` / ``mps`` / ``directml`` / ``hip`` (varies by hardware)
   * - ``normalize_text``
     - Enable external text normalization (disable for phoneme input)
   * - ``seed``
     - Random seed for reproducibility (default: -1 for random)
   * - ``lora_name``
     - Select a LoRA adapter from ``models/loras``
   * - ``min_tokens`` / ``max_tokens``
     - Token length range for generation
   * - ``force_offload``
     - Offload model from GPU after inference to save VRAM
   * - ``retry_max_attempts``
     - Maximum retries for bad generation outputs
   * - ``retry_threshold``
     - Threshold for bad-case detection

Troubleshooting
---------------

Out of memory
^^^^^^^^^^^^^

* Set ``force_offload`` to ``True`` to release GPU memory after each generation
* Switch to ``cpu`` device (slower but uses system RAM)
* Use VoxCPM-0.5B instead of 1.5 for lower memory usage
