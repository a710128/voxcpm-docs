========================
TTS WebUI
========================

VoxCPM is integrated into `TTS WebUI <https://github.com/rsxdalv/tts-webui>`_ as an installable extension, providing a browser-based interface for text-to-speech.

- Extension Repo: `rsxdalv/tts_webui_extension.vox_cpm <https://github.com/rsxdalv/tts_webui_extension.vox_cpm>`_

.. note::
    This extension wraps the official ``voxcpm`` Python package. The extension README is a template stub — refer to the main VoxCPM and TTS WebUI documentation for detailed usage.

.. list-table:: Supported VoxCPM Versions
   :widths: 30 70
   :header-rows: 0

   * - VoxCPM 1.0 (0.5B)
     - ✅ Default (UI hardcoded to ``openbmb/VoxCPM-0.5B``)
   * - VoxCPM 1.5
     - ❌ Not in extension UI (would require modifying source)
   * - VoxCPM 2
     - ❌ Not supported

Features
--------

* Adds a **"Vox cpm"** tab to TTS WebUI
* Leverages the official ``voxcpm`` Python package for inference
* Simple installation as a TTS WebUI extension

Prerequisites
-------------

* `TTS WebUI <https://github.com/rsxdalv/tts-webui>`_ installed and running
* Python >= 3.7

Installation
------------

.. code-block:: bash

    pip install git+https://github.com/rsxdalv/tts_webui_extension.vox_cpm@main

Then restart TTS WebUI. The **Vox cpm** tab will appear in the interface.

Usage
-----

1. Open TTS WebUI in your browser
2. Navigate to the **Vox cpm** tab
3. Enter text and configure generation parameters
4. Click generate to synthesize speech

For development:

.. code-block:: bash

    cd tts_webui_extension/vox_cpm
    python main.py
