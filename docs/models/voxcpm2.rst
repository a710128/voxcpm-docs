VoxCPM 2
========


.. image:: https://img.shields.io/badge/%F0%9F%A4%97%20Hugging%20Face-OpenBMB-yellow
   :target: https://huggingface.co/openbmb/VoxCPM2
   :alt: Hugging Face

.. image:: https://img.shields.io/badge/ModelScope-OpenBMB-purple
   :target: https://modelscope.cn/models/OpenBMB/VoxCPM2
   :alt: ModelScope

.. image:: https://img.shields.io/badge/Audio%20Samples-Page-green
   :target: https://openbmb.github.io/VoxCPM-demopage
   :alt: Audio Samples


* **Release Date:** March 2026
* **Parameter Size:** 2.3B
* **Sampling Rate:** 48kHz
* **Languages:** 30 languages

.. important::

   VoxCPM 2 is the current recommended release for new deployments and new feature work.


Overview
********

VoxCPM 2 is a major evolution of the VoxCPM family, bringing substantial improvements across architecture, audio quality, language coverage, and controllability. While preserving the core tokenizer-free philosophy and diffusion autoregressive framework, VoxCPM 2 introduces a redesigned information fusion pipeline, a next-generation AudioVAE with native 48kHz output, support for 30 languages, and new controllable generation capabilities including **Voice Design** and **Style Control**.


What's New
**********

.. grid:: 1 1 2 2
   :gutter: 4

   .. grid-item-card::
      :class-card: voxcpm-feature-card
      :padding: 4

      .. rst-class:: voxcpm-feature-icon

      🌍

      **30-Language Multilingual**
      ^^^

      Trained on 2.36 million hours of data (1.8M zh+en base + 560K multilingual), now covering 30 languages across multiple language families.

   .. grid-item-card::
      :class-card: voxcpm-feature-card
      :padding: 4

      .. rst-class:: voxcpm-feature-icon

      🎨

      **Voice Design & Style Control**
      ^^^

      Design a voice from scratch with natural language descriptions, or control the speaking style of a cloned voice — all through simple text tags.

   .. grid-item-card::
      :class-card: voxcpm-feature-card
      :padding: 4

      .. rst-class:: voxcpm-feature-icon

      🔊

      **48kHz Native Audio**
      ^^^

      A redesigned AudioVAE V2 with 3x higher upsampling ratio and sample-rate-conditioned decoding produces studio-quality 48kHz audio natively.

   .. grid-item-card::
      :class-card: voxcpm-feature-card
      :padding: 4

      .. rst-class:: voxcpm-feature-icon

      🧠

      **Redesigned Fusion Architecture**
      ^^^

      Concat-Projection fusion and multi-token DiT conditioning replace additive shortcuts, preserving richer information flow throughout the pipeline.


Language Support
****************

VoxCPM 2 supports **30 languages** spanning diverse language families. Building on the original 1.8 million-hour Chinese and English corpus, we added 560,000 hours of multilingual data to enable high-quality synthesis across:

.. list-table::
   :widths: 25 75
   :header-rows: 1

   * - Language Family
     - Languages
   * - **East Asian**
     - Chinese, Japanese, Korean
   * - **Southeast Asian**
     - Burmese, Indonesian, Khmer, Lao, Malay, Tagalog, Thai, Vietnamese
   * - **South Asian**
     - Hindi
   * - **European (Germanic)**
     - Danish, Dutch, English, Finnish, German, Norwegian, Swedish
   * - **European (Romance)**
     - French, Italian, Portuguese, Spanish
   * - **European (Other)**
     - Greek, Polish, Russian, Turkish
   * - **Semitic**
     - Arabic, Hebrew
   * - **African**
     - Swahili


Architecture
************

VoxCPM 2 retains the four-stage pipeline of VoxCPM — **Local Encoder → Text-Semantic LM → Residual Acoustic LM → Local DiT (CFM)** — while redesigning three core information pathways for better capacity and expressiveness.


Feature Comparison
^^^^^^^^^^^^^^^^^^^^

+------------------------------+----------------------+----------------------+
| Feature                      | VoxCPM 1 / 1.5       | VoxCPM 2             |
+==============================+======================+======================+
| **Patch Size**               | 2 / 4                | 4                    |
+------------------------------+----------------------+----------------------+
| **Residual LM Layers**       | 6                    | 8                    |
+------------------------------+----------------------+----------------------+
| **FSQ Latent Dim**           | 256                  | 512                  |
+------------------------------+----------------------+----------------------+
| **Max Sequence Length**      | 4096                 | 8192                 |
+------------------------------+----------------------+----------------------+
| **AudioVAE Output**          | 16kHz / 44.1kHz      | 48kHz (native)       |
+------------------------------+----------------------+----------------------+
| **Encode / Decode Rate**     | Symmetric (same SR)  | Asymmetric           |
|                              |                      | (16kHz -> 48kHz)     |
+------------------------------+----------------------+----------------------+
| **Residual LM Fusion**       | Additive             | Concat + Projection  |
+------------------------------+----------------------+----------------------+
| **DiT Conditioning**         | Single token (add)   | Multi-token (concat) |
+------------------------------+----------------------+----------------------+
| **Reference Audio**          | Prompt continuation  | Isolated ref channel |
+------------------------------+----------------------+----------------------+
| **Languages**                | 2 (zh, en)           | 30                   |
+------------------------------+----------------------+----------------------+
| **Controllability**          | --                   | Voice Design + Style |
|                              |                      | Control              |
+------------------------------+----------------------+----------------------+


Residual LM Fusion: Additive → Concat-Projection
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In VoxCPM 1.x, the input to the Residual Acoustic LM is formed by **adding** the base LM output and the local encoder features. VoxCPM 2 replaces this with a **concatenation followed by a learnable linear projection**:

.. code-block:: text

   # VoxCPM 1.x
   residual_input = lm_output + masked_audio_embed

   # VoxCPM 2
   residual_input = Linear₂ₕ→ₕ( concat(lm_output, masked_audio_embed) )

This gives the Residual LM more flexibility to learn how to combine semantic and acoustic information, rather than being constrained to element-wise addition.


DiT Conditioning: Single Token → Multi-Token Prefix
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In VoxCPM 1.x, the LM hidden state and Residual LM hidden state are **summed** into a single conditioning vector, which is then added to the diffusion timestep embedding and fed to the DiT as one prefix token.

VoxCPM 2 instead **concatenates** the two projected hidden states (doubling the dimension), then reshapes them into **multiple prefix tokens** that are presented to the DiT alongside the timestep token:

.. code-block:: text

   # VoxCPM 1.x DiT input sequence:
   [ (mu + t) | cond | x ]      ← 1 conditioning token

   # VoxCPM 2 DiT input sequence:
   [ mu₁ | mu₂ | t | cond | x ]  ← 2 conditioning tokens + timestep token

This allows the DiT's attention mechanism to independently attend to semantic-level and acoustic-level information without information collapse from early fusion.


Isolated Reference Audio Channel
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

VoxCPM 1.x only supports voice cloning through prompt continuation (concatenating prompt audio with generation). VoxCPM 2 introduces a **structurally isolated reference audio mechanism** using dedicated special tokens:

.. code-block:: text

   [ <ref_start> | ref_audio_patches | <ref_end> | text_tokens | <audio_start> | generation... ]

This decouples the timbre reference from the continuation context, enabling four generation modes:

1. **Zero-shot**: No reference audio, synthesize from text only
2. **Continuation**: Prompt text + prompt audio for seamless continuation
3. **Reference-only**: Isolated voice cloning from a reference clip
4. **Combined**: Reference audio for timbre + prompt audio for context. We observe that this mode yields a slight improvement in voice cloning similarity compared to using reference or continuation alone.


AudioVAE V2: Native 48kHz with Sample-Rate Conditioning
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The AudioVAE has been completely redesigned:

* **Asymmetric encode/decode design**: Unlike v1/v1.5 where encoder and decoder operate at the same sample rate, V2 encodes at 16kHz (640x downsampling, keeping the LM token rate low at 6.25Hz) but decodes directly to 48kHz via a 1920x upsampling decoder. This achieves high-quality output without increasing the LM sequence length.
* **Decoder capacity**: Channel width increased to 2048, with 6 upsampling stages ``[8, 6, 5, 2, 2, 2]``
* **Sample-rate conditioning**: A new ``SampleRateConditionLayer`` injects scale-bias modulation at each decoder block, allowing the same model to decode at different target sample rates


Controllable Generation
***********************

VoxCPM 2 introduces two new controllable generation features. Both use a simple convention: place control instructions inside parentheses ``()`` before the target text.

Voice Design
^^^^^^^^^^^^

Create a voice from a natural language description **without any reference audio**. Simply describe the desired voice characteristics in parentheses:

.. code-block:: python

   from voxcpm import VoxCPM
   import soundfile as sf

   model = VoxCPM.from_pretrained("openbmb/VoxCPM2")

   wav = model.generate(
      text="(A warm, gentle female voice in her 30s with a calm and soothing tone) "
           "Welcome to VoxCPM 2, the next generation of realistic speech synthesis.",
      cfg_value=2.0,
      inference_timesteps=10,
   )
   sf.write("voice_design.wav", wav, 48000)

.. tip::

   Voice Design works best with descriptive attributes such as age, gender, pitch, speaking pace, emotional tone, and vocal texture. Be as specific as you like — the model interprets natural language descriptions.


Style Control
^^^^^^^^^^^^^

Control the speaking style while using a reference audio for voice cloning. Pass control tags in parentheses alongside the reference audio:

.. code-block:: python

   from voxcpm import VoxCPM
   import soundfile as sf

   model = VoxCPM.from_pretrained("openbmb/VoxCPM2")

   wav = model.generate(
      text="(Speaking slowly with a whispering, mysterious tone) "
           "The secret lies hidden in the ancient library, waiting to be discovered.",
      reference_wav_path="reference_speaker.wav",
      cfg_value=2.0,
      inference_timesteps=10,
   )
   sf.write("style_control.wav", wav, 48000)

.. note::

   In Style Control mode, the reference audio determines **who** speaks (timbre), while the text tag in parentheses controls **how** they speak (style, emotion, pace, etc.).


Usage Examples
**************

For installation and the shared ``generate()`` API, start with :doc:`../quickstart`. The examples below focus on VoxCPM 2 specific capabilities.

Reference-Only Voice Cloning
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: python

   wav = model.generate(
      text="This is a voice cloning demonstration using VoxCPM 2.",
      reference_wav_path="speaker_reference.wav",
      cfg_value=2.0,
      inference_timesteps=10,
   )
   sf.write("cloned.wav", wav, 48000)

Multilingual Generation
^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: python

   # Korean
   wav = model.generate(
      text="VoxCPM 2는 30개 언어를 지원하는 차세대 음성 합성 모델입니다.",
      reference_wav_path="korean_speaker.wav",
      cfg_value=2.0,
   )
   sf.write("korean.wav", wav, 48000)

   # French
   wav = model.generate(
      text="VoxCPM 2 prend en charge la synthèse vocale en trente langues différentes.",
      reference_wav_path="french_speaker.wav",
      cfg_value=2.0,
   )
   sf.write("french.wav", wav, 48000)


Migration Guide
***************

From VoxCPM 1.5 to VoxCPM 2
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. **Update Model Path**: Point to VoxCPM2 checkpoint
2. **Update Sample Rate**: Change ``sample_rate`` from ``44100`` to ``48000`` when saving audio
3. **Voice Cloning API**: Use the new ``reference_wav_path`` parameter for isolated voice cloning (``prompt_wav_path`` still works for continuation mode)
4. **Controllable Features**: Explore Voice Design and Style Control by adding text tags in parentheses

Backward Compatibility
^^^^^^^^^^^^^^^^^^^^^^

* VoxCPM 1.0 and 1.5 models and configurations remain fully supported
* Code automatically detects model architecture (``voxcpm`` vs ``voxcpm2``) from ``config.json``
* The ``generate()`` API is backward-compatible; new parameters are optional
