VoxCPM 1.0
===========


.. image:: https://img.shields.io/badge/%F0%9F%A4%97%20Hugging%20Face-OpenBMB-yellow
   :target: https://huggingface.co/openbmb/VoxCPM-0.5B
   :alt: Hugging Face

.. image:: https://img.shields.io/badge/ModelScope-OpenBMB-purple
   :target: https://modelscope.cn/models/OpenBMB/VoxCPM-0.5B
   :alt: ModelScope

.. image:: https://img.shields.io/badge/Audio%20Samples-Page-green
   :target: https://openbmb.github.io/VoxCPM-demopage
   :alt: Audio Samples


* **Release Date:** September 16, 2025
* **Parameter Size:** 600M
* **Sampling Rate:** 16kHz


VoxCPM is a novel tokenizer-free Text-to-Speech (TTS) system that redefines realism in speech synthesis. By modeling speech in a continuous space, it overcomes the limitations of discrete tokenization and enables two flagship capabilities: context-aware speech generation and true-to-life zero-shot voice cloning.

Unlike mainstream approaches that convert speech to discrete tokens, VoxCPM uses an end-to-end diffusion autoregressive architecture that directly generates continuous speech representations from text. Built on MiniCPM-4 backbone, it achieves implicit semantic-acoustic decoupling through hierachical language modeling and FSQ constraints, greatly enhancing both expressiveness and generation stability.

🔧 Architecture
*****************

.. figure:: /_static/voxcpm1/voxcpm_model.png
    :width: 100%
    :align: center
    :alt: VoxCPM 1.0 Architecture
    :class: no-scaled-link


🚀 Basic Usage
*****************
.. code-block:: python

   from voxcpm import VoxCPM
   import soundfile as sf
   # Load VoxCPM model
   model = VoxCPM.from_pretrained("openbmb/VoxCPM-0.5B")
   # Generate speech
   wav = model.generate(
      text="VoxCPM is an innovative end-to-end TTS model from ModelBest, designed to generate highly expressive speech.",
      cfg_value=1.5,
      inference_timesteps=10,
   )
   sf.write("output.wav", wav, 16000)
   print("saved: output.wav")

📊 Benchmark
****************

VoxCPM achieves competitive results on public zero-shot TTS benchmarks:

Seed-TTS-eval Benchmark
^^^^^^^^^^^^^^^^^^^^^^^^^^

.. table::
    :widths: auto
    :align: center

    ================= ========== =========== ============== ============== ============== ============== ================ ================
    Model             Parameters Open-Source test-EN                       test-ZH                       test-Hard                        
    ----------------- ---------- ----------- ----------------------------- ----------------------------- ---------------------------------
        /                                     WER/%⬇         SIM/%⬆         CER/%⬇         SIM/%⬆         CER/%⬇           SIM/%⬆          
    ================= ========== =========== ============== ============== ============== ============== ================ ================
    MegaTTS3          0.5B       ❌           2.79           77.1           1.52           79.0           /                /               
    DiTAR             0.6B       ❌           1.69           73.5           1.02           75.3           /                /               
    CosyVoice3        0.5B       ❌           2.02           71.8           1.16           78.0           6.08             75.8            
    CosyVoice3        1.5B       ❌           2.22           72.0           1.12           78.1           5.83             75.8            
    Seed-TTS          /          ❌           2.25           76.2           1.12           79.6           7.59             77.6            
    MiniMax-Speech    /          ❌           1.65           69.2           0.83           78.3           /                /               
    CosyVoice         0.3B       ✅           4.29           60.9           3.63           72.3           11.75            70.9            
    CosyVoice2        0.5B       ✅           3.09           65.9           1.38           75.7           **6.83**         72.4            
    F5-TTS            0.3B       ✅           2.00           67.0           1.53           76.0           8.67             71.3            
    SparkTTS          0.5B       ✅           3.14           57.3           1.54           66.0           /                /               
    FireRedTTS        0.5B       ✅           3.82           46.0           1.51           63.5           17.45            62.1            
    FireRedTTS-2      1.5B       ✅           1.95           66.5           1.14           73.6           /                /               
    Qwen2.5-Omni      7B         ✅           2.72           63.2           1.70           75.2           7.97             **74.7**        
    OpenAudio-s1-mini 0.5B       ✅           1.94           55.0           1.18           68.5           /                /               
    IndexTTS2         1.5B       ✅           2.23           70.6           1.03           76.5           /                /               
    VibeVoice         1.5B       ✅           3.04           68.9           1.16           74.4           /                /               
    HiggsAudio-v2     3B         ✅           2.44           67.7           1.50           74.0           /                /               
    **VoxCPM**        0.5B       ✅           **1.85**       **72.9**       **0.93**       **77.2**       8.87             73.0            
    ================= ========== =========== ============== ============== ============== ============== ================ ================

CV3-eval Benchmark
^^^^^^^^^^^^^^^^^^^^^^^^^^
.. table::
    :widths: auto
    :align: center

    ================= ======== ======== ======= ====== ======= ======== ====== =======
      Model             zh       en       hard/zh               hard/en                
    ----------------- -------- -------- ---------------------- -----------------------
          /           CER/%⬇   WER/%⬇   CER/%⬇  SIM/%⬆ DNSMOS⬆ WER/%⬇   SIM/%⬆ DNSMOS⬆
    ================= ======== ======== ======= ====== ======= ======== ====== =======
    F5-TTS            5.47     8.90     /       /      /       /        /      /      
    SparkTTS          5.15     11.0     /       /      /       /        /      /      
    GPT-SoVits        7.34     12.5     /       /      /       /        /      /      
    CosyVoice2        4.08     6.32     12.58   72.6   3.81    11.96    66.7   3.95   
    OpenAudio-s1-mini 4.00     5.54     18.1    58.2   3.77    12.4     55.7   3.89   
    IndexTTS2         3.58     4.45     12.8    74.6   3.65    /        /      /      
    HiggsAudio-v2     9.54     7.89     41.0    60.2   3.39    10.3     61.8   3.68   
    CosyVoice3-0.5B   3.89     5.24     14.15   78.6   3.75    9.04     75.9   3.92   
    CosyVoice3-1.5B   3.91     4.99     9.77    78.5   3.79    10.55    76.1   3.95   
    **VoxCPM**        **3.40** **4.04** 12.9    66.1   3.59    **7.89** 64.3   3.74   
    ================= ======== ======== ======= ====== ======= ======== ====== =======
