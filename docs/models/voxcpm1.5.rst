VoxCPM 1.5
===========

* **Release Date:** December 5, 2025
* **Parameter Size:** 750M
* **Sampling Rate:** 44.1kHz

🎉 Overview
*****************

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


🚀 Basic Usage
*****************
.. code-block:: python

   from voxcpm import VoxCPM
   import soundfile as sf
   # Load VoxCPM-1.5 model
   model = VoxCPM.from_pretrained("openbmb/VoxCPM1.5")
   # Generate speech
   wav = model.generate(
      text="VoxCPM 1.5 is an innovative end-to-end TTS model from ModelBest, designed to generate highly expressive speech.",
      cfg_value=1.5,
      inference_timesteps=10,
   )
   sf.write("output.wav", wav, 44100)
   print("saved: output.wav")

🎵 Model Updates
*****************

🔊 AudioVAE Sampling Rate: 16kHz → 44.1kHz
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The AudioVAE now supports 44.1kHz sampling rate, which allows the model to:

* 🎯 Clone better, preserving more high-frequency details and generate higher quality voice outputs

.. note::
   This upgrade enables higher quality generation when using high-quality reference audio, but does not guarantee that all generated audio will be high-fidelity. The output quality depends on the **prompt speech** quality.

⚡ Token Rate: 12.5Hz → 6.25Hz
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

We reduced the token rate in LM from 12.5Hz to 6.25Hz (patch size increased from 2 to 4) while maintaining similar performance on evaluation benchmarks. This change:

* 💨 Reduces computational requirements for generating the same length of audio
* 📈 Provides a foundation for longer audio generation

🔄 Migration Guide
*********************

From VoxCPM-0.5B to VoxCPM1.5
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. **Update Model Path**: Point to VoxCPM1.5 checkpoint
2. **Update Sample Rate**: Change ``sample_rate`` from ``16000`` to ``44100`` in configs
3. **Update Audio Data**: Ensure training data is 44.1kHz (or resample if needed)
4. **Review Training Parameters**: Adjust batch size if needed due to higher sampling rate

✅ Backward Compatibility
^^^^^^^^^^^^^^^^^^^^^^^^^^^

* VoxCPM-0.5B models and configurations remain fully supported
* Code automatically detects and adapts to model version
* No breaking changes to the API

