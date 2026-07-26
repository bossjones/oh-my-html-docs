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

# Regenerate CHANGELOG.md from conventional commits.
changelog:
    uvx git-cliff --output CHANGELOG.md

# Run all pre-commit hooks across the repo.
pre-commit:
    uv run pre-commit run --all-files

# Remove build artifacts.
clean:
    rm -rf site .pagefind
