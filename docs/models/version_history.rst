Version History
===============

This page summarizes all VoxCPM releases, including feature comparison, version highlights, and migration guidance.

Quick Comparison
****************

.. list-table::
   :widths: 28 24 24 24
   :header-rows: 1

   * - Feature
     - VoxCPM 1.0
     - VoxCPM 1.5
     - VoxCPM 2
   * - **Parameters**
     - 640M
     - 800M
     - 2.3B
   * - **Audio Output**
     - 16kHz
     - 44.1kHz
     - 48kHz (native)
   * - **Languages**
     - 2 (zh, en)
     - 2 (zh, en)
     - 30
   * - **Patch Size**
     - 2
     - 4
     - 4
   * - **LM Token Rate**
     - 12.5Hz
     - 6.25Hz
     - 6.25Hz
   * - **Max Sequence Length**
     - 4096
     - 4096
     - 8192
   * - **Residual LM Fusion**
     - Additive
     - Additive
     - Concat + Projection
   * - **DiT Conditioning**
     - Single token (add)
     - Single token (add)
     - Multi-token (concat)
   * - **Reference Audio**
     - Prompt continuation
     - Prompt continuation
     - Isolated ref channel
   * - **Voice Design**
     - —
     - —
     - ✅
   * - **Style Control**
     - —
     - —
     - ✅
   * - **SFT / LoRA**
     - ✅
     - ✅
     - ✅
   * - **RTF (RTX 4090)**
     - ~0.17
     - ~0.15
     - ~0.3

For a detailed explanation of the architecture components (four-stage pipeline, AudioVAE, Local DiT), see :doc:`./architecture`.

VoxCPM 2
*********

VoxCPM 2 is the latest major release — a 2.3B parameter model trained on 2.36 million hours of multilingual data. It represents a significant leap in capacity, quality, and controllability over the 1.x series.

Key characteristics:

- 48kHz native audio output via AudioVAE V2 (asymmetric 16kHz encode → 48kHz decode)
- 30-language multilingual support
- Voice Design: create a voice from natural-language description, no reference audio needed
- Style Control: control emotion, pace, and speaking style of a cloned voice via text tags
- Isolated reference channel for voice cloning (no matching transcript required)
- Concat-Projection residual LM fusion and multi-token DiT conditioning for richer expressiveness
- Built on a `MiniCPM-4 <https://github.com/OpenBMB/MiniCPM>`_ backbone

Use VoxCPM 2 for all new projects. It is the recommended default for multilingual synthesis, voice cloning, voice design, and production deployment.

VoxCPM 1.5
***********

VoxCPM 1.5 is the final 1.x upgrade before VoxCPM 2. It improves audio quality and efficiency while keeping the core context-aware generation and zero-shot voice cloning workflow familiar to existing 1.x users.

Key characteristics:

- 44.1kHz output
- 6.25Hz LM token rate
- patch size increased from 2 to 4
- simpler migration path for existing VoxCPM 1.0 users

Use VoxCPM 1.5 when you want a lighter Chinese/English checkpoint than VoxCPM 2, while keeping stronger output quality than VoxCPM 1.0.

VoxCPM 1.0
***********

VoxCPM 1.0 is the original tokenizer-free VoxCPM release. It remains useful as the baseline reference point for the family and for older experiments built around the original 0.5B checkpoint.

Key characteristics:

- 600M parameter size
- 16kHz output
- original VoxCPM architecture release
- benchmark reference for early VoxCPM results

Use VoxCPM 1.0 when you need the smallest historical checkpoint or want to compare against the original baseline behavior.

Migration Guidance
******************

- **New projects** should start with VoxCPM 2.
- **Existing VoxCPM 1.0 users** should generally move to VoxCPM 1.5 first if they need a lower-risk 1.x upgrade path.
- If you need multilingual synthesis, Voice Design, Style Control, or native 48kHz output, move directly to VoxCPM 2.

Detailed Pages
**************

- Full VoxCPM 2 page: :doc:`./voxcpm2`
- Full VoxCPM 1.5 page: :doc:`./voxcpm1.5`
- Full VoxCPM 1.0 page: :doc:`./voxcpm1`
