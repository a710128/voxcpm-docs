.. orphan:

Choose a Model
==============

This page is a quick decision guide for the current VoxCPM model family. If you already know which checkpoint you want, jump directly to the detailed model pages in the sidebar.

Quick Comparison
****************

.. list-table::
    :widths: 22 26 18 18 16
    :header-rows: 1
    :align: center

    * - Model
      - Best For
      - Parameter Size
      - Sampling Rate
      - Languages
    * - :doc:`VoxCPM 2 <./models/voxcpm2>`
      - Multilingual generation, voice design, style control, and the highest native output quality
      - 2.3B
      - 48kHz
      - 30
    * - :doc:`VoxCPM 1.5 <./models/voxcpm1.5>`
      - A lighter general-purpose checkpoint for Chinese and English with 44.1kHz output
      - 750M
      - 44.1kHz
      - 2
    * - :doc:`VoxCPM 1.0 <./models/voxcpm1>`
      - The smallest baseline model and the original release of the VoxCPM architecture
      - 600M
      - 16kHz
      - 2

Recommendations
****************

- Choose :doc:`./models/voxcpm2` if you need multilingual synthesis, Voice Design, Style Control, or the best built-in audio fidelity.
- Choose :doc:`./models/voxcpm1.5` if you want a smaller Chinese/English checkpoint with strong quality and a simpler migration path from earlier 1.x usage.
- Choose :doc:`./models/voxcpm1` if you need the original baseline behavior or a smaller legacy checkpoint.

What To Read Next
*****************

- Start with :doc:`./quickstart` to install the package and run your first generation example.
- Continue with :doc:`./chefsguide` for prompt strategy, cloning tips, and quality tuning advice.
- Open the detailed model pages in ``Models`` when you need architecture details, examples, or migration notes.
