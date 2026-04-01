Usage Guide
===========

This page explains VoxCPM 2's generation parameters and three generation modes, then covers text input, reference audio, quality tuning, and streaming in more detail.

Generation Parameters
*********************

The ``generate()`` method accepts the following key parameters:

.. list-table::
   :widths: 25 15 60
   :header-rows: 1

   * - Parameter
     - Default
     - Description
   * - ``text``
     - (required)
     - The text to synthesize. Supports Chinese, English, and 30+ languages in VoxCPM 2.
   * - ``reference_wav_path``
     - ``None``
     - Reference audio for voice cloning (VoxCPM 2 only). The model extracts the timbre without needing a transcript.
   * - ``prompt_wav_path``
     - ``None``
     - Prompt audio for continuation-style cloning. Must be paired with ``prompt_text``.
   * - ``prompt_text``
     - ``None``
     - Exact transcript of ``prompt_wav_path``. Must be provided together with it.
   * - ``cfg_value``
     - ``2.0``
     - Guidance scale. Higher values follow the conditioning more strictly; lower values allow more variation. Typical range: 1.0–3.0.
   * - ``inference_timesteps``
     - ``10``
     - Number of diffusion steps. More steps improve detail and naturalness at the cost of speed.
   * - ``normalize``
     - ``False``
     - Run text normalization to expand numbers, dates, etc. Useful for raw text input.
   * - ``denoise``
     - ``False``
     - Denoise prompt/reference audio before generation. Helps when the reference audio is noisy.
   * - ``retry_badcase``
     - ``True``
     - Automatically retry when the generated audio is abnormally short or long relative to the text.

Three Generation Modes
**********************

VoxCPM 2 supports three modes depending on how much control you want over the output voice.

Voice Design
^^^^^^^^^^^^

No reference audio needed. Describe the voice you want in a control instruction prepended to the text, and VoxCPM generates a new voice from scratch.

.. code-block:: python

   from voxcpm import VoxCPM
   import soundfile as sf

   model = VoxCPM.from_pretrained("openbmb/VoxCPM2", load_denoiser=False)

   wav = model.generate(
       text="(A young woman, gentle and sweet voice)Hello, welcome to VoxCPM!",
       cfg_value=2.0,
       inference_timesteps=10,
   )
   sf.write("voice_design.wav", wav, model.tts_model.sample_rate)

The control instruction is written in parentheses before the target text — for example ``(年轻女性，温柔甜美)`` or ``(an excited young man)``. Chinese and English are both supported in the instruction.

Controllable Voice Cloning
^^^^^^^^^^^^^^^^^^^^^^^^^^

Upload a reference audio. The model clones the timbre, and you can still use control instructions to adjust speed, emotion, or style.

.. code-block:: python

   wav = model.generate(
       text="(slightly faster, cheerful tone)This is a cloned voice with style control.",
       reference_wav_path="speaker.wav",
       cfg_value=2.0,
       inference_timesteps=10,
   )
   sf.write("controllable_clone.wav", wav, model.tts_model.sample_rate)

In this mode, ``reference_wav_path`` provides the timbre, and the parenthesized instruction controls the style. No transcript of the reference audio is needed.

Hi-Fi Cloning
^^^^^^^^^^^^^

For maximum voice similarity, provide both the reference audio and its exact transcript. The model uses the transcript to align the prompt audio precisely, producing the highest cloning fidelity.

.. code-block:: python

   wav = model.generate(
       text="This is a high-fidelity cloned voice.",
       prompt_wav_path="speaker.wav",
       prompt_text="The exact transcript of speaker.wav goes here.",
       reference_wav_path="speaker.wav",
       cfg_value=2.0,
       inference_timesteps=10,
   )
   sf.write("hifi_clone.wav", wav, model.tts_model.sample_rate)

.. tip::

   Use ASR to get the transcript rather than typing it manually. The web demo does this automatically through SenseVoice. When Hi-Fi mode is enabled, the control instruction is ignored.

Text Input
**********

Regular text vs. phoneme input
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Use **regular text** for most cases. Keep ``normalize=True`` when you want VoxCPM to expand numbers, dates, and similar formats automatically.

Use **phoneme input** only when you need finer pronunciation control. In that case, disable text normalization:

.. code-block:: python

   wav = model.generate(
       text="{ni3}{hao3}{shi4}{jie4}",
       normalize=False,
   )

- **Chinese:** use pinyin with tone numbers such as ``{ni3}{hao3}``
- **English:** use CMUDict-style phonemes such as ``{HH AH0 L OW1}``

Text normalization
^^^^^^^^^^^^^^^^^^

If numbers are being read digit by digit, enable text normalization:

.. code-block:: python

   wav = model.generate(
       text="总建筑面积为5640平方米",
       normalize=True,
   )

.. note::

   Text normalization may not handle every edge case perfectly. For example, some model names or product names may need manual pre-processing.

Punctuation and pauses
^^^^^^^^^^^^^^^^^^^^^^

VoxCPM uses punctuation as a prosody cue:

- Periods and question marks usually create clearer sentence-final pauses
- Commas usually create shorter pauses
- Ellipsis can produce hesitation or trailing effects

If you need a stronger pause, split the text into shorter sentences instead of relying only on punctuation.

Short text
^^^^^^^^^^

Very short inputs such as ``"Hello"`` or ``"好的"`` may sound weak because the model was trained with a minimum audio length of around one second. In practice, inputs that naturally produce at least a few seconds of speech are more stable.

Dialect tips
^^^^^^^^^^^^

To generate speech in a specific dialect, write the target text in that dialect's own vocabulary and expressions, not in standard Mandarin:

- Cantonese: ``(广东话，中年男性)伙計，唔該一個A餐，凍奶茶少甜！`` ✅
- Cantonese: ``(广东话，中年男性)伙计，麻烦来一个A餐，冻奶茶少甜！`` ❌ (standard Mandarin)

If you are not sure how to write idiomatic dialect text, you can use LLMs like DeepSeek or Doubao to translate from Mandarin first.

Reference Audio
***************

Audio quality
^^^^^^^^^^^^^

- **Duration:** 5 to 30 seconds is a practical range
- **Format:** any format supported by torchaudio, including WAV, FLAC, and MP3
- **Quality:** cleaner audio usually gives better timbre preservation
- **Language:** VoxCPM 2 supports 30+ languages

No reference audio
^^^^^^^^^^^^^^^^^^

If you do not provide a reference audio, VoxCPM generates a random voice each time. The model can still infer an appropriate speaking style from the text, but the timbre will not stay consistent across calls.

Keeping a consistent voice
^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Reuse the same reference audio every time.
2. Use ``reference_wav_path`` in Voice Cloning mode for a stable timbre.
3. For production-grade consistency, consider LoRA fine-tuning. See :doc:`./finetuning/finetune`.

.. note::

   VoxCPM 1.x requires ``prompt_wav_path`` + ``prompt_text`` for cloning and does not support ``reference_wav_path``. See :doc:`./models/voxcpm1.5` for 1.x-specific usage.

Quality Tuning
**************

CFG value
^^^^^^^^^

.. list-table::
   :widths: 20 80
   :header-rows: 1

   * - Value
     - Effect
   * - **1.0–2.0**
     - More relaxed and natural, but may drift slightly from the target text
   * - **2.0**
     - Balanced default
   * - **2.0-3.0**
     - Stronger adherence to the text, but more risk of noise or artifacts on difficult inputs

If long-form output becomes noisy or buzzy, lowering ``cfg_value`` toward ``1.5–1.6`` is often more stable.

Long text
^^^^^^^^^

Long text is one of the easiest ways to trigger unstable behavior, including:

- gradual speed-up or buzzing
- out-of-memory errors from KV cache growth
- generations that never stop

The practical solution is to split long text into shorter segments and concatenate the resulting waveforms:

.. code-block:: python

   import numpy as np

   segments = ["First paragraph...", "Second paragraph...", "Third paragraph..."]
   all_wavs = []
   for seg in segments:
       wav = model.generate(text=seg, reference_wav_path="voice.wav")
       all_wavs.append(wav)
   full_wav = np.concatenate(all_wavs)

Leading and trailing artifacts
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you hear extra sounds at the beginning or end of the generated audio:

- **VoxCPM 1.x:** check whether ``prompt_text`` matches the reference audio exactly — mismatched transcripts are the most common cause

Other things to try:

- enable ``retry_badcase=True``
- lower ``cfg_value``
- trim the output afterwards if needed

.. code-block:: python

   import librosa
   wav_trimmed, _ = librosa.effects.trim(wav)

Denoise
^^^^^^^

The ``denoise`` parameter improves **prompt audio**, not the generated output itself:

- ``denoise=True`` is useful when the reference audio is noisy
- ``denoise=False`` is better when the prompt is already clean and you want to preserve the original voice characteristics

.. warning::

   The denoiser runs in a 16kHz pipeline and can slightly change the voice characteristics. If cloning quality gets worse, try turning it off.

Streaming
*********

VoxCPM supports streaming audio output through ``generate_streaming()``. For interactive applications, a sentence-level approach is usually more stable than trying to stream one growing text input:

1. Split incoming text into sentences.
2. Call ``generate_streaming()`` for each sentence.
3. Play or buffer each audio chunk in order.

.. code-block:: python

   import numpy as np
   import soundfile as sf

   chunks = []
   for chunk in model.generate_streaming(
       text="Streaming text to speech is easy with VoxCPM!",
   ):
       chunks.append(chunk)
   wav = np.concatenate(chunks)
   sf.write("streaming.wav", wav, model.tts_model.sample_rate)

Bidirectional streaming, where text arrives token by token while audio is generated at the same time, is not currently supported.

What's Next?
************

- Check :doc:`./faq` when you hit environment, runtime, or deployment problems.
- Read the pages under ``Models`` for version-specific features and migration notes.
- Fine-tune the model with :doc:`./finetuning/finetune` to adapt it to your use case.
- Deploy the model with :doc:`./deployment/nanovllm_voxcpm` for high-throughput serving.
