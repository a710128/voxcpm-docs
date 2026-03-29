Usage Guide & Best Practices
============================

This guide focuses on practical usage decisions: how to format text, how to use reference audio correctly, and how to tune generation quality without repeating the installation material from :doc:`./quickstart`.

Text Input Strategy
*******************

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

Reference Audio Strategy
************************

Voice cloning in VoxCPM 1.x
^^^^^^^^^^^^^^^^^^^^^^^^^^^

When using voice cloning with VoxCPM 1.x, ``prompt_text`` must accurately match the spoken content of the reference audio. Mismatched text is a common reason for artifacts such as extra leading sounds, garbled output, or the prompt audio leaking into the generation.

.. code-block:: python

   wav = model.generate(
       text="Target text to synthesize.",
       prompt_wav_path="reference.wav",
       prompt_text="Exact transcription of reference.wav",
   )

.. tip::

   If possible, use ASR to transcribe the prompt audio rather than typing the transcript manually. The web demo does this automatically through SenseVoice.

Voice cloning in VoxCPM 2
^^^^^^^^^^^^^^^^^^^^^^^^^

VoxCPM 2 adds an isolated reference channel. For reference-only cloning, you only need ``reference_wav_path`` and do not need a matching transcript. See :doc:`./models/voxcpm2` for the detailed modes.

Reference audio quality
^^^^^^^^^^^^^^^^^^^^^^^

- **Duration:** 5 to 30 seconds is a practical range
- **Format:** any format supported by torchaudio, including WAV, FLAC, and MP3
- **Quality:** cleaner audio usually gives better timbre preservation
- **Language:** VoxCPM 1.x is mainly Chinese/English, while VoxCPM 2 supports 30 languages

No reference audio
^^^^^^^^^^^^^^^^^^

If you do not provide a reference audio, VoxCPM will generate a random voice each time. The model can still infer an appropriate speaking style from the text, but the timbre will not stay consistent across calls.

To keep a consistent voice:

1. Reuse the same reference audio every time.
2. For VoxCPM 2, use ``reference_wav_path`` in isolated reference mode.
3. For production-grade consistency, consider LoRA fine-tuning. See :doc:`./finetuning/finetune`.

Quality Tuning
**************

CFG value
^^^^^^^^^

The ``cfg_value`` parameter controls how strictly the model follows the conditioning:

.. list-table::
   :widths: 20 80
   :header-rows: 1

   * - Value
     - Effect
   * - **1.0-1.5**
     - More relaxed and natural, but may drift slightly from the target text
   * - **2.0**
     - Balanced default
   * - **3.0+**
     - Stronger adherence to the text, but more risk of noise or artifacts on difficult inputs

If long-form output becomes noisy or buzzy, lowering ``cfg_value`` toward ``1.5-1.6`` is often more stable.

Inference timesteps
^^^^^^^^^^^^^^^^^^^

Lower ``inference_timesteps`` gives faster drafts. Higher values generally improve detail and naturalness at the cost of speed. The default setting is a good starting point before further tuning.

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
       wav = model.generate(text=seg, prompt_wav_path="voice.wav", prompt_text="...")
       all_wavs.append(wav)
   full_wav = np.concatenate(all_wavs)

Leading and trailing artifacts
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you hear extra sounds at the beginning, first check whether ``prompt_text`` matches the reference audio exactly.

If you get noisy tails or too much silence at the end:

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
- ``denoise=False`` is better when the prompt is already clean and you want to preserve the original voice characteristics as much as possible

.. warning::

   The denoiser runs in a 16kHz pipeline and can slightly change the voice characteristics. If cloning quality gets worse, try turning it off.

Streaming Strategy
******************

VoxCPM supports streaming audio output through ``generate_streaming()``. For interactive applications, a sentence-level approach is usually more stable than trying to stream one growing text input:

1. Split incoming text into sentences.
2. Call ``generate_streaming()`` for each sentence.
3. Play or buffer each audio chunk in order.

Bidirectional streaming, where text arrives token by token while audio is generated at the same time, is not currently supported.

What's Next?
************

- Go back to :doc:`./quickstart` if you need installation, CLI, or web demo instructions.
- Open :doc:`./faq` when you hit environment, runtime, or deployment problems.
- Read the pages under ``Current Version`` and ``Legacy Versions`` for architecture notes and version-specific features.
