FAQ & Troubleshooting
=====================

This page focuses on setup, runtime, deployment, and training problems reported by the VoxCPM community. For prompt strategy, cloning tips, and quality tuning, see :doc:`./chefsguide`.

----

Installation & Environment
****************************

Triton errors on Windows
^^^^^^^^^^^^^^^^^^^^^^^^^

**Symptom:** ``Python int too large to convert to C long`` or Triton-related import failures when loading the model on Windows.

**Cause:** Triton has limited Windows support, and certain PyTorch + Triton version combinations trigger known bugs.

**Solutions:**

1. Install Triton for Windows from the `triton-windows <https://github.com/woct0rdho/triton-windows>`_ community project (`#36 <https://github.com/OpenBMB/VoxCPM/issues/36>`_). **Triton and PyTorch versions must match**:

   .. list-table::
      :widths: 50 50
      :header-rows: 1

      * - PyTorch
        - Triton
      * - 2.4 / 2.5
        - 3.1
      * - 2.6
        - 3.2
      * - 2.7
        - 3.3
      * - 2.8
        - 3.4

2. If Triton still doesn't work, you can skip ``torch.compile`` entirely by loading the model with:

   .. code-block:: python

      model = VoxCPM.from_pretrained("openbmb/VoxCPM2", optimize=False)

   This disables ``torch.compile`` acceleration. Inference will be slower but functionally correct.

3. For the ``Python int too large to convert to C long`` error specifically, see the `PyTorch fix <https://github.com/pytorch/pytorch/issues/162430#issuecomment-3289054096>`_ which involves patching ``torch_python.dll`` (`#27 <https://github.com/OpenBMB/VoxCPM/issues/27>`_).


torchcodec / libtorchcodec errors
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Symptom:** ``RuntimeError: Could not load libtorchcodec`` or ``ImportError: TorchCodec is required for load_with_torchcodec`` when using voice cloning with a reference audio.

**Cause:** ``torchaudio`` (>= 2.9) uses ``torchcodec`` as its default audio backend, which requires FFmpeg to be properly installed.

**Solutions:**

1. Install FFmpeg system-wide (version 4–7 supported):

   - **Linux:** ``sudo apt install ffmpeg``
   - **macOS:** ``brew install ffmpeg``
   - **Windows:** Download from `ffmpeg.org <https://ffmpeg.org/download.html>`_ and add to ``PATH``

2. Install a compatible torchcodec version:

   .. code-block:: sh

      pip install torchcodec

3. If issues persist, force torchaudio to use the ``soundfile`` backend instead:

   .. code-block:: python

      import torchaudio
      torchaudio.set_audio_backend("soundfile")

See also: `HuggingFace discussion on torchcodec <https://discuss.huggingface.co/t/cannot-load-torchcodec/169260/4>`_ (referenced in `#86 <https://github.com/OpenBMB/VoxCPM/issues/86>`_, `#119 <https://github.com/OpenBMB/VoxCPM/issues/119>`_, `#123 <https://github.com/OpenBMB/VoxCPM/issues/123>`_)


torch.compile errors on first run
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Symptom:** ``torch._dynamo.exc.Unsupported`` errors (often mentioning ``einops`` or ``symmetric_difference``) during the warm-up phase.

**Cause:** Certain combinations of PyTorch, Triton, and einops versions have incompatibilities with ``torch.compile`` (`#19 <https://github.com/OpenBMB/VoxCPM/issues/19>`_).

**Solutions:**

1. **Quick fix** — disable torch.compile:

   .. code-block:: python

      model = VoxCPM.from_pretrained("openbmb/VoxCPM2", optimize=False)

2. **Recommended environment** (verified on 4090 per `#19 <https://github.com/OpenBMB/VoxCPM/issues/19>`_):

   .. list-table::
      :widths: 30 70
      :header-rows: 1

      * - Package
        - Version
      * - PyTorch
        - 2.5.1+
      * - Triton
        - 3.1.0+
      * - einops
        - 0.8.1
      * - Python
        - 3.10–3.11

3. If you're on an older GPU with limited SMs, you may also see ``Not enough SMs to use max_autotune_gemm mode`` — this is a warning and can be ignored if inference completes successfully.


Mac / MPS support
^^^^^^^^^^^^^^^^^^

**Q: Can VoxCPM run on Mac (Apple Silicon)?**

Yes. VoxCPM supports CPU and MPS (Metal Performance Shaders) on Apple Silicon Macs (`#14 <https://github.com/OpenBMB/VoxCPM/issues/14>`_, `#20 <https://github.com/OpenBMB/VoxCPM/issues/20>`_, `#41 <https://github.com/OpenBMB/VoxCPM/issues/41>`_).

- **CPU:** Works out of the box, but inference is slow (`#67 <https://github.com/OpenBMB/VoxCPM/issues/67>`_).
- **MPS:** Supported for accelerated inference. Load the model normally and it will automatically detect MPS if available.

.. note::

   The denoiser (ZipEnhancer) runs on CPU even when MPS is active. If you don't need prompt speech enhancement, set ``load_denoiser=False`` to save memory.


Python version compatibility
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

VoxCPM officially supports **Python 3.10–3.11**. Known issues:

- **Python 3.14+:** Installation may fail due to dependency incompatibilities (`#176 <https://github.com/OpenBMB/VoxCPM/issues/176>`_). Use Python 3.10–3.12 instead.
- **``No module named 'pkg_resources'``:** This happens on newer Python/setuptools versions (`#189 <https://github.com/OpenBMB/VoxCPM/issues/189>`_). Fix with:

  .. code-block:: sh

     pip install setuptools

----

Performance & Deployment
**************************

VRAM usage reference (still being validated)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. list-table::
   :widths: 40 30 30
   :header-rows: 1

   * - Model
     - VRAM (GPU)
     - RTF (4090)
   * - VoxCPM 1.0 (0.5B)
     - ~5 GB
     - ~0.17
   * - VoxCPM 1.5 (0.8B)
     - ~6 GB
     - ~0.15
   * - VoxCPM 2
     - ~8 GB
     - ~0.12

RTF (Real-Time Factor) is measured with ``inference_timesteps=10`` and ``torch.compile`` enabled on a single NVIDIA RTX 4090 GPU (`#9 <https://github.com/OpenBMB/VoxCPM/issues/9>`_, `#67 <https://github.com/OpenBMB/VoxCPM/issues/67>`_, `#105 <https://github.com/OpenBMB/VoxCPM/issues/105>`_).


CUDA Graphs and multi-threading
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. warning::

   VoxCPM with ``torch.compile`` (default) uses CUDA Graphs, which are **not compatible with multi-threading** (`#97 <https://github.com/OpenBMB/VoxCPM/issues/97>`_, `#107 <https://github.com/OpenBMB/VoxCPM/issues/107>`_, `#125 <https://github.com/OpenBMB/VoxCPM/issues/125>`_). Running inference from a background thread will cause ``AssertionError`` in ``cudagraph_trees``.

**Solutions:**

1. **Disable torch.compile** if you need multi-threading:

   .. code-block:: python

      model = VoxCPM.from_pretrained("openbmb/VoxCPM1.5", optimize=False)

2. **Use NanoVLLM** for concurrent serving — it handles batching and threading correctly:

   See :doc:`./deployment/nanovllm` for setup instructions.

3. **For Gradio apps** (``app.py``), limit concurrency to avoid CUDA Graph conflicts (`#97 <https://github.com/OpenBMB/VoxCPM/issues/97>`_):

   .. code-block:: python

      interface.queue(max_size=10, default_concurrency_limit=1).launch()


vLLM / lmdeploy compatibility
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

VoxCPM is **not compatible** with standard LLM inference frameworks (vLLM, lmdeploy, etc.) because it uses a diffusion-based architecture that generates continuous audio latents rather than discrete tokens (`#6 <https://github.com/OpenBMB/VoxCPM/issues/6>`_, `#91 <https://github.com/OpenBMB/VoxCPM/issues/91>`_).

For high-throughput deployment, use `NanoVLLM-VoxCPM <https://github.com/a710128/nanovllm-voxcpm>`_ instead.


----

Fine-Tuning
*************

Can I fine-tune for a new language?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Yes. Community reports suggest starting with LoRA before full fine-tuning, mixing some Chinese/English data to reduce forgetting, and using conservative learning rates. For the full workflow, see :doc:`./finetuning/finetune`.


Common training issues
^^^^^^^^^^^^^^^^^^^^^^^^

**Model ignores input text after fine-tuning:**
(`#169 <https://github.com/OpenBMB/VoxCPM/issues/169>`_)

This typically means the model has overfit to reproducing training audio without text conditioning.

- Reduce learning rate to ``1e-5`` (full FT) or ``1e-4`` (LoRA).
- Keep ``training_cfg_rate=0.1`` (do NOT set it to 0).
- Keep ``weight_decay=0.01``.
- Test checkpoints every ~2000 steps to catch the issue early.

**Generation doesn't stop (runaway):**
(`#195 <https://github.com/OpenBMB/VoxCPM/issues/195>`_, `#124 <https://github.com/OpenBMB/VoxCPM/issues/124>`_)

- Check your data for clips with long trailing silence (>0.5s) and trim them.
- Enable ``retry_badcase=True`` at inference time.
- If fine-tuning a new language, the stop loss and diffusion loss may converge at different rates — try increasing the stop loss weight.

**Resume training shows wrong step count:**
(`#187 <https://github.com/OpenBMB/VoxCPM/issues/187>`_)

This is a known bug in multi-GPU training. Ensure you're using the latest version of the training scripts.

----

Still have questions?
***********************

If your question isn't covered here:

1. Search the `GitHub Issues <https://github.com/OpenBMB/VoxCPM/issues>`_ — someone may have already asked.
2. Open a `new issue <https://github.com/OpenBMB/VoxCPM/issues/new>`_ with details about your environment, error logs, and steps to reproduce.
3. Join the community WeChat group (see the `README <https://github.com/OpenBMB/VoxCPM#readme>`_ for the QR code).
