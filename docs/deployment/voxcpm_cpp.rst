========================
VoxCPM.cpp
========================

VoxCPM.cpp is a standalone C++ inference engine for VoxCPM based on ggml, with GGUF model support.

- Repo: `bluryar/VoxCPM.cpp <https://github.com/bluryar/VoxCPM.cpp>`_
- GGUF Weights: `bluryar/VoxCPM-GGUF <https://huggingface.co/bluryar/VoxCPM-GGUF>`_
- Upstream: `OpenBMB/VoxCPM <https://github.com/OpenBMB/VoxCPM>`_

It provides a CLI tool (``voxcpm_tts``) for offline synthesis and an OpenAI-compatible HTTP server (``voxcpm-server``) with streaming support.

.. list-table:: Supported VoxCPM Versions
   :widths: 30 70
   :header-rows: 0

   * - VoxCPM 1.0 (0.5B)
     - ✅ Supported
   * - VoxCPM 1.5
     - ✅ Supported
   * - VoxCPM 2
     - ❌ Not supported

Multiple quantization formats available: Q4_K, Q8_0, F16, F32.

Features
--------

* CLI backends: **CPU**, **CUDA**, **Vulkan** (via ``--backend {cpu|cuda|vulkan|auto}``)
* GGUF quantized models (Q4_K, Q8_0, F16, F32) for flexible speed/quality trade-offs
* OpenAI-compatible HTTP server with streaming (audio / SSE modes)
* Voice registration and management via API
* Optional Bearer token authentication (``--api-key``)
* Benchmark scripts for performance profiling
* Experimental WASM/Emscripten web playground (see ``docs/wasm_playground.md`` in repo)

Performance
-----------

Benchmarked on NVIDIA RTX 4060 Ti (CUDA) and Intel i5-12600K (CPU, 8 threads), inference timesteps = 10:

.. list-table:: CUDA Inference (RTF, lower is better)
   :widths: 20 15 20 20 20
   :header-rows: 1

   * - Model
     - Quant
     - Model Only
     - Without Encode
     - Full Pipeline
   * - VoxCPM 1.5
     - Q8_0
     - 0.320
     - 0.411
     - 0.596
   * - VoxCPM 1.5
     - F16
     - 0.352
     - 0.442
     - 0.648
   * - VoxCPM-0.5B
     - F16
     - 0.390
     - 0.428
     - 0.567

.. list-table:: CPU Inference (RTF, lower is better)
   :widths: 20 15 20 20 20
   :header-rows: 1

   * - Model
     - Quant
     - Model Only
     - Without Encode
     - Full Pipeline
   * - VoxCPM 1.5
     - Q8_0
     - 2.086
     - 2.982
     - 4.291
   * - VoxCPM-0.5B
     - Q4_K
     - 1.826
     - 2.219
     - 3.609

Prerequisites
-------------

* CMake >= 3.14
* C++ compiler with C++17 support
* (Optional) CUDA toolkit for GPU acceleration
* (Optional) Vulkan SDK for Vulkan backend

Installation
------------

Build from source:

.. code-block:: bash

    git clone https://github.com/bluryar/VoxCPM.cpp.git
    cd VoxCPM.cpp

    # CPU build
    cmake -B build
    cmake --build build

    # CUDA build
    cmake -B build-cuda -DVOXCPM_CUDA=ON \
        -DCMAKE_CUDA_ARCHITECTURES=89 \
        -DVOXCPM_BUILD_BENCHMARK=OFF \
        -DVOXCPM_BUILD_TESTS=OFF
    cmake --build build-cuda

Download GGUF weights from Hugging Face:

.. code-block:: bash

    # Example: download VoxCPM 1.5 Q8_0 with AudioVAE F16
    huggingface-cli download bluryar/VoxCPM-GGUF \
        --include "voxcpm1.5-q8_0-audiovae-f16.gguf" \
        --local-dir models/

Basic usage (CLI)
-----------------

The ``voxcpm_tts`` binary supports text-to-speech and voice cloning:

.. code-block:: bash

    # Basic TTS
    ./build/examples/voxcpm_tts \
        --model-path models/voxcpm1.5-q8_0-audiovae-f16.gguf \
        --backend auto \
        --threads 8 \
        --text "Hello, this is VoxCPM running in C++." \
        --output output.wav

    # Voice cloning
    ./build/examples/voxcpm_tts \
        --model-path models/voxcpm1.5-q8_0-audiovae-f16.gguf \
        --backend auto \
        --prompt-audio ref_voice.wav \
        --prompt-text "Reference transcript" \
        --text "Cloned voice speaking new text." \
        --output output.wav \
        --inference-timesteps 10 \
        --cfg-value 2.0

HTTP Server
-----------

The ``voxcpm-server`` provides an OpenAI-compatible ``/v1/audio/speech`` endpoint:

.. code-block:: bash

    ./build/examples/voxcpm-server \
        --model-path models/voxcpm1.5-q8_0-audiovae-f16.gguf \
        --model-name voxcpm-1.5 \
        --voice-dir voices/ \
        --disable-auth \
        --host 0.0.0.0 --port 8080

Register a voice and synthesize:

.. code-block:: bash

    # Register a voice
    curl -X POST http://localhost:8080/v1/voices \
        -F "id=my_voice" \
        -F "audio=@ref_voice.wav" \
        -F "text=Reference transcript"

    # Synthesize with registered voice
    curl http://localhost:8080/v1/audio/speech \
        -H "Content-Type: application/json" \
        -d '{"model":"voxcpm-1.5","voice":"my_voice","input":"Hello world"}' \
        --output speech.wav

.. note::
    The examples above use ``--disable-auth``. When authentication is enabled, add ``-H "Authorization: Bearer <your-key>"`` to all requests.

Key server options:

* ``--api-key`` — set Bearer token for authentication
* ``--disable-auth`` — disable Bearer token authentication
* ``--max-queue`` — maximum queued requests (returns 503 when full)
* ``--model-name`` — model identifier used in API requests

.. warning::
    The HTTP server is intended for development and testing. Use ``--api-key`` before exposing to untrusted networks.

Troubleshooting
---------------

Binary not found after build
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Built binaries are located under ``build/examples/``, not ``build/bin/``. For CUDA builds, look in ``build-cuda/examples/``.

Model loading errors
^^^^^^^^^^^^^^^^^^^^

Ensure you are passing a single ``.gguf`` file path (not a directory) to ``--model-path``.
