========================
VoxCPM-ONNX
========================

VoxCPM-ONNX provides ONNX export and ONNX Runtime inference for VoxCPM, with an optional FastAPI REST server.

- Repo: `bluryar/VoxCPM-ONNX <https://github.com/bluryar/VoxCPM-ONNX>`_

.. warning::
    This project is **archived** by the author. For active development, consider `VoxCPM.cpp <https://github.com/bluryar/VoxCPM.cpp>`_ instead.
    The code and documentation were largely AI-generated; use as a reference.

It provides ONNX export scripts, an ONNX Runtime inference pipeline, and a FastAPI server with an OpenAI-style TTS API.

.. list-table:: Supported VoxCPM Versions
   :widths: 30 70
   :header-rows: 0

   * - VoxCPM 1.0 (0.5B)
     - ✅ Supported (default ``openbmb/VoxCPM-0.5B``, 16 kHz)
   * - VoxCPM 1.5
     - ❌ Not in this repo (see `DakeQQ's export script <https://github.com/DakeQQ/Text-to-Speech-TTS-ONNX/blob/main/VoxCPM/Export_VoxCPM_ONNX.py>`_)
   * - VoxCPM 2
     - ❌ Not supported

Features
--------

* ONNX export from PyTorch VoxCPM-0.5B weights
* CPU and GPU inference via ONNX Runtime
* FastAPI server with ``/tts``, ``/ref_feat``, ``/health`` endpoints
* SQLite-backed reference feature caching (via ``/ref_feat``)
* Docker Compose support (CPU and GPU services)

Prerequisites
-------------

* Python >= 3.10
* ``openbmb/VoxCPM-0.5B`` checkpoint
* (Optional) CUDA 11.8+ for GPU inference
* (Optional) Docker + NVIDIA Container Toolkit

Installation
------------

.. code-block:: bash

    git clone https://github.com/bluryar/VoxCPM-ONNX.git
    cd VoxCPM-ONNX

    # Install dependencies
    uv sync          # or: pip install -e .

    # Export ONNX models (set env vars first)
    export MODEL_PATH=/path/to/VoxCPM-0.5B
    export OUTPUT_DIR=./onnx_models
    export TIMESTEPS=5
    export CFG_VALUE=2.0
    bash export.sh
    bash opt.sh      # optimize exported models

Basic usage (Server)
--------------------

Start the FastAPI server:

.. code-block:: bash

    # Via Docker Compose (GPU) — exposed on port 8101
    docker-compose up voxcpm-gpu

    # Or manually on port 8000
    VOX_MODELS_DIR=/path/to/onnx_models VOX_DEVICE=cuda \
        uvicorn src.server.app:app --host 0.0.0.0 --port 8000

Key environment variables:

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - Variable
     - Description
   * - ``VOX_MODELS_DIR``
     - Path to exported ONNX model directory
   * - ``VOX_DEVICE``
     - ``cpu`` or ``cuda``
   * - ``VOX_SQLITE_PATH``
     - Path to SQLite database for reference feature caching

API examples:

.. code-block:: bash

    # Health check
    curl http://localhost:8000/health

    # Text-to-speech (Form-encoded)
    curl -X POST http://localhost:8000/tts \
        -F "input=Hello from ONNX inference" \
        --output output.wav

    # With Docker Compose GPU service (port 8101)
    curl -X POST http://localhost:8101/tts \
        -F "input=Hello from ONNX inference" \
        --output output.wav

Limitations
-----------

* Targets **VoxCPM-0.5B** only; for VoxCPM 1.5 ONNX export, see DakeQQ's script linked above
* Fixed inference timesteps in exported ONNX models (set at export time)
* Duplicate prefill/decode weights increase model size
