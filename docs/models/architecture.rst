Architecture
============

VoxCPM adopts a **tokenizer-free, diffusion autoregressive** architecture that models speech in continuous latent space rather than discrete tokens. This page describes the core design shared across all VoxCPM models, followed by version-specific improvements.

.. figure:: /_static/voxcpm1/voxcpm_model.png
   :alt: VoxCPM Model Architecture
   :align: center
   :width: 90%

   VoxCPM model architecture overview.

----

Overview
********

Unlike mainstream TTS approaches that convert speech into discrete tokens, VoxCPM uses an end-to-end architecture that **directly generates continuous speech representations** from text. Built on a `MiniCPM-4 <https://github.com/OpenBMB/MiniCPM>`_ backbone, the system achieves implicit semantic-acoustic decoupling through hierarchical language modeling and FSQ constraints, greatly enhancing both expressiveness and generation stability.

The system consists of a four-stage pipeline:

.. list-table::
   :widths: 5 25 70
   :header-rows: 1

   * - #
     - Stage
     - Description
   * - 1
     - **Local Encoder**
     - Encodes input audio patches into compact local representations. Groups consecutive audio frames into patches to reduce the effective sequence length for the language model.
   * - 2
     - **Text-Semantic LM**
     - A causal language model (based on `MiniCPM-4 <https://github.com/OpenBMB/MiniCPM>`_) that jointly processes text tokens and audio embeddings to capture high-level semantic intent. This stage handles the "what to say" — planning prosody, pacing, and emphasis from the text content.
   * - 3
     - **Residual Acoustic LM**
     - Fuses semantic-level and acoustic-level information to model fine-grained acoustic details. Bridges the gap between the text-semantic planning and the final audio generation.
   * - 4
     - **Local DiT (CFM)**
     - A Conditional Flow Matching (CFM) diffusion transformer that generates continuous audio latents conditioned on the LM outputs. Produces high-fidelity speech patches at each autoregressive step.

The generated latents are decoded by **AudioVAE** into raw waveforms.

----

Key Design Principles
**********************

Tokenizer-Free Continuous Modeling
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Most TTS systems discretize speech into tokens (e.g., via VQ-VAE), which introduces information loss. VoxCPM instead operates in **continuous latent space**, preserving fine-grained acoustic details like micro-prosody, breathing, and natural timbre variations.

Hierarchical Semantic-Acoustic Decoupling
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The two-stage LM design (Text-Semantic LM + Residual Acoustic LM) enables an implicit separation of concerns:

- The **Text-Semantic LM** focuses on high-level planning — what words to emphasize, where to pause, what emotion to convey.
- The **Residual Acoustic LM** focuses on low-level rendering — precise timbre, acoustic texture, and spectral details.

This hierarchical approach is key to VoxCPM's stability on long-form generation and its ability to produce expressive, context-aware speech.

Autoregressive Patch-Level Generation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

VoxCPM generates audio **patch by patch** (not frame by frame), where each patch covers multiple audio frames. This significantly reduces the number of autoregressive steps required, enabling real-time synthesis with RTF as low as ~0.15 on a consumer GPU.

----

AudioVAE
*********

The Audio VAE is responsible for encoding raw waveforms into latent representations (used during training) and decoding latents back into waveforms (used during inference). It is based on the `DAC <https://github.com/descriptinc/descript-audio-codec>`_ architecture.

.. list-table::
   :widths: 30 35 35
   :header-rows: 1

   * - Property
     - VoxCPM 1.x
     - VoxCPM 2
   * - **Output Sample Rate**
     - 16kHz (v1.0) / 44.1kHz (v1.5)
     - 48kHz (native)
   * - **Encode / Decode**
     - Symmetric (same rate)
     - Asymmetric (16kHz encode → 48kHz decode)
   * - **Latent Rate**
     - 25Hz
     - 25Hz
   * - **FSQ Latent Dim**
     - 256
     - 512

VoxCPM 2 introduces **AudioVAE V2** with an asymmetric encode/decode design and sample-rate conditioning. This allows the encoder to operate at 16kHz (reducing compute) while the decoder natively outputs 48kHz studio-quality audio — no post-processing upsampling needed.

----

Local DiT (Conditional Flow Matching)
***************************************

The Local DiT is a diffusion transformer operating within each audio patch. Instead of generating discrete tokens, it uses **Conditional Flow Matching (CFM)** to model the continuous distribution of audio latents.

At inference time, the ``inference_timesteps`` parameter controls how many denoising steps the DiT performs per patch:

- **Lower values** (e.g., 5): Faster generation, slightly lower quality.
- **Higher values** (e.g., 10–20): Better quality, slower generation.

The ``cfg_value`` (Classifier-Free Guidance) parameter controls how strongly the DiT conditions on the LM output:

- **Lower values** (1.0–1.5): More natural, relaxed output.
- **Higher values** (2.0+): Stricter adherence to conditioning, but may introduce artifacts on long sequences.

----

References
***********

- `DiTAR <https://arxiv.org/abs/2502.03930>`_ — Diffusion autoregressive backbone
- `MiniCPM-4 <https://github.com/OpenBMB/MiniCPM>`_ — Language model foundation
- `CosyVoice <https://github.com/FunAudioLLM/CosyVoice>`_ — Flow Matching-based LocDiT implementation
- `DAC <https://github.com/descriptinc/descript-audio-codec>`_ — Audio VAE backbone
- `VoxCPM Technical Report <https://arxiv.org/abs/2509.24650>`_ — Full paper with training details and ablations
