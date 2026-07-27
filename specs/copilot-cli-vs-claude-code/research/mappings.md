# Feature-mapping resolutions: Copilot CLI vs Claude Code

All citations refer to files in `specs/copilot-cli-vs-claude-code/research/`. "Command reference" =
`copilot-cli-command-reference.md`. Items the corpus does not answer are marked **Downgrade: .p**
(never "doesn't exist" unless the docs say so).

---

## §02 — COPILOT SIDE: config & files

### 1. User-settings file

**Resolved:** User settings live in `~/.copilot/settings.json`. "User settings were previously stored
in `~/.copilot/config.json`. Existing user-editable settings in that location are automatically
migrated to `~/.copilot/settings.json` on startup." The whole config/state directory is
`$HOME/.copilot`, overridable with the `COPILOT_HOME` env var (the `--config-dir` flag is deprecated
in favor of it). `/settings` (alias `/config`) opens the settings dialog or sets keys inline
(`/settings KEY VALUE`, `/settings show KEY`); it has **User**, **Repo**, and **Repo (local)** tabs.
`copilot help config` is a documented help topic ("Help topics include: `billing`, `config`,
`commands`, `environment`, `logging`, `monitoring`, `permissions`, and `providers`"). Separately, if
no system keychain exists, the OAuth token is stored in "a plaintext configuration file at
`~/.copilot/config.json`".
**Citation:** Command reference — "Configuration file settings" note (line 577), `--config-dir` /
`COPILOT_HOME` rows, `/settings` row in "Slash commands"; `copilot-authenticate-copilot-cli.md` —
"How Copilot CLI stores credentials"; `copilot-using-overview.md` — "Configure settings".

### 2. Per-repository/project settings

**Resolved:** Yes. `/settings --repo` targets `.github/copilot/settings.json` and `/settings --local`
targets `.github/copilot/settings.local.json` ("Add `--repo` or `--local` to target
`.github/copilot/settings.json` or `.github/copilot/settings.local.json` instead of the user settings
file—for example, `/settings --repo model gpt-5.2`. Only repo-overridable keys can be set this way.").
Settings overridden in another scope show a badge naming which scope wins; managed rows render
read-only with a `(managed)` tag.
**Citation:** Command reference — `/settings` row in "Slash commands in the interactive interface".

### 3. MCP server config file

**Resolved:** Persistent user-level servers: `~/.copilot/mcp-config.json` — this is what
`copilot mcp add <name>` writes ("Add a server to the user configuration. Writes to
`~/.copilot/mcp-config.json`."). Per-repo/workspace: `.mcp.json` and `.github/mcp.json`, "loaded from
the working directory upward to the Git root; requires the folder to be trusted". Session-only:
`--additional-mcp-config=JSON` (string or `@file`). Loading priority (highest first):
`--additional-mcp-config` → plugin-provided → workspace (`.mcp.json`, `.github/mcp.json`) →
`~/.copilot/mcp-config.json`. A documented migration from `.vscode/mcp.json` remaps `servers` →
`mcpServers`.
**Citation:** Command reference — "MCP server configuration", "`copilot mcp` subcommand", "MCP server
loading priority", "MCP server trust levels", "Migrating from `.vscode/mcp.json`".

### 4. Skills folders & format

**Resolved:** Project skills: `.github/skills/`, `.agents/skills/`, or `.claude/skills/`
("Claude-compatible location"), plus parent `.github/skills/` for monorepos. Personal skills:
`~/.copilot/skills/` or `~/.agents/skills/`. Also plugin `skills/` dirs, `COPILOT_SKILLS_DIRS`
(comma-separated env), built-in bundled skills (lowest priority), and remote org/enterprise skills
"projected via the AHP relay". First-found-wins on duplicate names. Format: each skill is a directory
containing a `SKILL.md` file ("Skill files must be named `SKILL.md`") — Markdown with YAML
frontmatter. Frontmatter fields: `name` (required), `description` (required), `license` (optional,
per the how-to), plus `argument-hint`, `allowed-tools`, `user-invocable` (default `true`),
`disable-model-invocation` (default `false`) per the reference. Managed with `/skills
[list|info|add|remove|reload]` and `copilot skill` / `copilot plugins install --skill`.
**Citation:** `copilot-add-skills.md` — "Creating and adding a skill"; Command reference — "Skills
reference" → "Skill frontmatter fields", "Skill locations".

### 5. Custom agents

**Resolved:** Markdown files with `.agent.md` (or `.md`) extension; "The filename (minus extension)
becomes the agent ID." Locations: Project — `.github/agents/` or `.claude/agents/`; User —
`~/.copilot/agents/`; Plugin — `<plugin>/agents/`. Monorepo: CLI walks upward from cwd to Git root
loading agent dirs at each ancestor level; `.github/agents/` takes precedence over `.claude/agents/`
at the same level; home-directory agent wins over a same-named repo agent per the how-to. Frontmatter
fields: `description` (required), `name`, `model`, `tools` (default `["*"]`), `infer` (allow
auto-delegation, default `true`), `mcp-servers`. Created interactively via `/agent` → "Create new
agent"; used via `/agent`, explicit instruction, inference, or `copilot --agent NAME -p "..."`.
**Citation:** Command reference — "Custom agents reference" → "Custom agent frontmatter fields",
"Custom agent locations"; `copilot-create-custom-agents-for-cli.md` — "Creating a custom agent",
"Using a custom agent".

### 6. Hooks

**Resolved:** Repository-level: any `NAME.json` file in `.github/hooks/`. User-level:
`~/.copilot/hooks/` (or `$COPILOT_HOME/hooks/` if `COPILOT_HOME` is set;
`%USERPROFILE%\.copilot\hooks\` on Windows). Schema: `{"version": 1, "hooks": { ... }}` where each
event key maps to an array of `{"type": "command", "bash": ..., "powershell": ..., "cwd": ...,
"timeoutSec": ..., "env": {...}}` entries. **Exact event identifiers in the template:**
`sessionStart`, `sessionEnd`, `userPromptSubmitted`, `preToolUse`, `postToolUse`, `errorOccurred`;
the user-level examples additionally use **`agentStop`** ("play a sound ... when the CLI finishes
responding to a prompt"). Default timeout 30 seconds; hook configs load when the CLI starts; hooks
receive JSON on stdin (e.g. `{"timestamp":...,"cwd":...,"toolName":...,"toolArgs":...}`) and must
emit single-line JSON. Input payloads and decision control are in the separate "GitHub Copilot hooks
reference" page, which is **not in the corpus** (→ .p on decision-control details). Repo hooks in
prompt mode require `GITHUB_COPILOT_PROMPT_MODE_REPO_HOOKS=true` or a trusted folder.
**Citation:** `copilot-use-hooks.md` — "Creating a repository-level hook", "Creating a user-level
hook", "Troubleshooting", "Debugging"; Command reference — "Hooks reference", env-var table.

### 7. Custom slash commands (distinct from skills)

**Resolved:** Yes — "Commands (alternative skill format)": "Commands are an alternative to skills
stored as individual `.md` files in `.claude/commands/`. The command name is derived from the
filename. Command files use a simplified format (no `name` field required) and support
`argument-hint`, `description`, `allowed-tools`, and `disable-model-invocation`. Commands have lower
priority than skills with the same name." (Skills themselves are also user-invocable as
`/SKILL-NAME`.)
**Citation:** Command reference — "Commands (alternative skill format)" (§ Skills reference);
`copilot-cli-plugin-reference.md` — loading-order diagram ("then commands (.claude/commands/), skills
override commands").

### 8. Persistent memory

**Resolved (partial):** Copilot CLI has **Copilot Memory**: "Copilot Memory allows Copilot to build a
persistent understanding of your repository by storing 'memories', which are pieces of information
about coding conventions, patterns, and preferences that Copilot deduces as it works." Supporting
evidence: `--enable-memory` flag ("Enable memory in prompt mode (disabled by default)") and a
`memory` permission kind ("Storing facts to agent memory"). **Downgrade: .p** on mechanics — the
"About GitHub Copilot Memory" concept page is not in the corpus, so storage location/format and any
`#`-style shortcut are unknown.
**Citation:** `copilot-about-copilot-cli.md` — "Customizing GitHub Copilot CLI" → "Copilot Memory";
Command reference — `--enable-memory` row, "Tool permission patterns" table.

### 9. LSP servers

**Resolved (partial):** Config loading priority (highest → lowest): 1. **Project config**
`.github/lsp.json`; 2. **Plugin configs**; 3. **User config** `~/.copilot/lsp-config.json`.
"Higher-priority configurations override lower-priority ones with the same server name." Managed
in-session with `/lsp [show|test|reload|logs|help] [SERVER-NAME]`. Plugins carry LSP config as
`lsp.json` or `.github/lsp.json`; the plugin reference shows the JSON shape (Open Plugin Spec
"LSP server configuration"). **Downgrade: .p** on the standalone user/project file schema — the
"Adding LSP servers" how-to page is not in the corpus.
**Citation:** `copilot-lsp-servers.md` — "How LSP servers are loaded"; Command reference — `/lsp`
row; `copilot-cli-plugin-reference.md` — "LSP server configuration", "File locations".

### 10. Custom instructions: all recognized files & precedence

**Resolved:** Recognized locations (all merged simultaneously — "All custom instruction files now
combine instead of using priority-based fallbacks"; the docs state Copilot "does not define a general
precedence order between these files"):

| File | Notes |
| --- | --- |
| `$HOME/.copilot/copilot-instructions.md` | User-level, cross-repo (`COPILOT_HOME` honored) |
| `$HOME/.copilot/instructions/**/*.instructions.md` | Modular user-level |
| `.github/copilot-instructions.md` | Repository-wide (what `copilot init`/`/init` writes) |
| `.github/instructions/**/*.instructions.md` | Path-specific via `applyTo` frontmatter glob (+ optional `excludeAgent`) |
| `AGENTS.md` | Standard locations (Git root, cwd, intermediates, nested dirs) |
| `CLAUDE.md` | Same; "Copilot CLI also uses `.claude/CLAUDE.md`" |
| `GEMINI.md` | Standard locations |
| dirs in `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` | Additional `AGENTS.md` + `*.instructions.md`, comma-separated |

Global AGENTS.md: no `~/AGENTS.md` is listed; the user-level equivalents are the
`$HOME/.copilot/...` entries (extra dirs via the env var). `@path` imports are supported in
`AGENTS.md`, `CLAUDE.md`, and `.github/copilot-instructions.md` (recursive with cycle/size guards;
not expanded in `GEMINI.md` or `*.instructions.md`). `/instructions` views/toggles files;
`--no-custom-instructions` disables loading; changes need session restart/resume.
**Citation:** `copilot-add-custom-instructions.md` — "Types of custom instructions", "How multiple
instruction files interact"; Command reference — "Custom instructions locations", "Custom
instructions imports".

---

## §03 — COPILOT SIDE: CLI flags

### 11. Resume/continue flags

**Resolved:** `--continue` — "Resume the most recent session in the current working directory,
falling back to the globally most recent session. Conflicts with `--resume`." `-r, --resume[=VALUE]`
— resume by session ID, ID prefix, or name; bare `--resume` shows an interactive session picker
(requires a TTY; under `-p`/non-TTY the CLI exits with an error rather than silently starting new).
`--session-id ID` for exact-ID targeting; `-n/--name` names sessions for `--resume`/`/resume`
lookup. In-session: `/resume [SESSION-ID]` / `/continue [SESSION-ID]` switch sessions via a picker
(sortable: relevance/created/name/last used; `d` deletes). `-p` exit summary prints a
`copilot --resume=SESSION-ID` hint. `--connect[=SESSION-ID]` attaches to remote sessions.
**Citation:** Command reference — "Command-line options" rows `--continue`, `--resume`,
`--session-id`, `-n`; "Session picker shortcuts"; `/resume` row; `copilot-using-overview.md` —
"Resume an interactive session".

### 12. Model selection

**Resolved:** `--model=MODEL` flag, `COPILOT_MODEL` env var, and `/model` (alias `/models`) slash
command; pass `auto` for auto model selection. `/model --repo|--local` pins the default model in
repository settings; `/model --session` (alias `-s`) changes model/reasoning effort/context window
for the current session only. Reasoning: `--effort/--reasoning-effort` (`low|medium|high|xhigh|max`);
context tier: `--context` (`default`, `long_context`). Models table in the reference:
`claude-sonnet-4.6` ("General-purpose coding (default)"), `gpt-5.4`, `claude-haiku-4.5`,
`gpt-5.3-codex`, `gemini-3.1-pro-preview`, `gemini-3.5-flash`, `gemini-3.6-flash`,
`mai-code-1-flash`. (Note: `copilot-cli-best-practices.md` shows an older/conflicting table with
"Claude Opus 4.5 (default)".) BYOK: `COPILOT_PROVIDER_BASE_URL`, `COPILOT_PROVIDER_TYPE`
(`openai|azure|anthropic`), `COPILOT_PROVIDER_API_KEY` + `COPILOT_MODEL`.
**Citation:** Command reference — "Supported models", `/model` row, `--effort`, `--context`;
`copilot-about-copilot-cli.md` — "Model usage", "Using your own model provider";
`copilot-cli-best-practices.md` — "Select your preferred model".

### 13. `--add-dir` equivalent

**Resolved:** Identical flag name: `--add-dir=PATH` — "Add a directory to the allowed list for file
access (can be used multiple times)." In-session: `/add-dir PATH`; list with `/list-dirs`; also
`--allow-all-paths`, `--disallow-temp-dir`, `-C DIRECTORY` (change cwd before start), `/cwd`//`/cd`.
**Citation:** Command reference — `--add-dir`, `/add-dir`, `/list-dirs` rows;
`copilot-using-overview.md` — "Work with files in a different location".

### 14. Structured output / programmatic-mode flags

**Resolved:** `--output-format=FORMAT` — "FORMAT can be `text` (default) or `json` (outputs JSONL:
one JSON object per line)." `--stream=MODE` (`on`|`off`, default `on`) for progressive display.
Other programmatic-relevant flags: `-p/--prompt` (exit after completion), `-s/--silent` ("Output only
the agent response (without usage statistics), useful for scripting with `-p`"), `--no-ask-user`,
`--allow-all-tools` ("Required when using the CLI programmatically", env `COPILOT_ALLOW_ALL`),
`--log-level=LEVEL` (`none|error|warning|info|debug|all|default`), `--log-dir=DIRECTORY` (default
`~/.copilot/logs/`), `--no-color`, `--screen-reader`, `--banner`/`--no-banner`, `--share=PATH` /
`--share-gist` (session transcript export), `-i/--interactive=PROMPT`, `--mode=MODE`
(`interactive|plan|autopilot`), `--autopilot`, `--max-autopilot-continues`, `--max-ai-credits`,
`--agent`, `--attachment PATH`, `--secret-env-vars`, `--acp` (Agent Client Protocol server),
`COPILOT_TASK_WAIT_TIMEOUT_SECONDS`. Piped stdin (`echo ... | copilot`) also works (ignored if `-p`
given).
**Citation:** Command reference — "Command-line options" table; `copilot-run-cli-programmatically.md`
— "Tips for using Copilot CLI programmatically", "Shell scripting patterns".

### 15. System-prompt append/override equivalent

**Downgrade: .p** — No `--append-system-prompt`/`--system-prompt` equivalent appears anywhere in the
corpus. What IS documented as adjacent: custom-instruction files are injected into prompts
(`copilot-add-custom-instructions.md`), `--no-custom-instructions` disables them, and
`--allow-all-mcp-server-instructions` controls MCP server instructions in "the system prompt"
(showing the system prompt is not user-settable via a documented flag, but absence is not asserted
by the docs).
**Citation:** Command reference — full "Command-line options" table (no system-prompt flag present);
`--allow-all-mcp-server-instructions` row.

### 16. `copilot mcp` subcommands

**Resolved:** `copilot mcp list [--json]`, `copilot mcp get <name> [--json]`, `copilot mcp add
<name>`, `copilot mcp remove <name>`. `add` options: `-- <command> [args...]`, `--url <url>`,
`--type <type>` (`local|stdio|http|sse`), `--env KEY=VALUE`, `--header KEY=VALUE`, `--tools
<tools>`, `--timeout <ms>`, `--json`, `--show-secrets`. In-session equivalent: `/mcp
[list|show|add|edit|delete|disable|enable|auth|reload|search] [SERVER-NAME]`.
**Citation:** Command reference — "`copilot mcp` subcommand" and `/mcp` slash-command row.

### 17. Login/logout & diagnostics

**Resolved:** CLI: `copilot login` (`--host HOST` for GHE Cloud data residency); slash: `/login`,
`/logout` ("removes the locally stored token but does not revoke it"), `/user [show|list|switch]`
for multi-account. Diagnostics: `copilot help [TOPIC]` with topics `billing`, `config`, `commands`,
`environment`, `logging`, `monitoring`, `permissions`, `providers`; logs in `~/.copilot/logs/`
(`--log-dir`, `--log-level`); an entire "OpenTelemetry monitoring" section (traces, metrics, span
events, OTel env vars); `/feedback` (alias `/bug`) for surveys/bug reports; `/env` shows loaded
environment (instructions, MCP servers, skills, agents, hooks, plugins, LSPs, extensions);
`copilot version` "Display version information and check for updates". **A `copilot doctor`
equivalent is not documented in the corpus** (→ .p for a single diagnostics command; Claude Code has
`claude doctor`).
**Citation:** `copilot-authenticate-copilot-cli.md` — "Authenticating with OAuth", "Switching between
accounts", "Signing out"; Command reference — "Command-line commands", "OpenTelemetry monitoring",
`/env`, `/feedback` rows; `copilot-using-overview.md` — "Find out more".

### 18. Full flags list for a flags table

**Resolved:** From "Command-line options" (verbatim names): `--add-dir=PATH`,
`--add-github-mcp-tool=TOOL`, `--add-github-mcp-toolset=TOOLSET`, `--additional-mcp-config=JSON`,
`--agent=AGENT`, `--allow-all`, `--allow-all-mcp-server-instructions`, `--allow-all-paths`,
`--allow-all-tools`, `--allow-all-urls`, `--allow-tool=TOOL ...`, `--allow-url=URL ...`, `--acp`,
`--attachment PATH`, `--autopilot`, `--available-tools=TOOL ...`, `--banner`/`--no-banner`,
`--bash-env`/`--no-bash-env`, `-C DIRECTORY`, `--connect[=SESSION-ID]`, `--context TIER`,
`--config-dir=DIRECTORY` (deprecated), `--continue`, `--deny-tool=TOOL ...`, `--deny-url=URL ...`,
`--disable-builtin-mcps`, `--disable-mcp-server=SERVER-NAME`, `--disallow-temp-dir`,
`--effort=LEVEL`/`--reasoning-effort=LEVEL`, `--enable-all-github-mcp-tools`, `--enable-memory`,
`--enable-reasoning-summaries`, `--excluded-tools=TOOL ...`, `--experimental`/`--no-experimental`,
`--extension-sdk-path DIRECTORY`, `-h/--help`, `-i PROMPT`/`--interactive=PROMPT`,
`--log-dir=DIRECTORY`, `--log-level=LEVEL`, `--max-ai-credits=CREDITS`,
`--max-autopilot-continues=COUNT`, `--mode=MODE`, `--model=MODEL`, `--mouse[=VALUE]`/`--no-mouse`,
`-n NAME`/`--name=NAME`, `--no-ask-user`, `--no-auto-update`, `--no-color`,
`--no-custom-instructions`, `--no-remote`/`--remote`, `--no-remote-export`/`--remote-export`,
`--output-format=FORMAT`, `-p PROMPT`/`--prompt=PROMPT`, `--plan`, `--plain-diff`,
`--plugin-dir=DIRECTORY`, `-r`/`--resume[=VALUE]`, `-s`/`--silent`, `--screen-reader`,
`--secret-env-vars=VAR ...`, `--session-id ID`, `--sandbox`/`--no-sandbox` (experimental),
`--share=PATH`, `--share-gist`, `--stream=MODE`, `-v`/`--version`, `-w`/`--worktree[=NAME]`
(experimental), `--yolo`. Also `copilot --cloud` (cloud sandbox session, from the About page).
**Citation:** Command reference — "Command-line options" (lines 351–428);
`copilot-about-copilot-cli.md` — "Cloud sandboxing".

---

## §04 — COPILOT SIDE: slash commands & keys

### 19. In-session slash commands

**Resolved:** All of the probed commands exist: `/help`, `/settings` (alias `/config`), `/model`
(alias `/models`), `/clear` (aliases `/new`, `/reset`), `/mcp`, `/agent`, `/subagents` (alias
`/agents`), `/login`, `/logout`, `/feedback` (alias `/bug`), `/compact [FOCUS-INSTRUCTIONS]`,
`/session` (alias `/sessions`, subcommands `info|checkpoints [n]|files|plan|rename|cleanup|prune|
delete|delete-all`), `/theme [default|github|dim|high-contrast|colorblind]`, `/usage`, `/user
[show|list|switch]`. Full documented list additionally includes: `/add-dir`, `/after`, `/allow-all`
(alias `/yolo`), `/app`, `/ask`, `/changelog` (`/release-notes`), `/chronicle`, `/clikit`,
`/context`, `/copy`, `/cwd` (`/cd`), `/delegate`, `/diff`, `/downgrade`, `/env`, `/every`, `/exit`
(`/quit`), `/extensions`, `/experimental`, `/fleet`, `/fork` (`/branch`), `/ide`, `/init`,
`/instructions`, `/keep-alive` (`/caffeinate`), `/limits`, `/list-dirs`, `/lsp`, `/mcp`, `/move`,
`/permissions [show|reset]`, `/plan`, `/plugins` (`/plugin`, with install/update/uninstall/list/
enable/disable/remove/marketplace/mcp subcommands), `/pr`, `/refine`, `/remote`, `/rename`,
`/research`, `/reset-allowed-tools`, `/restart`, `/resume` (`/continue`), `/review`, `/rubber-duck`,
`/sandbox`, `/search` (`/find`), `/security-review`, `/share` (`/export`), `/skills`, `/statusline`
(`/footer`), `/tasks`, `/terminal-setup`, `/tuikit`, `/undo` (`/rewind`), `/update` (`/upgrade`),
`/version`, `/voice`, `/worktree`.
**Citation:** Command reference — "Slash commands in the interactive interface" (lines 257–349).

### 20. Prompt prefixes & keyboard shortcuts

**Resolved:**
* `! COMMAND` — "Execute a command in your local shell, bypassing Copilot"; `!` alone enters shell
  mode; Esc or Ctrl+C on empty prompt exits it.
* `$` — hand the terminal to a real interactive shell (suspends the CLI UI entirely); disabled by
  default, enabled via the `shellShortcut` setting, can be disabled by enterprise managed settings.
* `@ FILENAME` — "Include file contents in the context."
* `# NUMBER` — "Include a GitHub issue or pull request in the context." (Note: `#` is context
  inclusion here, not a memory shortcut.)
* **Shift+Tab** — "Cycle between standard, plan, and autopilot mode." (Confirmed; Claude Code's
  Shift+Tab cycles permission modes instead.)
* **Esc** — "Cancel the current operation. Press twice to interrupt the running turn, or to stop
  background agents when the main agent is idle." **Ctrl+C** — "Cancel operation / clear input.
  Press twice to exit." **Ctrl+D** — shutdown.
* Tab completion: terminal-level via `copilot completion SHELL` (bash/zsh/fish); in-UI, **Tab /
  Ctrl+Y** "Accept the current inline completion suggestion."
* Others: Ctrl+G / Ctrl+X then `e` (external editor), Ctrl+Enter/Ctrl+Q (queue message while busy),
  Ctrl+R (reverse history search), Ctrl+V (paste as attachment), Ctrl+X then `/` (run slash command
  mid-prompt), Ctrl+X then `b` (background the running task), Ctrl+T (toggle reasoning), Ctrl+F
  (timeline search), Ctrl+O/Ctrl+E (expand timeline).
**Citation:** Command reference — "Global shortcuts in the interactive interface", "Timeline
shortcuts", "Navigation shortcuts", "Using `copilot completion`"; `copilot-using-overview.md` — "Run
shell commands", "Toggle reasoning visibility".

---

## §06 — COPILOT SIDE: permissions & enterprise

### 21. Permission prompt persistence

**Resolved:** Prompt keys: `y` (once), `n` (deny once), `!` ("Allow all similar requests for the
rest of the session"), `#` ("Deny all similar requests for the rest of the session"), `?` (details).
Full dialog offers three persistence tiers: **Once** (none), **This location** ("Until manually
cleared — Saved to disk per location"; appears when the CLI can determine a location key, Git root
or current directory), **Always** ("Permanent — Config file"). `/permissions [show|reset]` views or
clears in-memory approvals; `/reset-allowed-tools` resets allowed tools. Interactive "approve for
the rest of the session" is session-scoped only ("It will ask for your approval again in new
sessions, or if you resume the current session"). CLI-flag equivalents `--allow-tool`/`--deny-tool`
use `Kind(argument)` patterns (`shell(git:*)`, `write(src/*.ts)`, `MyMCP(create_issue)`, `url(...)`,
`read(...)`, `memory`); "Deny rules always take precedence over allow rules, even when
`--allow-all` is set." Trusted directories gate file access and workspace-provided config. The
`permissions.disableBypassPermissionsMode: "disable"` setting (user settings `~/.copilot/settings.json`,
server-fetched managed settings, or MDM plist/registry/file) suppresses all allow-all flags at
startup.
**Citation:** Command reference — "Permission approval responses", "Tool permission patterns", note
after "Command-line options"; `copilot-about-copilot-cli.md` — "Allowed tools", "Trusted
directories".

### 22. Sandboxing

**Resolved:** Yes. `/sandbox [enable|disable]` — "Enable, disable, or configure OS-level sandboxing
that restricts filesystem and network access for shell commands, MCP/LSP servers, and built-in
file/web tools. Run `/sandbox` with no arguments to open the policy dialog." Session-only override:
`--sandbox` / `--no-sandbox` (experimental mode only). Local stdio MCP servers spawn inside the
sandbox and show `connected (sandboxed)`. This is part of "Cloud and local sandboxes for GitHub
Copilot" (public preview): local sandboxing on your machine plus cloud sandboxing via
`copilot --cloud` (isolated cloud-hosted environments; policies inherit Copilot cloud agent
firewall rules). **.p on OS mechanisms/platforms** — which OS primitives are used is not documented
in the corpus (contrast Claude's Seatbelt/bubblewrap detail).
**Citation:** Command reference — `/sandbox`, `--sandbox`/`--no-sandbox` rows, "MCP server
configuration"; `copilot-about-copilot-cli.md` — "Running in a sandbox…", "Risk mitigation";
`copilot-using-overview.md` — "Run in a sandbox".

### 23. Enterprise/org policy

**Resolved:** Admins control Copilot CLI via enterprise **AI controls → Copilot** policies
("Copilot Clients" section → Copilot CLI policy: Enabled everywhere / Disabled everywhere / Let
organizations decide). Controls that apply: CLI enablement (enterprise or org level); **model
selection** ("Users can only access AI models that are enabled at the enterprise level"; custom
models via enterprise BYOK keys appear in `/model`); enterprise-configured **custom agents**;
**MCP server policies** ("You can configure an MCP registry URL so developers can discover approved
servers, and set an allowlist policy to restrict which MCP servers can run") — enforced fail-closed
by fingerprint against an allowlist-evaluate endpoint; **Copilot cloud agent** policy (both it and
the CLI policy must be enabled for `/delegate`); **audit logging** of policy updates; **seat
assignment** required. Controls that do **not** apply: IDE-specific policies and content exclusions
("File path-based content exclusions"). Known limitation: the org-level "MCP servers in Copilot"
on/off policy and "MCP Registry URL" policy are not currently supported by the CLI. Device-level:
MDM managed settings (plist/registry/file) and server-fetched per-account managed settings; managed
rows show `(managed)` in `/settings`. Actions billing: org policy "Allow use of Copilot CLI billed
to the organization" enables `GITHUB_TOKEN` auth in workflows.
**Citation:** `copilot-administer-copilot-cli-for-your-enterprise.md` — "Enabling or disabling
Copilot CLI", "How do other AI controls affect Copilot CLI?"; Command reference — "Enterprise MCP
allowlist", managed-settings note; `copilot-about-copilot-cli.md` — "Known MCP server policy
limitations"; `copilot-use-copilot-cli-in-actions.md` — "Enabling the policy".

---

## CLAUDE SIDE (verification against claude-* files)

### 24. Custom slash commands — current status

**Resolved:** `claude-slash-commands.md` (source `code.claude.com/docs/en/slash-commands.md`) now
serves the skills page: "**Custom commands have been merged into skills.** A file at
`.claude/commands/deploy.md` and a skill at `.claude/skills/deploy/SKILL.md` both create `/deploy`
and work the same way. Your existing `.claude/commands/` files keep working." Commands support the
same frontmatter; "if a skill and a command share the same name, the skill takes precedence."
Precedence across levels: enterprise > personal > project; any level overrides bundled skills;
plugin skills are namespaced `plugin-name:skill-name`.
**Citation:** `claude-slash-commands.md` / `claude-skills.md` — intro note (line 16) and "Where
skills live" (line 118, 165, 280).

### 25. Checkpoints / rewind

**Resolved:** "When the input is empty, double `Esc` opens the rewind menu to restore or summarize
code and conversation from a previous point." Settings: `fileCheckpointingEnabled` (default `true`)
— "Snapshot files before each edit so `/rewind` can restore them. Appears in `/config` as **Rewind
code (checkpoints)**"; disable via `CLAUDE_CODE_DISABLE_FILE_CHECKPOINTING`.
**Citation:** `claude-interactive-mode.md` — "General controls" (`Esc` + `Esc` row) and "See also →
Checkpointing"; `claude-settings.md` — `fileCheckpointingEnabled` row (line 280).

### 26. `--output-format json|stream-json` + `--include-partial-messages`

**Resolved:** `--output-format` options `text` (default), `json` ("structured JSON with result,
session ID, and metadata"), `stream-json` ("newline-delimited JSON for real-time streaming"). For
token streaming: "Use `--output-format stream-json` with `--verbose` and
`--include-partial-messages` to receive tokens as they're generated." Schema-validated output via
`--json-schema` (result in `structured_output`). Related: `--input-format text|stream-json`,
`--include-hook-events`, `--forward-subagent-text`, `system/init` + `system/api_retry` events.
**Citation:** `claude-headless.md` — "Get structured output", "Stream responses";
`claude-cli-reference.md` — `--output-format`, `--include-partial-messages`, `--json-schema` rows.

### 27. Hook events full list + decision control

**Resolved:** The corpus documents 30 hook events (order per doc lifecycle): `SessionStart`,
`Setup`, `InstructionsLoaded`, `UserPromptSubmit`, `UserPromptExpansion`, `MessageDisplay`,
`PreToolUse`, `PermissionRequest`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`,
`PermissionDenied`, `Notification`, `SubagentStart`, `SubagentStop`, `TaskCreated`, `TaskCompleted`,
`Stop`, `StopFailure`, `TeammateIdle`, `ConfigChange`, `CwdChanged`, `FileChanged`,
`WorktreeCreate`, `WorktreeRemove`, `PreCompact`, `PostCompact`, `SessionEnd`, `Elicitation`,
`ElicitationResult`. Decision control: top-level `decision: "block"` + `reason` (UserPromptSubmit,
PostToolUse, Stop, SubagentStop, PreCompact, ConfigChange, etc.); PreToolUse uses
`hookSpecificOutput.permissionDecision` (**allow/deny/ask/defer**) + `permissionDecisionReason` and
can rewrite `updatedInput`; PermissionRequest returns `decision.behavior` (allow/deny); PostToolUse
can rewrite `updatedToolOutput`; exit code 2 blocks with stderr feedback. Hook locations:
`~/.claude/settings.json`, `.claude/settings.json`, `.claude/settings.local.json`, managed policy
settings, plugin `hooks/hooks.json`, skill/agent frontmatter.
**Citation:** `claude-hooks.md` — "Hook events" (### headings at lines 923–2749), "Decision control"
(line 843 table), "Hook locations" (line 172).

### 28. Sandboxing

**Resolved:** "Configure the sandboxed Bash tool" — filesystem + network isolation for Bash
commands and all child processes. Platforms: "runs on macOS, Linux, and WSL2. Native Windows is not
supported." Enforcement: macOS Seatbelt; Linux/WSL2 bubblewrap (+ socat for the network proxy
relay); WSL1 unsupported. Defaults: write only to cwd + session temp dir; read everywhere except
denied dirs; no domains pre-allowed (proxy prompts per domain). Enabled via `/sandbox` panel (writes
`.claude/settings.local.json`), `sandbox.enabled` in `~/.claude/settings.json`, or enforced
org-wide via managed settings; `sandbox.failIfUnavailable` makes missing-sandbox a hard failure.
Also available standalone as `@anthropic-ai/sandbox-runtime`.
**Citation:** `claude-sandboxing.md` — "Get started" (lines 15–53), "How sandboxing works" → "OS-level
enforcement" (lines 332–342), "Enforce sandboxing with managed settings".

### 29. Memory

**Resolved:** Two mechanisms: **CLAUDE.md** (user `~/.claude/CLAUDE.md`, project `CLAUDE.md` /
`.claude/CLAUDE.md`, `CLAUDE.local.md`, `.claude/rules/`, `@` imports, AGENTS.md support) and **auto
memory** — "on by default", stored per project at `~/.claude/projects/<project>/memory/` with a
`MEMORY.md` index ("The first 200 lines of `MEMORY.md`, or the first 25KB … are loaded at the start
of every conversation") plus on-demand topic files. Toggle via `/memory` (saves
`autoMemoryEnabled` to `~/.claude/settings.json`), env `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`,
relocation via `autoMemoryDirectory`. `/memory` lists and opens all memory files. **`#` shortcut:
not documented in the corpus** — the quick-command table lists only `/`, `!`, `@`, `:`, `?`; the
documented flow is "When you ask Claude to remember something … Claude saves it to auto memory"
(→ .p on `#`; do not claim it exists or was removed).
**Citation:** `claude-memory.md` — "Auto memory" (lines 338–398), "View and edit with `/memory`"
(line 404–410), "CLAUDE.md files"; `claude-interactive-mode.md` — "Quick commands" (lines 83–91).

### 30. Managed settings / enterprise policy file paths

**Resolved:** Managed settings delivery: (a) **server-managed** at sign-in (claude.ai admin console
or self-hosted Claude apps gateway); (b) **MDM/OS-level** — macOS `com.anthropic.claudecode`
managed-preferences domain; Windows `HKLM\SOFTWARE\Policies\ClaudeCode` (`Settings` REG_SZ JSON),
user-level fallback `HKCU\SOFTWARE\Policies\ClaudeCode`; (c) **file-based** `managed-settings.json`
and `managed-mcp.json` in: macOS `/Library/Application Support/ClaudeCode/`, Linux/WSL
`/etc/claude-code/`, Windows `C:\Program Files\ClaudeCode\` (legacy `C:\ProgramData\ClaudeCode\`
unsupported since v2.1.75), plus a `managed-settings.d/` drop-in directory merged systemd-style.
"All use the same JSON format and cannot be overridden by user or project settings." Regular scopes:
`~/.claude/settings.json`, `.claude/settings.json`, `.claude/settings.local.json`; other state in
`~/.claude.json`; project MCP in `.mcp.json`.
**Citation:** `claude-settings.md` — "Settings files" (lines 78–131).

### 31. GitHub Actions

**Resolved:** Claude Code runs in Actions via the **`claude-code-action`** GitHub Action
(github.com/anthropics/claude-code-action). Setup: `/install-github-app` from the Claude Code
terminal (installs the Claude GitHub App + workflows + API key secret; requires repo admin), or
manual: install the app, "Add ANTHROPIC_API_KEY to your repository secrets", copy
`examples/claude.yml` into `.github/workflows/`. Workflows reference
`anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}` (listed as a required input). Trigger by
tagging `@claude` in an issue/PR comment; Bedrock/Vertex variants use OIDC instead. **OAuth-token
auth in Actions is not documented in this corpus page** — the closest documented facility is
`claude setup-token` ("Generate a long-lived OAuth token for CI and scripts") in the CLI reference
(→ .p for OAuth-in-Actions specifics).
**Citation:** `claude-github-actions.md` — "Claude Code Action", "Quick setup", "Manual setup",
input table (line 637); `claude-cli-reference.md` — `claude setup-token` row.

### 32. Model selection (flags/commands/settings)

**Resolved:** `--model` flag — "Sets the model for the current session with an alias for the latest
model (`sonnet`, `opus`, `haiku`, or `fable`) or a model's full name. Overrides the `model` setting
and `ANTHROPIC_MODEL`." In-session: `/model` ("`model`: use `/model` to switch mid-session").
Settings: `model` key in `settings.json`, plus `fallbackModel` / `--fallback-model` chains,
`--effort` (`low|medium|high|xhigh|max|ultracode`) and the `effortLevel` setting.
**Citation:** `claude-cli-reference.md` — `--model`, `--fallback-model`, `--effort` rows;
`claude-settings.md` — line 180 (`model` … `/model`), "Available settings".

### 33. Resume flags / session handling

**Resolved:** `-c` / `--continue` — "Load the most recent conversation in the current directory."
`-r` / `--resume` — "Resume a specific session by ID or name, or show an interactive picker."
Extras: `claude -c -p "query"` (continue via SDK), `--fork-session` (new session ID on resume),
`--session-id <uuid>`, `--name/-n` (+ `/rename`), `--from-pr` (picker filtered by PR),
`--no-session-persistence` (print mode), `claude project purge` (delete local session state),
background sessions appear in the picker marked `bg`.
**Citation:** `claude-cli-reference.md` — "CLI commands" rows `claude -c`, `claude -r`; flags
`--continue`, `--resume`, `--fork-session`, `--session-id`, `--name`, `--from-pr`.

### 34. LSP support in Claude Code

**Resolved:** Yes — via plugins. "LSP (Language Server Protocol) plugins give Claude real-time code
intelligence. … install the pre-built LSP plugins from the official marketplace" for TypeScript,
Python, Rust; custom support via an `.lsp.json` file in a plugin (example: `gopls` with `command`,
`args`, `extensionToLanguage`). `--safe-mode` lists "LSP servers" among customizations it disables,
confirming they are a load-time component. (No standalone non-plugin LSP config file is documented
in the corpus — Copilot's `.github/lsp.json`/`~/.copilot/lsp-config.json` has no direct standalone
counterpart here; → .p only on that sub-point.)
**Citation:** `claude-plugins.md` — "Add LSP servers to your plugin" (lines 252–274);
`claude-cli-reference.md` — `--safe-mode` row.

### 35. Plugins / marketplaces on both sides

**Resolved:**
* **Copilot:** `copilot plugin`/`copilot plugins` — `install SPECIFICATION` (marketplace spec
  `plugin@marketplace`, `OWNER/REPO`, `OWNER/REPO:PATH`, git URL, local path), `uninstall`, `list`,
  `update [--all]`, `enable`, `disable`; `copilot plugin marketplace add|list|browse|remove
  [--force]|update` (alias `refresh`); in-session `/plugins ...` dashboard (`--plugin|--mcp|--skill`
  tabs) and `--plugin-dir` flag. Manifests: `plugin.json` (checked at `.plugin/plugin.json`,
  `plugin.json`, `.github/plugin/plugin.json`, or `.claude-plugin/plugin.json`) and
  `marketplace.json` (also `.claude-plugin/marketplace.json`) — the Claude-compatible paths are
  explicit. Installed plugins live in `~/.copilot/installed-plugins/...`. "Built-in default
  marketplaces ship with the runtime and can't be removed."
* **Claude Code:** `claude plugin` (alias `claude plugins`), e.g.
  `claude plugin install code-review@claude-plugins-official`; session-scoped `--plugin-dir` (dir or
  `.zip`) and `--plugin-url`. Settings keys: `enabledPlugins`, `pluginConfigs`,
  `extraKnownMarketplaces`, `strictKnownMarketplaces` (managed restriction of marketplace
  additions), `strictPluginOnlyCustomization`. Plugin bundles can carry skills, agents, hooks
  (`hooks/hooks.json`), MCP servers, LSP servers (`.lsp.json`), background monitors
  (`monitors/monitors.json`), and default settings; community marketplace submission documented.
**Citation:** `copilot-cli-plugin-reference.md` — "CLI commands", "File locations", "Loading order
and precedence"; `claude-cli-reference.md` — `claude plugin`, `--plugin-dir`, `--plugin-url` rows;
`claude-settings.md` — "Plugin configuration" (lines 754–1173); `claude-plugins.md` — structure and
component sections.

---

## SURPRISES

1. **Copilot ships far more surface than a typical comparison table assumes.** Documented features
   we hadn't listed: `/fleet` (parallel subagents), `/rubber-duck` (second-opinion agent on a
   *complementary* model), `/research` (deep research), `/pr [view|create|fix|auto|automerge]`
   (drive a PR to green and merge), `/delegate` (hand off to Copilot cloud agent), `/worktree` and
   `/move` plus `-w/--worktree`, `/fork`//`/branch` (session forking), `/every` & `/after`
   (scheduled prompts), `/voice`, `/remote` (steer a session from GitHub Mobile/GitHub.com),
   `/share`/`--share-gist` (transcript export/sharing), `/refine` (prompt rewriting), sidekick
   agents, agent-to-agent messaging (`list_agents`/`write_agent` with sibling/child scopes), ACP
   server mode (`--acp`), and full OpenTelemetry GenAI tracing/metrics.
2. **Copilot `/undo` (alias `/rewind`)**: "Rewind the last turn and revert file changes. File
   tracking is done via the tool layer and does not require Git" — a direct checkpoint/rewind
   counterpart to Claude's `/rewind`, plus `/session checkpoints [n]`.
3. **Copilot natively reads Claude's config surface**: `CLAUDE.md` (incl. `.claude/CLAUDE.md`),
   `.claude/skills/`, `.claude/agents/`, `.claude/commands/`, and `.claude-plugin/plugin.json` /
   `.claude-plugin/marketplace.json`, and exposes `${CLAUDE_PLUGIN_DATA}` as an alias. Migration
   from Claude Code is clearly a design goal.
4. **`#` means opposite things**: in Copilot it includes a GitHub issue/PR in context (and at a
   permission prompt it means "deny all similar"); Claude Code's corpus no longer documents the old
   `#`-to-memory shortcut at all (auto memory replaced it).
5. **Model doc inconsistency inside GitHub's own docs**: the command reference says the default
   model is `claude-sonnet-4.6`, while `copilot-cli-best-practices.md` says "Claude Opus 4.5
   (default)". Worth flagging rather than asserting either as the single truth. Also notable: a
   GitHub product defaults to Anthropic models, and `--effort ... max` "is the highest-depth tier
   for Anthropic models".
6. **Copilot's JSON output is JSONL**: `--output-format json` "outputs JSONL: one JSON object per
   line" — closer to Claude's `stream-json` than to Claude's `json`.
7. **Copilot has no documented system-prompt override flag** — automation relies on custom
   instructions and `--agent`; Claude has four system-prompt flags plus
   `--append-subagent-system-prompt`.
8. **Both have permission "always allow" persisted to config**, but Copilot adds a middle tier —
   "This location" (per Git root/directory, saved to disk) — that Claude expresses instead through
   settings-file scoping.
9. **Enterprise fail-closed MCP allowlist** on Copilot: server fingerprints are checked against an
   evaluate endpoint and "if the evaluate endpoint is unreachable … non-default servers are blocked
   until the policy can be verified."
10. **Quotable for the doc**: "Copilot automatically compresses your history in the background …
    This enables virtually infinite sessions" (about page); Claude Code: "Custom commands have been
    merged into skills."; Copilot plan mode: "it's a safety net, not a guarantee."
11. **Claude hook system dwarfs Copilot's documented one**: 30 events with allow/deny/ask/defer and
    input/output rewriting vs Copilot's 7 camelCase events (decision-control details live in a
    hooks-reference page not captured in this corpus).
12. **Copilot env-var hardening**: inline assignments of `LD_*`, `DYLD_*`, `GIT_CONFIG_*`, `PATH`,
    `BASH_ENV`, etc. are blocked outright in shell commands — a denylist Claude's docs don't have a
    direct analogue for (Claude counters with sandbox `credentials` masking).

## HOOK EVENT MAP

Copilot event ids are camelCase (repo/user `hooks/*.json`); Claude Code events are PascalCase
(settings-file `hooks` config). One row per event on either side.

| Copilot CLI event | Claude Code event | Notes |
| --- | --- | --- |
| `sessionStart` | `SessionStart` | Direct equivalent |
| `sessionEnd` | `SessionEnd` | Direct equivalent |
| `userPromptSubmitted` | `UserPromptSubmit` | Direct equivalent |
| `preToolUse` | `PreToolUse` | Direct equivalent (Claude adds allow/deny/ask/defer + input rewrite) |
| `postToolUse` | `PostToolUse` | Direct equivalent (Claude adds output rewrite) |
| `errorOccurred` | — (closest: `PostToolUseFailure` / `StopFailure`) | No exact Claude event; Claude splits tool-failure vs stop-failure |
| `agentStop` | `Stop` | Fires when the agent finishes responding |
| — | `Setup` | No Copilot equivalent documented (closest: `copilot init` is instructions-only) |
| — | `InstructionsLoaded` | No Copilot equivalent documented |
| — | `UserPromptExpansion` | No Copilot equivalent documented |
| — | `MessageDisplay` | No Copilot equivalent documented |
| — | `PermissionRequest` | No Copilot hook; Copilot handles via permission dialog/flags |
| — | `PermissionDenied` | No Copilot equivalent documented |
| — | `PostToolBatch` | No Copilot equivalent documented |
| — | `Notification` | No Copilot equivalent documented |
| — | `SubagentStart` | No Copilot equivalent documented |
| — | `SubagentStop` | No Copilot equivalent documented |
| — | `TaskCreated` / `TaskCompleted` | No Copilot equivalent documented |
| — | `TeammateIdle` | Agent-teams feature; no Copilot counterpart |
| — | `ConfigChange` | No Copilot equivalent documented |
| — | `CwdChanged` | No Copilot equivalent documented (Copilot has `/cwd` but no hook) |
| — | `FileChanged` | No Copilot equivalent documented |
| — | `WorktreeCreate` / `WorktreeRemove` | Copilot has `/worktree` but no worktree hooks documented |
| — | `PreCompact` / `PostCompact` | Copilot auto-compacts at 95% but exposes no compaction hooks |
| — | `StopFailure` | No Copilot equivalent documented |
| — | `Elicitation` / `ElicitationResult` | MCP elicitation; no Copilot equivalent documented |

**Caveat:** the Copilot column reflects only `copilot-use-hooks.md`; the full "GitHub Copilot hooks
reference" page is outside this corpus, so additional Copilot events may exist (treat absences on
the Copilot side as .p, not .n).

<!-- Compiled 2026-07-27 from the 33-file corpus in this directory; every claim above is sourced
     from the cited local files only (no network fetches). -->
