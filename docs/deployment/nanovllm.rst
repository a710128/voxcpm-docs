========================
Nano-vLLM
========================

Nano-vLLM-VoxCPM is an inference engine for VoxCPM based on Nano-vLLM.

- Repo: `a710128/nanovllm-voxcpm <https://github.com/a710128/nanovllm-voxcpm>`_


It provides a Python API (sync + async streaming) and an optional FastAPI demo server.

.. note::
    This runtime is GPU-centric (CUDA + Triton + FlashAttention) and does not support CPU-only execution.

Features
--------

* High throughput on CUDA devices (RTX 4090, H100, A100, etc.)
* Concurrent requests via an internal scheduler
* Streaming inference (yield waveform chunks)
* Optional HTTP demo server (FastAPI)
* Multi-GPU request-level parallelism via a server pool (one process per GPU)

Prerequisites
-------------

* Linux + NVIDIA GPU (CUDA)
* Python >= 3.10, < 3.13
* A local VoxCPM checkpoint directory

Model directory layout
^^^^^^^^^^^^^^^^^^^^^^

Nano-vLLM-VoxCPM loads weights from ``*.safetensors`` files.
Your model directory should contain at least:

.. code-block:: text

    /path/to/model_dir/
    ├── config.json
    ├── audiovae.pth
    └── *.safetensors

If your checkpoint only ships weights as ``.pt`` / ``pytorch_model.bin``, convert it to safetensors first.

Installation
------------

Nano-vLLM-VoxCPM is not published on PyPI yet; install from source.

.. code-block:: bash

    git clone https://github.com/a710128/nanovllm-voxcpm.git
    cd nanovllm-voxcpm

    # Recommended: use uv + lockfile
    uv sync --frozen

Basic usage (Python)
--------------------

The main entrypoint is ``nanovllm_voxcpm.VoxCPM.from_pretrained(...)``.

Generate (async streaming)
^^^^^^^^^^^^^^^^^^^^^^^^^^

If called inside an async event loop, ``from_pretrained`` returns an async server pool.

.. code-block:: python

    import asyncio
    import numpy as np

    from nanovllm_voxcpm import VoxCPM


    async def main() -> None:
        server = VoxCPM.from_pretrained(
            model="/path/to/model_dir",
            devices=[0],
            max_num_batched_tokens=8192,
            max_num_seqs=16,
            gpu_memory_utilization=0.95,
        )
        await server.wait_for_ready()

        chunks: list[np.ndarray] = []
        async for chunk in server.generate(target_text="Hello world"):
            chunks.append(chunk)  # float32 numpy array

        wav = np.concatenate(chunks, axis=0)
        await server.stop()


    if __name__ == "__main__":
        asyncio.run(main())

Generate (sync)
^^^^^^^^^^^^^^^

If called outside an event loop, ``from_pretrained`` returns a synchronous server pool.

.. code-block:: python

    import numpy as np

    from nanovllm_voxcpm import VoxCPM


    server = VoxCPM.from_pretrained(model="/path/to/model_dir", devices=[0])
    chunks = [chunk for chunk in server.generate(target_text="Hello world")]
    wav = np.concatenate(chunks, axis=0)
    server.stop()

FastAPI demo (HTTP)
-------------------

The repo includes a minimal FastAPI wrapper in ``fastapi/``.

.. warning::
    The FastAPI demo is not production-ready (no auth, no persistence). Do not expose it to untrusted networks.

Install demo extras
^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

    uv pip install -r fastapi/requirements.txt

Configure model path
^^^^^^^^^^^^^^^^^^^^

Edit ``fastapi/app.py`` and set ``MODEL_PATH`` to your local checkpoint directory.

Start server
^^^^^^^^^^^^

.. code-block:: bash

    uv run fastapi run fastapi/app.py --host 0.0.0.0 --port 8000

Then open:

* ``http://localhost:8000/docs``

The ``/generate`` endpoint streams raw audio bytes:

* Content-Type: ``audio/raw``
* Payload: little-endian ``float32`` PCM (mono)
* Audio format is described in response headers (sample rate, dtype, channels)

Troubleshooting
---------------

Missing parameters / weights not found
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If you see errors like:

.. code-block:: text

    ValueError: Missing parameters: ['base_lm.embed_tokens.weight', ...]

Your model directory likely does not contain ``*.safetensors`` weights (some VoxCPM releases ship ``.pt`` files).
Use a safetensors-converted checkpoint and ensure the ``*.safetensors`` files live next to ``config.json``.

Slow startup
^^^^^^^^^^^^

The first startup can be slow due to model loading and GPU memory allocation. This is expected.
