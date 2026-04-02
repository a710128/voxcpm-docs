Changelog
=========

This page documents **developer-visible** changes across VoxCPM releases — new
APIs, architecture flags, CLI commands, config fields, training script updates,
and dependency changes. If you are migrating between versions, read from your
current version forward.

----

VoxCPM 2.0 — March 2026
************************

.. important::

   **Breaking changes at a glance** — read before upgrading from 1.x:

   1. ``VoxCPM.from_pretrained()`` now defaults to ``openbmb/VoxCPM2``.
      If you rely on the default, your code will load the 2.3B model instead
      of VoxCPM 1.5. Pin explicitly if needed:
      ``VoxCPM.from_pretrained("openbmb/VoxCPM1.5")``.

   2. **Output sample rate changed**: 44.1 kHz (1.5) → **48 kHz** (2.0).
      Any code that hard-codes ``sf.write(..., 44100)`` must switch to
      ``model.tts_model.sample_rate`` (which returns ``48000`` for V2).

   3. **Gradio** dependency bumped to ``>=6,<7``.
      Gradio 5 apps will not install alongside VoxCPM 2. ``app_old.py``
      (the 1.5 demo) has been adapted to Gradio 6 as well.

   4. **CLI subcommand design**: the old flat ``voxcpm --text ...`` still
      works but prints a deprecation warning. Prefer
      ``voxcpm design|clone|batch``.


30-Language Multilingual
^^^^^^^^^^^^^^^^^^^^^^^^^

VoxCPM 2 extends language support from **2 (Chinese, English)** to **30
languages** across 8 language families, trained on 2.36 million hours of data
(1.8M zh+en base + 560K multilingual). The full language list is documented in
:doc:`../models/voxcpm2`.

At the code level, multilingual synthesis requires **no API changes** — simply
pass text in any supported language. Language detection is handled internally by
the model.


Model & Architecture
^^^^^^^^^^^^^^^^^^^^

- **New model class** ``VoxCPM2Model`` (``model/voxcpm2.py``).
  Existing ``VoxCPMModel`` (``model/voxcpm.py``) is unchanged and continues to
  serve 1.0 / 1.5 checkpoints.

- **Architecture auto-detection** via ``config.json`` → ``"architecture"`` field:

  - ``"voxcpm2"`` → ``VoxCPM2Model``
  - ``"voxcpm"`` (or key absent) → ``VoxCPMModel``

- **Parameter count**: 2.3B (up from 750M in 1.5).

- **Residual LM fusion**: additive → concat-projection.
  New ``fusion_concat_proj`` linear layer (``Linear(2h → h)``).

  .. code-block:: text

     # 1.x
     residual_input = lm_output + masked_audio_embed

     # 2.0
     residual_input = fusion_concat_proj(cat(lm_output, masked_audio_embed))

- **DiT conditioning**: single-token add → multi-token concat.
  ``VoxCPMLocDiTV2`` (``modules/locdit/local_dit_v2.py``) reshapes the concatenated
  LM + residual projections into multiple prefix tokens.

  .. code-block:: text

     # 1.x DiT input
     [ (mu + t) | cond | x ]       ← 1 conditioning token

     # 2.0 DiT input
     [ mu₁ | mu₂ | t | cond | x ]  ← 2 conditioning tokens + timestep

- **Isolated reference audio channel** with special tokens
  ``ref_audio_start_token = 103``, ``ref_audio_end_token = 104``.
  Enables four generation modes: zero-shot, continuation, reference-only,
  combined (ref + continuation).

- **Config defaults changed**:

  .. list-table::
     :widths: 40 20 20
     :header-rows: 1

     * - Field
       - 1.x
       - 2.0
     * - ``patch_size``
       - 2 / 4
       - 4
     * - ``residual_lm_num_layers``
       - 6
       - 8
     * - ``scalar_quantization_latent_dim``
       - 256
       - 512
     * - ``max_length``
       - 4096
       - 8192

- **New config field**: ``residual_lm_no_rope`` (bool, default ``False``).

- **``dit_mean_mode``** moved from root ``VoxCPMConfig`` (1.x) into nested
  ``VoxCPMDitConfig`` (2.0).


AudioVAE V2
^^^^^^^^^^^^

- **New module** ``AudioVAEV2`` (``modules/audiovae/audio_vae_v2.py``).

  .. list-table::
     :widths: 30 35 35
     :header-rows: 1

     * - Attribute
       - AudioVAE (v1)
       - AudioVAEV2
     * - ``decoder_dim``
       - 1536
       - 2048
     * - ``decoder_rates``
       - ``[8, 8, 5, 2]``
       - ``[8, 6, 5, 2, 2, 2]``
     * - Output sample rate
       - ``sample_rate`` (16 kHz / 44.1 kHz)
       - ``out_sample_rate`` (48 kHz native)
     * - Sample-rate conditioning
       - No
       - Yes (``SampleRateConditionLayer``)

- **Asymmetric encode/decode**: encoder at 16 kHz (640× downsample, 6.25 Hz
  token rate) → decoder at 48 kHz (1920× upsample).


Python API (``core.py``)
^^^^^^^^^^^^^^^^^^^^^^^^^

- **Default Hub model** changed from ``openbmb/VoxCPM1.5`` to ``openbmb/VoxCPM2``
  in ``VoxCPM.from_pretrained()``.

- **``generate()`` parameter comparison** (1.x vs 2.0):

  .. list-table::
     :widths: 30 15 15 40
     :header-rows: 1

     * - Parameter
       - 1.x
       - 2.0
       - Notes
     * - ``text``
       - yes
       - yes
       - In 2.0, prepend ``(instruction)`` for Voice Design / Style Control
     * - ``prompt_wav_path``
       - yes
       - yes
       - Continuation mode cloning (same as 1.x)
     * - ``prompt_text``
       - yes
       - yes
       - Must pair with ``prompt_wav_path``
     * - ``reference_wav_path``
       - **no**
       - **new**
       - Isolated voice cloning. Raises ``ValueError`` on 1.x models
     * - ``cfg_value``
       - yes
       - yes
       -
     * - ``inference_timesteps``
       - yes
       - yes
       -
     * - ``normalize``
       - yes
       - yes
       -
     * - ``denoise``
       - yes
       - yes
       - 2.0: also denoises ``reference_wav_path``
     * - ``streaming``
       - yes
       - yes
       -

- **Four generation modes** (V2 only) — determined by which audio arguments
  you pass:

  .. list-table::
     :widths: 25 20 20 35
     :header-rows: 1

     * - Mode
       - ``prompt_wav_path``
       - ``reference_wav_path``
       - Use case
     * - Zero-shot
       - ``None``
       - ``None``
       - Text-only synthesis (or Voice Design with ``(instruction)`` prefix)
     * - Continuation
       - set
       - ``None``
       - Seamless continuation from prompt audio (same as 1.x)
     * - Reference-only
       - ``None``
       - set
       - Isolated voice cloning from a reference clip
     * - Combined
       - set
       - set
       - Reference for timbre + prompt for context (best cloning similarity)

  .. code-block:: python

     # Reference-only cloning (V2 only)
     wav = model.generate(
         text="Hello world.",
         reference_wav_path="speaker.wav",
     )

     # Voice Design (V2 only) — describe a voice in parentheses
     wav = model.generate(
         text="(Warm female voice, mid-30s, calm tone) Welcome to VoxCPM 2.",
     )

     # Style Control (V2 only) — reference for timbre, instruction for style
     wav = model.generate(
         text="(Whispering, mysterious) The secret lies in the ancient library.",
         reference_wav_path="speaker.wav",
     )

- **``sample_rate`` property** on the inner model now returns the **output**
  rate: V1 uses ``audio_vae.sample_rate`` (16 kHz / 44.1 kHz), V2 uses
  ``audio_vae.out_sample_rate`` (**48 kHz**). Always use
  ``model.tts_model.sample_rate`` when saving audio:

  .. code-block:: python

     sf.write("output.wav", wav, model.tts_model.sample_rate)

- **Reference audio VAD trim** (V2 only): ``_trim_audio_silence_vad`` in
  ``VoxCPM2Model`` automatically trims trailing silence from reference audio
  using librosa-based energy detection.

- **``build_prompt_cache``** dispatch:

  - V2: accepts ``prompt_text``, ``prompt_wav_path``, ``reference_wav_path``.
    Returns a dict with ``mode`` (``"reference"`` / ``"continuation"`` /
    ``"ref_continuation"``).
  - V1: accepts ``prompt_text``, ``prompt_wav_path`` only. No ``mode`` key.

- **LoRA interface** on ``VoxCPM``: ``load_lora()``, ``unload_lora()``,
  ``set_lora_enabled()``, ``get_lora_state_dict()``, ``lora_enabled`` property.

- **Denoiser**: supports denoising both ``prompt_wav_path`` and
  ``reference_wav_path`` when ``denoise=True``.


CLI (``cli.py``)
^^^^^^^^^^^^^^^^^

- **Complete rewrite** — VoxCPM2-first subcommand design.

- **New subcommands**:

  - ``voxcpm design`` — text-to-speech with optional ``--control`` instruction.
  - ``voxcpm clone`` — voice cloning via ``--reference-audio`` and/or
    ``--prompt-audio`` + ``--prompt-text``.
  - ``voxcpm batch`` — batch processing from a text file.

- **New flags**:

  .. list-table::
     :widths: 35 65
     :header-rows: 1

     * - Flag
       - Description
     * - ``--control``
       - Voice design / style control instruction (prepended as ``(control)text``)
     * - ``--reference-audio`` / ``-ra``
       - Reference audio for isolated voice cloning (VoxCPM2 only)
     * - ``--prompt-file``
       - Load prompt text from a file
     * - ``--denoise``
       - Enhance prompt/reference audio
     * - ``--no-optimize``
       - Disable ``torch.compile``
     * - ``--no-denoiser``
       - Skip denoiser loading
     * - ``--zipenhancer-path``
       - Custom denoiser model path
     * - ``--lora-path``
       - Inference-time LoRA weights
     * - ``--lora-r`` / ``--lora-alpha`` / ``--lora-dropout``
       - LoRA config overrides at inference
     * - ``--lora-disable-lm``
       - Disable LoRA on LM layers
     * - ``--lora-disable-dit``
       - Disable LoRA on DiT layers
     * - ``--lora-enable-proj``
       - Enable LoRA on projection layers

- **Default HF model**: ``openbmb/VoxCPM2`` (constant ``DEFAULT_HF_MODEL_ID``).

- **Architecture detection** (``detect_model_architecture``): reads local
  ``config.json`` or infers from HF id string. ``--reference-audio`` is
  rejected on 1.x models.

- **Legacy root arguments** (``voxcpm --text ...``) still work but print a
  deprecation warning via ``warn_legacy_mode()``.

- **Control instruction wiring**: ``build_final_text(text, control)`` produces
  ``"(control)text"`` — the convention used by VoxCPM 2 for Voice Design and
  Style Control.


Controllable Generation
^^^^^^^^^^^^^^^^^^^^^^^^

Both features use the same convention: place a natural-language instruction
inside parentheses ``()`` before the target text.

- **Voice Design**: generate speech from a natural-language description without
  reference audio. Use ``(description)`` prefix in text, or ``--control`` in
  CLI.

  .. code-block:: bash

     # CLI
     voxcpm design \
       --text "Welcome to VoxCPM 2." \
       --control "Young female voice, warm and gentle" \
       --output out.wav

  .. code-block:: python

     # Python — the control instruction is part of the text string
     wav = model.generate(
         text="(Young female voice, warm and gentle) Welcome to VoxCPM 2.",
     )

- **Style Control**: control speaking style while using reference audio for
  timbre. The reference determines **who** speaks; the instruction controls
  **how** they speak.

  .. code-block:: bash

     voxcpm clone \
       --text "The secret lies hidden in the ancient library." \
       --control "Speaking slowly with a whispering tone" \
       --reference-audio ref.wav \
       --output out.wav


Training Script
^^^^^^^^^^^^^^^^

- ``scripts/train_voxcpm_finetune.py`` now **auto-detects** ``VoxCPMModel`` vs
  ``VoxCPM2Model`` from the pretrained checkpoint's ``config.json``. No
  separate VoxCPM2 training script needed.

- **New training parameter** ``grad_accum_steps`` — gradient accumulation for
  effective larger batch size without extra VRAM.

- **Validation improvements**: generates sample audio and mel spectrograms to
  TensorBoard at each ``valid_interval``.

- **Signal handler**: catches ``SIGTERM`` / ``SIGINT`` and saves a checkpoint
  before exiting.

- **DDP**: manual epoch management with ``DistributedSampler.set_epoch()`` for
  correct shuffle across epochs.

- **Checkpoint format**:

  - LoRA: ``lora_weights.safetensors`` (or ``.ckpt``), ``lora_config.json``
    with ``base_model`` and ``lora_config`` fields.
  - Full SFT: ``model.safetensors`` (or ``pytorch_model.bin``), plus copied
    ``config.json``, ``audiovae.pth``/``audiovae.safetensors``, and tokenizer
    files.
  - Both: ``optimizer.pth``, ``scheduler.pth``, ``training_state.json``.
  - ``latest/`` folder updated on every save for easy resume.

- **LoRA distribution flag**: ``distribute: true`` + ``hf_model_id`` in YAML
  saves the HF id (instead of a local path) as ``base_model`` in
  ``lora_config.json`` for easier sharing.


LoRA
^^^^^

- **V2 LoRA target modules**: ``target_proj_modules`` now includes
  ``fusion_concat_proj`` (in addition to ``enc_to_lm_proj``,
  ``lm_to_dit_proj``, ``res_to_dit_proj``).

- **``LoRALinear``** stores ``scaling`` as a non-persistent buffer to avoid
  ``torch.compile`` recompilation when toggling LoRA.


``torch.compile`` Optimization
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

- **Both** ``VoxCPMModel`` and ``VoxCPM2Model`` support ``optimize()`` method:

  - Compiles ``base_lm.forward_step``, ``residual_lm.forward_step``,
    ``feat_encoder``, ``feat_decoder.estimator`` with
    ``mode="reduce-overhead"``, ``fullgraph=True``.
  - Requires CUDA + Triton; gracefully skips on other backends.

- ``optimize=True`` by default in ``VoxCPM.__init__`` / ``from_pretrained``.
  Use ``--no-optimize`` in CLI to disable.

- Warm-up call after model load to trigger initial compilation.


Dependencies (``pyproject.toml``)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

- ``gradio>=6,<7`` (was ``gradio<6``).
- ``torch>=2.5.0``, ``torchaudio>=2.5.0`` (minimum bumped).
- Added ``torchcodec``, ``safetensors``, ``argbind``.
- Removed ``mypy`` from dev dependencies.
- Package version now managed by ``setuptools_scm`` (git-tag-based, no
  hard-coded ``__version__``).
- Entry point: ``voxcpm = "voxcpm.cli:main"``.


Demo App (``app.py``)
^^^^^^^^^^^^^^^^^^^^^^

- Full rewrite targeting VoxCPM 2:

  - Default model ``openbmb/VoxCPM2``.
  - Voice Design + Style Control via ``control_instruction`` field.
  - Reference audio + optional continuation (Hi-Fi) path.
  - i18n (English / 中文) support.
  - Gradio 6 patterns (theme/css passed to ``launch()``).

- Original 1.5 demo preserved as ``app_old.py``.


----

VoxCPM 1.5.0 — December 5, 2025
*********************************

Model & Architecture
^^^^^^^^^^^^^^^^^^^^

- **AudioVAE sampling rate**: 16 kHz → **44.1 kHz**. Preserves more
  high-frequency detail for voice cloning.

- **LM token rate**: 12.5 Hz → **6.25 Hz** (halved). Reduces computational
  cost per second of audio.

- **Patch size**: 2 → **4** (LocEnc & LocDiT). Encoder/decoder process longer
  patches, requiring deeper local modules → slightly larger total parameter
  count (**~750M**).

- **RTF**: ~0.15 on RTX 4090 (comparable to 1.0 despite larger model).

- **config.json** ``architecture`` value: ``"voxcpm"`` (same code path as
  1.0).

- Same model class ``VoxCPMModel`` as 1.0.
  All 1.0 → 1.5 differences are in checkpoint weights and config values,
  **not** in a separate Python class.


Fine-tuning
^^^^^^^^^^^^

- **SFT** (full fine-tuning) and **LoRA** fine-tuning officially supported.

- **Training script** ``scripts/train_voxcpm_finetune.py`` added.

- **Training configs** ``conf/voxcpm_v1.5/``:

  - ``voxcpm_finetune_all.yaml`` — full SFT, ``sample_rate: 44100``,
    ``learning_rate: 1e-5``.
  - ``voxcpm_finetune_lora.yaml`` — LoRA, ``sample_rate: 44100``,
    ``learning_rate: 1e-4``, ``r: 8``, ``alpha: 16``.

- **LoRA WebUI** ``lora_ft_webui.py`` added for browser-based LoRA
  training / inference.

- **Inference test scripts**:

  - ``scripts/test_voxcpm_ft_infer.py`` — full fine-tune checkpoint inference.
  - ``scripts/test_voxcpm_lora_infer.py`` — LoRA checkpoint inference with
    hot-swap demo (``load_lora`` / ``unload_lora`` / ``set_lora_enabled``).


Python API
^^^^^^^^^^^

- ``VoxCPM.from_pretrained()`` default: ``openbmb/VoxCPM1.5``.

- **Streaming** ``generate_streaming()`` API added (returns a generator of
  audio chunks).


Stability Improvements
^^^^^^^^^^^^^^^^^^^^^^^

- Reduced beginning/ending audio artifacts through improved inference logic and
  training data cleaning.

- Lower token rate (6.25 Hz) improves stability on longer speech.


----

VoxCPM 1.0.0 — September 16, 2025
************************************

Initial public release of VoxCPM.

Model
^^^^^^

- **Parameter size**: 600M (VoxCPM-0.5B).
- **Sampling rate**: 16 kHz (AudioVAE v1).
- **LM token rate**: 12.5 Hz, patch size 2.
- **Languages**: Chinese and English.

Python API
^^^^^^^^^^^

- ``VoxCPM`` class with ``from_pretrained()`` / ``generate()`` interface.
- HF model id: ``openbmb/VoxCPM-0.5B``.
- Voice cloning via ``prompt_wav_path`` + ``prompt_text`` (continuation mode
  only).

Training Configs
^^^^^^^^^^^^^^^^^

- ``conf/voxcpm_v1/voxcpm_finetune_all.yaml`` — ``sample_rate: 16000``.
- ``conf/voxcpm_v1/voxcpm_finetune_lora.yaml`` — ``sample_rate: 16000``.

PyPI
^^^^^

- Package ``voxcpm`` published with tags ``1.0.0rc1`` through ``1.0.5``.


----

Version Tags
*************

Versions are managed by ``setuptools_scm`` from git tags. There is no
hard-coded ``__version__`` in the source.

.. list-table::
   :widths: 20 20 60
   :header-rows: 1

   * - Tag
     - Date
     - Notes
   * - ``1.0.0rc1`` – ``1.0.0rc3``
     - 2025-09-16
     - Release candidates
   * - ``1.0.0``
     - 2025-09-16
     - Initial release
   * - ``1.0.1``
     - 2025-09-16
     - Patch
   * - ``1.0.2``
     - 2025-09-17
     - Patch
   * - ``1.0.3``
     - 2025-09-18
     - Patch
   * - ``1.0.4``
     - 2025-09-22
     - Patch
   * - ``1.0.5``
     - 2025-09-30
     - Patch (technical report release)
   * - ``1.5.0``
     - 2025-12-05
     - VoxCPM 1.5
