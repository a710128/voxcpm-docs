❓ FAQ & Troubleshooting
=========================

This page covers the most frequently asked questions from the VoxCPM community, based on real issues reported by users.

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

Voice Cloning
****************

prompt_text must match the reference audio
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. important::

   When using voice cloning, the ``prompt_text`` parameter **must accurately match the spoken content** of the reference audio (`#77 <https://github.com/OpenBMB/VoxCPM/issues/77>`_, `#111 <https://github.com/OpenBMB/VoxCPM/issues/111>`_). Mismatched text is the most common cause of audio artifacts (extra sounds at the beginning, garbled output, or the reference audio being prepended to the generated speech).

.. tip::

   VoxCPM 2 introduces an **isolated reference channel** that separates the reference audio from the generation context. In this mode, you only need to provide the reference audio without a matching transcript. See :doc:`./models/voxcpm2` for details.

**Best practice:** Use automatic speech recognition (ASR) to transcribe the reference audio rather than writing the text manually. The ``app.py`` web demo does this automatically via SenseVoice.

.. code-block:: python

   wav = model.generate(
       text="Target text to synthesize.",
       prompt_wav_path="reference.wav",
       prompt_text="Exact transcription of reference.wav",  # Must match!
   )


Reference audio requirements
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

- **Duration:** 5–30 seconds is recommended (`#40 <https://github.com/OpenBMB/VoxCPM/issues/40>`_). Very short clips (<3s) may produce poor timbre; very long clips may slow inference without benefit.
- **Format:** Any format supported by torchaudio (WAV, FLAC, MP3, etc., `#65 <https://github.com/OpenBMB/VoxCPM/issues/65>`_).
- **Quality:** Clean audio with minimal background noise. Enable ``denoise=True`` to enhance the prompt audio automatically.
- **Language:** VoxCPM 1.x supports Chinese and English prompts, with cross-lingual cloning (e.g., Chinese prompt → English output, `#65 <https://github.com/OpenBMB/VoxCPM/issues/65>`_). VoxCPM 2 supports 30 languages.


No reference audio = random voice
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you don't provide a reference audio, VoxCPM generates speech with a **random voice** each time (`#79 <https://github.com/OpenBMB/VoxCPM/issues/79>`_, `#113 <https://github.com/OpenBMB/VoxCPM/issues/113>`_). The model infers a fitting speaking style from the text content, but the timbre will not be consistent across calls.

To get a **consistent voice**, you have several options:

1. **Use voice cloning** — always pass the same reference audio for every generation call.

   - **VoxCPM 1.x:** Provide both ``prompt_wav_path`` and a matching ``prompt_text``.
   - **VoxCPM 2 (isolated mode):** Only ``reference_wav_path`` is needed — no transcript required. See :doc:`./models/voxcpm2` for details.

2. **LoRA fine-tuning** — for production use, fine-tune the model on a specific voice to guarantee consistency. See the :doc:`./finetuning/finetune` guide.


----

Audio Quality
***************

CFG value tuning
^^^^^^^^^^^^^^^^^^

The ``cfg_value`` parameter controls how closely the model follows the text conditioning:

.. list-table::
   :widths: 20 80
   :header-rows: 1

   * - Value
     - Effect
   * - **1.0–1.5**
     - More relaxed, natural-sounding. May drift from text slightly.
   * - **2.0** (default)
     - Balanced quality. Good starting point.
   * - **3.0+**
     - Stricter adherence to text, but may introduce noise or artifacts, especially on long text.

**Tip:** If you experience noise or buzzing in long-form generation, try lowering ``cfg_value`` to **1.5–1.6**, which users have reported as more stable (`#96 <https://github.com/OpenBMB/VoxCPM/issues/96>`_, `#61 <https://github.com/OpenBMB/VoxCPM/issues/61>`_).


Long text handling
^^^^^^^^^^^^^^^^^^^^

VoxCPM generates speech autoregressively, and very long inputs can cause (`#96 <https://github.com/OpenBMB/VoxCPM/issues/96>`_, `#52 <https://github.com/OpenBMB/VoxCPM/issues/52>`_, `#34 <https://github.com/OpenBMB/VoxCPM/issues/34>`_):

- Gradual speed-up and buzzing sounds
- Out-of-memory errors (KV cache exhaustion)
- Generation that never stops

**Recommended approach:** Split long text into segments of **50–200 characters** (roughly one paragraph or a few sentences), generate each segment separately, and concatenate the audio.

.. code-block:: python

   import numpy as np

   segments = ["First paragraph...", "Second paragraph...", "Third paragraph..."]
   all_wavs = []
   for seg in segments:
       wav = model.generate(text=seg, prompt_wav_path="voice.wav", prompt_text="...")
       all_wavs.append(wav)
   full_wav = np.concatenate(all_wavs)


Leading / trailing audio artifacts
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Extra sounds at the beginning:**
(`#77 <https://github.com/OpenBMB/VoxCPM/issues/77>`_, `#111 <https://github.com/OpenBMB/VoxCPM/issues/111>`_)

- Usually caused by mismatched ``prompt_text``. Ensure it exactly matches the reference audio content (see above).
- Adding a brief silence padding (~0.1s) before the text can sometimes help.

**Noise or silence at the end:**
(`#94 <https://github.com/OpenBMB/VoxCPM/issues/94>`_, `#127 <https://github.com/OpenBMB/VoxCPM/issues/127>`_, `#132 <https://github.com/OpenBMB/VoxCPM/issues/132>`_)

- Enable ``retry_badcase=True`` to automatically retry when the model generates abnormally long output.
- Post-process with silence trimming (`#132 <https://github.com/OpenBMB/VoxCPM/issues/132>`_):

  .. code-block:: python

     import librosa
     wav_trimmed, _ = librosa.effects.trim(wav)

- Lowering ``cfg_value`` can reduce tail noise.


denoise parameter
^^^^^^^^^^^^^^^^^^^

The ``denoise`` parameter controls whether **prompt audio** (not the output) is enhanced using ZipEnhancer:

- ``denoise=True``: Enhances the reference audio quality before voice cloning. Recommended when the reference has background noise.
- ``denoise=False``: Uses the reference audio as-is. Use this when your reference audio is already clean.

.. warning::

   The denoiser operates at 16kHz internally and may slightly alter the voice characteristics. If the generated voice sounds unnatural, try setting ``denoise=False`` (`#51 <https://github.com/OpenBMB/VoxCPM/issues/51>`_).


Short text issues
^^^^^^^^^^^^^^^^^^^

Very short inputs (e.g., "Hello", "好的") may produce poor results because the model was trained with a minimum audio length of ~1 second (`#92 <https://github.com/OpenBMB/VoxCPM/issues/92>`_, `#40 <https://github.com/OpenBMB/VoxCPM/issues/40>`_). For best results, inputs should produce at least 3 seconds of audio.


----

Text & Pronunciation
***********************

Text normalization (numbers, dates, amounts)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Problem:** Numbers like "5640" are read digit-by-digit ("五六四零") instead of as a number ("五千六百四十") (`#30 <https://github.com/OpenBMB/VoxCPM/issues/30>`_, `#51 <https://github.com/OpenBMB/VoxCPM/issues/51>`_, `#164 <https://github.com/OpenBMB/VoxCPM/issues/164>`_).

**Solution:** Enable text normalization:

.. code-block:: python

   wav = model.generate(
       text="总建筑面积为5640平方米",
       normalize=True,  # Enables WeTextProcessing for number/date conversion
   )

When ``normalize=True``, VoxCPM uses the WeTextProcessing library to convert numbers, dates, and special formats into spoken-form text.

.. note::

   Text normalization may not handle all edge cases perfectly (e.g., model names like "麒麟9400" should be read digit-by-digit). For critical applications, consider pre-processing the text manually.


Phoneme input for pronunciation control
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For fine-grained pronunciation control, use phoneme input with text normalization **disabled** (`#45 <https://github.com/OpenBMB/VoxCPM/issues/45>`_, `#57 <https://github.com/OpenBMB/VoxCPM/issues/57>`_):

.. code-block:: python

   wav = model.generate(
       text="{ni3}{hao3}{shi4}{jie4}",   # Chinese pinyin
       normalize=False,  # Must be disabled for phoneme input
   )

- **Chinese:** Use pinyin with tone numbers, e.g., ``{ni3}{hao3}``
- **English:** Use CMUDict-style phonemes, e.g., ``{HH AH0 L OW1}``

See the :doc:`./chefsguide` for more details on phoneme input.


Punctuation and pauses
^^^^^^^^^^^^^^^^^^^^^^^^

VoxCPM uses punctuation as cues for prosody and pauses (`#29 <https://github.com/OpenBMB/VoxCPM/issues/29>`_):

- **Periods (。/.)** and **question marks (？/?)**: Generate clear sentence-ending pauses.
- **Commas (，/,)**: Generate shorter pauses, though the effect may be subtle.
- **Ellipsis (……/...)**: Can produce hesitation or trailing effects.

For more pronounced pauses, consider splitting the text into separate sentences at the desired break points.

.. tip::

   VoxCPM 2 has improved prosody and pause control, making punctuation-driven pauses more natural and responsive compared to VoxCPM 1.x.


----

Performance & Deployment
**************************

VRAM usage reference  (还需要进一步测试)
^^^^^^^^^^^^^^^^^^^^^

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

Dataset requirements
^^^^^^^^^^^^^^^^^^^^^^

.. list-table::
   :widths: 25 75
   :header-rows: 1

   * - Requirement
     - Details
   * - **Audio format**
     - WAV or FLAC. Any sample rate (automatically resampled to model's target rate during training, `#181 <https://github.com/OpenBMB/VoxCPM/issues/181>`_).
   * - **Transcription**
     - Accurate text transcription for each audio file.
   * - **Duration per clip**
     - 3–30 seconds recommended. Clips shorter than 1 second are typically filtered out.
   * - **Total data**
     - LoRA: as few as 50–100 clips for a single voice. Full SFT for a new language: 100+ hours recommended.
   * - **Quality**
     - Clean audio with minimal background noise produces best results.


New language fine-tuning
^^^^^^^^^^^^^^^^^^^^^^^^^

VoxCPM 1.x is pre-trained on Chinese and English. To add a new language:

1. **Start with LoRA** (lower risk, less data needed) before attempting full-parameter fine-tuning (`#47 <https://github.com/OpenBMB/VoxCPM/issues/47>`_, `#114 <https://github.com/OpenBMB/VoxCPM/issues/114>`_).
2. **Mix in Chinese/English data** (~10–20%) to prevent catastrophic forgetting of the base language capabilities (`#178 <https://github.com/OpenBMB/VoxCPM/issues/178>`_).
3. **Use a low learning rate**: ``1e-5`` for full fine-tuning, ``1e-4`` for LoRA (`#169 <https://github.com/OpenBMB/VoxCPM/issues/169>`_).
4. **Monitor for "runaway generation"** — if the model stops conditioning on input text, your learning rate may be too high (`#169 <https://github.com/OpenBMB/VoxCPM/issues/169>`_, `#195 <https://github.com/OpenBMB/VoxCPM/issues/195>`_). See the training tips below.

Refer to the :doc:`./finetuning/finetune` guide for step-by-step instructions.


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

Multilingual Support
**********************

Supported languages
^^^^^^^^^^^^^^^^^^^^^

.. list-table::
   :widths: 30 70
   :header-rows: 1

   * - Model
     - Languages
   * - VoxCPM 1.0 / 1.5
     - Chinese, English
   * - VoxCPM 2
     - 30 languages including Chinese, English, Japanese, Korean, French, German, Spanish, Arabic, Hindi, and more

For VoxCPM 1.x, cross-lingual voice cloning is supported (e.g., Chinese reference → English output, `#65 <https://github.com/OpenBMB/VoxCPM/issues/65>`_, `#66 <https://github.com/OpenBMB/VoxCPM/issues/66>`_).


Adding a new language (VoxCPM 1.x)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If your target language is not supported, you can fine-tune VoxCPM on your own data:

1. Prepare a dataset of audio + transcription pairs in the target language.
2. Follow the fine-tuning guide with either LoRA or full SFT.
3. Mix ~10–20% Chinese/English data to preserve base capabilities.
4. Community members have successfully fine-tuned for Japanese, Korean, Thai, Latvian, and Arabic — see `issue #114 <https://github.com/OpenBMB/VoxCPM/issues/114>`_ for tips.


----

Streaming
***********

How to use streaming output
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

VoxCPM supports streaming audio generation (`#8 <https://github.com/OpenBMB/VoxCPM/issues/8>`_, `#21 <https://github.com/OpenBMB/VoxCPM/issues/21>`_, `#64 <https://github.com/OpenBMB/VoxCPM/issues/64>`_), allowing you to play audio chunks in real-time as they are produced:

.. code-block:: python

   for chunk in model.generate_streaming(
       text="Streaming text to speech is easy with VoxCPM!",
       prompt_wav_path="voice.wav",
       prompt_text="Reference transcript",
   ):
       # chunk is a numpy array — play it immediately or buffer it
       play_audio(chunk)

Each chunk is a segment of the audio waveform. The streaming API accepts all the same parameters as the non-streaming ``generate()`` method.


Sentence-level streaming
^^^^^^^^^^^^^^^^^^^^^^^^^^

VoxCPM does not support word-level streaming input (generating audio as text is being typed, `#39 <https://github.com/OpenBMB/VoxCPM/issues/39>`_, `#179 <https://github.com/OpenBMB/VoxCPM/issues/179>`_). However, you can implement sentence-level streaming by:

1. Splitting incoming text into sentences as they arrive.
2. Calling ``generate_streaming()`` for each sentence.
3. Playing audio chunks from each sentence sequentially.

Bidirectional streaming (streaming text input + streaming audio output) is not supported (`#179 <https://github.com/OpenBMB/VoxCPM/issues/179>`_).

----

Still have questions?
***********************

If your question isn't covered here:

1. Search the `GitHub Issues <https://github.com/OpenBMB/VoxCPM/issues>`_ — someone may have already asked.
2. Open a `new issue <https://github.com/OpenBMB/VoxCPM/issues/new>`_ with details about your environment, error logs, and steps to reproduce.
3. Join the community WeChat group (see the `README <https://github.com/OpenBMB/VoxCPM#readme>`_ for the QR code).
