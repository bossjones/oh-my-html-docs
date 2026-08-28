# IndyDevDan (disler) — Pi-related work, local repo survey

Surveyed 2026-08-27 from `~/dev/disler-aka-indydevdan/` (clones of github.com/disler/*).
Pi-relevant repos: pi-vs-claude-code, pi-agent-observability, fusion-harness, the-verifier-agent,
live-bench, bash-damage-from-within (+ passing mentions in planf3, fixing-smartass-opus-5,
inkwell-agent-sandboxes-and-software-factory). No Pi content: nano-agent, benchy,
agentic-coding-tool-eval, the-library (pre-Pi context work).

Package-name history: older repos import `@mariozechner/pi-coding-agent` (Mario Zechner's
original), newer ones `@earendil-works/pi-coding-agent`.

## pi-vs-claude-code — the flagship Pi playground

github.com/disler/pi-vs-claude-code · videos: youtu.be/f8cfH5XX-XU ("Pi Coding Agent: The Only
Claude Code Competitor"), youtu.be/PIdETjcXNIk ("Pi to Pi: Two-Way Agent Orchestration")

18 standalone Pi extensions showcasing "hedging against the leader in the agentic coding market".
Prereqs: Bun >= 1.3.2, just, pi. Pi does NOT auto-load `.env` — export keys before launch.
Run: `pi -e extensions/<name>.ts`; compose with multiple `-e` flags; `just` recipes wrap combos.

Key files:

- `extensions/minimal.ts` — smallest complete example: custom footer (model + context meter).
- `extensions/damage-control.ts` + `.pi/damage-control-rules.yaml` — real-time bash/path safety
  auditing via `tool_call` interception; `-continue` variant returns feedback instead of aborting.
- `extensions/coms.ts` / `coms-net.ts` + `scripts/coms-net-server.ts` — Pi-to-Pi messaging
  (Unix sockets local; HTTP/SSE hub over LAN). Tools: coms_list/send/get/await.
- `extensions/agent-team.ts` (+ `.pi/agents/teams.yaml`) — dispatcher-only orchestrator with
  `dispatch_agent` tool + grid dashboard; `agent-chain.ts` — sequential pipeline.
- `extensions/cross-agent.ts` — scans `.claude/`, `.gemini/`, `.codex/` dirs and registers their
  commands/skills/agents inside Pi.
- Also: subagent-widget.ts, tilldone.ts, purpose-gate.ts, tool-counter.ts, system-select.ts,
  session-replay.ts, theme-cycler.ts, pi-pi.ts (meta-agent building Pi agents).
- `.pi/settings.json` — `{"theme": "synthwave", "prompts": ["../.claude/commands"]}` (share Claude
  commands with Pi). `.pi/themes/*.json` — 11 custom themes. THEME.md / TOOLS.md /
  RESERVED_KEYS.md — extension-author references.
- **COMPARISON.md** (38.5K) — "Pi v0.52.10 vs Claude Code (Feb 2026)": CC = batteries-included,
  ~10K-token guardrailed prompt, safe-by-default; Pi = 4 tools, ~200-token prompt,
  YOLO-by-default, in-process TypeScript extensions, 324 models / 20+ providers.
  **PI_VS_OPEN_CODE.md** (29.9K) — Pi as "programmable platform" (25+ in-process hooks) vs
  OpenCode as "configurable product".

Canonical extension shape (extensions/minimal.ts, quote with attribution):

```ts
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    ctx.ui.setFooter((_tui, theme) => ({
      render(width) {
        const usage = ctx.getContextUsage();
        const pct = usage?.percent ?? 0;
        const bar = "#".repeat(Math.round(pct / 10)).padEnd(10, "-");
        return [`${ctx.model?.id ?? "no-model"} [${bar}] ${Math.round(pct)}%`];
      }, invalidate() {}, dispose() {},
    }));
  });
}
```

Repo convention (its CLAUDE.md): "Register tools at the top level of the extension function
(not inside event handlers)."

## pi-agent-observability — telemetry stack

github.com/disler/pi-agent-observability · video: youtu.be/o4KZH_KSqYQ

Local observability for Pi + a product-agent demo; successor to
claude-code-hooks-multi-agent-observability. Thesis: measure the performance–speed–cost trifecta.
Four parts: (1) `extension/pi-observability.ts` (~800 lines) — drop into any Pi with `-e`; streams
16-event lifecycle (session_start, before_agent_start, agent_end, turn_start/end,
message_start/update/end, tool_call, tool_result, model_select, session_compact, session_tree,
session_shutdown); batches 50 events, backpressure, retries. (2) `apps/observability/` — Bun +
SQLite (WAL) + SSE server, three vanilla-JS views: single / swimlane / race. (3) `apps/steelman/`
— real product agent on an observed Pi. (4) `.claude/skills/` — /spec /htmlspec /htmlvspec /vspec.
Setup: bun >= 1.1, pi on $PATH, just, sqlite3; `just all`. `extension/package.json` shows the
package.json registration convention: `"pi": {"extensions": ["./pi-observability.ts"]}` with
devDep `@earendil-works/pi-coding-agent`.

## fusion-harness — multi-model fusion extension

github.com/disler/fusion-harness · videos: youtu.be/rqZHR-hRllI (V2), youtu.be/AQl5Q-0l7FQ (V1)

"Fuse 2–5 frontier models instead of racing them. AND, not OR." One ARCHITECT, one primary
BUILDER, up to three secondaries; opinions/fusion/debate/collaborate flows; single-writer
invariant. Install context: `npm install -g @earendil-works/pi-coding-agent`; prereqs pi, just,
bun, jq, uv; 34 deterministic tests with zero paid calls. Documented gotcha: pi reads
`GEMINI_API_KEY`, not `GOOGLE_GENERATIVE_AI_API_KEY`.
Key files: `extensions/fusion-harness/fusion-harness.ts` + modules (model-stack.ts,
child-runner.ts — clean-room children via `--no-extensions`; writer-lease.ts;
collaboration-graph.ts; tui.ts); `.pi/fusion-harness/model-stack-*.yaml` — declarative 2–5-slot
stacks with per-slot append_system_prompt. Commands: /fh /fh-opinion /fh-fusion /fh-debate
/fh-collaborate /fh-only /fh-model (uses pi.setModel + pi.setThinkingLevel) /fh-auto-validate
/fh-reset.

## the-verifier-agent — builder/verifier two-agent harness

github.com/disler/the-verifier-agent · video: youtu.be/EnXKysJNz_8

Interactive Builder Pi + input-locked Verifier Pi in a sibling tmux/OS window. Top-down observer:
builder doesn't know verifier exists; verifier connects over a unix socket
(`/tmp/pi-verifier/<sessionId>.sock`, chmod 0700), reads the builder's session JSONL at
`~/.pi/agent/sessions/<sid>.jsonl`, and on failure calls its sole write-path tool
`verifier_prompt` — delivered via `pi.sendUserMessage(deliverAs: "followUp")`. Loops max 3x, then
escalates to a human. Pins `@mariozechner/pi-coding-agent ^0.70.5` + pi-tui. Themes: "spend
tokens to save time"; read-only verifier tool surface; the verifier is "structurally
un-promptable" (fix the persona/template, not the instance).

## bash-damage-from-within — safety ladder in both harnesses

github.com/disler/bash-damage-from-within. "5 levels to stop your agent from destroying
production" — runnable side-by-side demos for Claude Code AND Pi (`pi/level-1..5/` mirrors
`claude-code/`); shared `extensions/minimal.ts` + `themeMap.ts`; one just recipe per level.

## live-bench — Pi drives the benchmark

github.com/disler/live-bench · video: youtu.be/00Y-p62sk0s. LAN-only live benchmarking of local
models (M5 Max vs M4 Max, Qwen 3.5 / Gemma 4, GGUF vs MLX). `benchmarks/pi-coding-agent.yaml` +
`-3way.yaml`: 6 tasks × 3 models measuring wall time, correctness, token efficiency, tool calls.
README credit: "Pi Coding Agent — drives the agentic coding benchmark."

## Doctrine (for §Dan framing; agenticengineer.com · youtube.com/@indydevdan)

- Measure the performance–speed–cost trifecta ("If you don't measure, you can't improve").
- AND-not-OR multi-model orchestration (fusion, coms, verifier).
- "Spend tokens to save time."
- Templated engineering: fix the system prompt/persona/skill, never the instance — "build the
  system that builds the system."
- Hedge against single-vendor lock-in (pi-vs-claude-code's stated purpose).
- Defense-in-depth on the bash tool.
- Pi appeals precisely for its minimalism: ~200-token prompt, 4 tools, in-process TypeScript
  extensions with full event interception — the "programmable platform" thesis.

## Runtime note

Dan's repos standardize on **Bun** (>= 1.3.2 / >= 1.1) + `just` as task runner, while Pi itself
requires Node >= 22.19.0. The guide must state both without conflating them.
