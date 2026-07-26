# Plan: Create `oh-my-html-docs` — a uv/MkDocs site for hosting standalone HTML documentation

> **Status:** implemented (in progress). This is the originating design spec, now living with the repo it
> describes. The scaffold and the first seeded document (`boss-ai-monitoring`) are done; remaining work is
> importing more documents. Kept for historical/design context — the README and CLAUDE.md are the
> day-to-day references.

## Context

Malcolm has accumulated **standalone HTML documentation** — self-contained pages that carry their own
CSS/JS (and often sibling image assets), e.g.
`~/dev/disler-aka-indydevdan/learning-cmux-with-agents/guide/index.html` and
`boss-skills/specs/boss-ai-monitoring/boss-ai-monitoring.html`. Today these are scattered across repos
with no unified way to browse, categorize, search, or publish them. The goal is a **new dedicated repo**
(`~/dev/bossjones/oh-my-html-docs`) that hosts these pages as a navigable, categorized, tag-filterable,
searchable site — loadable both **locally** (uv + a dev server) and via **GitHub Pages** — with a
`justfile` for lifecycle/lint/static-analysis and uv-native tooling throughout.

Two exploration agents established the load-bearing facts:

1. **Content is not fully self-contained.** Each doc is effectively a *folder* — HTML with inline CSS/JS
   but **relative references to sibling assets** (`images/*.webp|svg`, sibling `*.png`, a 9.9 MB PDF).
   The `guide` page also pulls **Google Fonts via CDN** and has a `../prompts/` cross-link that escapes
   its folder. Import must **preserve directory structure** and serve bundles **verbatim**.
2. **boss-skills config files are heavily repo-specific.** `.gitignore`, `pyproject.toml`, `Makefile`,
   `.claude/settings.json`, `.pre-commit-config.yaml`, and `.rumdl.toml` are wired to the skills/plugins
   layout and must be **sanitized/rewritten**, not copied blindly. `.claude/settings.local.json`
   **contains a live LangSmith API key** and must **never** be copied. The requested
   `.claude/settings.local.example.json` **does not exist** upstream — the real template is
   `.claude/settings.example.json`; we synthesize a sanitized `settings.local.example.json`.

## Objective

A public GitHub repo `bossjones/oh-my-html-docs` on a `main` branch that:

- Hosts standalone HTML docs organized by **category** and **tag**, browsable via a Material for MkDocs shell.
- Serves each doc's HTML/assets **verbatim** (own styling preserved) behind a thin markdown "card."
- Provides **full-text search over the actual HTML** via **Pagefind** (uv-installed, offline-capable).
- Runs locally with `just serve` and deploys to **GitHub Pages via GitHub Actions** on push to `main`.
- Ships a `justfile`, uv-managed toolchain, pre-commit, lychee link-checking, and git-cliff changelogs.
- Carries **sanitized** copies of boss-skills' `.gitignore`, `.claude/settings*.json`,
  `.pre-commit-config.yaml`, `lychee.toml`, and `cliff.toml`.

## Problem Statement

Standalone HTML docs have no home: no navigation between pages, no category/tag taxonomy, no search, no
single "load it locally or publish it" story. A markdown-native generator alone (e.g. plain MkDocs) does
not index or gracefully host pre-built HTML bundles, and re-theming tools (Pelican) fight pages that carry
their own CSS/JS. We need a shell that **wraps** verbatim HTML with discoverability metadata, plus a
search layer that indexes built HTML rather than markdown source.

## Solution Approach

**Material for MkDocs as the shell + verbatim HTML bundles + Pagefind for search**, with framework
lock-in kept low so the eventual **Zensical** migration (Material EOL is **Nov 5, 2026**) is cheap.

- **Verbatim hosting:** MkDocs copies any non-`.md` file under `docs/` into `site/` unchanged, preserving
  relative asset paths. Standalone bundles live under `docs/pages/<slug>/` (or a single `docs/pages/<slug>.html`)
  and are served as-is — the doc's own CSS/JS/images render exactly as authored.
- **Discoverability via "cards":** each doc gets a thin markdown card under `docs/library/<category>/<slug>.md`
  carrying front matter (`title`, `description`, `tags`, `category`, `html` link, `source`, `added`). Cards
  are the MkDocs pages that populate the nav, drive the **built-in tags plugin** (tag/category index pages),
  and provide an "Open the document →" button linking to the verbatim bundle. Separating cards (`library/`)
  from bundles (`pages/`) avoids the `use_directory_urls` output-path collision that co-locating a
  `foo.md` and a `foo/` bundle would cause.
- **Search via Pagefind:** after `mkdocs build`, run Pagefind over `site/` to index the *real* HTML
  (including standalone bundles); it works offline/`file://`, unlike Material's lunr search. Pagefind is
  installed as a uv dependency (Python wheel bundles the binary) — no Node required. Material's built-in
  search stays enabled for `mkdocs serve` dev convenience.
- **Zensical-readiness:** keep `mkdocs.yml` standard and plugin set minimal; because search is
  framework-independent (Pagefind) and content is verbatim, migration later reduces to swapping the build
  tool + theme config.

### Why not the alternatives (recorded, not chosen)

- **Zensical now:** official successor, Material-compatible, 4–5× faster — but **alpha** with sparse docs;
  too much friction for "as easy as possible." We stay Zensical-portable instead.
- **Pelican:** re-themes content through its templates, clobbering self-contained pages' own styling.
- **Plain MkDocs (no Material):** loses Material's polished tags/categories UI; more hand-rolling.
- **Material built-in lunr search:** only indexes markdown, breaks on `file://`.

## Relevant Files

### Source references (read-only, in other repos)

- `~/dev/disler-aka-indydevdan/learning-cmux-with-agents/guide/` — first bundle to import (index.html +
  `images/`, `cmux-guide.pdf` 9.9 MB; Google-Fonts CDN; `../prompts/` cross-link to handle).
- `boss-skills/specs/boss-ai-monitoring/boss-ai-monitoring.html` + 8 sibling `*.png` (~9 MB) — second import.
- boss-skills config sources to sanitize: `.gitignore`, `.claude/settings.json`,
  `.claude/settings.example.json`, `.pre-commit-config.yaml`, `lychee.toml`, `cliff.toml`, `.rumdl.toml`,
  `Makefile` (targets to port), `pyproject.toml` (tool config to port). **Do not read/copy** `.claude/settings.local.json` (live key) or `.env`.

### New repo layout (`~/dev/bossjones/oh-my-html-docs/`)

```text
.github/workflows/deploy.yml     # uv → mkdocs build --strict → pagefind → deploy Pages
.claude/
  settings.json                  # sanitized (no machine dirs / hooks / skills-repo perms / plugins)
  settings.example.json          # copied template
  settings.local.example.json    # NEW sanitized template (real settings.local.json git-ignored)
docs/
  index.md                       # catalog landing (intro + category overview)
  tags.md                        # tags index (Material tags plugin target)
  library/<category>/<slug>.md   # thin cards: front matter + "Open the document →" button
  pages/<slug>/…                 # verbatim HTML bundles (index.html + images/…) OR pages/<slug>.html
  assets/                        # optional site-level css/js
overrides/                       # optional Material theme partials (e.g. Pagefind search box in prod)
scripts/new_doc.py               # PEP723 uv script: import an HTML file/dir → bundle + generated card
mkdocs.yml
justfile
pyproject.toml                   # [dependency-groups] docs = mkdocs, mkdocs-material, pagefind
uv.lock
.pre-commit-config.yaml
lychee.toml
cliff.toml
.rumdl.toml
.gitignore
README.md
CHANGELOG.md
LICENSE
```

## Implementation Phases

### Phase 1: Repo scaffold + tooling

Bootstrap the repo, uv project, sanitized config files, justfile, and Material/MkDocs/Pagefind skeleton
that builds an empty site.

### Phase 2: Content pipeline + seed imports

Define the card front-matter schema, the `pages/` verbatim convention, the `new_doc.py` importer, and
import the two example docs to prove end-to-end (browse → open verbatim → search finds inner text).

### Phase 3: Search, deploy, and polish

Wire Pagefind into build + a search UI, add the GitHub Actions Pages workflow, enable Pages, verify the
live URL, and add lint/link-check/changelog + docs (README, CONTRIBUTING conventions).

## Step by Step Tasks

IMPORTANT: Execute every step in order, top to bottom.

### 1. Write the spec

- Write this document to `boss-skills/specs/oh-my-html-docs.md` (the plan deliverable — done when this
  file exists).

### 2. Bootstrap the repo

- `mkdir -p ~/dev/bossjones/oh-my-html-docs && cd` there; `git init -b main`.
- Create `pyproject.toml`: `[project]` name `oh-my-html-docs`, version `0.1.0`, `requires-python >=3.13`,
  minimal/no runtime deps; `[dependency-groups]` `docs = ["mkdocs","mkdocs-material","pagefind"]`,
  `dev = ["ruff","rumdl","pre-commit"]`; `[tool.uv] package = false`; a **minimal** `[tool.ruff]`
  (line-length 120) scoped to `scripts/` only — drop all boss-skills `per-file-ignores`/plugin excludes.
- `uv sync` to generate `uv.lock` and `.venv`.

### 3. Add sanitized config files (rewrite, do not copy blindly)

- `.gitignore`: clean GitHub Python template **plus** `/site`, `.venv/`, `.ruff_cache/`, `.env`,
  `.claude/settings.local.json`, `.lycheecache`, `.lychee-report.md`. Drop every plugin/skills/adobe/
  `plugin_eval` line and dedupe.
- `.claude/settings.json`: keep generic `git/gh/uv/ruff` allow perms; **remove** `additionalDirectories`
  machine paths, `statusLine`, all `PostToolUse` hooks, and skills-repo perms (`verify-structure`, `rtk`);
  prune `enabledPlugins` (drop `agent-harness@boss-skills`).
- `.claude/settings.example.json`: copy from boss-skills as-is.
- `.claude/settings.local.example.json`: **synthesize** a sanitized template documenting local env/perms
  with **no real keys**. The real `settings.local.json` is git-ignored and recreated per-machine — the
  LangSmith key is **never** carried over.
- `lychee.toml`: near drop-in — remove `ai_docs/` and `scripts/plugin_eval/` from `exclude_path`; add
  `site/`, `.venv/`; keep `fallback_extensions = ["md","html"]` + `include_fragments = true`.
- `cliff.toml`: copy; set `[remote.github]` `owner = "bossjones"`, `repo = "oh-my-html-docs"`.
- `.rumdl.toml`: copy generic `disable` list; repoint `include` to `docs/**/*.md` + `README.md`; drop
  SKILL.md globs.
- `.pre-commit-config.yaml`: keep `uv-sync` + `pre-commit-hooks` + `rumdl` (repointed); **drop**
  `unicode-hygiene`, `snyk`, and boss-skills `exclude` regexes. **Configure `check-added-large-files`**
  (`--maxkb`) or exclude `docs/pages/` — the imported PNGs (~1.1 MB each) and PDF (9.9 MB) exceed the
  500 KB default and will otherwise block commits (see Notes: large assets).

### 4. Author the MkDocs shell

- `mkdocs.yml`: `theme: material` with `features` (navigation.tabs, navigation.sections,
  content.code.copy), `site_url: https://bossjones.github.io/oh-my-html-docs/`; `plugins: [search, tags]`
  with `tags` writing to `tags.md`; `nav`: Home / Library (by category) / Tags; `markdown_extensions:
  attr_list, md_in_html, admonition, pymdownx.superfences, pymdownx.highlight`.
- `docs/index.md` (catalog landing) and `docs/tags.md` (tags index).
- `just build` (`uv run mkdocs build --strict`) produces an empty-but-valid `site/`.

### 5. Define the content pipeline

- Card front-matter schema (in `docs/library/<category>/<slug>.md`):

  ```yaml
  ---
  title: cmux Guide
  description: Visual guide to orchestrating agents with cmux.
  tags: [cmux, agents, orchestration]
  category: guides
  html: /pages/cmux-guide/        # verbatim bundle URL
  source: disler-aka-indydevdan/learning-cmux-with-agents
  added: 2026-07-26
  ---
  ```

  Card body: short blurb + an `attr_list` "Open the document →" button linking to `html`.
- `scripts/new_doc.py` (PEP723, `uv run`): given an HTML file or folder + `--title/--category/--tags`,
  copy the bundle into `docs/pages/<slug>/` (preserving structure) and generate the card. `just add` wraps it.

### 6. Seed the two example imports

- Import `learning-cmux-with-agents/guide/` → `docs/pages/cmux-guide/` (index.html + `images/`; decide on
  the 9.9 MB PDF — likely omit or git-lfs); card `docs/library/guides/cmux-guide.md`. Note the dangling
  `../prompts/` link (lychee will flag) and the Google-Fonts CDN dependency.
- Import `boss-ai-monitoring.html` + 8 PNGs → `docs/pages/boss-ai-monitoring/`; card
  `docs/library/specs/boss-ai-monitoring.md`.

### 7. Wire Pagefind search

- Add a `just search` target: `uv run python -m pagefind --site site` (indexes built HTML into `site/pagefind/`).
- Add a search UI: a `docs/search.md` (or `overrides/` partial) that loads `pagefind-ui` from
  `/pagefind/` in production. Document that Pagefind search is validated via `just preview` (build +
  index + static-serve `site/`), while `mkdocs serve` uses Material's built-in search for dev.

### 8. Author the justfile

- Targets: `install` (uv sync), `serve` (mkdocs serve), `build` (mkdocs build --strict),
  `search` (pagefind), `preview` (build + search + `python -m http.server -d site`), `add` (new_doc.py),
  `lint` (ruff + rumdl check), `fmt` (ruff format + rumdl fmt), `check` (mkdocs build --strict),
  `links` (lychee), `changelog` (`uvx git-cliff`), `pre-commit`, `clean`.

### 9. GitHub Actions Pages deploy

- `.github/workflows/deploy.yml`: on push to `main`; `astral-sh/setup-uv`; Python from `pyproject.toml`;
  `uv sync --group docs`; `uv run mkdocs build --strict`; `uv run python -m pagefind --site site`;
  `actions/upload-pages-artifact` (`site/`) + `actions/deploy-pages`; `permissions: pages: write,
  id-token: write`.

### 10. Create the GitHub repo and publish

- `gh repo create bossjones/oh-my-html-docs --public --source=. --remote=origin --push
  --description "Standalone HTML documentation, browsable + searchable"`.
- Set Pages source to **GitHub Actions** (`gh api -X POST repos/bossjones/oh-my-html-docs/pages
  -f build_type=workflow`, or via repo Settings). Confirm first workflow run deploys.

### 11. Docs + validation

- `README.md` (local + Pages usage, `just add` workflow, card schema), `CHANGELOG.md` seed, `LICENSE`.
- Run the full Validation Commands below; fix until green; confirm the live Pages URL renders a card,
  opens a verbatim doc with its own styling + images, and Pagefind finds text inside a standalone page.

## Testing Strategy

- **Build integrity:** `uv run mkdocs build --strict` succeeds with zero warnings; assert verbatim assets
  land in `site/pages/<slug>/…` unchanged (byte-compare a sample image; grep the HTML is not re-themed).
- **Search:** after `just search`, `site/pagefind/` exists; in `just preview` the search box returns a hit
  for a phrase that only appears *inside* a standalone HTML doc (proves HTML-body indexing, not just cards).
- **Navigation/taxonomy:** tag and category index pages list the seeded docs; card "Open" button resolves.
- **Link check:** `just links` (lychee) runs; the known `../prompts/` dangling link is the only expected
  failure — decide to import `prompts/`, fix, or `exclude` it.
- **Importer:** `scripts/new_doc.py` has a pytest that imports a tiny fixture folder and asserts the card
  - copied bundle are produced with correct front matter (PEP723 script loaded via `importlib`).
- **CI:** first GitHub Actions run builds + deploys; live URL reachable.

## Acceptance Criteria

- Public repo `bossjones/oh-my-html-docs` exists on `main`, pushed via `gh`.
- `just serve` runs a local site; `just build` produces a strict, warning-free `site/`.
- Standalone HTML bundles render **verbatim** (own CSS/JS/images intact) via direct-link cards.
- Docs are browsable by **category** and **tag**; Pagefind search finds text **inside** standalone HTML
  and works from `just preview` / the deployed site.
- GitHub Actions deploys to **GitHub Pages** on push to `main`; live URL confirmed.
- `justfile` provides up/serve/build/search/lint/fmt/links/changelog/deploy; pre-commit, lychee, and
  git-cliff configured.
- Sanitized `.gitignore`, `.claude/settings.json`, `.claude/settings.example.json`,
  `.claude/settings.local.example.json`, `.pre-commit-config.yaml`, `lychee.toml`, `cliff.toml` present —
  **no** LangSmith key, **no** boss-skills machine paths or skills-repo tooling references.

## Validation Commands

- `uv sync` — resolve the toolchain, produce `uv.lock`.
- `just build` → `uv run mkdocs build --strict` — strict build, zero warnings.
- `just search` → `uv run python -m pagefind --site site` — build the search index (`site/pagefind/`).
- `just preview` — build + index + serve `site/`; manually verify a card → verbatim doc → in-page search hit.
- `just lint` — `ruff check` + `rumdl check .` clean.
- `just links` — `lychee` (only the expected `../prompts/` dangling link should surface).
- `uv run pytest -s` — `scripts/new_doc.py` importer test passes.
- `gh run watch` (after push) — first Pages deploy succeeds; open the live URL.

## Notes

- **Large assets (gotcha):** imports include 1.1 MB PNGs and a 9.9 MB PDF. `check-added-large-files`
  defaults to 500 KB and will block commits. Decide up front: raise `--maxkb`, exclude `docs/pages/`, or
  adopt **git-lfs** for `docs/pages/**` binaries. Also weigh whether to commit the PDF at all.
- **CDN / offline:** the `guide` page loads Google Fonts via CDN — fine on Pages, degrades to system fonts
  offline. No CSP is enforced. The monitoring page has no external CSS/JS.
- **Cross-links that escape a bundle** (`../prompts/`): either import the sibling `prompts/` doc too or
  document/exclude the dangling reference.
- **Zensical migration path:** Material EOL is **Nov 5, 2026**. Keep `mkdocs.yml` standard and the plugin
  set minimal; because search is Pagefind and content is verbatim, a later Material→Zensical move is a
  config/theme swap, not a content rewrite.
- **New tools via uv:** `uv add --group docs mkdocs mkdocs-material pagefind`;
  `uv add --group dev ruff rumdl pre-commit`; changelog via `uvx git-cliff` (no project dep needed).
- **Optional later:** `renovate.json` (near drop-in from boss-skills) and `.editorconfig` for parity.
