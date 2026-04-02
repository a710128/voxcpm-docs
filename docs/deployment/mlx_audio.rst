========================
MLX-Audio
========================

MLX-Audio is an audio framework built on `Apple MLX <https://github.com/ml-explore/mlx>`_ for **Apple Silicon** Macs. It supports VoxCPM as one of its TTS backends, and gives you a CLI, an OpenAI-compatible FastAPI server, and a separate Next.js web UI.

- Repo: `Blaizzy/mlx-audio <https://github.com/Blaizzy/mlx-audio>`_

.. note::
    This is a good fit if you want to run VoxCPM on an Apple Silicon Mac through the MLX stack, especially when you also want a local API server or a browser UI.

.. list-table:: Supported VoxCPM Versions
   :widths: 30 70
   :header-rows: 0

   * - VoxCPM 1.0 (0.5B)
     - ✅ Supported
   * - VoxCPM 1.5
     - ✅ Supported
   * - VoxCPM 2
     - ⚠️ This page focuses on the current VoxCPM 1.x path on MLX-Audio

Prerequisites
*************

- Apple Silicon Mac (M1 or later)
- Python 3.10+
- ``mlx`` and ``mlx-audio`` installed

Installation
************

.. code-block:: sh

   pip install mlx-audio

Or from source:

.. code-block:: sh

   git clone https://github.com/Blaizzy/mlx-audio.git
   cd mlx-audio
   pip install -e .

CLI Usage
*********

Generate speech directly from the command line:

.. code-block:: sh

   mlx_audio.tts.generate --text "Hello from MLX-Audio!" --model voxcpm

The ``--model`` flag accepts ``voxcpm`` (maps to VoxCPM 1.0) or ``voxcpm1.5``.

API Server
**********

MLX-Audio includes an OpenAI-compatible FastAPI server:

.. code-block:: sh

   mlx_audio.server --model voxcpm

This starts a local server that accepts ``/v1/audio/speech`` requests, compatible with the OpenAI TTS API format. You can point any OpenAI-compatible client at it.

Web UI
******

A separate Next.js web UI is included under ``mlx_audio/ui/``. See the `MLX-Audio README <https://github.com/Blaizzy/mlx-audio#web-ui>`_ for setup instructions.

Limitations
***********

- VoxCPM 2 support is not yet available in MLX-Audio. The current backend covers VoxCPM 1.0 and 1.5.
- Performance depends on your Apple Silicon chip. M1 Pro / M1 Max and later provide the best experience.
- The MLX-Audio project is community-maintained and not officially affiliated with OpenBMB.
