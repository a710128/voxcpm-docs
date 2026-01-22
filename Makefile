.PHONY: docs docs-clean docs-linkcheck docs-doctest docs-strict

# Convenience targets for building Sphinx docs via uv.

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
