========================
voxcpm_rs
========================

voxcpm_rs is a **Rust** reimplementation of VoxCPM-0.5B using the `burn <https://github.com/tracel-ai/burn>`_ deep learning framework.

- Repo: `madushan1000/voxcpm_rs <https://github.com/madushan1000/voxcpm_rs>`_
- Upstream: `OpenBMB/VoxCPM <https://github.com/OpenBMB/VoxCPM>`_

.. note::
    This is an experimental project targeting **VoxCPM-0.5B**. Voice cloning with reference audio is supported (see usage below).

.. list-table:: Supported VoxCPM Versions
   :widths: 30 70
   :header-rows: 0

   * - VoxCPM 1.0 (0.5B)
     - ✅ Supported (hardcoded 16 kHz in source)
   * - VoxCPM 1.5
     - ❌ Not tested
   * - VoxCPM 2
     - ❌ Not supported

Features
--------

* Pure Rust implementation — no Python runtime dependency
* Weight conversion from Hugging Face format to burn format
* CLI for text-to-speech synthesis and voice cloning

Prerequisites
-------------

* Rust toolchain (stable)
* A specific commit of the ``burn`` framework (see below)
* ``openbmb/VoxCPM-0.5B`` weights

Installation
------------

This project depends on a pinned commit of ``burn``:

.. code-block:: bash

    # Clone and checkout the required burn version
    git clone https://github.com/tracel-ai/burn.git
    cd burn
    git checkout e0847cbf618395775bf534cbece9f0c7f0d897be
    cd ..

    # Download VoxCPM-0.5B weights
    git clone https://huggingface.co/openbmb/VoxCPM-0.5B

    # Clone and build voxcpm_rs
    git clone https://github.com/madushan1000/voxcpm_rs.git
    cd voxcpm_rs
    cargo build --release

Basic usage
-----------

Convert weights
^^^^^^^^^^^^^^^

.. code-block:: bash

    cargo run --release --bin voxcpm convert \
        --input-path ../VoxCPM-0.5B/ \
        --output-path burn-models/

Generate speech (zero-shot)
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    cargo run --release --bin voxcpm run \
        --model-path burn-models/ \
        --target-text "Hello, this is VoxCPM running in Rust."

    # Play the output
    mpv output.wav

Voice cloning
^^^^^^^^^^^^^

.. code-block:: bash

    cargo run --release --bin voxcpm run \
        --model-path burn-models/ \
        --target-text "Cloned voice output." \
        --prompt-text "Reference transcript" \
        --prompt-wav-path ref_voice.wav \
        --max-len 2048

Output is saved to ``output.wav`` in the current directory.

Limitations
-----------

* **VoxCPM-0.5B only** — VoxCPM 1.5 not yet tested
* Requires a specific pinned version of the ``burn`` framework
* Limited documentation — refer to source code for advanced usage
