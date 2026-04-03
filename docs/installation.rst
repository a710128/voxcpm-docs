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
      - 12.0 or higher
    * - Python
      - 3.10 or higher
    * - Disk Space
      - Several GBs for model weights, depending on the checkpoint you use

Install with uv (recommended)
*****************************

`uv <https://docs.astral.sh/uv/>`_ is the recommended way to install VoxCPM. It is fast and handles dependency resolution well.

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

Install with pip
****************

From PyPI:

.. code-block:: sh

    pip install voxcpm

From source:

.. code-block:: sh

    git clone https://github.com/OpenBMB/VoxCPM.git
    cd VoxCPM
    pip install -e .

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
