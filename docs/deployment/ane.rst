========================
VoxCPMANE
========================

VoxCPMANE runs VoxCPM on the **Apple Neural Engine (ANE)** via CoreML, packaged as a Python server with a built-in web playground.

- Repo: `0seba/VoxCPMANE <https://github.com/0seba/VoxCPMANE>`_
- CoreML Assets: `seba/VoxCPM-ANE <https://huggingface.co/seba/VoxCPM-ANE>`_ on Hugging Face

.. note::
    This project requires **macOS with Apple Silicon** (M1/M2/M3/M4). It does not support Intel Macs, Linux, or Windows.

.. list-table:: Supported VoxCPM Versions
   :widths: 30 70
   :header-rows: 0

   * - VoxCPM 1.0 (0.5B)
     - ✅ Supported (source code default, 16 kHz)
   * - VoxCPM 1.5
     - ⚠️ Announced in README as beta (``pip install --pre``); source defaults to 0.5B
   * - VoxCPM 2
     - ❌ Not supported

Features
--------

* Native Apple Neural Engine acceleration via CoreML
* Voice cloning with cached compiled voices
* Streaming audio generation
* Built-in web playground UI (Create Voice tab for uploads)
* Server-side playback option
* Preset sample voices included
* VoxCPM 1.5 support announced in README (beta, via ``pip install --pre``; the checked-in source defaults to VoxCPM-0.5B at 16 kHz)

Prerequisites
-------------

* macOS with Apple Silicon (M1 or later)
* Python 3.9 – 3.12
* ``uv`` package manager (recommended)
* (Optional) ``pydub`` for mp3/opus/ogg/aac output formats on ``/v1/audio/speech`` (WAV and FLAC work without it)

Installation
------------

.. code-block:: bash

    # Stable release
    uv pip install voxcpmane
    # or
    pip install voxcpmane

    # VoxCPM 1.5 beta
    uv pip install -U --pre voxcpmane

CoreML model assets are downloaded automatically on first run via Hugging Face Hub (cached under ``~/.cache/huggingface/``). Custom voices are stored in ``~/.cache/ane_tts/``.

Basic usage
-----------

Start the server (default host ``0.0.0.0``, port ``8000``):

.. code-block:: bash

    voxcpmane-server
    # Server starts at http://localhost:8000

    # Custom options
    voxcpmane-server --host 127.0.0.1 --port 9000 --cache-dir /path/to/cache

Open ``http://localhost:8000`` in your browser to access the web playground.

Voice cloning
^^^^^^^^^^^^^

Register custom voices via the API or web UI. The API accepts a JSON body where ``prompt_wav_path`` refers to a file path **on the server filesystem**:

.. code-block:: bash

    # Register a voice via API (JSON)
    curl -X POST http://localhost:8000/v1/voices \
        -H "Content-Type: application/json" \
        -d '{"voice_name":"my_voice","prompt_wav_path":"/path/to/reference.wav","prompt_text":"Reference transcript"}'

For uploading audio files, use the **"Create Voice"** tab in the web playground at ``http://localhost:8000``.

You can also drop audio files with matching ``.txt`` transcripts into the cache directory (``~/.cache/ane_tts/``); they will be compiled on startup.

API reference
-------------

Full API documentation is available in the repository at ``docs/API.md``. Key endpoints:

* ``POST /v1/voices`` — Register a custom voice (JSON body)
* ``POST /v1/audio/speech`` — Generate speech
* ``POST /v1/audio/speech/stream`` — Streaming speech generation
* ``GET /voices`` — List available voices
* ``GET /health`` — Health check
* ``POST /v1/audio/speech/playback`` — Server-side audio playback
* ``POST /v1/audio/speech/cancel`` — Cancel ongoing generation

Limitations
-----------

* **macOS Apple Silicon only** — no cross-platform support
* Long text inputs may need chunking (roadmap item)
* Voice compilation can take several seconds on first use
