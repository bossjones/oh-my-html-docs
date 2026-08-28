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
- [Codex CLI vs Claude Code](guides/codex-cli-vs-claude-code.md) — conversion field guide between the
  two terminal agents: CLAUDE.md ↔ AGENTS.md, settings.json ↔ config.toml, flags, slash commands, the
  shared hook-event set, the sandbox/approval model, `codex exec`, and each agent's exclusives.
- [Copilot CLI vs Claude Code](guides/copilot-cli-vs-claude-code.md) — conversion field guide between
  the two terminal agents: config files, flags, slash commands, hooks, permissions, CI, and each
  tool's exclusive features.
- [Opus 5 Mastery — Unhobble the Model](guides/opus-5-mastery.md) — field guide to getting the best
  out of Claude Opus 5: delete Claude-4-era constraints, pull the effort/thinking/context levers, and
  paste 18 ready-made prompts.
- [Pi — The Coding Harness](guides/pi-harness-guide.md) — from-zero field guide to
  [Pi](https://pi.dev) (earendil-works), the minimal programmable harness: quickstart, recommended
  setup, TypeScript extensions, VS Code/Cursor config, 12 ecosystem packages, and
  [IndyDevDan](https://www.youtube.com/@indydevdan)'s Pi repos.

## specs

- [boss-ai-monitoring — Local Observability for AI Coding Agents](specs/boss-ai-monitoring.md) —
  storage pipeline, dashboards, and agent-loop instrumentation.

!!! tip "Add a document"
    `just add <path> --title "…" --category … --tags a,b` copies the HTML verbatim and generates a card
    here.
