.. VoxCPM documentation master file

VoxCPM documentation
====================================================

.. figure:: _static/voxcpm_logo.png
   :width: 70%
   :align: left
   :alt: VoxCPM
   :figclass: only-light voxcpm-logo-figure
   :class: no-scaled-link

.. figure:: _static/voxcpm_logo_dark.png
   :width: 70%
   :align: left
   :alt: VoxCPM
   :figclass: only-dark voxcpm-logo-figure
   :class: no-scaled-link

.. image:: https://img.shields.io/badge/Project%20Page-GitHub-blue
   :target: https://github.com/OpenBMB/VoxCPM/
   :alt: Project Page

.. image:: https://img.shields.io/badge/Technical%20Report-Arxiv-red
   :target: https://arxiv.org/abs/2509.24650
   :alt: Technical Report

.. image:: https://img.shields.io/badge/Live%20PlayGround-Demo-orange
   :target: https://huggingface.co/spaces/OpenBMB/VoxCPM-Demo
   :alt: Live Playground



VoxCPM is a realistic voice synthesis toolkit that brings authentic, expressive voices to your applications!

----

🌟 Key Features
******************

* **🎯 Context-Aware, Expressive Speech Generation** - VoxCPM comprehends text to infer and generate appropriate prosody, delivering speech with remarkable expressiveness and natural flow. It spontaneously adapts speaking style based on content, producing highly fitting vocal expression trained on a massive 1.8 million-hour bilingual corpus.
* **🎭 True-to-Life Voice Cloning** - With only a short reference audio clip, VoxCPM performs accurate zero-shot voice cloning, capturing not only the speaker’s timbre but also fine-grained characteristics such as accent, emotional tone, rhythm, and pacing to create a faithful and natural replica.
* **⚡ High-Efficiency Synthesis** - VoxCPM supports streaming synthesis with a Real-Time Factor (RTF) as low as 0.17 (based on VoxCPM-0.5B) on a consumer-grade NVIDIA RTX 4090 GPU, making it possible for real-time applications.

----

.. _model-versions:

📚 Model Versions
*******************

.. card-carousel:: 2

   .. card:: VoxCPM 2
      :class-card: sd-text-muted sd-rounded-2
      :class-title: sd-fs-4
      
      Under Development 🚧
      
      +++

      .. button-ref:: model-versions
         :ref-type: ref
         :color: muted
         :outline:
         
         Comming Soon

   .. card:: VoxCPM 1.5
      :class-card: sd-rounded-2
      :class-title: sd-fs-4
      
      * Faster Inference
      * Higher Quality (44.1kHz)
      
      +++

      .. button-ref:: models/voxcpm1.5
         :ref-type: doc
         :color: primary
         :outline:
         
         Try Now →

   .. card:: VoxCPM 1.0
      :class-card: sd-rounded-2
      :class-title: sd-fs-4

      * Realistic Voice Synthesis
      * Zero-shot Voice Cloning
      * Streaming Output Support

      +++

      .. button-ref:: models/voxcpm1
         :ref-type: doc
         :color: primary
         :outline:
         
         Try Now →

----


🤗 Community Projects
***********************

We're excited to see the VoxCPM community growing! Here are some amazing projects and features built by our community:


.. list-table::
   :widths: 25 75
   :header-rows: 1

   * - Project
     - Description
   * - `ComfyUI-VoxCPM <https://github.com/wildminder/ComfyUI-VoxCPM>`_
     - A VoxCPM extension for ComfyUI.
   * - `ComfyUI-VoxCPMTTS <https://github.com/1038lab/ComfyUI-VoxCPMTTS>`_
     - A VoxCPM extension for ComfyUI.
   * - `WebUI-VoxCPM <https://github.com/rsxdalv/tts_webui_extension.vox_cpm>`_
     - A template extension for TTS WebUI.
   * - `Streaming API Support (by AbrahamSanders) <https://github.com/OpenBMB/VoxCPM/pull/26>`_
     - The pull request that adds streaming API support to VoxCPM.
   * - `VoxCPM-NanoVLLM <https://github.com/a710128/nanovllm-voxcpm>`_
     - NanoVLLM integration for VoxCPM for faster, high-throughput inference on GPU.
   * - `VoxCPM-ONNX <https://github.com/bluryar/VoxCPM-ONNX>`_
     - ONNX export for VoxCPM supports faster CPU inference.
   * - `VoxCPMANE <https://github.com/0seba/VoxCPMANE>`_
     - VoxCPM TTS with Apple Neural Engine backend server.

**📢 WANTED:** Have you built something cool with VoxCPM? We'd love to feature it here! Please open an issue or pull request to add your project.

**‼ NOTE:** The projects are not officially maintained by OpenBMB.

----

⚠️ Risks and limitations
***************************

- **General Model Behavior:** While VoxCPM has been trained on a large-scale dataset, it may still produce outputs that are unexpected, biased, or contain artifacts.
- **Potential for Misuse of Voice Cloning:** VoxCPM's powerful zero-shot voice cloning capability can generate highly realistic synthetic speech. This technology could be misused for creating convincing deepfakes for purposes of impersonation, fraud, or spreading disinformation. Users of this model must not use it to create content that infringes upon the rights of individuals. It is strictly forbidden to use VoxCPM for any illegal or unethical purposes. We strongly recommend that any publicly shared content generated with this model be clearly marked as AI-generated.
- **Current Technical Limitations:** Although generally stable, the model may occasionally exhibit instability, especially with very long or expressive inputs. Furthermore, the current version offers limited direct control over specific speech attributes like emotion or speaking style.
- **Bilingual Model:** VoxCPM is trained primarily on Chinese and English data. Performance on other languages is not guaranteed and may result in unpredictable or low-quality audio.
- **Usage Restrictions:** This model is released for research and development purposes. Commercial use is allowed, but we do not recommend its use in production or commercial applications without rigorous testing and safety evaluations. Please use VoxCPM responsibly.


📄 License
*******************

VoxCPM is released under the `Apache License 2.0 <https://www.apache.org/licenses/LICENSE-2.0>`_.

🙏 Acknowledgments
*******************

We extend our sincere gratitude to the following works and resources for their inspiration and contributions:

- `DiTAR <https://arxiv.org/abs/2502.03930>`_ for the diffusion autoregressive backbone used in speech generation
- `MiniCPM-4 <https://github.com/OpenBMB/MiniCPM>`_ for serving as the language model foundation
- `CosyVoice <https://github.com/FunAudioLLM/CosyVoice>`_ for the implementation of Flow Matching-based LocDiT
- `DAC <https://github.com/descriptinc/descript-audio-codec>`_ for providing the Audio VAE backbone


🏠 Institutions
*****************

This project is developed by the following institutions:

.. image:: _static/modelbest_logo.png
   :target: https://modelbest.cn/
   :alt: ModelBest Logo
   :width: 56px

.. image:: _static/thuhcsi_logo.png
   :target: https://github.com/thuhcsi
   :alt: THUHCSI Logo
   :width: 56px

⭐ Star History
**********************
 
.. image:: https://api.star-history.com/svg?repos=OpenBMB/VoxCPM&type=Date
   :target: https://star-history.com/#OpenBMB/VoxCPM&Date
   :alt: Star History Chart


✒️ Citation
*****************

If you find our model helpful, please consider citing our projects 📝 and staring us ⭐️！

.. code-block:: bibtex

   @article{voxcpm2025,
      title        = {VoxCPM: Tokenizer-Free TTS for Context-Aware Speech Generation and True-to-Life Voice Cloning},
      author       = {Zhou, Yixuan and Zeng, Guoyang and Liu, Xin and Li, Xiang and Yu, Renjie and Wang, Ziyang and Ye, Runchuan and Sun, Weiyue and Gui, Jiancheng and Li, Kehan and Wu, Zhiyong  and Liu, Zhiyuan},
      journal      = {arXiv preprint arXiv:2509.24650},
      year         = {2025},
   }

What's Next?
********************

* Have a look at the :doc:`./quickstart` for a quick start.


.. toctree::
   :hidden:
   
   self
   quickstart
   chefsguide
   models

.. toctree::
   :maxdepth: 2
   :caption: Models
   :hidden:

   models/voxcpm1
   models/voxcpm1.5

.. toctree::
   :maxdepth: 2
   :caption: Fine Tuning
   :hidden:

   finetuning/finetune

.. toctree::
   :maxdepth: 2
   :caption: Deployment
   :hidden:

   deployment/nanovllm
