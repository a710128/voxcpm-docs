# Agent Notes (voxcpm-docs)

This repository is a Sphinx documentation site for VoxCPM. The main content lives in `docs/` as reStructuredText (`.rst`) pages.

## Quick Orientation

- Docs source: `docs/` (entrypoint: `docs/index.rst`)
- Repo docs map: `INDEX.md` is a human-maintained outline of the `docs/` information architecture and per-page content overview (use it to quickly find where to edit).
- Sphinx config: `docs/conf.py`
- Theme: `furo` with custom CSS in `docs/_static/custom.css`
- Read the Docs config: `.readthedocs.yaml` (builds with Python 3.13)
- Python deps for building docs: `pyproject.toml` (also mirrored in `requirements.txt`)
- Dependency tooling: `uv` (creates `.venv/` via `uv sync`)
- Convenience build targets: repo root `Makefile` (delegates to `docs/Makefile`)

## Setup

Preferred setup (fast, reproducible) with `uv`:

```bash
uv sync
```

Fallback setup (if you do not want `uv`):

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install -U pip
python -m pip install -r requirements.txt
```

Notes:

- RTD uses Python 3.13; local builds should work on modern Python 3.x.
- If `sphinx-build` is not found, your environment is not activated or deps are not installed.
- Keep `pyproject.toml` and `requirements.txt` in sync if you add/remove build deps.

## Build / Lint / Test Commands

### Build docs (most common)

```bash
make docs
```

`make docs` runs a clean build via `uv run` (no manual venv activation needed). Artifacts land in `docs/_build/html/`.

For faster iteration (skip the clean step):

```bash
uv run -- make -C docs html
```

### Clean build artifacts

```bash
make docs-clean
```

### Other useful Sphinx targets

```bash
make docs-linkcheck
make docs-doctest
uv run -- make -C docs help
```

`linkcheck` is the closest thing to a "test" for docs content (checks external links; can be slow/flaky).

### Stricter local build (treat warnings as errors)

```bash
make docs-strict
```

### Run a single test (if/when tests exist)

This repo currently has no unit test suite configured. If you add `pytest` later, prefer these forms:

```bash
uv run -- pytest -q
uv run -- pytest -q path/to/test_file.py
uv run -- pytest -q path/to/test_file.py::TestClass::test_name
uv run -- pytest -q -k keyword_expression
```

For docs-focused checks today, run the smallest relevant Sphinx target instead (e.g. `make docs-doctest`).

### Linting / formatting

No linter/formatter is configured in this repo today.

If you need a quick, dependency-free sanity check for the only Python module here:

```bash
uv run -- python -m compileall docs/conf.py
```

If you introduce more Python code, consider adding `ruff` (and a config) and then documenting the exact commands here.

## Code Style Guidelines

### Documentation (reStructuredText + Sphinx)

- **Prefer `.rst`** for new pages to match existing structure (Sphinx directives are used heavily).
- **File naming:** use lowercase filenames (e.g., `new_page.rst`), no spaces; keep paths stable once published.
- **Headings:** follow existing convention (top-level uses `=`; next levels use `*`, `-`, `^`, etc.). Keep it consistent within a file.
- **Directives indentation:** directive options align under the directive; directive bodies are indented consistently (typically 3 spaces in this repo).
- **Code blocks:** always specify a language:
  - `.. code-block:: bash`, `.. code-block:: python`, `.. code-block:: json`, `.. code-block:: yaml`
- **Inline code:** use double backticks in `.rst` for literals: ``like_this``.
- **Links and refs:**
  - Prefer Sphinx refs for internal navigation: `:doc:`, `:ref:`.
  - Use explicit external links with `` `text <https://...>`_ ``.
- **Tables:** this repo uses `.. list-table::` and grid tables; keep formatting readable and aligned.
- **Assets:** put images/CSS under `docs/_static/` and reference with relative paths (see `docs/index.rst`).
- **Toctrees:** when adding new pages, ensure they are reachable from a `.. toctree::` (often via the hidden trees in `docs/index.rst`).
- **Build outputs:** never edit or commit `docs/_build/`.
- **Avoid drive-by reflow:** do not rewrap/reflow large paragraphs unless you are actively editing that section (minimize diff noise).
- **Unicode/emojis:** existing docs include them; do not strip them. When adding new content, keep it readable and consistent.

### Python (Sphinx config and any helper scripts)

- **Imports:** group as standard library, third-party, then local; one import per line when it improves clarity.
- **Formatting:** follow PEP 8; keep lines reasonably short, but prioritize readability in config files.
- **Types:** optional; add type hints when they reduce ambiguity (prefer `typing` stdlib types; avoid runtime-heavy typing helpers unless needed).
- **Naming:**
  - `snake_case` for functions/variables.
  - `UPPER_SNAKE_CASE` for module-level constants.
- **Error handling:**
  - Prefer failing fast with clear exceptions rather than swallowing errors.
  - When handling an expected failure, include actionable context in the message (what to do next).

If you add a new script/module, keep it lightweight (avoid new runtime deps) unless the doc build genuinely needs it.

### CSS / styling

- Keep changes scoped to `docs/_static/custom.css` unless a theme-level change is required.
- Prefer small, targeted selectors to avoid unexpected theme regressions.

## Repo Policy Notes for Agentic Changes

- Keep diffs small and docs-focused; avoid adding new tooling unless necessary.
- If you add new developer tooling (ruff, pre-commit, etc.), also add:
  - a config file,
  - a short rationale,
  - and update this file with the exact commands.

## Notes on Lockfiles

- `uv.lock` is currently ignored via `.gitignore`; do not add or commit it unless the repo policy changes.

## Cursor / Copilot Instructions

- No Cursor rules found in `.cursor/rules/` or `.cursorrules`.
- No Copilot instructions found in `.github/copilot-instructions.md`.
