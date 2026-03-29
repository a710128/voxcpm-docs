========================
ComfyUI-VoxCPMTTS
========================

ComfyUI-VoxCPMTTS is a lightweight ComfyUI node for VoxCPM 1.5, featuring built-in **automatic speech recognition** for reference audio transcription.

- Repo: `1038lab/ComfyUI-VoxCPMTTS <https://github.com/1038lab/ComfyUI-VoxCPMTTS>`_

.. note::
    For LoRA training and dual-model support, see :doc:`comfyui_voxcpm`.

.. list-table:: Supported VoxCPM Versions
   :widths: 30 70
   :header-rows: 0

   * - VoxCPM 1.0 (0.5B)
     - ✅ Available in UI (16 kHz)
   * - VoxCPM 1.5
     - ✅ Default and recommended (44.1 kHz)
   * - VoxCPM 2
     - ❌ Not supported

This extension provides two node variants:

* **AILab_VoxCPMTTS** — simplified node with hidden advanced parameters
* **AILab_VoxCPMTTS_Advanced** — full control over all generation parameters

Features
--------

* TTS and voice cloning with **VoxCPM 1.5** (44.1 kHz output); VoxCPM 0.5B also available in the UI
* **Auto-transcription** of reference audio via faster-whisper (requires enabling ``auto_transcribe_reference``)
* Fade-in post-processing for smoother audio output (configurable ``fade_in_ms`` on Advanced node)
* Simplified node uses fixed defaults (``cfg_value=2.0``, ``inference_steps=10``); Advanced node exposes full manual control
* ``REFERENCE_TEXT`` output port for inspecting ASR results
* Configurable ASR model via environment variable ``VOXCPM_ASR_MODEL`` (``tiny`` / ``small`` / ``medium`` / ``large``)
* Multi-device: **auto** (auto-detect), **CUDA**, **MPS**, **CPU**

Prerequisites
-------------

* `ComfyUI <https://github.com/comfyanonymous/ComfyUI>`_ installed and running
* PyTorch with appropriate backend
* ~1.2 GB disk space for model downloads

Installation
------------

* Via ComfyUI Manager: search for ``VoxCPMTTS`` and install.

Manual installation:

.. code-block:: bash

    cd ComfyUI/custom_nodes/
    git clone https://github.com/1038lab/ComfyUI-VoxCPMTTS.git
    pip install -r ComfyUI-VoxCPMTTS/requirements.txt
    # Restart ComfyUI

Models are auto-downloaded on first use. Default path is ``ComfyUI/models/TTS/VoxCPM1.5/`` for the 1.5 model, or ``ComfyUI/models/TTS/VoxCPM-0.5B/`` if 0.5B is selected.

Basic usage
-----------

Text-to-Speech
^^^^^^^^^^^^^^

1. Add the **VoxCPM TTS** node (simplified) or **VoxCPM TTS (Advanced)** node
2. Enter the ``text`` to synthesize
3. The simplified node uses sensible defaults (``cfg_value=2.0``, ``inference_steps=10``)
4. The Advanced node lets you manually set ``cfg_value``, ``inference_steps``, and other parameters

Voice cloning
^^^^^^^^^^^^^

1. Connect ``reference_audio`` with a reference audio clip
2. For auto-transcription: enable ``auto_transcribe_reference`` on the node (required — leaving ``reference_text`` empty alone is not sufficient)
3. Alternatively, provide the transcript manually in ``reference_text``
4. The ``REFERENCE_TEXT`` output shows the detected/provided transcript for verification

Recommended parameter tuning
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The README suggests the following parameter combinations for different speed/quality trade-offs (set manually on the Advanced node):

.. list-table::
   :widths: 20 25 25 30
   :header-rows: 1

   * - Profile
     - CFG Value
     - Inference Steps
     - Speed
   * - Fast
     - 1.5
     - 5
     - Fastest
   * - Balanced
     - 2.0
     - 10
     - Moderate
   * - High Quality
     - 3.0
     - 20
     - Slowest

Advanced node parameters
^^^^^^^^^^^^^^^^^^^^^^^^

.. list-table::
   :widths: 25 75
   :header-rows: 1

   * - Parameter
     - Description
   * - ``cfg_value``
     - Classifier-free guidance scale
   * - ``inference_steps``
     - LocDiT diffusion steps
   * - ``max_length``
     - Maximum generation token length
   * - ``fade_in_ms``
     - Fade-in duration for audio smoothing
   * - ``retry_attempts``
     - Maximum retries for bad outputs
   * - ``retry_threshold``
     - Threshold for bad-case detection
   * - ``auto_transcribe_reference``
     - Enable ASR for reference audio
   * - ``normalize``
     - Enable text normalization
   * - ``unload_model``
     - Unload model after inference to free VRAM

Troubleshooting
---------------

Out of Memory (OOM)
^^^^^^^^^^^^^^^^^^^^

VoxCPM 1.5 requires significant VRAM. If you encounter OOM errors:

* Enable ``unload_model`` to release GPU memory after each generation
* Switch ``device`` to ``cpu`` (slower but uses system RAM)
* Close other GPU-intensive applications
* Try the **Fast** quality preset to reduce memory usage

Model download issues
^^^^^^^^^^^^^^^^^^^^^

If auto-download fails, manually download from `Hugging Face <https://huggingface.co/openbmb/VoxCPM1.5>`_ and place files in ``ComfyUI/models/TTS/VoxCPM1.5/``.

For debug logging, set ``COMFYUI_LOG_LEVEL=DEBUG``.

Comparing with ComfyUI-VoxCPM
------------------------------

.. list-table::
   :widths: 30 35 35
   :header-rows: 1

   * - Feature
     - ComfyUI-VoxCPM
     - ComfyUI-VoxCPMTTS
   * - Model support
     - VoxCPM 1.5 + 0.5B
     - VoxCPM 1.5 (recommended) + 0.5B
   * - LoRA training
     - ✅ Built-in
     - ❌
   * - Auto-transcription
     - ❌ Manual only
     - ✅ faster-whisper
   * - Node variants
     - Single node
     - Simple + Advanced
   * - Quality presets
     - Manual parameters
     - Fast / Balanced / HQ
   * - Dependencies
     - Heavier (LoRA training)
     - Lighter
