# oh-my-html-docs — task runner
# Run `just` (or `just --list`) to see all recipes.

set shell := ["zsh", "-uc"]

# Show available recipes.
default:
    @just --list

# Install/resolve the toolchain (mkdocs, material, pagefind, dev tools).
install:
    uv sync

# Live dev server with hot reload (uses Material's built-in search for dev).
serve:
    uv run mkdocs serve

# Strict production build into ./site (fails on any warning).
build:
    uv run mkdocs build --strict

# Build, then index the built HTML with Pagefind (full-text search over verbatim pages).
search: build
    uv run python -m pagefind --site site

# Build + Pagefind index + serve ./site statically so Pagefind search works locally.
preview: search
    uv run python -m http.server -d site 8000

# Import a standalone HTML doc: `just add <path> --title "…" --category … --tags a,b`
add *ARGS:
    uv run scripts/new_doc.py {{ ARGS }}

# Lint Python (ruff) and markdown (rumdl).
lint:
    uv run ruff check scripts tests
    uv run rumdl check .

# Auto-format Python (ruff) and markdown (rumdl).
fmt:
    uv run ruff format scripts tests
    uv run rumdl fmt .

# Static-analysis gate: a strict build must succeed.
check: build

# Check links in authored docs (requires the `lychee` binary).
links:
    lychee --config lychee.toml docs README.md

# Search GitHub Docs (unofficial API — fails loudly if it changes): `just ghdocs "copilot cli hooks"`
ghdocs QUERY:
    curl -fsG "https://docs.github.com/api/search/v1" \
      --data-urlencode "query={{ QUERY }}" \
      --data-urlencode "version=free-pro-team@latest" \
      --data-urlencode "language=en" \
      --data-urlencode "size=10" \
      --data-urlencode "client_name=oh-my-html-docs" | jq -r '.hits[] | "\(.url) — \(.title)"'

# Fetch one GitHub Docs article as raw markdown: `just ghdoc /en/copilot/how-tos/copilot-cli/cli-best-practices`
ghdoc PATHNAME:
    curl -fsG "https://docs.github.com/api/article/body" --data-urlencode "pathname={{ PATHNAME }}"

# Search the Claude Code docs index (llms.txt): `just ccdocs hooks`
ccdocs QUERY:
    curl -fs "https://code.claude.com/docs/llms.txt" | grep -i -- "{{ QUERY }}"

# Fetch one Claude Code docs page as raw markdown: `just ccdoc hooks`
ccdoc PAGE:
    curl -fs "https://code.claude.com/docs/en/{{ PAGE }}.md"

# -L is required: every developers.openai.com/codex/* URL answers 308.
# Search the Codex docs index (llms.txt): `just codexdocs hooks`
codexdocs QUERY:
    curl -fsSL "https://developers.openai.com/codex/llms.txt" | grep -i -- "{{ QUERY }}"

# Per-page files leave MDX <ConfigTable/> placeholders unrendered — for flag, command,
# and config.toml tables fetch the `codex-manual` page instead (~1.9 MB, fully rendered).
# Fetch one Codex docs page as raw markdown: `just codexdoc agent-configuration/agents-md`
codexdoc PAGE:
    curl -fsSL --retry 3 --retry-connrefused "https://learn.chatgpt.com/docs/{{ PAGE }}.md"

# Regenerate CHANGELOG.md from conventional commits.
changelog:
    uvx git-cliff --output CHANGELOG.md

# Run all pre-commit hooks across the repo.
pre-commit:
    uv run pre-commit run --all-files

# Remove build artifacts.
clean:
    rm -rf site .pagefind
