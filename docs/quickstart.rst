Quick Start
===========

This page is the shortest path from installation to a working local demo. If you follow it from top to bottom, you should end with a generated audio file and, optionally, the web demo running locally.

Requirements
************

To use VoxCPM, you need the following environment:

.. list-table::
    :widths: 25 75
    :header-rows: 1
    
    * - Dependency
      - Description
    * - PyTorch
      - 2.5.0 or higher
    * - CUDA
      - 12.0 or higher
    * - Python
      - 3.10 or higher
    * - Disk Space
      - Several GBs for model weights, depending on the checkpoint you use

Installation
************

VoxCPM is available on PyPI:

.. code-block:: sh

    pip install voxcpm

Or install from source:

.. code-block:: sh

    git clone https://github.com/OpenBMB/VoxCPM.git
    cd VoxCPM
    pip install -e .


Step 1: Generate Your First Audio File
**************************************

Start with the current recommended release, ``VoxCPM 2``:

.. code-block:: python

    from voxcpm import VoxCPM
    import soundfile as sf

    model = VoxCPM.from_pretrained(
        "openbmb/VoxCPM2",
        load_denoiser=True,
        zipenhancer_model_id="iic/speech_zipenhancer_ans_multiloss_16k_base",
        cache_dir=None,
        local_files_only=False,
    )

    wav = model.generate(
        text="VoxCPM 2 is the current recommended release for realistic multilingual speech synthesis.",
        cfg_value=2.0,
        inference_timesteps=10,
        normalize=True,
    )
    sf.write("demo.wav", wav, model.tts_model.sample_rate)
    print("saved: demo.wav")

The first run downloads model weights automatically. If you have trouble accessing Hugging Face directly, you can use a mirror such as ``https://hf-mirror.com``.

If this script runs successfully, you already have a working local installation.

.. note::

   For new projects, start with :doc:`./models/voxcpm2`, which is the current version. Earlier releases remain available under ``Earlier Releases`` when you need an older checkpoint.

Step 2: Launch the Web Demo
***************************

If you want a quick interactive demo after the Python example, run:

.. code-block:: sh

    python app.py

The web demo requires an additional ASR model, SenseVoice-Small, for prompt audio transcription. It will be downloaded automatically on first use.

At this point, you have verified two working paths:

- a local Python call that writes ``demo.wav``
- a local web demo started by ``python app.py``

Streaming Example
*****************

.. code-block:: python

    import numpy as np
    import soundfile as sf

    chunks = []
    for chunk in model.generate_streaming(
        text="Streaming text to speech is easy with VoxCPM!",
    ):
        chunks.append(chunk)
    wav = np.concatenate(chunks)

    sf.write("output_streaming.wav", wav, model.tts_model.sample_rate)
    print("saved: output_streaming.wav")

What This Page Does Not Cover
*****************************

To keep this page as a single runnable path, the following topics are documented elsewhere:

- CLI usage: see :doc:`./chefsguide`
- local model directory layout: see :doc:`./chefsguide`
- version-specific features and migration notes: see the pages under ``Current Version`` and ``Earlier Releases``
- deployment options: see :doc:`./deployment/nanovllm`


What's Next?
************

* Continue with :doc:`./chefsguide` for CLI usage, prompt strategy, cloning tips, and quality tuning.
* Open the ``Current Version`` or ``Earlier Releases`` pages in the sidebar if you need version-specific features, examples, or migration notes.
* Fine-tune the model in :doc:`./finetuning/finetune` to adapt it to your specific use case.
* Deploy the model in :doc:`./deployment/nanovllm` for production use.
