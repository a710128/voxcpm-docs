VoxCPM 1.0
===========

`Hugging Face <https://huggingface.co/openbmb/VoxCPM-0.5B>`_ | `ModelScope <https://modelscope.cn/models/OpenBMB/VoxCPM-0.5B>`_ | `Technical Report <https://arxiv.org/abs/2509.24650>`_ | `Audio Samples <https://openbmb.github.io/VoxCPM-demopage>`_

VoxCPM is a novel tokenizer-free Text-to-Speech (TTS) system that redefines realism in speech synthesis. By modeling speech in a continuous space, it overcomes the limitations of discrete tokenization and enables two flagship capabilities: context-aware speech generation and true-to-life zero-shot voice cloning.

Unlike mainstream approaches that convert speech to discrete tokens, VoxCPM uses an end-to-end diffusion autoregressive architecture that directly generates continuous speech representations from text. Built on MiniCPM-4 backbone, it achieves implicit semantic-acoustic decoupling through hierachical language modeling and FSQ constraints, greatly enhancing both expressiveness and generation stability.

Architecture
***************

.. figure:: /_static/voxcpm1/voxcpm_model.png
    :width: 100%
    :align: center
    :alt: VoxCPM 1.0 Architecture
    :class: no-scaled-link



.. toctree::
   :maxdepth: 1
   :hidden:

   quickstart
   chefsguide
   benchmark
