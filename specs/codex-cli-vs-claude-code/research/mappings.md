# Feature-mapping resolutions: Codex CLI vs Claude Code

All citations refer to files in this directory (`specs/codex-cli-vs-claude-code/research/`), harvested
2026-08-12. Compiled from the local corpus only — no network fetches during resolution.

Abbreviations used in citations:

- **Manual** = `codex-manual.md` (the 1.9 MB condensed Codex manual; the *only* Codex source with
  fully-rendered flag / command / config tables — the per-page `.md` twins leave MDX
  `<ConfigTable client:load .../>` placeholders unexpanded).
- **Dev commands** = `codex-developer-commands.md`.
- **Config ref** = `codex-config-file-config-reference.md`.

Confidence convention, inherited from the copilot guide: an item that the corpus does not settle is
marked **`Downgrade: .p`** (partial, with a footnote in the guide). Never "doesn't exist" unless a doc
sentence says so. Glyphs in the guide: `.gy` = documented, `.gp` = partial/conditional, `.gn` = not
documented.

---

## §01 — The vendor-published mapping

### 1. Does either vendor publish an official Claude Code ↔ Codex mapping?

**Resolved:** Yes — OpenAI does, and it is authoritative for the guide's spine. The `/import` flow
("Import from another agent") migrates a Claude Code setup into Codex and publishes a destination table:
Instruction files → `AGENTS.md`; `settings.json` → `config.toml`; Skills → Skills; Plugins → Plugins;
Project memories from Claude Code → Memories; MCP server configuration → Codex MCP configuration;
Hooks → Codex hooks; **Slash commands → Skills**; Subagents → Codex agents. The doc states the desktop
app can import from "**Claude Code**, **Claude Cowork**, or **Cursor**", and "Codex CLI can import from
**Claude Code** or **Cursor**." In the CLI the entry point is the `/import` slash command; it "imports
up to 50 chats from the last 30 days" and "isn't available during a running task, in a remote session,
or while connected to a local app-server daemon."

**Citation:** `codex-import.md` — "Import from another agent", "What ChatGPT can import",
"Import in Codex CLI"; Manual — "Slash commands in Codex CLI" (`/import` row).

### 2. Model families and reasoning-effort vocabulary

**Resolved:** Codex names models `gpt-5.6` (default for demanding agents), `gpt-5.6-terra` (faster,
lower cost), `gpt-5.6-luna` (fast, narrowly scoped). Reasoning effort is a separate axis,
`model_reasoning_effort`, with documented values `ultra`, `max`, `xhigh`, `high`, `medium`, `low`; the
CLI flag is `--effort {minimal,low,medium,high,xhigh}`. Claude Code exposes `--model` plus `--effort`
and `/effort`. Both therefore split "which model" from "how hard it thinks", with different level names.

**Citation:** `codex-agent-configuration-subagents.md` — "Model choice", "Reasoning effort
(`model_reasoning_effort`)"; Manual — global flag table (`--effort`); `claude-cli-reference.md` —
flag list (`--model`, `--effort`); `claude-commands.md` — `/effort`.

---

## §02 — Config & context files

### 3. Project instruction file

**Resolved:** `CLAUDE.md` ↔ `AGENTS.md`. Codex "reads `AGENTS.md` files before doing any work" and
builds an instruction chain with a documented precedence: (1) global scope — `~/.codex/AGENTS.override.md`
if present, else `~/.codex/AGENTS.md`, "only the first non-empty file at this level"; (2) project scope
— walk from the project root (typically the Git root) down to the cwd, checking
`AGENTS.override.md`, then `AGENTS.md`, then `project_doc_fallback_filenames`, "at most one file per
directory"; (3) merge from the root down, "[f]iles closer to your current directory override earlier
guidance." Claude Code's equivalent is `CLAUDE.md` (project root or `.claude/CLAUDE.md`), plus
`CLAUDE.local.md` for private preferences and `.claude/rules/*.md` for path-scoped topic files.

**Citation:** `codex-agent-configuration-agents-md.md` — "How Codex discovers guidance", "Layer project
instructions"; `claude-claude-directory.md` — `CLAUDE.md` entry ("Also works at `.claude/CLAUDE.md`"),
`CLAUDE.local.md` row, `rules/` entry.

### 4. Size cap on project instructions

**Resolved:** Codex documents a hard cap: it "skips empty files and stops adding files once the combined
size reaches the limit defined by `project_doc_max_bytes` (32 KiB by default)." Claude Code documents a
soft guideline instead — "Target under 200 lines. Longer files still load in full but may reduce
adherence." So Codex truncates, Claude Code degrades. This is a real behavioral difference worth a
gotcha card.

**Citation:** `codex-agent-configuration-agents-md.md` — "How Codex discovers guidance";
`claude-claude-directory.md` — `CLAUDE.md` tips.

### 5. Alternate instruction filenames

**Resolved:** Codex supports `project_doc_fallback_filenames` in `config.toml`, e.g.
`project_doc_fallback_filenames = ["TEAM_GUIDE.md", ".agents.md"]`, after which discovery order per
directory becomes `AGENTS.override.md`, `AGENTS.md`, `TEAM_GUIDE.md`, `.agents.md`. "Filenames not on
this list are ignored for instruction discovery." No equivalent rename knob is documented for
`CLAUDE.md` in this corpus. **Downgrade: `.p`** on the Claude side (absence of a doc statement, not a
documented absence).

**Citation:** `codex-agent-configuration-agents-md.md` — "Customize fallback filenames".

### 6. Machine-enforced settings file

**Resolved:** `settings.json` (JSON) ↔ `config.toml` (TOML) — this is OpenAI's own stated import
destination. Codex user config is `~/.codex/config.toml`; project overrides are `.codex/config.toml`,
and "Codex loads project `.codex/` layers only when you trust the project." Claude Code's equivalents
are `~/.claude/settings.json`, `.claude/settings.json` (committed), `.claude/settings.local.json`
(personal, gitignored) and enterprise `managed-settings.json`.

**Citation:** `codex-config-file-config-basic.md` — "Codex configuration file"; `codex-import.md` —
"What ChatGPT can import"; `claude-claude-directory.md` — `settings.json`, `settings.local.json`,
`managed-settings.json` entries.

### 7. Config precedence

**Resolved:** Codex resolves highest-first: (1) CLI flags and `--config` overrides; (2) project
`.codex/config.toml`, root down to cwd, closest wins, trusted projects only; (3) profile files selected
with `--profile NAME` (`~/.codex/NAME.config.toml`); (4) user `~/.codex/config.toml`; (5) system
`/etc/codex/config.toml` on Unix; (6) built-in defaults. Claude Code's documented order is local
settings and CLI flags over project `settings.json` over global `~/.claude/settings.json`, with managed
settings overriding all; array settings such as `permissions.allow` combine across scopes while scalar
settings like `model` take the local value. **Named profile files are a Codex-only layer in this corpus
— Downgrade: `.p`** on the Claude side.

**Citation:** `codex-config-file-config-basic.md` — "Configuration precedence";
`claude-claude-directory.md` — `settings.json` ("Overrides global `~/.claude/settings.json`. Local
settings, CLI flags, and managed settings override this"), `settings.local.json` tips.

### 8. Home directory and its override variable

**Resolved:** `~/.claude` + `CLAUDE_CONFIG_DIR` ↔ `~/.codex` + `CODEX_HOME`. `CODEX_HOME` "[s]ets the
root for Codex state, including config, auth, logs, sessions, skills, and standalone package metadata.
If you set it, the directory must already exist." Documented `~/.codex` contents: `config.toml`,
`auth.json` (or OS keychain), `history.jsonl` (if history persistence is enabled), plus logs and caches;
also `agents/`, `rules/`, `hooks.json` per their own pages. Claude Code's `~/.claude` holds
`settings.json`, `CLAUDE.md`, `skills/`, `commands/`, `agents/`, `projects/<project>/<session>.jsonl`,
`history.jsonl`, `plans/`, `file-history/`, `shell-snapshots/`, and more.

**Citation:** `codex-config-file-environment-variables.md` — "Core locations";
`codex-config-file-config-advanced.md` — "Config and state locations"; `claude-claude-directory.md` —
`~/.claude` tables.

### 9. Skills directory

**Resolved:** **Not a parallel path — this is the single most surprising mapping.** Codex skills live at
`~/.agents/skills` (global) and `.agents/skills` (repo), *not* under `~/.codex`: "Skills can be global
(in your user directory, for you as a developer) or repo-specific (checked into `.agents/skills`, for
your team)." The doc's own layer table reads `AGENTS: ~/.codex/AGENTS.md | AGENTS.md in repo root`,
`Skills: ~/.agents/skills | .agents/skills in repo`. Claude Code uses `~/.claude/skills/` and
`.claude/skills/`. Both use a `SKILL.md` with `name` + `description` frontmatter and optional
`scripts/`, `references/`, `assets/`, and both use progressive disclosure.

**Citation:** `codex-customization-overview.md` — "Skills" (layer table, `SKILL.md` example,
"progressive disclosure"); `claude-claude-directory.md` — `skills/` entry.

### 10. Subagent definition files

**Resolved:** `.claude/agents/*.md` (markdown + YAML frontmatter) ↔ `~/.codex/agents/*.toml` and
`.codex/agents/*.toml` (standalone TOML). Codex: "add standalone TOML files under `~/.codex/agents/`
for personal agents or `.codex/agents/` for project-scoped agents." Required fields are `name`,
`description`, `developer_instructions`; a file may also carry any supported `config.toml` key such as
`model`, `model_reasoning_effort`, `sandbox_mode`, `mcp_servers`, `skills.config`. Codex ships built-in
agents `default`, `worker`, `explorer`; "[i]f a custom agent name matches a built-in agent such as
`explorer`, your custom agent takes precedence." Codex candidly notes the format "can feel heavier than
a dedicated agent manifest, and the format may evolve."

**Citation:** `codex-agent-configuration-subagents.md` — "Custom agents", "Custom agent file schema",
"Global settings"; `claude-claude-directory.md` — `agents/` entry.

### 11. Custom slash commands

**Resolved:** Both products have collapsed custom slash commands into skills, independently and in the
same direction. Codex's `custom-prompts` page is titled "Custom Prompts" and described in the index as
"**Deprecated. Use skills for reusable prompts**"; the `/import` table routes Claude Code slash commands
to **Skills**. Claude Code says the same of its own two mechanisms: "Commands and skills are now the
same mechanism. For new workflows, use `skills/` instead: same `/name` invocation, plus you can bundle
supporting files", and "[a] file at `commands/deploy.md` creates `/deploy` the same way a skill at
`skills/deploy/SKILL.md` does." So: Claude Code still supports `.claude/commands/*.md` but points new
work at skills; Codex has deprecated its equivalent outright.

**Citation:** `codex-import.md` — "What ChatGPT can import" (Slash commands → Skills);
`codex-llms.txt` index entry for Custom Prompts (reproduced in the guide's §12 source list);
`claude-claude-directory.md` — `commands/` entry, commands note.

### 12. Memory

**Resolved:** Both have a memory feature distinct from the instruction file, and OpenAI maps them
directly: "Project memories from Claude Code → Memories". Codex exposes `/memories` to "[c]onfigure
whether the chat can use or generate memories, when Memories is available." Claude Code exposes
`/memory` (which "open[s] and edit[s] CLAUDE.md from within a session") plus auto memory in the
`.claude` directory. The two are close but not identical: Codex's `/memories` toggles memory
*generation*; Claude Code's `/memory` opens the instruction file. **Downgrade: `.p`** — related, not
equivalent.

**Citation:** `codex-import.md` — "What ChatGPT can import"; Manual — "Slash commands in Codex CLI"
(`/memories`); `codex-customization-memories.md`; `claude-claude-directory.md` — `CLAUDE.md` tips
(`/memory`).

---

## §03 — CLI invocation & flags

### 13. Interactive launch, one-shot, and resume

**Resolved:** `claude` ↔ `codex`. Headless is `claude -p "…"` / `--print` ↔ `codex exec "…"` — a
subcommand, not a flag, which is the highest-traffic gotcha for a switcher. Resume: `claude --continue`
/ `-c` and `claude --resume` / `-r` ↔ `codex resume` (interactive) and `codex exec resume` (headless).
`codex resume` "scopes `--last` to the current working directory unless you pass `--all`", and accepts a
session ID: `codex exec resume <SESSION_ID>`. Codex also asks which directory to use when cwd differs
from the session's saved directory, controlled by `tui.resume_cwd` (`"current"` or `"session"`), with an
explicit `--cd`/`-C` taking precedence.

**Citation:** Dev commands — "`codex resume`"; `codex-non-interactive-mode.md` — "Basic usage", "Resume
a non-interactive session"; `claude-cli-reference.md` — flag list (`--print`, `--continue`, `--resume`).

### 14. The yolo flag

**Resolved:** `--dangerously-skip-permissions` ↔ `--dangerously-bypass-approvals-and-sandbox`, alias
`--yolo`. The Codex combinations table lists it under "Dangerous full access" with the effect "No
sandbox; no approvals *(not recommended)*" and an elevated-risk badge. Note Claude Code also has
`--allow-dangerously-skip-permissions` as a separate flag in its reference. Both names are deliberately
unwieldy; only Codex ships a short alias.

**Citation:** `codex-agent-approvals-security.md` — "Common sandbox and approval combinations"; Manual —
global flag table (`--dangerously-bypass-approvals-and-sandbox, --yolo`); `claude-cli-reference.md` —
flag list.

### 15. Tool allow/deny flags

**Resolved:** **No direct flag equivalent — the mechanisms differ in kind.** Claude Code has
`--allowed-tools` / `--disallowed-tools` (and `--tools`, `--permission-mode`) that name *tools*. Codex
has no per-tool allow/deny flag in the corpus; it governs *commands* through execpolicy `.rules` files
(see §05 item 19) and governs *filesystem/network* through `--sandbox` and permission profiles. The
closest Codex flags are the negative ones: `--ignore-rules` ("skip user and project execpolicy `.rules`
files") and `--ignore-user-config` ("a run that doesn't load `$CODEX_HOME/config.toml`"). MCP tools do
get allow/deny lists, but in config not flags: `mcp_servers.<id>.enabled_tools` ("Allow list of tool
names exposed by the MCP server") and `disabled_tools` ("Deny list applied after `enabled_tools`").
**Downgrade: `.p`** — do not render this row as a clean pair.

**Citation:** Manual — global flag table, config reference rows `mcp_servers..enabled_tools` /
`..disabled_tools`; `codex-non-interactive-mode.md` — "Permissions and safety";
`claude-cli-reference.md` — flag list.

### 16. Structured / machine-readable output

**Resolved:** Both support it, with different flag names and a genuine capability difference in Codex's
favor on schemas. Claude Code: `--output-format` (incl. stream-json), `--json`, `--json-schema`,
`--include-partial-messages`. Codex: `--json` / `--experimental-json` makes stdout "a JSON Lines (JSONL)
stream", with event types `thread.started`, `turn.started`, `turn.completed`, `turn.failed`, `item.*`,
`error`. Codex additionally offers `--output-schema <file>` to "request a final response that conforms
to a JSON Schema", and `-o` / `--output-last-message <path>`. Baseline behavior: "Codex streams progress
to `stderr` and prints only the final agent message to `stdout`."

**Citation:** `codex-non-interactive-mode.md` — "Make output machine-readable", "Create structured
outputs with a schema", "Basic usage"; `claude-cli-reference.md` — flag list.

### 17. Working directory and extra directories

**Resolved:** `--add-dir` exists on **both** with the same name. Codex additionally has `--cd` / `-C` to
set the working directory at launch (`codex --cd services/payments …`); Claude Code's reference lists
`--add-dir` but no `--cd` equivalent in this corpus. **Downgrade: `.p`** for the `--cd` row.

**Citation:** Manual — global flag table (`--add-dir`, `--cd, -C`);
`codex-agent-configuration-agents-md.md` — "Layer project instructions" (`codex --cd` example);
`claude-cli-reference.md` — flag list.

### 18. Ad-hoc config override

**Resolved:** `codex -c KEY=VALUE` / `--config` sets any `config.toml` key inline, e.g.
`codex -c log_dir=./.codex-log`. Claude Code has `--config` and `--settings` plus `--setting-sources`.
Both exist; TOML-vs-JSON quoting differs.

**Citation:** `codex-config-file-config-basic.md` — "Configuration precedence";
`codex-agent-configuration-agents-md.md` — "Verify your setup"; `claude-cli-reference.md` — flag list.

### 19. Subcommand surface

**Resolved:** Codex: `exec`, `resume`, `fork`, `login`, `logout`, `mcp`, `plugin`, `doctor`,
`completion`, `apply`, `review`, `archive`/`unarchive`, `delete`, `cloud`, `app`, `app-server`,
`remote-control`, `execpolicy`, `features`, `debug …`. Claude Code: `mcp`, `plugin`, `agents`, `auth`,
`doctor`, `update`, `install`, `import`, `project`, `remote-control`, `daemon`, `logs`, `stop`,
`attach`, `respawn`, `rm`, `setup-token`, `gateway`, `auto-mode`, `self-hosted-runner`, `ultrareview`.
Shared names: `mcp`, `plugin`, `doctor`, `remote-control`. Notable: `codex doctor` ↔ `claude doctor`;
`codex completion` (shell completions) has no listed Claude counterpart — **Downgrade: `.p`**.

**Citation:** Dev commands — "Command overview", "Command details" headings; Manual — command overview
table; `claude-cli-reference.md` — `claude <subcommand>` rows.

---

## §04 — Slash commands & keys

### 20. Which slash commands map 1:1

**Resolved:** Direct name matches across both products: `/clear`, `/compact`, `/model`, `/plan`,
`/review`, `/status`, `/resume`, `/new`, `/fork`, `/init`, `/mcp`, `/hooks`, `/skills`, `/permissions`,
`/import`, `/feedback`, `/logout`, `/diff`, `/theme`, `/vim`, `/statusline`, `/usage`, `/fast`, `/app`,
`/ide`, `/quit`, `/exit`, `/stop`, `/btw`. Near matches: Codex `/agent`, `/subagents` ↔ Claude
`/agents`; Codex `/keymap` ↔ Claude `/keybindings`; Codex `/memories` ↔ Claude `/memory`; Codex
`/mention` ↔ Claude `@` file mentions; Codex `/side` ↔ Claude `/btw` (Claude has both spellings).
`/init` means the same thing on both sides: Codex "[g]enerate an `AGENTS.md` scaffold for the current
project."

**Citation:** Manual — "Slash commands in Codex CLI" → "Built-in slash commands" (50-row table);
`claude-commands.md` — command list.

### 21. Codex-only slash commands

**Resolved:** Not matched by name in the Claude corpus: `/approve` (approve one retry of an
automatic-review denial), `/goal` (set a persistent goal Codex works toward), `/personality`,
`/worktree` (run the chat in a new Git worktree — Claude has `--worktree` as a *flag* and
`/branch`, so **Downgrade: `.p`** rather than `.gn`), `/cloud`, `/cloud-environment`, `/local`,
`/ide-context`, `/project`, `/raw`, `/ps`, `/rename`, `/archive`, `/delete`, `/copy`, `/apps`,
`/plugins`, `/experimental`, `/debug-config`, `/title`, `/pets` (Claude has `/stickers`, not pets),
`/setup-default-sandbox` and `/sandbox-add-read-dir` (both Windows-only).

**Citation:** Manual — "Built-in slash commands" table; `claude-commands.md` — command list;
`claude-cli-reference.md` — `--worktree` flag.

### 22. Claude-only slash commands

**Resolved:** No Codex counterpart found for, among others: `/rewind` and `/undo` (checkpoint restore),
`/context`, `/cost`, `/security-review`, `/code-review`, `/deep-research`, `/agents` management,
`/add-dir`, `/allowed-tools`, `/bashes`, `/background`, `/schedule`, `/routines`, `/workflows`,
`/subtask`, `/teleport`, `/install-github-app`, `/install-slack-app`, `/setup-bedrock`, `/setup-vertex`,
`/terminal-setup`, `/doctor`, `/help`, `/config`, `/settings`, `/login`, `/bug`, `/simplify`,
`/verify`, `/recap`, `/insights`, `/stats`. Note Codex reaches several of these through subcommands
instead of slash commands (`codex doctor`, `codex login`, `codex review`), so the honest framing is
"different surface", not "missing" — treat surface-shifted items as `.gp`.

**Citation:** `claude-commands.md` — command list; Manual — "Built-in slash commands" table, command
overview table.

### 23. Plan mode

**Resolved:** Both have it, reached differently. Codex uses the `/plan` slash command — "Switch to plan
mode and optionally send a prompt" / "Toggle plan mode for multi-step planning." Claude Code has `/plan`
*and* `plan` as one of its permission modes cycled with Shift+Tab. So a Claude user's Shift+Tab muscle
memory does not carry over; **Downgrade: `.p`** on the key-binding row (no Codex Shift+Tab
plan-toggle documented in this corpus).

**Citation:** Manual — "Built-in slash commands" (`/plan`), shared command table (`/plan`);
`claude-permission-modes.md` — mode table (`plan`), Shift+Tab cycling; `claude-commands.md` — `/plan`.

### 24. Queuing commands mid-turn

**Resolved:** Codex-specific behavior worth a gotcha: "When a chat is already running, you can type a
slash command and press `Tab` to queue it for the next turn. Codex parses queued slash commands when
they run, so command menus and errors appear after the current turn finishes."

**Citation:** Manual — "Built-in slash commands" (preamble).

---

## §05 — Customization surfaces & hooks

### 25. Full hook event lists, both sides

**Resolved:** Codex documents exactly 11 events, grouped by when they fire: during a turn —
`PreToolUse`, `PermissionRequest`, `PostToolUse`, `PreCompact`, `PostCompact`, `UserPromptSubmit`,
`SubagentStop`, `Stop`; when a session or subagent starts — `SessionStart`, `SubagentStart`; when the
main thread ends — `SessionEnd` ("doesn't run for subagents"). **Every one of those names also exists in
Claude Code**, whose event set is a strict superset and additionally includes `ConfigChange`,
`CwdChanged`, `DirectoryAdded`, `Elicitation`, `ElicitationResult`, `FileChanged`, `InstructionsLoaded`,
`MessageDisplay`, `Notification`, `PermissionDenied`, `PostToolBatch`, `PostToolUseFailure`, `Setup`,
`StopFailure`, `TaskCompleted`, `TaskCreated`, `TeammateIdle`, `UserPromptExpansion`, `WorktreeCreate`,
`WorktreeRemove`. This is the guide's headline finding: **Codex's hook events are a strict, name-identical
subset of Claude Code's.**

**Citation:** `codex-hooks.md` — "Hooks run at different points in a conversation" table, and the
per-event `###` sections; `claude-hooks.md` — per-event `###` sections.

### 26. Hook config location and file format

**Resolved:** Schema-compatible JSON on both sides. Codex "discovers hooks next to active config layers
in either of these forms: `hooks.json`; inline `[hooks]` tables inside `config.toml`", and names the four
most useful locations as `~/.codex/hooks.json`, `~/.codex/config.toml`, `<repo>/.codex/hooks.json`,
`<repo>/.codex/config.toml`. Claude Code puts hooks in `~/.claude/settings.json`,
`.claude/settings.json`, and plugin `hooks/hooks.json`. Both use the same three-level shape — event →
matcher group → handlers — with `"type": "command"`, `"command"`, `"matcher"`, and `"timeout"`. Codex
adds `statusMessage`, `additionalContextLimit` (default 2500 tokens; `0` passes full context),
`async`, and `commandWindows`. Merge semantics on both: all matching hooks run; "[h]igher-precedence
config layers don't replace lower-precedence hooks."

**Citation:** `codex-hooks.md` — "Where Codex looks for hooks", "Config shape"; Config ref — `hooks`,
`hooks.`, `hooks.[].hooks[].additionalContextLimit`, `..async`, `..commandWindows` rows;
`claude-hooks.md` — settings-location table, plugin `hooks/hooks.json`.

### 27. Hook blocking semantics

**Resolved:** Near-identical. Codex: "To deny a supported tool call, return … `permissionDecision:
"deny"` with `permissionDecisionReason`"; also `"decision": "block"`; and "You can also use exit code
`2` and write the blocking reason to `stderr`." Allow-with-rewrite is supported via
`permissionDecision: "allow"` with `updatedInput`. Claude Code uses the same `permissionDecision` /
`permissionDecisionReason` fields and the same exit-code-2 convention, with a per-event table of what
exit code 2 does ("`PreToolUse` blocks the tool call, `UserPromptSubmit` rejects the prompt").

**Citation:** `codex-hooks.md` — "PreToolUse" section; `claude-hooks.md` — "Exit code 2", "Decision
control", `permissionDecision` examples.

### 28. Hook trust — a Codex-only safety layer

**Resolved:** Codex gates hooks behind an explicit, hash-pinned trust review that Claude Code does not
document: "Before a non-managed command hook can run, Codex requires you to review and trust the exact
hook definition. Codex records trust against the hook's current hash, so new or changed hooks are marked
for review and skipped until trusted." Inspection and trusting happen through `/hooks`. Managed hooks
"from system, MDM, cloud, or `requirements.toml` sources are marked as managed, trusted by policy, and
can't be disabled." The escape hatch is `--dangerously-bypass-hook-trust`. Project-local hooks "load
only when the project `.codex/` layer is trusted."

**Citation:** `codex-hooks.md` — "Review and trust hooks", "Where Codex looks for hooks"; Manual —
global flag table (`--dangerously-bypass-hook-trust`).

### 29. Rules — Codex's command-level policy engine

**Resolved:** Codex's `.rules` files have no Claude Code counterpart in kind, and this is the biggest
architectural divergence in the guide. Rules "control which commands Codex can run outside the sandbox",
live under a `rules/` folder next to any active config layer (`~/.codex/rules/default.rules`,
`<repo>/.codex/rules/`), and are written in **Starlark** — "[i]ts syntax is like Python, but it's
designed to be safe to run." The single documented primitive is `prefix_rule()` with fields `pattern`
(required), `decision` (`allow` | `prompt` | `forbidden`, default `allow`), `justification`, and
`match` / `not_match` inline unit tests. "Codex applies the most restrictive decision when more than one
rule matches (`forbidden` > `prompt` > `allow`)." Compound commands are split with tree-sitter when the
script is a linear chain of plain words joined by `&&`, `||`, `;`, `|` — so "[e]ven if you allow
`pattern=["git", "add"]`, Codex won't auto allow `git add . && rm -rf /`" — but scripts using
redirection, substitution, variables, wildcards, or control flow are evaluated as one opaque
`["bash", "-lc", "<full script>"]` invocation. Rules are testable offline with
`codex execpolicy check --pretty --rules … -- <cmd>`. Accepting a command in the TUI writes to
`~/.codex/rules/default.rules`. Rules are marked **experimental**: "Rules are experimental and may
change." Claude Code's nearest analogue is `permissions.allow` / `deny` / `ask` string patterns in
`settings.json` — declarative strings, not a scripting language, and no inline unit tests.

**Citation:** `codex-agent-configuration-rules.md` — entire page; `claude-claude-directory.md` —
`settings.json` entry ("Permissions control which commands and tools Claude can use").

### 30. MCP

**Resolved:** Both ship a first-class MCP CLI. `claude mcp` ↔ `codex mcp`, which "[m]anage[s] Model
Context Protocol server entries stored in `~/.codex/config.toml`" with `add`, `list`, `login`, `logout`
documented by example (`codex mcp add context7 -- npx -y @upstash/context7-mcp`;
`codex mcp add openaiDeveloperDocs --url https://developers.openai.com/mcp`; `codex mcp login <server>`).
"OAuth actions (`login`, `logout`) only work with streamable HTTP servers (and only when the server
supports OAuth)." Codex config keys are rich: `enabled_tools`/`disabled_tools`,
`default_tools_approval_mode` (`auto | prompt | writes | approve`), `bearer_token_env_var`,
`http_headers`, `env_http_headers`, `oauth_resource`, `experimental_environment` (`local | remote`),
and `required = true` — if a required server fails to initialize, "`codex exec` exits with an error
instead of continuing without that server."

**Citation:** Dev commands — "`codex mcp`"; `codex-extend-mcp.md` — usage examples; Config ref —
`mcp_servers..*` rows; `codex-non-interactive-mode.md` — "Permissions and safety".

### 31. Codex as an MCP server

**Resolved:** Both directions exist on the Codex side: `codex mcp` consumes servers, and the separate
`mcp-server` page covers invoking "Codex as an MCP server to build multi-agent development workflows"
with the Agents SDK. Claude Code's corresponding surface in this corpus is the Agent SDK rather than an
MCP-server mode. **Downgrade: `.p`** — do not assert Claude Code lacks it.

**Citation:** `codex-mcp-server.md` — "Use Codex with the Agents SDK"; `codex-codex-sdk.md`.

### 32. Plugins

**Resolved:** Both have a plugin layer that packages skills for distribution, and both expose a `plugin`
subcommand (`codex plugin`, `claude plugin`) and a browser (`/plugins`, `/reload-plugins`). Codex frames
the relationship crisply: "Skills remain the authoring format; plugins are the installable distribution
unit." Plugins can bundle MCP servers and lifecycle hooks; plugin-bundled hooks "load alongside other
hook sources and use the same trust-review flow." A skill's MCP dependency is declared in
`agents/openai.yaml`.

**Citation:** `codex-customization-overview.md` — "Skills", "Skills + MCP together"; `codex-hooks.md` —
"Plugin-bundled hooks"; Dev commands — "`codex plugin`"; `claude-plugins-reference.md`.

### 33. Subagent orchestration and global caps

**Resolved:** Codex settings live under `[agents]` in config: `agents.enabled` (default `true`),
`agents.max_concurrent_threads_per_session` (legacy alias `agents.max_threads`),
`agents.default_subagent_model`, `agents.default_subagent_reasoning_effort`, `agents.interrupt_message`.
"Subagents inherit your current sandbox policy", and "Codex … reapplies the parent turn's live runtime
overrides when it spawns a child … such as `/permissions` changes or `--yolo`, even if the selected
custom agent file sets different defaults" — a security-relevant gotcha. In the CLI, `/agent` switches
between live agent threads, and approval requests can surface from inactive threads (press `o` to open
the source thread). "In non-interactive flows … an action that needs new approval fails and Codex
surfaces the error back to the parent workflow."

**Citation:** `codex-agent-configuration-subagents.md` — "Global settings", "Approvals and sandbox
controls", "Managing subagents".

---

## §06 — Permissions & safety

### 34. The two-axis model

**Resolved:** Codex separates sandbox from approvals explicitly: "The **sandbox** defines which files
and network resources ChatGPT can access. **Approvals** determine when ChatGPT pauses before an action
or sends the request to automatic review", and crucially "[c]hanging who reviews a request doesn't
expand the sandbox." Sandbox values: `read-only`, `workspace-write`, `danger-full-access`. Approval
values for `--ask-for-approval` / `approval_policy`: `untrusted`, `on-request`, `never` (plus a
`granular` table form with `sandbox_approval`, `rules`, `mcp_elicitations`, `request_permissions`,
`skill_approval`). Claude Code instead exposes a single ordered permission-mode axis: `default`,
`acceptEdits`, `plan`, `auto`, `dontAsk`, `bypassPermissions`. **This is a genuine model mismatch —
Claude Code's one dial vs Codex's two — and is the right subject for a gotcha card.**

**Citation:** `codex-permission-modes.md` — "How permissions work"; `codex-agent-approvals-security.md`
— "Common sandbox and approval combinations", "Configuration in `config.toml`";
`claude-permission-modes.md` — mode table, decision table.

### 35. Documented preset combinations

**Resolved:** Codex publishes a combinations table: Auto (preset) = no flags, or
`--sandbox workspace-write --ask-for-approval on-request`; safe read-only browsing =
`--sandbox read-only --ask-for-approval on-request`; read-only non-interactive CI =
`--sandbox read-only --ask-for-approval never`; edit-but-ask-before-untrusted-commands =
`--sandbox workspace-write --ask-for-approval untrusted`; auto-review =
`… -c approvals_reviewer=auto_review`; dangerous full access = `--yolo`. With `untrusted`, "Codex runs
only known-safe read operations automatically."

**Citation:** `codex-agent-approvals-security.md` — "Common sandbox and approval combinations".

### 36. Named permission profiles

**Resolved:** Codex-only in this corpus. "Codex also supports named permission profiles for reusable
filesystem and network policies. Built-in profiles are `:read-only`, `:workspace`, and
`:danger-full-access`. Custom profiles use `[permissions.<name>]` tables and a matching
`default_permissions` value." Separately, `--profile NAME` selects a whole config profile file at
`~/.codex/NAME.config.toml`. **Downgrade: `.p`** on the Claude side.

**Citation:** `codex-config-file-config-basic.md` — "Permission profiles", "Configuration precedence";
`codex-permissions.md`.

### 37. Permission-rule persistence

**Resolved:** Both persist an in-session approval, to different files. Codex: "When you add a command to
the allow list in the TUI, Codex writes to the user layer at `~/.codex/rules/default.rules` so future
runs can skip the prompt." Claude Code: "Permission rules you approve in-session go to
`.claude/settings.local.json`." Note the scope difference — Codex persists to the *user* layer, Claude
Code to the *project-local* file.

**Citation:** `codex-agent-configuration-rules.md` — "Create a rules file";
`claude-claude-directory.md` — `.claude.json` tips.

### 38. Smart approvals / auto-review

**Resolved:** Codex documents an agentic reviewer in the approval path: with
`approvals_reviewer = "auto_review"`, "eligible approval requests are reviewed by Auto-review instead of
surfacing to the user", and `/approve` exists to "[a]pprove one retry of a recent automatic-review
denial." Also: "When Smart approvals are enabled (the default), Codex may propose a `prefix_rule` for
you during escalation requests. Review the suggested prefix carefully before accepting it." Claude
Code's analogue is auto mode with a classifier (`--enable-auto-mode`, `/fewer-permission-prompts`,
`auto-mode-config`). Both exist; mechanisms differ — render as `.gp` on both sides.

**Citation:** `codex-agent-approvals-security.md` — "Common sandbox and approval combinations";
`codex-agent-configuration-rules.md` — "Create a rules file"; Manual — `/approve` row;
`claude-permission-modes.md` — auto mode; `claude-auto-mode-config.md`.

### 39. Enterprise / managed policy

**Resolved:** Both have one. Codex uses `requirements.toml`: "On managed machines, your organization may
also enforce constraints via `requirements.toml` (for example, disallowing `approval_policy = "never"`
or `sandbox_mode = "danger-full-access"`)", and "[a]dmins can also enforce restrictive `prefix_rule`
entries from `requirements.toml`." Claude Code uses `managed-settings.json` ("Enterprise-enforced,
system-level, varies by OS"). Codex also documents Team Config for shared defaults, rules, and skills.

**Citation:** `codex-config-file-config-basic.md` — "Configuration precedence" note;
`codex-agent-configuration-rules.md` — "Create a rules file";
`codex-enterprise-managed-configuration.md`; `claude-claude-directory.md` — `managed-settings.json`.

### 40. Protected paths and network default

**Resolved:** Codex documents protected paths inside writable roots (`.git`/`.codex`) and a network
default that is off in `workspace-write` unless opted in:
`[sandbox_workspace_write] network_access = true`. There is also `allow_login_shell = false` as
"optional hardening: disallow login shells for shell-based tools."

**Citation:** `codex-agent-approvals-security.md` — "Configuration in `config.toml`", references to
"Protected paths in writable roots" and "Network access"; `codex-config-file-config-basic.md` —
"Sandbox level".

---

## §07 — Headless, CI & GitHub Actions

### 41. Git-repo requirement in headless mode

**Resolved:** Codex-only constraint, and a sharp gotcha: "Codex requires commands to run inside a Git
repository to prevent destructive changes. Override this check with `codex exec --skip-git-repo-check`
if you're sure the environment is safe." No equivalent requirement is documented for `claude -p`.

**Citation:** `codex-non-interactive-mode.md` — "Git repository required".

### 42. Headless default sandbox

**Resolved:** "By default, `codex exec` runs in a read-only sandbox." Escalation is explicit:
`--sandbox workspace-write` to allow edits, `--sandbox danger-full-access` for broader access ("[u]se
`danger-full-access` only in a controlled environment"). `--full-auto` is retained as "a deprecated
compatibility flag" that "prints a warning."

**Citation:** `codex-non-interactive-mode.md` — "Permissions and safety".

### 43. CI credentials

**Resolved:** Codex: `CODEX_API_KEY` is "only supported in `codex exec`", and the docs give an explicit
warning worth quoting in the guide: "Do not set `OPENAI_API_KEY` or `CODEX_API_KEY` as a job-level
environment variable in workflows that check out or run repository-controlled code. Build scripts,
tests, dependency lifecycle hooks, or a compromised action in the same job can read those environment
variables." Set it inline for the single invocation. `CODEX_ACCESS_TOKEN` covers ChatGPT/Codex tokens
for trusted automation; `~/.codex/auth.json` holds access tokens and should be treated "like a
password." Claude Code's analogue is `ANTHROPIC_API_KEY` / `claude setup-token`.

**Citation:** `codex-non-interactive-mode.md` — "Use API key auth";
`codex-config-file-environment-variables.md` — "Authentication and network";
`claude-cli-reference.md` — `claude setup-token`.

### 44. GitHub Action

**Resolved:** `openai/codex-action@v1` ↔ `anthropics/claude-code-action`. The Codex action "installs the
Codex CLI, starts the Responses API proxy when you provide an API key, and runs `codex exec` under the
permissions you specify." Documented inputs include `openai-api-key`, `prompt` or `prompt-file`,
`output-file`, and `safety-strategy`; the documented output is `final-message`. Prerequisites: Linux or
macOS runner ("For Windows, set `safety-strategy: unsafe`"), and check out code first.

**Citation:** `codex-github-action.md` — "Codex GitHub Action", "Prerequisites", "Example workflow";
`claude-github-actions.md`.

### 45. Piping and stdin

**Resolved:** Codex documents stdin composition explicitly: "If stdin is piped and you also provide a
prompt argument, Codex treats the prompt as the instruction and the piped content as additional
context", e.g. `curl -s … | codex exec "format the top 20 items into a markdown table" > table.md`.
`--ephemeral` avoids persisting session rollout files to disk.

**Citation:** `codex-non-interactive-mode.md` — "Basic usage".

---

## §09/§10 — Exclusives

### 46. Codex-side exclusives (each doc-backed)

**Resolved:** `/import` migration from Claude Code and Cursor (§01 item 1); execpolicy `.rules` in
Starlark with `codex execpolicy check` (item 29); hash-pinned hook trust and
`--dangerously-bypass-hook-trust` (item 28); named permission profiles `:read-only` / `:workspace` /
`:danger-full-access` and `[permissions.<name>]` (item 36); config profile files
`~/.codex/NAME.config.toml` via `--profile` (item 7); `--output-schema` JSON-Schema-constrained final
output (item 16); `codex exec --skip-git-repo-check` (item 41); `requirements.toml` admin constraints
(item 39); Codex-as-MCP-server for the Agents SDK (item 31); the `--oss` / local-provider path and
`openai_base_url` for proxies; `/goal` persistent goals; `/worktree`; `/personality`.

**Citation:** as cited per item above; `codex-config-file-config-advanced.md` — "Config and state
locations" (`openai_base_url`); Manual — global flag table (`--oss`, `--local-provider`).

### 47. Claude-side exclusives (each doc-backed)

**Resolved:** A much larger hook surface — 20+ events with no Codex counterpart, including
`Notification`, `PostToolBatch`, `PostToolUseFailure`, `FileChanged`, `TaskCreated`/`TaskCompleted`,
`WorktreeCreate`/`WorktreeRemove`, `TeammateIdle`, `InstructionsLoaded` (item 25); `asyncRewake` hooks
that "run[] in the background and wake[] Claude on exit code 2"; per-tool `--allowed-tools` /
`--disallowed-tools` (item 15); `.claude/rules/*.md` with `paths:` frontmatter for conditionally-loaded
instructions; `CLAUDE.local.md`; system-prompt control (`--system-prompt`, `--append-system-prompt`,
`--system-prompt-file`, `--append-subagent-system-prompt`); `--max-turns`, `--max-budget-usd`,
`--fallback-model`; `/rewind` and `/undo` checkpointing with `file-history/` pre-edit snapshots;
`/security-review`, `/code-review`, `ultrareview`; `/schedule` and `/routines`. Note several of these
have partial Codex analogues by another route — mark those `.gp`, not `.gn`.

**Citation:** `claude-hooks.md` — event sections, `asyncRewake` row; `claude-cli-reference.md` — flag
list; `claude-claude-directory.md` — `rules/`, `CLAUDE.local.md`, `file-history/`;
`claude-commands.md` — command list.

---

## Hook event map (source table for §05)

| Event | Claude Code | Codex CLI | Note |
| --- | --- | --- | --- |
| `SessionStart` | yes | yes | Codex matcher example `startup\|resume` |
| `SessionEnd` | yes | yes | Codex: does not run for subagents; always synchronous |
| `UserPromptSubmit` | yes | yes | Exit code 2 rejects the prompt on both |
| `PreToolUse` | yes | yes | `permissionDecision: deny` on both |
| `PostToolUse` | yes | yes | — |
| `PermissionRequest` | yes | yes | — |
| `PreCompact` | yes | yes | — |
| `PostCompact` | yes | yes | — |
| `Stop` | yes | yes | — |
| `SubagentStart` | yes | yes | — |
| `SubagentStop` | yes | yes | — |
| `Notification` | yes | — | No Codex equivalent documented |
| `PostToolBatch` | yes | — | No Codex equivalent documented |
| `PostToolUseFailure` | yes | — | No Codex equivalent documented |
| `PermissionDenied` | yes | — | Codex routes retries through `/approve` instead |
| `FileChanged` | yes | — | No Codex equivalent documented |
| `CwdChanged` | yes | — | No Codex equivalent documented |
| `DirectoryAdded` | yes | — | No Codex equivalent documented |
| `ConfigChange` | yes | — | No Codex equivalent documented |
| `InstructionsLoaded` | yes | — | No Codex equivalent documented |
| `MessageDisplay` | yes | — | No Codex equivalent documented |
| `Elicitation` / `ElicitationResult` | yes | — | Codex has `mcp_elicitations` in granular approvals |
| `Setup` | yes | — | No Codex equivalent documented |
| `StopFailure` | yes | — | No Codex equivalent documented |
| `TaskCreated` / `TaskCompleted` | yes | — | No Codex equivalent documented |
| `TeammateIdle` | yes | — | No Codex equivalent documented |
| `UserPromptExpansion` | yes | — | No Codex equivalent documented |
| `WorktreeCreate` / `WorktreeRemove` | yes | — | Codex has `/worktree` but no documented hook |

**Caveat:** "no Codex equivalent documented" means the name does not appear in the Codex hook page's
event table. Codex is in active development and its hook framework is newer than Claude Code's; absence
here is absence of documentation at the harvest date, not a guarantee the behavior is unreachable.

---

## Corpus caveats

- Per-page Codex `.md` twins are incomplete wherever the page rendered an MDX `<ConfigTable/>`,
  `<FileTree/>`, `<ContentModeSwitch/>`, `<Illustration/>` or `<PermissionModeSelectorDemo/>` component.
  Flag, command, config-key, and permission-mode tables were therefore read from `codex-manual.md`.
- `learn.chatgpt.com/guides/best-practices.md` returned 404 at harvest time even though the Codex
  `llms.txt` index lists it; only the HTML page resolves. It is not cited anywhere above.
- Claude Code's docs reorganized between the July 2026 copilot-guide harvest and this one:
  `code.claude.com/docs/en/slash-commands.md` now serves the *skills* page, and the command reference
  moved to `commands.md`. `claude-directory.md`, `permission-modes.md`, `hooks-guide.md`,
  `plugins-reference.md`, and `auto-mode-config.md` are new since that harvest.

<!-- Compiled 2026-08-12 from the 58-file corpus in this directory; every claim above is sourced from
     the cited local files only (no network fetches during resolution). -->
