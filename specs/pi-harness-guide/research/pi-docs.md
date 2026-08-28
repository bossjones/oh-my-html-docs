# Pi (pi.dev) — consolidated research corpus

Harvested 2026-08-27 from pi.dev/docs, pi.dev/packages, api.github.com, and the npm registry.
Volatile numbers (versions, stars, downloads, package counts) are snapshots — re-verify at build time.

## Positioning

- Homepage tagline: "There are many agent harnesses but this one is yours"; "Pi is a minimal agent
  harness. Adapt Pi to your workflows, not the other way around." (https://pi.dev/)
- GitHub description: "AI agent toolkit: unified LLM API, agent loop, TUI, coding agent CLI".
  Org: Earendil Inc. & Contributors. (https://github.com/earendil-works/pi)
- Monorepo packages: `@earendil-works/pi-telemetry` (telemetry contracts), `@earendil-works/pi-ai`
  (unified multi-provider LLM API), `@earendil-works/pi-agent-core` (agent runtime),
  `@earendil-works/pi-coding-agent` (the CLI users install), `@earendil-works/pi-tui` (differential
  terminal rendering). Repo dirs: `ai/`, `agent/`, `tui/`, `coding-agent/`.
- Operating modes: interactive TUI (default), print (`-p`/`--print`), JSON event stream
  (`--mode json`), RPC (`--mode rpc`, JSON over stdin/stdout), SDK embedding.
  (https://pi.dev/docs/latest/usage, /sdk)

## Version / stats (snapshot 2026-08-27)

- npm latest: **0.84.3** (published 2026-08-24). `engines.node >= 22.19.0`. MIT.
  Dist-tag `legacy-node20` → 0.74.2.
- GitHub: 98,281 stars, 12,156 forks, created 2025-08-09, same-day push activity, TypeScript, MIT.
- Registry: **5,467 packages** at https://pi.dev/packages (filter by extension/skill/theme/prompt).
- Community: Discord https://discord.com/invite/3cU7Bz4UPx · X @pidotdev.

## Install & uninstall

- `curl -fsSL https://pi.dev/install.sh | sh` (macOS/Linux; first-listed method).
- `powershell -c "irm https://pi.dev/install.ps1 | iex"` (Windows).
- `npm install -g --ignore-scripts @earendil-works/pi-coding-agent` (also pnpm/bun; `--ignore-scripts`
  because pi needs no lifecycle scripts — smaller supply-chain surface).
- Uninstall preserves `~/.pi/agent/` (settings, credentials, sessions).
- Platforms: macOS, Linux, Windows, Termux/Android; tmux + terminal-setup pages exist.

## Auth

- `/login` OAuth for subscriptions: ChatGPT Plus/Pro (officially endorsed by OpenAI), Claude Pro/Max,
  GitHub Copilot (incl. GHE Server), xAI, OpenRouter, Radius. Tokens auto-refresh in
  `~/.pi/agent/auth.json`; `/logout` clears. (https://pi.dev/docs/latest/providers)
- Env keys: ANTHROPIC_API_KEY, OPENAI_API_KEY, GEMINI_API_KEY (NOT GOOGLE_GENERATIVE_AI_API_KEY),
  DEEPSEEK_API_KEY, MISTRAL_API_KEY, GROQ_API_KEY, XAI_API_KEY, OPENROUTER_API_KEY,
  AZURE_OPENAI_API_KEY, AWS_BEARER_TOKEN_BEDROCK, CLOUDFLARE_API_KEY, NVIDIA_API_KEY,
  CEREBRAS_API_KEY, HF_TOKEN, FIREWORKS_API_KEY, TOGETHER_API_KEY, QWEN_TOKEN_PLAN_API_KEY,
  MINIMAX_API_KEY, XIAOMI_API_KEY; Vertex via gcloud ADC.
- auth.json `key` supports `"!command"`, `"$ENV_VAR"`, or literals. Resolution order:
  `--api-key` flag → auth.json → env var → models.json custom-provider keys.
- Pi does **not** auto-load `.env` — export keys before launch.
- Custom/local models: `models.json` (Ollama, LM Studio, vLLM; OpenAI-Completions /
  Anthropic-Messages / Google-GenAI-compatible APIs) or `pi.registerProvider` from an extension.

## Daily use

- Default tools: `read write edit bash` (+ `powershell` on Windows) + read-only `grep find ls`.
- One-shot `pi -p "…"`; piping `cat file | pi -p "…"`; file refs `pi @README.md "…"`.
- Editor: `@` fuzzy file search, Tab completion, Shift+Enter newline, `!cmd` shell (output included),
  `!!cmd` silent, Ctrl+G external editor, Ctrl+V paste image, Ctrl+X copy. Enter mid-run = steering;
  Alt+Enter = follow-up queue; Escape aborts.
- Slash commands: /login /logout /llama /model /thinking /scoped-models /settings /resume /new /name
  /session /tree /trust /fork /clone /compact [prompt] /copy /export [file] /import <file> /share
  /reload /hotkeys /changelog /quit; skills appear as `/skill:name`.
- Keybindings (`~/.pi/agent/keybindings.json`, namespaced ids `tui.editor.*` / `app.*`, arrays
  allowed): Ctrl+L model selector, Ctrl+P cycle model, Shift+Tab cycle thinking, Ctrl+O expand tool
  output, Ctrl+T collapse thinking, Ctrl+Shift+F transcript search, Ctrl+D exit. Emacs and Vim
  preset configs documented.
- Sessions: JSONL auto-saved to `~/.pi/agent/sessions/` by cwd; session **tree** with branching;
  `pi -c` (continue), `pi -r` (browse), `--name`, `--no-session`, `--session`, `--fork`; export
  HTML/JSONL; `/share` = GitHub gist.
- Compaction: auto when contextTokens > contextWindow − reserveTokens; defaults
  `compaction.reserveTokens` 16384, `keepRecentTokens` 20000; manual `/compact [instructions]`;
  branch summaries offered when navigating away in `/tree`.

## Config surface

- Global `~/.pi/agent/`: settings.json, auth.json, keybindings.json, trust.json, sessions/,
  extensions/, skills/, themes/, npm/, git/. Project `.pi/`: settings.json, extensions/, skills/,
  themes/, npm/, git/, SYSTEM.md (replaces system prompt).
- Context files: global `~/.pi/agent/AGENTS.md`; project `AGENTS.md` or `CLAUDE.md` (walked from
  parents); `AGENTS.override.md` wins. `/reload` applies edits live.
- settings.json: project overrides global, nested objects merge. Highlights: model/thinking, theme,
  compaction, retry/backoff, steering delivery, shell path, tools filter, custom session dir,
  Ctrl+P cycling patterns, markdown/Mermaid, `extensions`/`skills`/`prompts`/`themes`/`packages`
  resource arrays, `defaultProjectTrust` (`ask`/`always`/`never`), `npmCommand`.
- Trust: project-local extensions/settings load only after `/trust`; recorded in trust.json.

## Extensions

- TypeScript modules loaded via **jiti** — no compile step. Entry:
  `export default function (pi: ExtensionAPI) { ... }` (async OK).
- Discovery: `~/.pi/agent/extensions/*.ts` or `*/index.ts`; `.pi/extensions/` (after trust);
  settings `extensions` array; one-off `pi -e ./ext.ts`; hot reload `/reload`.
- API: `pi.on(event, handler)`, `pi.registerTool` (TypeBox `parameters`, `execute(toolCallId,
  params, signal, onUpdate, ctx)`, `renderCall`/`renderResult`), `pi.registerCommand`,
  `pi.registerShortcut`, `pi.registerFlag`, `pi.sendMessage`/`sendUserMessage`, `pi.appendEntry`,
  message/entry renderers, `pi.setModel`, `pi.set/getThinkingLevel`, `pi.registerProvider`,
  `pi.exec`, `pi.events` (inter-extension bus).
- Events: `project_trust`, `session_start` (reason: startup|reload|new|resume|fork),
  `session_shutdown`, `session_before_switch/fork/compact`; `before_agent_start` (inject
  message / modify system prompt), `agent_start/end/settled`, `turn_start/end`,
  `message_start/update/end`, `tool_execution_start/update/end`; `context`,
  `before_provider_headers/request`, `after_provider_response`; `tool_call` (block/mutate),
  `tool_result` (modify), `input`; `model_select`, `thinking_level_select`, `resources_discover`.
- ctx: `ui` (select/confirm/input/notify/custom), `cwd`, `isProjectTrusted()`, `sessionManager`,
  `modelRegistry`, `model`, `thinkingLevel`, `getContextUsage()`, `compact()`, `getSystemPrompt()`;
  command ctx adds `newSession`, `fork`, `navigateTree`, `switchSession`, `waitForIdle`, `reload`.
- Types: `@earendil-works/pi-coding-agent` (ExtensionAPI, ExtensionContext), `typebox` (Type),
  `@earendil-works/pi-ai` (StringEnum), `@earendil-works/pi-tui` (Box, Text). npm deps resolve from
  a package.json in the extension dir or parents (`npm install` there; node_modules auto-found).
- Examples: `packages/coding-agent/examples/extensions/` (snake.ts, summarize.ts,
  input-transform.ts).
- SDK: `createAgentSession({sessionManager, modelRuntime, model, tools, customTools,
  resourceLoader, cwd})`; `session.subscribe/prompt/steer/followUp`; `defineTool()`,
  `createCodingTools`, `runPrintMode()`, `runRpcMode()`.

## Packages

- Install: `pi install npm:@foo/bar@1.0.0` · `pi install git:github.com/user/repo@v1` ·
  `pi install https://github.com/user/repo` · `pi install /abs/path`. Manage: `pi list`,
  `pi update [--all | npm:…]`, `pi remove npm:…`. Trial without installing: `pi -e npm:@foo/bar`.
- npm installs land in `~/.pi/agent/npm/` (or `.pi/npm/`); git clones in `~/.pi/agent/git/<host>/…`.
  Version/ref-pinned specs are skipped by `pi update`.
- Manifest: package.json with `"keywords": ["pi-package"]` and a `"pi"` field
  `{extensions, skills, prompts, themes, video, image}` (globs, `!` exclusions) — or convention
  dirs `extensions/ skills/ prompts/ themes/`. settings `packages` array supports filtered entries.
- Publishing: plain `npm publish` with the `pi-package` keyword; pi.dev/packages auto-discovers.
- Security (docs, quote verbatim in the guide): "Pi packages run with full system access.
  Extensions execute arbitrary code, and skills can instruct the model to perform any action
  including running executables."

## Skills / prompts / themes

- Skills: Agent Skills standard — SKILL.md + YAML frontmatter (name ≤64, description ≤1024,
  optional license/compatibility/metadata/allowed-tools/disable-model-invocation). Discovered from
  `~/.pi/agent/skills/`, `~/.agents/skills/`, `.pi/skills/`, `.agents/skills/` (up to git root).
  Invoked as `/skill:name`. (https://pi.dev/docs/latest/skills)
- Themes: JSON, built-ins dark/light auto-picked from terminal bg; **51 required color tokens**
  (core UI, backgrounds, markdown, diffs, 9 syntax, 7 thinking-level borders, bashMode); values =
  hex / palette index / var ref / "" (terminal default). Hot reload while editing. Optional
  `export` section styles `/export` HTML. Switch via /settings, settings.json, `--use-theme`.
  Schema: raw.githubusercontent.com/earendil-works/pi/main/packages/coding-agent/src/modes/interactive/theme/theme-schema.json
- MCP is **not in core** — provided by the `pi-mcp-adapter` package (deliberate minimal-core
  design; reads standard `.mcp.json` so Claude Code MCP configs carry over).

## The 12 packages (registry data 2026-08-27; install: `pi install npm:<name>`)

| Package | Author | Ver | DL/mo | What it does |
| --- | --- | --- | --- | --- |
| pi-mcp-adapter | nicopreme | 2.29.0 | 628.2K | MCP via one ~200-token `mcp()` proxy tool (search/describe/call/auth) instead of ~10K tokens of upfront defs; `/mcp` commands; reads `.mcp.json`; OAuth + approval gates. #1 by downloads. |
| pi-web-access | nicopreme | 0.25.0 | 384K | Web search (OpenAI/Brave/Exa/Tavily/Firecrawl/Jina…), URL→markdown, repo cloning, PDF extraction, video analysis, fact-checking with citations. Tools: web_search, fetch_content, source_check. |
| pi-subagents | nicopreme | 0.58.0 | 340.9K | Delegation + scripted multi-agent workflows; six built-ins (scout, researcher, worker, reviewer, oracle, delegate); /council, /parallel-review, /review-loop, /subagents-fleet. |
| @companion-ai/feynman | advaitpaliwal (Companion) | 0.3.47 | 252.8K | "Research-first CLI agent built on Pi and alphaXiv" (feynman.is) — a full CLI app built on Pi as a platform; own installer, cited research briefs, deepresearch mode. NOTE: pi.dev detail page returned HTTP 500 at harvest — re-check; fall back to registry listing + github.com/companion-inc/feynman. |
| pi-background-tasks | ismailsaleekh | 2.4.2 | 107.1K | Durable background shell tasks, read-only delegated child-Pi agents, attested runs, multi-model "Fusion" workflows; 11 commands (/bg /jobs /kill /logs /fusion…), 11 tools. |
| context-mode | mksglu | 1.0.169 | 81.7K | "Saves 98% of your context window": sandboxed code execution (12 languages), FTS5 indexing, retrieval instead of raw output; cross-agent. Tools: ctx_execute, ctx_search, ctx_index… Elastic License 2.0. |
| pi-lens | apmantza | 4.1.2 | 58K | LSP diagnostics + impact-cascade across related files, per-edit lint/type-check, safe autofix, AST rules, security/dependency scanning, ranked symbol search; /lens-map, /lens-health. |
| @plannotator/pi-extension | backnotprop | 0.27.8 | 50.9K | File-based plan mode with a visual browser UI to review/annotate/approve plans; read-only exploration during planning; code-review UI; /plannotator-plan-mode (Ctrl+Alt+P). |
| @dietrichgebert/ponytail | dietrichgebert | 4.9.0 | 49.2K | "Lazy senior dev mode" — decision-ladder anti-over-engineering skill (prefer native/stdlib/existing deps); /ponytail [lite|full|ultra|off], /ponytail-review, -audit, -debt. Cross-platform. |
| pi-memory | jayzeng | 0.4.2 | 35.7K | Persistent memory across sessions: curated long-term memory + append-only daily logs + scratchpad; keyword/semantic/hybrid search. Tools: memory_write/read/search/forget, scratchpad. |
| @ersintarhan/pi-toolkit | ersintarhan | 0.11.0 | 1.8K | Claude OAuth compat adapter, native web search + /search, `context` tool (anchor/view/pivot/recall), /context window reporting, /usage quotas, status footer, SSRF protection; six toggleable features. |
| @gotgenes/pi-github-tools | gotgenes | 4.4.0 | 1.1K | Deterministic GitHub CI/release tools replacing ad-hoc `gh` polling: ci_find/ci_watch/ci_list, release_pr_find/merge, release_watch, issue_close; zero deps. |

## Deep-link map

All under `https://pi.dev/docs/latest/`: (index) · quickstart · usage · providers · security ·
containerization · settings · keybindings · sessions · compaction · extensions · skills ·
prompt-templates · themes · packages · models · custom-provider · sdk · rpc · json · tui ·
session-format · environment-variables · windows · termux · tmux · terminal-setup · shell-aliases ·
development. Plus: https://pi.dev/packages · https://pi.dev/models · https://pi.dev/news ·
https://github.com/earendil-works/pi (coding agent at `packages/coding-agent/`).
Docs have on-site search (Cmd+K) for build-time lookups.

## tmux fix (featured in Recommended Setup)

Add to `~/.tmux.conf`, then restart tmux fully (Shift+Enter / Ctrl+Enter are otherwise
indistinguishable from Enter):

```text
set -g extended-keys on
set -g extended-keys-format csi-u
```

## pi.dev visual identity (for the guide's synced theme)

Paper-light "engineer's notebook": graph-paper ground, serif-italic display (Plantin MT Pro),
mono small-caps labels (Commit Mono / Departure Mono). Stylesheet accents: `--accent: #6a9fcc`
(steel blue), `--accent-rust: #8f3222`, dark-mode grounds `#0d1116` / `#161d27`.
Guide mapping: paper `#F4F2ED`, ink `#1C222B`, accent `#3D6E9E` (AA-darkened #6a9fcc),
rust `#8F3222`; Google Fonts stand-ins: Source Serif 4 (italic display), Inter (body),
IBM Plex Mono (labels/code).
