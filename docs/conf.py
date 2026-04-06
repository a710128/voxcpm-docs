import os

# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html


def _resolve_docs_language() -> str:
    """Resolve the target docs language for local and RTD builds."""
    raw_language = os.environ.get("DOCS_LANGUAGE") or os.environ.get("READTHEDOCS_LANGUAGE") or "en"
    normalized = raw_language.replace("_", "-").lower()

    language_mapping = {
        "en": "en",
        "zh-cn": "zh_CN",
    }
    return language_mapping.get(normalized, raw_language)

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = "VoxCPM"
copyright = "2025, OpenBMB"
author = "OpenBMB"
release = "2.0"

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = ["myst_parser", "sphinx_copybutton", "sphinx_design"]

copybutton_prompt_text = r">>> |\.\.\. |\$ "
copybutton_prompt_is_regexp = True

source_suffix = [".rst", ".md"]
language = _resolve_docs_language()
locale_dirs = ["locale/"]
gettext_compact = False
gettext_uuid = True

templates_path = ["_templates"]
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store", "models.rst"]


# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = "furo"
html_static_path = ["_static"]
html_css_files = ["custom.css"]
