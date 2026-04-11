Installation
============

This page covers all supported installation methods for VoxCPM. If you just want the fastest path to get started, see :doc:`./quickstart`.

Requirements
************

.. list-table::
    :widths: 25 75
    :header-rows: 1

    * - Dependency
      - Description
    * - PyTorch
      - 2.5.0 or higher
    * - CUDA
      - Optional. 12.0 or higher for NVIDIA GPU acceleration
    * - Python
      - 3.10–3.12 recommended (3.10–3.11 most tested)
    * - Disk Space
      - Several GBs for model weights, depending on the checkpoint you use

.. note::

   CUDA is not required for CPU inference or Apple Silicon MPS usage. See :doc:`./faq` for Mac / MPS notes.

Runtime Device Selection
************************

VoxCPM supports automatic device selection and explicit device forcing in both
the Python API and the CLI.

Automatic selection

- ``device=None`` or ``device="auto"`` uses automatic fallback
- The fallback order is ``cuda -> mps -> cpu``
- The CLI uses the same behavior through ``--device auto``

Explicit selection

- ``device="cpu"`` forces CPU inference
- ``device="mps"`` forces Apple Silicon MPS
- ``device="cuda"`` or ``device="cuda:N"`` forces CUDA
- Explicit device requests do **not** auto-fallback; if the requested backend is
  unavailable, VoxCPM raises an error so the failure is visible

.. code-block:: python

   from voxcpm import VoxCPM

   model = VoxCPM.from_pretrained("openbmb/VoxCPM2", device="auto")
   cpu_model = VoxCPM.from_pretrained("openbmb/VoxCPM2", device="cpu", optimize=False)

.. code-block:: sh

   voxcpm design --text "Hello" --device auto --output out.wav
   voxcpm design --text "Hello" --device cpu --no-optimize --output out.wav

.. note::

   ``optimize=True`` enables ``torch.compile`` acceleration and is primarily
   useful on CUDA. On CPU, MPS, ROCm, or other non-standard environments, you
   may need ``optimize=False`` or CLI ``--no-optimize`` for compatibility.

Install with pip (recommended)
******************************

``pip`` is the default recommended way to install VoxCPM. It keeps setup simple and matches the most common Python workflow.

From PyPI:

.. code-block:: sh

    pip install voxcpm

From source:

.. code-block:: sh

    git clone https://github.com/OpenBMB/VoxCPM.git
    cd VoxCPM
    pip install -e .

Install with uv (secondary option)
**********************************

`uv <https://docs.astral.sh/uv/>`_ is a good secondary option if you prefer a managed environment and faster dependency resolution.

From PyPI:

.. code-block:: sh

    uv pip install voxcpm

From source (needed for running the web demo or local development):

.. code-block:: sh

    git clone https://github.com/OpenBMB/VoxCPM.git
    cd VoxCPM
    uv sync

.. tip::

   If you installed via ``uv sync``, run scripts with ``uv run`` to use the
   managed environment. For example: ``uv run python app.py``,
   ``uv run python scripts/train_voxcpm_finetune.py ...``.

The source installation is required if you want to:

- run the local web demo (``python app.py``)
- modify VoxCPM source code
- contribute to the project

Hugging Face mirror
*******************

If you have trouble accessing Hugging Face directly (common in some regions), set the mirror before running any script:

.. code-block:: sh

    export HF_ENDPOINT=https://hf-mirror.com

Model weights will then be downloaded through the mirror automatically.

Verify installation
*******************

After installing, run a quick check:

.. code-block:: sh

    python -c "from voxcpm import VoxCPM; print('VoxCPM is ready')"

If this prints without errors, your installation is working.
