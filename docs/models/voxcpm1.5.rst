VoxCPM 1.5
==========

* **Release Date:** December 5, 2025
* **Parameter Size:** 750M
* **Sampling Rate:** 44.1kHz

Overview
********

We're thrilled to introduce a major upgrade that improves audio quality and efficiency of VoxCPM, while maintaining the core capabilities of context-aware speech generation and zero-shot voice cloning.

+---------------------------+------------+---------------+
| Feature                   | VoxCPM     | VoxCPM1.5     |
+===========================+============+===============+
| **Audio VAE Sampling**    | 16kHz      | 44.1kHz       |
| **Rate**                  |            |               |
+---------------------------+------------+---------------+
| **LM Token Rate**         | 12.5Hz     | 6.25Hz        |
+---------------------------+------------+---------------+
| **Patch Size**            | 2          | 4             |
+---------------------------+------------+---------------+
| **Token Rate**            | 12.5Hz     | 6.25Hz        |
+---------------------------+------------+---------------+


Getting Started
***************

For installation, loading, and the shared generation API, start with :doc:`../quickstart`.

Choose VoxCPM 1.5 when you want a lighter Chinese/English checkpoint than VoxCPM 2 while keeping higher output quality than VoxCPM 1.0.

Model Updates
*************

AudioVAE Sampling Rate: 16kHz -> 44.1kHz
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The AudioVAE now supports 44.1kHz sampling rate, which allows the model to:

* Better cloning fidelity with more preserved high-frequency detail

.. note::
   This upgrade enables higher quality generation when using high-quality reference audio, but does not guarantee that all generated audio will be high-fidelity. The output quality depends on the **prompt speech** quality.

Token Rate: 12.5Hz -> 6.25Hz
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

We reduced the token rate in LM from 12.5Hz to 6.25Hz (patch size increased from 2 to 4) while maintaining similar performance on evaluation benchmarks. This change:

* Reduces computational requirements for generating the same length of audio
* Provides a foundation for longer audio generation

Migration Guide
***************

From VoxCPM-0.5B to VoxCPM1.5
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. **Update Model Path**: Point to VoxCPM1.5 checkpoint
2. **Update Sample Rate**: Change ``sample_rate`` from ``16000`` to ``44100`` in configs
3. **Update Audio Data**: Ensure training data is 44.1kHz (or resample if needed)
4. **Review Training Parameters**: Adjust batch size if needed due to higher sampling rate

Backward Compatibility
^^^^^^^^^^^^^^^^^^^^^^

* VoxCPM-0.5B models and configurations remain fully supported
* Code automatically detects and adapts to model version
* No breaking changes to the API

