# Library

Every document lives here as a **card** — a short entry with a description, tags, and a link that opens
the full standalone HTML document.

Cards are organized by **category** (subfolders of `docs/library/`) and filterable by **tag** via the
[Tags](../tags.md) index.

## guides

- [cmux — Orchestrate Agents](guides/cmux-guide.md) — visual guide to orchestrating coding agents with
  cmux (tiers, the agentic loop, multi-agent access). By
  [IndyDevDan](https://www.youtube.com/@indydevdan) /
  [disler](https://github.com/disler/learning-cmux-with-agents).

## specs

- [boss-ai-monitoring — Local Observability for AI Coding Agents](specs/boss-ai-monitoring.md) —
  storage pipeline, dashboards, and agent-loop instrumentation.

!!! tip "Add a document"
    `just add <path> --title "…" --category … --tags a,b` copies the HTML verbatim and generates a card
    here.
