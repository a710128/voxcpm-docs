.. VoxCPM documentation master file

VoxCPM documentation
====================================================

.. container:: voxcpm-hero

   .. figure:: _static/voxcpm_logo.png
      :alt: VoxCPM
      :figclass: only-light voxcpm-logo-figure
      :class: no-scaled-link

   .. figure:: _static/voxcpm_logo_dark.png
      :alt: VoxCPM
      :figclass: only-dark voxcpm-logo-figure
      :class: no-scaled-link

   A realistic voice synthesis toolkit that brings authentic, expressive voices to your applications — powered by continuous-space diffusion autoregressive modeling.

   .. container:: voxcpm-badges

      .. image:: https://img.shields.io/badge/Project%20Page-GitHub-blue
         :target: https://github.com/OpenBMB/VoxCPM/
         :alt: Project Page

      .. image:: https://img.shields.io/badge/Technical%20Report-Arxiv-red
         :target: https://arxiv.org/abs/2509.24650
         :alt: Technical Report

      .. image:: https://img.shields.io/badge/Live%20PlayGround-Demo-orange
         :target: https://huggingface.co/spaces/OpenBMB/VoxCPM-Demo
         :alt: Live Playground

   .. container:: voxcpm-cta-row

      .. button-ref:: quickstart
         :ref-type: doc
         :color: primary
         :class: sd-rounded-pill

         Get Started

      .. button-link:: https://github.com/OpenBMB/VoxCPM/
         :color: secondary
         :outline:
         :class: sd-rounded-pill

         View on GitHub

----

🌟 Key Features
******************

.. grid:: 1 1 3 3
   :gutter: 4

   .. grid-item-card::
      :class-card: voxcpm-feature-card
      :padding: 4

      .. rst-class:: voxcpm-feature-icon

      🎯

      **Context-Aware Generation**
      ^^^

      Comprehends text to infer and generate appropriate prosody, delivering speech with remarkable expressiveness. Trained on a massive **2.36 million-hour** multilingual corpus covering 30 languages.

   .. grid-item-card::
      :class-card: voxcpm-feature-card
      :padding: 4

      .. rst-class:: voxcpm-feature-icon

      🎭

      **True-to-Life Voice Cloning**
      ^^^

      With only a short reference audio clip, performs accurate **zero-shot voice cloning** — capturing timbre, accent, emotional tone, rhythm, and pacing.

   .. grid-item-card::
      :class-card: voxcpm-feature-card
      :padding: 4

      .. rst-class:: voxcpm-feature-icon

      ⚡

      **High-Efficiency Synthesis**
      ^^^

      Streaming synthesis with RTF as low as **0.17** on a consumer-grade NVIDIA RTX 4090 GPU, enabling real-time applications.

----

.. _model-versions:

📚 Model Versions
*******************

.. grid:: 1 1 3 3
   :gutter: 4

   .. grid-item-card:: VoxCPM 2
      :class-card: voxcpm-model-card voxcpm-model-featured
      :class-title: sd-fs-4

      * 30-Language Multilingual
      * Voice Design & Style Control
      * Native 48kHz Audio

      +++

      .. button-ref:: models/voxcpm2
         :ref-type: doc
         :color: primary

         Try Now →

   .. grid-item-card:: VoxCPM 1.5
      :class-card: voxcpm-model-card
      :class-title: sd-fs-4

      * Faster Inference
      * Higher Quality (44.1kHz)

      +++

      .. button-ref:: models/voxcpm1.5
         :ref-type: doc
         :color: primary
         :outline:

         Try Now →

   .. grid-item-card:: VoxCPM 1.0
      :class-card: voxcpm-model-card
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
   * - `VoxCPM.cpp <https://github.com/bluryar/VoxCPM.cpp>`_
     - C++ inference engine based on ggml with GGUF quantization, supporting CPU/CUDA/Vulkan.
   * - `VoxCPM-RKNN2 <https://huggingface.co/happyme531/VoxCPM-0.5B-RKNN2>`_
     - Rockchip RK3588 NPU deployment for edge devices.
   * - `voxcpm_rs <https://github.com/madushan1000/voxcpm_rs>`_
     - Rust reimplementation of VoxCPM-0.5B using the burn framework.

.. tip::

   **Have you built something cool with VoxCPM?** We'd love to feature it here! Please open an issue or pull request to add your project.

.. note::

   The community projects listed above are not officially maintained by OpenBMB.

----

⚠️ Risks and Limitations
***************************

- **General Model Behavior:** While VoxCPM has been trained on a large-scale dataset, it may still produce outputs that are unexpected, biased, or contain artifacts.
- **Potential for Misuse of Voice Cloning:** VoxCPM's powerful zero-shot voice cloning capability can generate highly realistic synthetic speech. This technology could be misused for creating convincing deepfakes for purposes of impersonation, fraud, or spreading disinformation. Users of this model must not use it to create content that infringes upon the rights of individuals. It is strictly forbidden to use VoxCPM for any illegal or unethical purposes. We strongly recommend that any publicly shared content generated with this model be clearly marked as AI-generated.
- **Current Technical Limitations:** Although generally stable, the model may occasionally exhibit instability, especially with very long or expressive inputs. VoxCPM 2 introduces Voice Design and Style Control for more direct attribute control, though results may vary.
- **Language Coverage:** VoxCPM 1.x is trained primarily on Chinese and English data. VoxCPM 2 extends support to 30 languages, though performance may vary across languages depending on training data availability.
- **Usage Restrictions:** This model is released for research and development purposes. Commercial use is allowed, but we do not recommend its use in production or commercial applications without rigorous testing and safety evaluations. Please use VoxCPM responsibly.

----

.. rst-class:: voxcpm-footer-section

📄 License
*******************

VoxCPM is released under the `Apache License 2.0 <https://www.apache.org/licenses/LICENSE-2.0>`_.

.. rst-class:: voxcpm-footer-section

🙏 Acknowledgments
*******************

We extend our sincere gratitude to the following works and resources for their inspiration and contributions:

- `DiTAR <https://arxiv.org/abs/2502.03930>`_ for the diffusion autoregressive backbone used in speech generation
- `MiniCPM-4 <https://github.com/OpenBMB/MiniCPM>`_ for serving as the language model foundation
- `CosyVoice <https://github.com/FunAudioLLM/CosyVoice>`_ for the implementation of Flow Matching-based LocDiT
- `DAC <https://github.com/descriptinc/descript-audio-codec>`_ for providing the Audio VAE backbone

.. rst-class:: voxcpm-footer-section

🏠 Institutions
*****************

This project is developed by the following institutions:

.. container:: voxcpm-institutions

   .. image:: _static/modelbest_logo.png
      :target: https://modelbest.cn/
      :alt: ModelBest Logo
      :width: 56px

   .. image:: _static/thuhcsi_logo.png
      :target: https://github.com/thuhcsi
      :alt: THUHCSI Logo
      :width: 56px

.. rst-class:: voxcpm-footer-section

⭐ Star History
**********************

.. image:: https://api.star-history.com/svg?repos=OpenBMB/VoxCPM&type=Date
   :target: https://star-history.com/#OpenBMB/VoxCPM&Date
   :alt: Star History Chart

.. rst-class:: voxcpm-footer-section

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


.. toctree::
   :hidden:

   self
   models

.. toctree::
   :maxdepth: 2
   :caption: Getting Started
   :hidden:

   quickstart
   chefsguide

.. toctree::
   :maxdepth: 2
   :caption: Models
   :hidden:

   models/voxcpm2
   models/voxcpm1.5
   models/voxcpm1

.. toctree::
   :maxdepth: 2
   :caption: Guides
   :hidden:

   finetuning/finetune
   faq

.. toctree::
   :maxdepth: 2
   :caption: Community & Deployment
   :hidden:

   deployment/nanovllm
   deployment/voxcpm_cpp
   deployment/onnx
   deployment/ane
   deployment/rknn
   deployment/voxcpm_rs
   integrations/comfyui_voxcpm
   integrations/comfyui_voxcpmtts
   integrations/tts_webui
