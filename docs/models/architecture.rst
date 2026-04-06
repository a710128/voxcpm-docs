Architecture
============

VoxCPM adopts a **tokenizer-free, diffusion autoregressive** architecture that models speech in continuous latent space rather than discrete tokens. This page first explains the high-level design shared across the VoxCPM family, then summarizes the main architectural improvements introduced in VoxCPM 2.

.. figure:: /_static/voxcpm1/voxcpm_model.png
   :alt: VoxCPM Model Architecture
   :align: center
   :width: 90%

   High-level VoxCPM pipeline shared across the model family.

----

Overview
********

Unlike mainstream TTS approaches that convert speech into discrete tokens, VoxCPM uses an end-to-end architecture that **directly generates continuous speech representations** from text. Built on a `MiniCPM-4 <https://github.com/OpenBMB/MiniCPM>`_ backbone, the system uses hierarchical language modeling and FSQ-constrained continuous latents to separate high-level semantic planning from low-level acoustic rendering.

Across VoxCPM 1.0, 1.5, and 2, the family shares the same high-level generation path:

**text -> four-stage generative pipeline -> AudioVAE decoder -> waveform**

The generative backbone consists of four stages:

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

The generated latents are then decoded by **AudioVAE** into raw waveforms. AudioVAE is a supporting codec component used around the generative backbone: it provides latent representations during training and converts predicted latents back to waveform samples during inference.

Across versions, the codec layer evolves from a symmetric audio VAE in VoxCPM 1.x to **AudioVAE V2** in VoxCPM 2, which uses asymmetric 16kHz encode -> 48kHz decode and sample-rate conditioning.

Three design choices define the shared VoxCPM architecture:

- **Tokenizer-free continuous modeling** preserves fine-grained acoustic detail instead of compressing speech into discrete tokens.
- **Hierarchical semantic-acoustic separation** lets the model split high-level planning from low-level rendering.
- **Patch-level autoregressive generation** reduces sequence length and helps the system scale to longer and faster synthesis settings.

For version-by-version model selection and migration guidance, see :doc:`./version_history`.

----

VoxCPM 2 Improvements
*********************

VoxCPM 2 keeps the same overall four-stage structure, but redesigns several internal information pathways. These changes are important because they explain why VoxCPM 2 improves expressiveness, controllability, and output quality without changing the high-level mental model of the system.

.. list-table::
   :widths: 28 34 38
   :header-rows: 1

   * - Area
     - VoxCPM 1.x
     - VoxCPM 2
   * - **Residual Acoustic LM fusion**
     - Additive fusion
     - Concat + projection fusion for richer semantic-acoustic mixing
   * - **Local DiT conditioning**
     - Single fused conditioning token
     - Multi-token conditioning prefix to preserve more information
   * - **Reference audio pathway**
     - Prompt continuation only
     - Structurally isolated reference-audio channel
   * - **AudioVAE**
     - Symmetric encode/decode
     - AudioVAE V2 with asymmetric 16kHz encode -> 48kHz decode

Residual Acoustic LM Fusion
^^^^^^^^^^^^^^^^^^^^^^^^^^^

In VoxCPM 1.x, the Residual Acoustic LM combines the semantic LM output and local acoustic features through **addition**. VoxCPM 2 replaces this with **concatenation followed by a learnable projection**.

This gives the model more freedom to decide how semantic intent and acoustic evidence should interact, instead of forcing them into the same representation through element-wise addition. In practice, this supports richer acoustic detail and stronger expressiveness.

Local DiT Conditioning
^^^^^^^^^^^^^^^^^^^^^^

The Local DiT is a diffusion transformer operating within each audio patch. Instead of using a single early-fused conditioning signal, VoxCPM 2 feeds the DiT a **multi-token conditioning prefix** derived from the semantic and acoustic pathways.

This preserves more information for attention to work with inside the DiT, reducing information collapse from premature fusion. The result is a more expressive and controllable final acoustic generation stage.

Isolated Reference Audio Channel
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

VoxCPM 1.x primarily supports voice cloning through prompt continuation. VoxCPM 2 adds a **structurally isolated reference-audio pathway**, separating timbre reference from continuation context.

This architectural change is what enables stronger reference-only cloning behavior and makes it easier to combine voice identity control with other generation modes.

Why AudioVAE V2 Matters
^^^^^^^^^^^^^^^^^^^^^^^

AudioVAE V2 is not just a higher-sample-rate decoder. Its asymmetric encode/decode design keeps the language-model-side sequence efficient while still producing 48kHz output directly.

This is a key architectural improvement because it raises output fidelity without requiring a proportional increase in sequence length or a separate upsampling stage.

----

Where to Go Next
****************

- For release-by-release comparisons and migration guidance, see :doc:`./version_history`.
- For VoxCPM 2 specific details and examples, see :doc:`./voxcpm2`.

----

References
***********

- `DiTAR <https://arxiv.org/abs/2502.03930>`_ — Diffusion autoregressive backbone
- `MiniCPM-4 <https://github.com/OpenBMB/MiniCPM>`_ — Language model foundation
- `CosyVoice <https://github.com/FunAudioLLM/CosyVoice>`_ — Flow Matching-based LocDiT implementation
- `DAC <https://github.com/descriptinc/descript-audio-codec>`_ — Audio VAE backbone
- `VoxCPM Technical Report <https://arxiv.org/abs/2509.24650>`_ — Full paper with training details and ablations
