.PHONY: docs docs-clean docs-linkcheck docs-doctest docs-strict docs-gettext docs-i18n-init docs-i18n-update docs-zh docs-zh-strict

# Convenience targets for building Sphinx docs via uv.

I18N_LANG ?= zh_CN

docs:
	uv run -- make -C docs clean
	uv run -- make -C docs html

docs-clean:
	uv run -- make -C docs clean

docs-linkcheck:
	uv run -- make -C docs linkcheck

docs-doctest:
	uv run -- make -C docs doctest

docs-strict:
	uv run -- make -C docs clean
	uv run -- make -C docs html SPHINXOPTS='-W --keep-going'

docs-gettext:
	uv run -- sphinx-build -b gettext docs docs/_build/gettext

docs-i18n-init: docs-gettext
	uv run -- sphinx-intl update -p docs/_build/gettext -d docs/locale -l $(I18N_LANG)

docs-i18n-update: docs-gettext
	uv run -- sphinx-intl update -p docs/_build/gettext -d docs/locale -l $(I18N_LANG)

docs-zh:
	DOCS_LANGUAGE=$(I18N_LANG) uv run -- sphinx-build -b html docs docs/_build/html/$(I18N_LANG)

docs-zh-strict:
	DOCS_LANGUAGE=$(I18N_LANG) uv run -- sphinx-build -b html -W --keep-going docs docs/_build/html/$(I18N_LANG)
