API Reference
=============

Python API
**********

.. py:class:: VoxCPM(voxcpm_model_path, zipenhancer_model_path="iic/speech_zipenhancer_ans_multiloss_16k_base", enable_denoiser=True, optimize=True, lora_config=None, lora_weights_path=None)

   Initialize VoxCPM from a local model directory.

   The model architecture (``voxcpm`` or ``voxcpm2``) is auto-detected from the ``architecture`` field in ``config.json``.

   :param str voxcpm_model_path: Local path to the model directory containing weights, configs, and tokenizer files.
   :param str|None zipenhancer_model_path: ModelScope denoiser model id or local path. Set to ``None`` to skip the denoiser entirely.
   :param bool enable_denoiser: Whether to initialize the ZipEnhancer denoiser pipeline.
   :param bool optimize: Enable ``torch.compile`` acceleration. Disable for debugging or unsupported platforms.
   :param LoRAConfig|None lora_config: LoRA configuration. If ``lora_weights_path`` is provided without this, a default config (``enable_lm=True``, ``enable_dit=True``) is created automatically.
   :param str|None lora_weights_path: Path to pre-trained LoRA weights (``.pth`` file or directory containing ``lora_weights.ckpt``).

   .. code-block:: python

      model = VoxCPM(
          voxcpm_model_path="/path/to/VoxCPM2",
          enable_denoiser=False,
      )


.. py:classmethod:: VoxCPM.from_pretrained(hf_model_id="openbmb/VoxCPM2", load_denoiser=True, zipenhancer_model_id="iic/speech_zipenhancer_ans_multiloss_16k_base", cache_dir=None, local_files_only=False, optimize=True, lora_config=None, lora_weights_path=None, **kwargs)

   Instantiate ``VoxCPM`` from a Hugging Face Hub snapshot. Downloads model weights automatically on first use.

   :param str hf_model_id: Hugging Face repo id (e.g. ``"openbmb/VoxCPM2"``) or local directory path.
   :param bool load_denoiser: Whether to initialize the denoiser pipeline.
   :param str zipenhancer_model_id: Denoiser model id or local path. Ignored when ``load_denoiser=False``.
   :param str|None cache_dir: Custom cache directory for the snapshot download.
   :param bool local_files_only: If ``True``, only use local files and do not attempt to download.
   :param bool optimize: Enable ``torch.compile`` acceleration.
   :param LoRAConfig|None lora_config: LoRA configuration for fine-tuned models.
   :param str|None lora_weights_path: Path to LoRA weights. If provided, LoRA is loaded after initialization.
   :returns: Initialized VoxCPM instance.
   :rtype: VoxCPM
   :raises ValueError: If ``hf_model_id`` is empty.

   .. code-block:: python

      model = VoxCPM.from_pretrained("openbmb/VoxCPM2", load_denoiser=False)


.. py:method:: VoxCPM.generate(text, prompt_wav_path=None, prompt_text=None, reference_wav_path=None, cfg_value=2.0, inference_timesteps=10, min_len=2, max_len=4096, normalize=False, denoise=False, retry_badcase=True, retry_badcase_max_times=3, retry_badcase_ratio_threshold=6.0)

   Synthesize speech from text.

   :param str text: Input text to synthesize. For Voice Design, prepend control instructions in parentheses: ``"(warm female voice)Hello"``.
   :param str|None prompt_wav_path: Prompt audio path for continuation-style cloning. Must be paired with ``prompt_text``. For Hi-Fi cloning, combine it with ``reference_wav_path``.
   :param str|None prompt_text: Exact transcript of the prompt audio. Must be provided together with ``prompt_wav_path``.
   :param str|None reference_wav_path: Reference audio path for isolated voice cloning (**VoxCPM 2 only**). Can be used alone or combined with ``prompt_wav_path`` + ``prompt_text``.
   :param float cfg_value: Guidance scale. Higher values follow the conditioning more strictly; lower values allow more variation. Recommended: 1.0–3.0.
   :param int inference_timesteps: Number of diffusion steps. More steps improve detail at the cost of speed. Recommended: 4–30.
   :param int min_len: Minimum audio length in model tokens.
   :param int max_len: Maximum token length during generation. Increase for very long outputs.
   :param bool normalize: Run text normalization (expand numbers, dates, etc.) before generation.
   :param bool denoise: Denoise prompt/reference audio before generation. Requires the denoiser to be loaded.
   :param bool retry_badcase: Automatically retry when the generated audio length is abnormally short or long.
   :param int retry_badcase_max_times: Maximum number of bad-case retries.
   :param float retry_badcase_ratio_threshold: Audio-to-text duration ratio threshold for bad-case detection.
   :returns: 1-D waveform array (float32). Sample rate is available at ``model.tts_model.sample_rate``.
   :rtype: numpy.ndarray
   :raises ValueError: If ``text`` is empty.
   :raises ValueError: If ``prompt_wav_path`` and ``prompt_text`` are not both provided or both ``None``.
   :raises ValueError: If ``reference_wav_path`` is used with a VoxCPM 1.x model.
   :raises FileNotFoundError: If audio file paths do not exist.

   .. code-block:: python

      # Voice Design
      wav = model.generate(
          text="(warm female voice)Hello from VoxCPM!",
          cfg_value=2.0,
      )

      # Reference-only cloning (VoxCPM 2)
      wav = model.generate(
          text="Hello from VoxCPM!",
          reference_wav_path="speaker.wav",
      )

      # Hi-Fi cloning
      wav = model.generate(
          text="Hello from VoxCPM!",
          prompt_wav_path="speaker.wav",
          prompt_text="Exact transcript of speaker.wav.",
          reference_wav_path="speaker.wav",
      )


.. py:method:: VoxCPM.generate_streaming(text, prompt_wav_path=None, prompt_text=None, reference_wav_path=None, cfg_value=2.0, inference_timesteps=10, min_len=2, max_len=4096, normalize=False, denoise=False, retry_badcase=True, retry_badcase_max_times=3, retry_badcase_ratio_threshold=6.0)

   Same interface as :py:meth:`generate`, but returns a generator that yields audio chunks incrementally.

   All parameters are identical to :py:meth:`generate`.

   :returns: Generator yielding 1-D waveform chunks (float32).
   :rtype: Generator[numpy.ndarray, None, None]

   .. code-block:: python

      import numpy as np

      chunks = []
      for chunk in model.generate_streaming(text="Streaming output."):
          chunks.append(chunk)
      wav = np.concatenate(chunks)


.. py:method:: VoxCPM.load_lora(lora_weights_path)

   Load LoRA weights from a checkpoint file or directory.

   :param str lora_weights_path: Path to LoRA weights (``.pth`` file or directory containing ``lora_weights.ckpt``).
   :returns: ``(loaded_keys, skipped_keys)`` — lists of loaded and skipped parameter names.
   :rtype: tuple[list[str], list[str]]
   :raises RuntimeError: If model was not initialized with a LoRA config.


.. py:method:: VoxCPM.unload_lora()

   Reset all LoRA weights to their initial state (effectively zeroing them out). The LoRA layers remain in the model but have no effect.


.. py:method:: VoxCPM.set_lora_enabled(enabled)

   Enable or disable LoRA layers without unloading weights.

   :param bool enabled: ``True`` to activate LoRA; ``False`` to use the base model only.


.. py:method:: VoxCPM.get_lora_state_dict()

   Get the current LoRA parameters.

   :returns: State dict containing all ``lora_A`` and ``lora_B`` parameters.
   :rtype: dict


.. py:attribute:: VoxCPM.lora_enabled
   :type: bool

   ``True`` if a LoRA config is currently loaded on this model.


----

CLI
***

The ``voxcpm`` command provides three subcommands. Default model: ``openbmb/VoxCPM2``.

Subcommands
-----------

.. program:: voxcpm design

.. py:function:: voxcpm design

   Generate speech from text without any reference audio. Optionally describe the target voice with ``--control``.

   .. code-block:: sh

      voxcpm design --text "Hello world" --output out.wav
      voxcpm design --text "Hello world" --control "warm female voice" --output out.wav

.. program:: voxcpm clone

.. py:function:: voxcpm clone

   Clone a voice using reference audio or prompt audio with transcript.

   .. code-block:: sh

      # Reference-only cloning (VoxCPM 2)
      voxcpm clone --text "Hello" --reference-audio ref.wav --output out.wav

      # Hi-Fi cloning
      voxcpm clone --text "Hello" \
          --prompt-audio ref.wav --prompt-text "Transcript of ref.wav" \
          --reference-audio ref.wav --output out.wav

      # With style control
      voxcpm clone --text "Hello" --reference-audio ref.wav \
          --control "speaking slowly" --output out.wav

.. program:: voxcpm batch

.. py:function:: voxcpm batch

   Process a text file where each line becomes a separate output WAV (``output_001.wav``, ``output_002.wav``, ...).

   .. code-block:: sh

      voxcpm batch --input texts.txt --output-dir ./outs
      voxcpm batch --input texts.txt --output-dir ./outs --reference-audio ref.wav

Arguments
---------

**Generation**

.. option:: --text, -t <TEXT>

   Text to synthesize.

.. option:: --control <INSTRUCTION>

   Control instruction for voice design or style control (e.g. ``"warm female voice"``). Cannot be used together with ``--prompt-text``.

.. option:: --cfg-value <FLOAT>

   CFG guidance scale. Default: ``2.0``. Recommended: 1.0–3.0.

.. option:: --inference-timesteps <INT>

   Number of diffusion steps. Default: ``10``. Recommended: 4–30.

.. option:: --normalize

   Enable text normalization (expand numbers, dates, etc.).

**Prompt & Reference Audio**

.. option:: --prompt-audio, -pa <PATH>

   Prompt audio file for continuation mode. Requires ``--prompt-text`` or ``--prompt-file``.

.. option:: --prompt-text, -pt <TEXT>

   Text transcript of the prompt audio.

.. option:: --prompt-file <PATH>

   Text file containing the prompt transcript (alternative to ``--prompt-text``).

.. option:: --reference-audio, -ra <PATH>

   Reference audio for isolated voice cloning (VoxCPM 2 only).

.. option:: --denoise

   Denoise prompt/reference audio with ZipEnhancer before generation.

**Model Loading**

.. option:: --model-path <PATH>

   Local model directory. If set, ``--hf-model-id`` is ignored.

.. option:: --hf-model-id <ID>

   Hugging Face repo id. Default: ``openbmb/VoxCPM2``.

.. option:: --cache-dir <PATH>

   Cache directory for Hub downloads.

.. option:: --local-files-only

   Only use local files, do not download from Hub.

.. option:: --no-denoiser

   Skip loading the denoiser model.

.. option:: --no-optimize

   Disable ``torch.compile`` acceleration.

.. option:: --zipenhancer-path <PATH>

   Custom ZipEnhancer model id or local path.

**LoRA**

.. option:: --lora-path <PATH>

   Path to LoRA weights directory.

.. option:: --lora-r <INT>

   LoRA rank. Default: ``32``.

.. option:: --lora-alpha <INT>

   LoRA alpha (scaling = alpha / r). Default: ``16``.

.. option:: --lora-dropout <FLOAT>

   LoRA dropout rate (0.0–1.0). Default: ``0.0``.

.. option:: --lora-disable-lm

   Disable LoRA on LM layers.

.. option:: --lora-disable-dit

   Disable LoRA on DiT layers.

.. option:: --lora-enable-proj

   Enable LoRA on projection layers.

.. note::

   The legacy flat CLI (``voxcpm --text "..." --output out.wav``) still works but is deprecated. Prefer the subcommand style.
