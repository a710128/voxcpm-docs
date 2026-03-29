Quick Start
===========

Requirements
************

To use VoxCPM, you need to have the following dependencies:

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
      - several GBs for model weights (depends on the model you want to use)

Installation
************

VoxCPM is available on PyPI, you can install it using the following command:

.. code-block:: sh

    pip install voxcpm

or install from source:

.. code-block:: sh

    git clone https://github.com/OpenBMB/VoxCPM.git
    cd VoxCPM
    pip install -e .


Download Models (Optional)
**************************

The model weights will be downloaded automatically when you first run VoxCPM, or you can download them manually using the following command:

.. code-block:: sh

    hf download openbmb/VoxCPM1.5 # or other models you want to use
    modelscope download iic/speech_zipenhancer_ans_multiloss_16k_base # for speech prompt enhancement (optional)
    modelscope download iic/SenseVoiceSmall # for web demo (optional)



Run Your First Generation
*************************

There are multiple ways to use VoxCPM, you can choose the one that suits you best.

Python API
^^^^^^^^^^

VoxCPM provides a flexible Python API for both streaming and non-streaming generation. Start by loading a checkpoint:

.. code-block:: python

    from voxcpm import VoxCPM
    model = VoxCPM.from_pretrained(
        "openbmb/VoxCPM1.5",
        load_denoiser=True,
        zipenhancer_model_id="iic/speech_zipenhancer_ans_multiloss_16k_base",
        cache_dir=None,
        local_files_only=False,
    )

The first run downloads model weights automatically. If you have trouble accessing Hugging Face directly, you can use a mirror such as ``https://hf-mirror.com``.

After the model is loaded, you can generate speech:

**Non-streaming**

.. code-block:: python

    import soundfile as sf
    import numpy as np

    wav = model.generate(
        text="VoxCPM is an innovative end-to-end TTS model from ModelBest, designed to generate highly expressive speech.",
        prompt_wav_path=None,
        prompt_text=None,
        cfg_value=2.0,
        inference_timesteps=10,
        normalize=True,
        denoise=True,
        retry_badcase=True,
        retry_badcase_max_times=3,
        retry_badcase_ratio_threshold=6.0,
    )
    sf.write("output.wav", wav, model.tts_model.sample_rate)
    print("saved: output.wav")

**Streaming**

.. code-block:: python

    chunks = []
    for chunk in model.generate_streaming(
        text="Streaming text to speech is easy with VoxCPM!",
    ):
        chunks.append(chunk)
    wav = np.concatenate(chunks)

    sf.write("output_streaming.wav", wav, model.tts_model.sample_rate)
    print("saved: output_streaming.wav")

.. note::

   If you want multilingual generation, Voice Design, or Style Control, choose :doc:`./models/voxcpm2` instead of a 1.x checkpoint.

CLI
^^^

VoxCPM also provides a CLI interface for generating speech from text. You can use the following command to generate speech from text:

.. code-block:: sh

    # 1) Direct synthesis (single text)
    voxcpm --text "VoxCPM is an innovative end-to-end TTS model from ModelBest, designed to generate highly expressive speech." --output out.wav

    # 2) Voice cloning (reference audio + transcript)
    voxcpm --text "VoxCPM is an innovative end-to-end TTS model from ModelBest, designed to generate highly expressive speech." \
    --prompt-audio path/to/voice.wav \
    --prompt-text "reference transcript" \
    --output out.wav \
    --denoise

    # (Optional) Voice cloning (reference audio + transcript file)
    voxcpm --text "VoxCPM is an innovative end-to-end TTS model from ModelBest, designed to generate highly expressive speech." \
    --prompt-audio path/to/voice.wav \
    --prompt-file "/path/to/text-file" \
    --output out.wav \
    --denoise

    # 3) Batch processing (one text per line)
    voxcpm --input examples/input.txt --output-dir outs
    # (optional) Batch + cloning
    voxcpm --input examples/input.txt --output-dir outs \
    --prompt-audio path/to/voice.wav \
    --prompt-text "reference transcript" \
    --denoise

    # 4) Inference parameters (quality/speed)
    voxcpm --text "..." --output out.wav \
    --cfg-value 2.0 --inference-timesteps 10 --normalize

    # 5) Model loading
    # Prefer local path
    voxcpm --text "..." --output out.wav --model-path /path/to/VoxCPM_model_dir
    # Or from Hugging Face (auto download/cache)
    voxcpm --text "..." --output out.wav \
    --hf-model-id openbmb/VoxCPM1.5 --cache-dir ~/.cache/huggingface --local-files-only

    # 6) Denoiser control
    voxcpm --text "..." --output out.wav \
    --no-denoiser --zipenhancer-path iic/speech_zipenhancer_ans_multiloss_16k_base

    # 7) Help
    voxcpm --help
    python -m voxcpm.cli --help

Local model directory layout
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

When you pass a local path (``VoxCPM.from_pretrained("/path/to/model_dir")`` or CLI ``--model-path``), the directory is expected to contain (at least) the following files:

.. code-block:: text

    /path/to/model_dir/
    ├── config.json
    ├── audiovae.pth
    ├── model.safetensors        # preferred
    ├── pytorch_model.bin        # optional fallback when safetensors is absent
    ├── tokenizer.json
    ├── tokenizer_config.json
    └── special_tokens_map.json

Web Demo
^^^^^^^^

You can start the UI interface by running `python app.py`, which allows you to perform Voice Cloning and Voice Creation.

.. code-block:: sh

    python app.py

The web demo requires an additional ASR model, SenseVoice-Small, for prompt audio transcription. It will be downloaded automatically on first use.


What's Next?
************

* Have a look at the :doc:`./chefsguide` for more advanced usage.
* Open the model pages in the sidebar if you need version-specific features, examples, or migration notes.
* Fine-tune the model in :doc:`./finetuning/finetune` to adapt it to your specific use case.
* Deploy the model in :doc:`./deployment/nanovllm` for production use.
