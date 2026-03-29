========================
VoxCPM-RKNN2
========================

VoxCPM-RKNN2 deploys VoxCPM-0.5B on **Rockchip RK3588** edge devices using the RKNN2/RKLLM NPU acceleration stack.

- Repo: `happyme531/VoxCPM-0.5B-RKNN2 <https://huggingface.co/happyme531/VoxCPM-0.5B-RKNN2>`_ on Hugging Face

.. note::
    This project targets **Rockchip RK3588** (and compatible RKNPU2 devices). It is not a general-purpose desktop/server deployment.

.. list-table:: Supported VoxCPM Versions
   :widths: 30 70
   :header-rows: 0

   * - VoxCPM 1.0 (0.5B)
     - ✅ Supported (``openbmb/VoxCPM-0.5B``, 16 kHz)
   * - VoxCPM 1.5
     - ❌ Not supported
   * - VoxCPM 2
     - ❌ Not supported

Features
--------

* NPU-accelerated inference on Rockchip RK3588 SoC
* Combines RKNN (for audio VAE / LocDiT ops) with RKLLM (for LLM backbone)
* Voice cloning with reference audio
* Model conversion pipeline from PyTorch to RKNN/RKLLM formats

Performance
-----------

Benchmarked on RK3588:

* **RTF**: ~4.5 (approximately 45 seconds to generate ~10 seconds of audio)
* **RAM usage**: ~3.3 GB

Prerequisites
-------------

* Rockchip RK3588 board (e.g., Orange Pi 5, Rock 5B)
* Python with RKNN2 runtime libraries
* ``openbmb/VoxCPM-0.5B`` weights (for conversion)

Installation (Inference)
------------------------

.. code-block:: bash

    pip install numpy scipy soundfile tqdm transformers sentencepiece \
        ztu-somemodelruntime-ez-rknn-async

Basic usage
-----------

.. code-block:: bash

    python onnx_infer-rknn2.py \
        --onnx-dir /path/to/rknn_models \
        --tokenizer-dir /path/to/tokenizer \
        --base-hf-dir /path/to/base_model \
        --residual-hf-dir /path/to/residual_model \
        --text "你好，这是 VoxCPM 在 RK3588 上的推理。" \
        --seed 42 \
        --output output.wav

    # Voice cloning
    python onnx_infer-rknn2.py \
        --onnx-dir /path/to/rknn_models \
        --tokenizer-dir /path/to/tokenizer \
        --base-hf-dir /path/to/base_model \
        --residual-hf-dir /path/to/residual_model \
        --prompt-audio ref_voice.wav \
        --prompt-text "参考音频文本" \
        --text "克隆语音说新的文字。" \
        --cfg-value 2.0 \
        --inference-timesteps 10 \
        --seed 42 \
        --output output.wav

Model conversion
----------------

To convert VoxCPM-0.5B weights to RKNN/RKLLM format:

1. Install the conversion toolkit:

.. code-block:: bash

    pip install torch==2.10.0 transformers==4.57.6 onnx==1.18.0 \
        onnxruntime==1.22.0 einops==0.8.2 \
        rknn-toolkit2==2.3.2 rkllm-toolkit==1.2.3

2. Download the base model:

.. code-block:: bash

    # Download openbmb/VoxCPM-0.5B to ./VoxCPM-0.5B

3. Run the conversion pipeline:

.. code-block:: bash

    cd convert
    python scripts/build_rk3588_pipeline.py
    # Artifacts output to build/rk3588/final_models/

See the `conversion guide <https://huggingface.co/happyme531/VoxCPM-0.5B-RKNN2/tree/main/convert>`_ for detailed instructions.

Known issues
------------

* Possible **infinite generation loop** — upstream bad-case guard not yet ported
* Two separate LocEnc models due to RKNN toolchain shape limitations
* RKLLM outputs require manual ×4 scaling workaround
