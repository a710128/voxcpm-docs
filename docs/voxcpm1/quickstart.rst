🚀 Quick Start
=================

1. Requirements
********************

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
      - ~2GB for model weights

2. Installation
********************

VoxCPM is available on PyPI, you can install it using the following command:

.. code-block:: sh

    pip install voxcpm

or install from source:

.. code-block:: sh

    git clone https://github.com/OpenBMB/VoxCPM.git
    cd VoxCPM
    pip install -e .


3. Model Download (Optional)
*******************************

The model weights will be downloaded automatically when you first run VoxCPM, or you can download them manually using the following command:

.. code-block:: sh

    hf download openbmb/VoxCPM-0.5B
    modelscope download iic/speech_zipenhancer_ans_multiloss_16k_base # for speech prompt enhancement (optional)
    modelscope download iic/SenseVoiceSmall # for web demo (optional)



4. Basic Usage
********************

There are multiple ways to use VoxCPM, you can choose the one that suits you best.

4.1 Code API
^^^^^^^^^^^^^^^^^^^^

VoxCPM provides a flexible code API for both streaming and non-streaming generation. Before using the code API, you need to initialize the model first:

.. code-block:: python

    from voxcpm import VoxCPM
    model = VoxCPM.from_pretrained(
        "openbmb/VoxCPM-0.5B", # can be a local path or huggingface model id
        load_denoiser=True, # load the denoiser model, default is True, if you don't need it, set it to False. Denoiser is used to enhance the speech prompt.
        zipenhancer_model_id="iic/speech_zipenhancer_ans_multiloss_16k_base", # optional: model id for denoiser on modelscope, this is only used when load_denoiser is True.
        cache_dir=None, # Custom cache directory for the snapshot.
        local_files_only=False, # If True, only use local files and do not attempt to download.
    )

This will load the model weights from the checkpoint file and initialize the model. When the first time you run this code, it will download the model weights from the huggingface model hub.
If you have problem with internet connection, you can use a huggingface mirror to download the model weights. (e.g. https://hf-mirror.com)

The model weights would take about 2GB of disk space. After the model is loaded, you can use it to generate speech using the following code:

**Non-streaming**

.. code-block:: python

    import soundfile as sf
    import numpy as np

    # Non-streaming
    wav = model.generate(
        text="VoxCPM is an innovative end-to-end TTS model from ModelBest, designed to generate highly expressive speech.",
        prompt_wav_path=None,      # optional: path to a prompt speech for voice cloning
        prompt_text=None,          # optional: reference text
        cfg_value=2.0,             # LM guidance on LocDiT, higher for better adherence to the prompt, but maybe worse
        inference_timesteps=10,   # LocDiT inference timesteps, higher for better result, lower for fast speed
        normalize=True,           # enable external TN tool
        denoise=True,             # enable external Denoise tool
        retry_badcase=True,        # enable retrying mode for some bad cases (unstoppable)
        retry_badcase_max_times=3,  # maximum retrying times
        retry_badcase_ratio_threshold=6.0, # maximum length restriction for bad case detection (simple but effective), it could be adjusted for slow pace speech
    )
    sf.write("output.wav", wav, 16000)
    print("saved: output.wav")

**Streaming**

.. code-block:: python

    chunks = []
    for chunk in model.generate_streaming(
        text = "Streaming text to speech is easy with VoxCPM!",
        # supports same args as above
    ):
        chunks.append(chunk) # chunk is a numpy array of numpy.float32 of audio waveform, you can play it immediately in real-time.
    wav = np.concatenate(chunks)

    sf.write("output_streaming.wav", wav, 16000)
    print("saved: output_streaming.wav")

4.2 CLI Usage
^^^^^^^^^^^^^^^^^^^^

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

    # (Optinal) Voice cloning (reference audio + transcript file)
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
    --hf-model-id openbmb/VoxCPM-0.5B --cache-dir ~/.cache/huggingface --local-files-only

    # 6) Denoiser control
    voxcpm --text "..." --output out.wav \
    --no-denoiser --zipenhancer-path iic/speech_zipenhancer_ans_multiloss_16k_base

    # 7) Help
    voxcpm --help
    python -m voxcpm.cli --help

4.3 Web Demo
^^^^^^^^^^^^^^^^^^^^

You can start the UI interface by running `python app.py`, which allows you to perform Voice Cloning and Voice Creation.

.. code-block:: sh

    python app.py

The web demo requires an additional model: SenseVoice-Small to perform speech prompt ASR. When the first time you run this command, it will download the model weights from the modelscope model hub.


What's Next?
********************

Have a look at the :doc:`./chefsguide` for more advanced usage.