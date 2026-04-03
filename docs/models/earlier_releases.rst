Earlier Releases
================

This page summarizes the earlier VoxCPM releases that remain useful for compatibility, lighter deployment targets, and historical reference. For new projects, use :doc:`./voxcpm2`.

When To Use An Earlier Release
******************************

Choose an earlier release if you need one of the following:

- compatibility with an existing 1.x workflow
- a lighter Chinese/English-only checkpoint
- baseline comparison against the original VoxCPM release
- historical reference for earlier benchmarks or architecture decisions

Quick Comparison
****************

.. list-table::
   :widths: 20 15 15 50
   :header-rows: 1

   * - Release
     - Parameter Size
     - Sampling Rate
     - Best For
   * - **VoxCPM 1.5**
     - 750M
     - 44.1kHz
     - Lighter Chinese/English deployment with higher output quality than VoxCPM 1.0
   * - **VoxCPM 1.0**
     - 600M
     - 16kHz
     - Baseline compatibility, historical reference, and the original VoxCPM release

VoxCPM 1.5
**********

VoxCPM 1.5 is the final 1.x upgrade before VoxCPM 2. It improves audio quality and efficiency while keeping the core context-aware generation and zero-shot voice cloning workflow familiar to existing 1.x users.

Key characteristics:

- 44.1kHz output
- 6.25Hz LM token rate
- patch size increased from 2 to 4
- simpler migration path for existing VoxCPM 1.0 users

Use VoxCPM 1.5 when you want a lighter Chinese/English checkpoint than VoxCPM 2, while keeping stronger output quality than VoxCPM 1.0.

VoxCPM 1.0
**********

VoxCPM 1.0 is the original tokenizer-free VoxCPM release. It remains useful as the baseline reference point for the family and for older experiments built around the original 0.5B checkpoint.

Key characteristics:

- 600M parameter size
- 16kHz output
- original VoxCPM architecture release
- benchmark reference for early VoxCPM results

Use VoxCPM 1.0 when you need the smallest historical checkpoint or want to compare against the original baseline behavior.

Migration Guidance
******************

- New projects should start with :doc:`./voxcpm2`.
- Existing VoxCPM 1.0 users should generally move to VoxCPM 1.5 first if they need a lower-risk 1.x upgrade path.
- If you need multilingual synthesis, Voice Design, Style Control, or 48kHz output, move directly to :doc:`./voxcpm2`.

Archived Details
****************

Archived detailed pages remain available here for readers who want the original version-specific documentation.

- Full VoxCPM 1.5 page: :doc:`./voxcpm1.5`
- Full VoxCPM 1.0 page: :doc:`./voxcpm1`
