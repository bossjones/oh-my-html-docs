# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`oh-my-html-docs` hosts **standalone HTML documentation** — self-contained pages that carry their own
CSS/JS (and sibling image assets) — as a browsable, categorized, tag-filterable, searchable site. It is a
[Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) site with
[Pagefind](https://pagefind.app/) for full-text search, runnable locally and published to GitHub Pages.

The originating design spec is `specs/oh-my-html-docs.md`.

## Architecture

Each document is stored two ways:

- **Verbatim bundle** — `docs/pages/<slug>/` (a folder: entry HTML + its assets) or a single
  `docs/pages/<slug>.html`. MkDocs copies these to `site/` **unchanged**, so each page renders exactly as
  authored. These are static assets, not MkDocs pages — their internal links are not processed.
- **Card** — `docs/library/<category>/<slug>.md` — a thin markdown page with front matter (`title`,
  `description`, `tags`, `category`, `html`, `source`, `added`) and an "Open the document →" button. Cards
  populate the nav-adjacent Library/Tags browsing and are what Pagefind + Material index for metadata.

Cards live under `library/` and bundles under `pages/` to avoid a `use_directory_urls` output-path
collision (a `foo.md` and a `foo/` bundle would both build to `foo/index.html`).

## Commands

```bash
just install     # uv sync (mkdocs, material, pagefind, dev tools)
just serve       # live dev server at http://127.0.0.1:8000 (Material built-in search)
just build       # strict production build into ./site (fails on any warning)
just search      # build + Pagefind index (site/pagefind/)
just preview     # build + index + static server (test real Pagefind search locally)
just add <path> --title "…" --category … --tags a,b   # import a standalone HTML doc
just lint        # ruff (scripts/tests) + rumdl (markdown)
just fmt         # ruff format + rumdl fmt
uv run pytest    # importer tests
just links       # lychee link check (needs the lychee binary)
just changelog   # git-cliff → CHANGELOG.md
```

The justfile uses `zsh` as its recipe shell.

## Adding a document

`scripts/new_doc.py` (PEP 723, stdlib-only) copies the source verbatim into `docs/pages/<slug>/` and
generates the card. Entry-file detection: `index.html` if present, else the sole top-level `*.html`, else
pass `--entry`. A lone file is wrapped as `index.html`. The card's `html:` link is written root-absolute
(`/pages/<slug>/<entry>`) and MkDocs rewrites it to a subpath-safe relative URL (see below).

## GitHub Pages / base path

This project repo publishes under the **subpath** `https://bossjones.github.io/oh-my-html-docs/`. So
root-absolute links (`/pages/...`) would break there. `mkdocs.yml` sets
`validation.links.absolute_links: relative_to_docs`, which rewrites such links to be docs-relative and
therefore correct under the subpath. Deploy is via `.github/workflows/deploy.yml` (build → Pagefind →
Pages) on push to `main`.

## Validate rendering with playwright-cli

Standalone pages carry their own CSS/JS and load sibling images by relative path, so after importing a
doc, **verify it actually renders** (images resolve, layout intact) before publishing. Use the
`playwright-cli` skill:

```bash
# 1. Build and serve the site at root (a separate terminal, or backgrounded)
just build
python3 -m http.server -d site 8000 &

# 2. Open the verbatim page and screenshot it
playwright-cli open "http://localhost:8000/pages/<slug>/<entry>.html"
playwright-cli screenshot --filename=/tmp/<slug>.png      # then view the PNG

# 3. Confirm EVERY image loaded (naturalWidth > 0, complete)
playwright-cli --raw eval "JSON.stringify([...document.images].map(i => ({file: i.currentSrc.split('/').pop(), ok: i.complete && i.naturalWidth > 0})))"

# 4. Check the console for real errors (a favicon.ico 404 is harmless)
playwright-cli console

# 5. Verify the card's button resolves to the verbatim doc, then close
playwright-cli goto "http://localhost:8000/library/<category>/<slug>/"
playwright-cli --raw eval "[...document.querySelectorAll('a')].find(a => /Open the document/i.test(a.textContent)).href"
playwright-cli close
```

A green check = the page title is correct, the image array shows `ok: true` for all images, and `console`
shows no errors other than `favicon.ico`. The `playwright-cli` skill is installed globally at
`~/.claude/skills/playwright-cli`.

## Code standards

- Python 3.13+, full type annotations, `from __future__ import annotations`, `pathlib.Path`.
- `scripts/new_doc.py` is stdlib-only (no third-party deps) so it stays a portable PEP 723 script; tests
  load it via `importlib` (the `if __name__ == "__main__"` guard keeps import side-effect-free).
- Lint must be clean (`just lint`) and `just build` must pass `--strict` before committing.
- Cards carry both a front-matter `title:` and a body `# H1` (MD025 is disabled for this intentional
  pattern in `.rumdl.toml`).

## Configuration provenance

Config (`.gitignore`, `.claude/settings*`, `.pre-commit-config.yaml`, `lychee.toml`, `cliff.toml`,
`.rumdl.toml`) was adapted from [`boss-skills`](https://github.com/bossjones/boss-skills). The
`.gitignore` is intentionally kept complete (inherited verbatim) to guard agent-plugin-generated files;
`.claude/settings.local.json` is git-ignored and machine-local (copy `settings.local.example.json`).
