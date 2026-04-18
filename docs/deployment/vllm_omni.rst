=========
vLLM-Omni
=========

vLLM-Omni is the official omni-modal serving stack from the vLLM project with native
support for VoxCPM2.

- Repo: `vllm-project/vllm-omni <https://github.com/vllm-project/vllm-omni>`_
- VoxCPM2 example: `online_serving/voxcpm2 <https://github.com/vllm-project/vllm-omni/tree/main/examples/online_serving/voxcpm2>`_
- Installation guide: `vLLM-Omni docs <https://vllm-omni.readthedocs.io/en/latest/getting_started/installation/>`_

This is the recommended path for production deployments that need concurrent requests,
continuous batching, or multi-tenant GPU serving.

Features
--------

* Native VoxCPM2 serving on the upstream vLLM scheduler
* Continuous batching for concurrent inference workloads
* PagedAttention KV cache management
* OpenAI-compatible ``/v1/audio/speech`` endpoint
* Streaming chunk delivery and multi-GPU deployment support

Prerequisites
-------------

* Linux + GPU environment supported by vLLM-Omni
* Python environment with ``uv`` available
* Access to the ``openbmb/VoxCPM2`` model weights

Installation
------------

Install from source. The upstream project is evolving quickly, so prefer the latest
main branch unless you have a pinned deployment environment:

.. code-block:: bash

    uv pip install vllm==0.19.0 --torch-backend=auto
    git clone https://github.com/vllm-project/vllm-omni.git
    cd vllm-omni
    uv pip install -e .

See the upstream installation guide for other platforms such as ROCm, XPU, MUSA, NPU,
and Docker-based setups.

Serving VoxCPM2
---------------

Start an OpenAI-compatible TTS server:

.. code-block:: bash

    vllm serve openbmb/VoxCPM2 --omni --port 8000

Generate speech from any OpenAI-compatible client:

.. code-block:: bash

    curl http://localhost:8000/v1/audio/speech \
      -H "Content-Type: application/json" \
      -d '{"model":"openbmb/VoxCPM2","input":"Hello from VoxCPM2 on vLLM-Omni!","voice":"default"}' \
      --output out.wav

Notes
-----

.. note::

   If your workload requires high concurrency, this serving architecture is a better fit
   than running multiple independent ``torch.compile``-optimized VoxCPM processes on the
   same GPU.

.. tip::

   For a lighter Python-native serving stack with sync and async APIs, see
   :doc:`NanoVLLM-VoxCPM <nanovllm_voxcpm>`.
