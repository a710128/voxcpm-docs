=============================
ComfyUI_RH_VoxCPM
=============================

ComfyUI_RH_VoxCPM is a community-maintained ComfyUI integration for VoxCPM with
native **VoxCPM 2** support, multi-speaker dialogue generation, optional LoRA
loading, automatic ASR for cloning workflows, and reference-audio denoising.

- Repo: `HM-RunningHub/ComfyUI_RH_VoxCPM <https://github.com/HM-RunningHub/ComfyUI_RH_VoxCPM>`_
- Try online: `RunningHub <https://www.runninghub.ai/?inviteCode=rh-v1367>`_

.. note::

   This project is maintained by the community, not by OpenBMB. For the other
   ComfyUI integrations in the ecosystem, see :doc:`comfyui_voxcpm` and
   :doc:`comfyui_voxcpmtts`.

.. list-table:: Supported VoxCPM Versions
   :widths: 30 70
   :header-rows: 0

   * - VoxCPM 2
     - ✅ Recommended. Full feature set including Ultimate Cloning and multi-speaker workflows.
   * - VoxCPM 1.5
     - ✅ Supported through the shared loader workflow.
   * - VoxCPM-0.5B
     - ✅ Supported as a lighter-weight option.

Overview
--------

The integration exposes three main nodes:

* **RunningHub VoxCPM Load Model** — load a local VoxCPM model directory from
  ``ComfyUI/models/voxcpm/`` with optional LoRA weights
* **RunningHub VoxCPM Generate Speech** — a single generation node covering
  Voice Design, Controllable Cloning, and Ultimate Cloning
* **RunningHub VoxCPM Multi-Speaker** — generate tagged multi-speaker dialogue
  for up to five speakers with per-speaker voice control

Compared with other ComfyUI ecosystem options, this project is currently the
most feature-complete visual workflow for VoxCPM 2 in the docs set: it combines
native V2 support, multi-speaker generation, optional LoRA loading, auto-ASR,
and ZipEnhancer-based denoising in one package.

Features
--------

* **Voice Design** from a text-only control instruction
* **Controllable Cloning** from reference audio with optional style guidance
* **Ultimate Cloning** for prompt continuation / maximum fidelity (**VoxCPM 2 only**)
* **LoRA loading** from ``ComfyUI/models/voxcpm/loras/``
* **Automatic ASR** via FunASR SenseVoiceSmall when ``reference_audio_text`` is empty in Ultimate Cloning
* **Reference denoising** via ZipEnhancer before cloning
* **Multi-speaker dialogue** from tagged scripts such as ``[spk1]... [spk2]...``
* **Example workflows** included in the repository for both single-speaker and multi-speaker generation

Prerequisites
-------------

* `ComfyUI <https://github.com/comfyanonymous/ComfyUI>`_ installed and running
* VoxCPM model files placed under ``ComfyUI/models/voxcpm/``
* SenseVoiceSmall available under ``ComfyUI/models/SenseVoice/SenseVoiceSmall/`` if you want automatic transcription
* ZipEnhancer available under ``ComfyUI/models/voxcpm/speech_zipenhancer_ans_multiloss_16k_base/`` if you want reference denoising

Installation
------------

Via ComfyUI Manager:

* Search for ``ComfyUI_RH_VoxCPM`` and install it

Manual installation:

.. code-block:: bash

   cd ComfyUI/custom_nodes
   git clone https://github.com/HM-RunningHub/ComfyUI_RH_VoxCPM.git
   cd ComfyUI_RH_VoxCPM
   pip install -r requirements.txt

Model layout
------------

The README documents the following layout:

.. code-block:: text

   ComfyUI/
   └── models/
       └── voxcpm/
           ├── VoxCPM2/
           ├── VoxCPM1.5/
           ├── VoxCPM-0.5B/
           ├── loras/
           └── speech_zipenhancer_ans_multiloss_16k_base/

SenseVoiceSmall should be placed under:

.. code-block:: text

   ComfyUI/models/SenseVoice/SenseVoiceSmall/

Basic usage
-----------

Single-speaker generation
^^^^^^^^^^^^^^^^^^^^^^^^^

1. Add **RunningHub VoxCPM Load Model** and choose your model directory.
2. Optionally enable ``optimize`` in the loader node. The repository defaults it
   to ``False``, which is a reasonable starting point for compatibility.
3. Connect the output to **RunningHub VoxCPM Generate Speech**.
4. Use one of the following modes:

   * **Voice Design**: set ``control_instruction`` and leave ``reference_audio`` empty
   * **Controllable Cloning**: provide ``reference_audio`` and keep ``ultimate_clone`` off
   * **Ultimate Cloning**: provide ``reference_audio`` and turn ``ultimate_clone`` on

5. Connect the resulting ``AUDIO`` output to a preview or save node.

Auto ASR and denoising
^^^^^^^^^^^^^^^^^^^^^^

* In Ultimate Cloning mode, if ``reference_audio_text`` is empty, the node can
  auto-transcribe the reference through SenseVoiceSmall.
* If ``denoise_reference`` is enabled, the node uses ZipEnhancer before
  generation.

Multi-speaker workflow
^^^^^^^^^^^^^^^^^^^^^^

The **RunningHub VoxCPM Multi-Speaker** node accepts tagged scripts such as:

.. code-block:: text

   [spk1]Hello there.[spk2]Hi, welcome to VoxCPM.[spk1]Let's begin.

You can provide up to five speakers with separate:

* reference audio inputs (``audio_1`` to ``audio_5``)
* per-speaker control instructions (``control_1`` to ``control_5``)

This is useful for dialogue demos, podcast-style content, or character-based
audio generation inside ComfyUI.

Example workflows
-----------------

The repository currently ships at least two workflow examples:

* a basic VoxCPM 2 workflow for single-speaker generation
* a VoxCPM 2 multi-speaker workflow for tagged dialogue generation

These example JSON files can be imported directly into ComfyUI.

When to choose this integration
-------------------------------

Choose **ComfyUI_RH_VoxCPM** when you want:

* visual VoxCPM 2 workflows inside ComfyUI
* multi-speaker dialogue generation
* built-in auto-ASR for cloning
* optional LoRA loading without leaving the ComfyUI workflow

If you specifically want in-node LoRA **training**, see :doc:`comfyui_voxcpm`.
If you prefer a lighter VoxCPM 1.5-focused setup with auto-transcription, see
:doc:`comfyui_voxcpmtts`.
