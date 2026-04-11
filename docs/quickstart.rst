Quick Start
===========

This page gets you from zero to a working VoxCPM setup as fast as possible. Follow it top to bottom and you will have generated audio through three different paths: the Python API, the CLI, and the web demo.

Install
*******

.. code-block:: sh

    pip install voxcpm

That's it. For other installation methods (pip, source checkout, etc.), see :doc:`./installation`.

Step 1: Python API
******************

Start with the current recommended release, ``VoxCPM 2``:

.. code-block:: python

    from voxcpm import VoxCPM
    import soundfile as sf

    model = VoxCPM.from_pretrained(
        "openbmb/VoxCPM2",
        load_denoiser=False,
    )

    wav = model.generate(
        text="VoxCPM 2 is the current recommended release for realistic multilingual speech synthesis.",
        cfg_value=2.0,
        inference_timesteps=10,
    )
    sf.write("demo.wav", wav, model.tts_model.sample_rate)
    print("saved: demo.wav")

The first run downloads model weights automatically. If you have trouble accessing Hugging Face, see the mirror setup in :doc:`./installation`.

This example does not enable the optional denoiser — it is only needed when you want to enhance prompt or reference audio for voice cloning. See :doc:`./usage_guide` for details.

If this script runs and produces ``demo.wav``, your installation is working.

.. tip::

   Runtime device selection is automatic by default. ``VoxCPM.from_pretrained(..., device="auto")``
   prefers ``cuda -> mps -> cpu``. You can also force a device explicitly with
   ``device="cpu"``, ``device="mps"``, ``device="cuda"``, or ``device="cuda:0"``.
   If you hit platform-specific ``torch.compile`` issues, try ``optimize=False``.

.. note::

   For new projects, start with :doc:`./models/voxcpm2`, which is the current version. Earlier releases remain available from :doc:`./models/version_history` when you need an older checkpoint.

Step 2: CLI
***********

VoxCPM also provides a command-line interface. The CLI defaults to ``openbmb/VoxCPM2``, so you can use the recommended subcommands directly unless you want to override the checkpoint with ``--hf-model-id``:

.. code-block:: sh

    # Direct synthesis
    voxcpm design \
        --text "Hello from VoxCPM!" \
        --output out.wav

    # Reference-only cloning (VoxCPM 2)
    voxcpm clone \
        --text "This is a cloned voice sample." \
        --reference-audio path/to/voice.wav \
        --output out.wav \
        --denoise

    # Force CPU or MPS explicitly when needed
    voxcpm design --text "Hello from VoxCPM!" --device cpu --output out.wav
    voxcpm design --text "Hello from VoxCPM!" --device mps --no-optimize --output out.wav

    # Help
    voxcpm --help

Step 3: Web Demo
****************

The web demo requires a source checkout. If you installed via ``pip install voxcpm`` in the step above, you still need to clone the repository:

.. code-block:: sh

    git clone https://github.com/OpenBMB/VoxCPM.git
    cd VoxCPM
    pip install -e .
    python app.py

The web demo also downloads an additional ASR model (SenseVoice-Small) on first use for prompt audio transcription.

What's Next?
************

* Continue with :doc:`./usage_guide` for prompt strategy, voice cloning tips, and quality tuning.
* Check the pages under ``Models`` in the sidebar for version-specific features and migration notes.
* Fine-tune the model with :doc:`./finetuning/finetune` to adapt it to your use case.
* Deploy the model with :doc:`./deployment/nanovllm_voxcpm` for high-throughput serving.
