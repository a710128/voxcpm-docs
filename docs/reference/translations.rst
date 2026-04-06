:orphan:

Translations
============

This page documents how VoxCPM docs manage translations in the same repository.
The English pages under ``docs/`` remain the source of truth. Chinese content is
maintained through Sphinx gettext catalogs under ``docs/locale/zh_CN/LC_MESSAGES/``.

Overview
********

The translation workflow uses:

- Sphinx gettext catalogs generated from the English source pages
- ``sphinx-intl`` to create and update ``.po`` files
- a Chinese build driven by ``DOCS_LANGUAGE=zh_CN``

This avoids maintaining a separate ``docs/zh/`` tree and keeps page structure
aligned with the English site.

Local Commands
**************

Run these commands from the repository root:

.. code-block:: bash

   make docs-gettext
   make docs-i18n-init
   make docs-i18n-update
   make docs-zh
   make docs-zh-strict

Command reference:

.. list-table::
   :widths: 28 72
   :header-rows: 1

   * - Command
     - Purpose
   * - ``make docs-gettext``
     - Generate gettext ``.pot`` catalogs under ``docs/_build/gettext/``
   * - ``make docs-i18n-init``
     - Initialize or update ``zh_CN`` translation files in ``docs/locale/``
   * - ``make docs-i18n-update``
     - Refresh existing ``zh_CN`` translation files after English source changes
   * - ``make docs-zh``
     - Build the Chinese HTML site into ``docs/_build/html/zh_CN/``
   * - ``make docs-zh-strict``
     - Build the Chinese HTML site with warnings treated as errors

Translation Workflow
********************

When the English documentation changes:

1. Edit the English source files under ``docs/``.
2. Regenerate gettext catalogs:

   .. code-block:: bash

      make docs-gettext

3. Update the Chinese translation files:

   .. code-block:: bash

      make docs-i18n-update

4. Translate the new or modified strings in ``docs/locale/zh_CN/LC_MESSAGES/*.po``.
5. Build the Chinese site locally:

   .. code-block:: bash

      make docs-zh

6. If you need stricter validation, run:

   .. code-block:: bash

      make docs-zh-strict

.. note::

   ``gettext_uuid = True`` is enabled in ``docs/conf.py`` to reduce churn in
   ``.po`` files when source paragraphs are moved around.

Read the Docs Setup
*******************

Use two Read the Docs projects that point to the same repository:

1. **English parent project**

   - Keep the existing English project as the parent project.
   - Set its language to ``English`` in the RTD project settings.

2. **Chinese translation project**

   - Create a second RTD project from the same repository.
   - Set its language to ``Chinese (Simplified)``.
   - Attach it to the English project under ``Translations``.

With this setup, Read the Docs will expose both languages under the same site
and provide the language switcher automatically.

How language selection works
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``docs/conf.py`` resolves the build language from ``DOCS_LANGUAGE`` first and
falls back to ``READTHEDOCS_LANGUAGE``. This keeps local builds and RTD builds
on the same configuration path:

- local Chinese build: ``DOCS_LANGUAGE=zh_CN``
- RTD Chinese project: ``READTHEDOCS_LANGUAGE=zh-cn`` (provided by RTD)

Scope of the first Chinese rollout
**********************************

The current setup scaffolds ``.po`` files for all pages already linked from the
site navigation, including:

- ``index``, ``quickstart``, ``installation``, ``usage_guide``, ``cookbook``, ``faq``
- all pages under ``models/``
- all pages under ``finetuning/``
- all pages under ``reference/``
- all pages under ``deployment/`` and ``integrations/``

This means the infrastructure is ready for a phased translation rollout without
changing the site structure again later.
