# oh-my-html-docs

A home for **standalone HTML documentation** — self-contained pages that carry their own CSS/JS (and
sibling image assets) — made browsable, categorized, tag-filterable, and searchable. Built on
[Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) with
[Pagefind](https://pagefind.app/) for full-text search, runnable locally and publishable to GitHub Pages.

## Quickstart

```bash
just install     # uv sync — resolve mkdocs, material, pagefind, dev tools
just serve       # live dev server at http://127.0.0.1:8000 (Material's built-in search)
just build       # strict production build into ./site
just preview     # build + Pagefind index + static server (test real search locally)
```

Requires [uv](https://docs.astral.sh/uv/) and [just](https://github.com/casey/just).

## How it works

Each document is stored two ways:

- **The verbatim bundle** — `docs/pages/<slug>/` (a folder with `index.html` + assets) or a single
  `docs/pages/<slug>.html`. MkDocs copies these to the built site **unchanged**, so each page renders
  exactly as authored.
- **A thin card** — `docs/library/<category>/<slug>.md` — carries metadata that drives navigation and the
  Tags index, and links to the full document with an "Open the document →" button.

Full-text search over the *actual HTML* is provided by Pagefind (post-build), so it indexes the standalone
pages themselves and works offline — unlike Material's built-in search, which only covers markdown.

## Adding a document

```bash
# single self-contained file
just add ./report.html --title "My Report" --category specs --tags observability

# multi-file bundle (index.html + assets) — pass the directory
just add ./guide/ --title "cmux Guide" --category guides --tags cmux,agents --source "disler/learning-cmux-with-agents"
```

`scripts/new_doc.py` copies the content into `docs/pages/<slug>/` and generates the card. Card front
matter:

```yaml
---
title: cmux Guide
description: Visual guide to orchestrating agents with cmux.
tags: [cmux, agents, orchestration]
category: guides
html: /pages/cmux-guide/
source: disler/learning-cmux-with-agents
added: 2026-07-26
---
```

## Tooling

`just lint` (ruff + rumdl), `just fmt`, `just check` (strict build), `just links` (lychee),
`just changelog` (git-cliff), `just pre-commit`, `uv run pytest`.

## Deploying

`.github/workflows/deploy.yml` builds the site, runs Pagefind, and publishes to GitHub Pages on push to
`main`. Set the repo's Pages source to **GitHub Actions** once the repo exists.

## Notes on configuration

Config files (`.gitignore`, `.claude/settings*`, `.pre-commit-config.yaml`, `lychee.toml`, `cliff.toml`,
`.rumdl.toml`) were adapted from [`boss-skills`](https://github.com/bossjones/boss-skills):

- **`.claude/settings.local.json`** is git-ignored and machine-local — copy `settings.local.example.json`
  to create your own. Never commit secrets.
- **`.gitignore`** is intentionally kept complete (inherited verbatim) because agent plugins auto-generate
  files/logs that must not be committed. **Future work:** centralize that plugin log output to a single
  directory and trim the `.gitignore` accordingly.
