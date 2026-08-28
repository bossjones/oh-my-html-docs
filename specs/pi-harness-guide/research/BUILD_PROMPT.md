# BUILD PROMPT — Pi Coding Harness field guide

Paste this prompt into a Claude Code session running in the `oh-my-html-docs` repo (worktree
branch `claude/pi-harness-html-page-2fba0c`). It encodes the exact pipeline that produced
`docs/pages/herdr-guide/` (feature-herdr branch, session 2026-08-26), adapted to Pi.

---

Build the standalone HTML field guide **"Pi — The Coding Harness"** for this repo, following the
plan at `specs/pi-harness-guide.html` (open it; execute phases top-to-bottom, updating each
checklist `[]` → `[wip]` → `[x]`/`[f]` as you go, exactly as the plan's status-marker legend says).
Its Amendments section records deltas adopted from the herdr precedent — where the amendment and a
phase body disagree, the amendment wins (notably: generated WebP figures instead of inline-SVG-only).

## Ground rules

1. Facts come from the committed research corpus: `specs/pi-harness-guide/research/pi-docs.md`
   (pi.dev docs, versions, API surface, the 12 package profiles, deep-link map) and
   `specs/pi-harness-guide/research/disler-pi-survey.md` (IndyDevDan's Pi repos, snippets,
   doctrine). **No invented flags, commands, paths, or version numbers** — every command in the
   guide must appear in the corpus or be re-verified live (pi.dev docs have Cmd+K search;
   `curl` + the npm/GitHub APIs for volatile numbers). Anything unverifiable is cut or marked.
2. The guide is **self-contained**: one `index.html` with inline CSS + vanilla JS, sibling
   `images/` folder (WebP + favicon.svg), Google Fonts links only. No other external requests,
   no frameworks.
3. Quote IndyDevDan code at ≤20 lines per snippet, always with repo/path attribution and a link.
4. Work stays in this worktree; never `cd` to the main checkout except to run the image script
   (step below explains why).

## Deliverables (paths are exact)

- `specs/pi-harness-guide/doc/index.html` — the guide, staged.
- `specs/pi-harness-guide/doc/images/` — favicon.svg + 6 WebP figures.
- `specs/pi-harness-guide/gen.sh` — the image-generation batch script (committed, reproducible).
- `specs/pi-harness-guide/png-src/` — archived PNG originals + generation logs (like herdr).
- `docs/pages/pi-harness-guide/` — verbatim bundle (created by the importer from `doc/`).
- `docs/library/guides/pi-harness-guide.md` — card (importer + hand-added preview line).
- `docs/assets/previews/pi-harness-guide.png` — 1200×750 playwright screenshot (the strict MkDocs
  build FAILS if the card references it and it's missing — capture it before `just build`).
- Updated `docs/library/index.md` bullet; plan file statuses + a closing Amendment.

## Step 1 — Scaffold (plan Phase 2)

Create `doc/index.html` with the paper-and-ink identity from the plan's `:root` (paper `#F4F2ED`,
graph-grid background, ink `#1C222B`, accent `#3D6E9E`, rust `#8F3222`, ok `#2E7D4F`; fonts
Source Serif 4 italic display / Inter body / IBM Plex Mono; `meta color-scheme: light`;
dark terminal-style `pre` blocks on the light page). Port the proven component skeleton from the
sibling guides (`docs/pages/codex-cli-vs-claude-code/index.html` for topbar/TOC/scroll-spy/print
JS; `git show feature-herdr:docs/pages/herdr-guide/index.html` for `.prow` copy-row +
`.copy-btn`/`data-prompt` + flip-card patterns and section ids `s0…sN`). Favicon: italic serif π,
steel blue on paper, at `doc/images/favicon.svg`, referenced as `images/favicon.svg`.

Herdr lessons to bake in from the start:

- Quotes inside `data-prompt` attributes must be `&quot;` — never backslash-escaped. (8 escaped
  quotes broke herdr's box model: body rendered 2115px wide on a 1440px viewport.)
- The copy-button JS restore label must equal the button's initial text exactly.
- Keep content readable at 390px wide with no horizontal scroll.

## Step 2 — Author the 13 sections (plan Phase 3, ids s0–s12)

Follow the plan's section map exactly: s0 What Pi is (minimal-core thesis, monorepo, 4 modes) ·
s1 Quickstart (Node ≥ 22.19.0 callout → install trio → `/login` OAuth vs env keys → first
session) · s2 Recommended setup (mise/nvm Node, tmux csi-u block, starter settings.json,
config-tree, AGENTS.md/CLAUDE.md, trust model, env hygiene) · s3 Daily driving (slash-command +
keybinding tables, session tree, compaction) · s4 Package ecosystem (install/manage commands,
security warning quoted verbatim, 12 package cards ordered by downloads, starter-stack install
block) · s5 Extensions (ExtensionAPI contract, event catalog, minimal.ts worked example
attributed to disler, from-scratch `tool_call` guard 15-liner) · s6 Packages/providers/embedding
(pi-package manifest, npm publish, skills, themes, models.json, SDK/RPC) · s7 VS Code & Cursor
(extension-folder package.json + tsconfig `noEmit` + .vscode snippets — jiti executes, tsc only
diagnoses) · s8 IndyDevDan on Pi (six repo cards + doctrine pull-quotes + video links, Bun-vs-Node
note) · s9 Pi vs Claude Code (short matrix from COMPARISON.md, dated "Pi v0.52.10 snapshot,
Feb 2026", attributed) · s10 Open questions (mirror the plan's nine yes/no Questionables with
working assumptions) · s11 copy-pair cheat sheet (10 copyable blocks) · s12 Sources (full
deep-link map + harvest date).

Every factual claim links its source. Rich-link the doc pages listed in the corpus's deep-link
map. ~30 copyable command/prompt rows across the page is the herdr benchmark — hit it.

## Step 3 — Images (plan images + guide figures, herdr pipeline)

Write `specs/pi-harness-guide/gen.sh`: a batch script that calls the planf3 image script once per
image, in parallel with per-image `.log` files and a final `wait`:

```bash
uv run "$HOME/.claude/plugins/cache/boss-skills/agent-harness/0.31.3/skills/planf3/scripts/generate_gpt_image.py" \
  "<prompt>" <out>.png --size 1536x1024 --quality high
```

Embed one shared STYLE block in every prompt: warm paper `#F4F2ED` with a faint graph-paper grid,
ink `#1C222B` line work, steel-blue `#6A9FCC` primary accent, rust `#8F3222` sparingly, flat
geometric vector, engineer's-notebook aesthetic, serif-italic captions, **under 8 words of text
per image**, no gradients, no photorealism.

Thirteen images total — six guide figures to `doc/images/`: `hero` (terminal with π prompt,
circuit lines to plug-in modules), `core` (minimal core ring: 4 tools + read-only trio, package
sockets around it), `ladder` (Quickstart→Recommended→Advanced rungs), `tree` (session tree with a
branch summary node), `events` (agent event loop with extension hook points), `ecosystem` (map:
DOCS / PACKAGES / DAN / EDITOR territories) — and seven plan figures to `specs/pi-harness-guide/`
matching the plan's `{{...IMAGE}}` placeholder subjects (hero, problem, solution, phase-identity,
phase-sections, questionables, notes-map).

The script reads `OPENAI_API_KEY` via python-dotenv from the **cwd's** `.env` — the worktree has
none, so run gen.sh with the main checkout as cwd
(`cd /Users/bossjones/dev/bossjones/oh-my-html-docs && zsh <worktree>/specs/pi-harness-guide/gen.sh`),
writing outputs back into the worktree by absolute path — exactly how the herdr session ran it.
If the key is genuinely unavailable: guide figures fall back to inline SVG in the identity
palette, plan figures stay as comments, and the shortfall is recorded in the plan's Amendments.

Then convert guide PNGs with `cwebp -q 82 <in>.png -o <out>.webp` (herdr: 6.8 MB → 116 KB),
reference only `.webp` in the HTML, and archive PNGs + logs in `png-src/`. Fill the plan's seven
`<figure>` placeholders with `<img src="pi-harness-guide/<name>.png">` (plan figures stay PNG).

## Step 4 — Import (plan Phase 4)

Read `scripts/new_doc.py --help` first, then run it directly (NOT `just add` — it drops quoting
on multi-word titles) to import `specs/pi-harness-guide/doc/` with title "Pi — The Coding
Harness", slug `pi-harness-guide`, category `guides`, tags
`pi,harness,agents,typescript,extensions,indydevdan`, source "pi.dev docs + earendil-works/pi +
disler repos, August 2026". Serve the built site, capture the 1200×750 preview PNG via
playwright-cli, hand-insert the linked preview-image line into the card (copy the pattern from
`docs/library/guides/codex-cli-vs-claude-code.md`), and add the `docs/library/index.md` bullet
under `## guides` crediting Pi (earendil-works) and IndyDevDan.

## Step 5 — Verify loop (plan Phase 5; herdr QA bar)

Run the CLAUDE.md playwright-cli recipe against the built site
(`just build && python3 -m http.server -d site 8000 &`), and do not stop until ALL of:

- `/pages/pi-harness-guide/index.html` — correct title; zero console errors (favicon 404 exempt).
- Image eval: every `<img>` has `complete && naturalWidth > 0`.
- `document.body.scrollWidth === window.innerWidth` at 1440×900 AND 390×844 (the herdr
  escaped-quote overflow check).
- Copy buttons: clicking copies the exact `data-prompt` text and the label restores.
- Flip/interactive components toggle and reset with correct `aria-expanded`.
- Card page `/library/guides/pi-harness-guide/`: preview renders; "Open the document →" resolves
  to the verbatim doc.
- Section screenshots at desktop + hero/terminal-section at mobile, reviewed with your own eyes
  (Read the PNGs) — this is where herdr's layout bug was actually caught.
- `just lint` · `just build` · `just search` · `uv run pytest` all green;
  `grep -rn 'TODO\|{{' docs/pages/pi-harness-guide specs/pi-harness-guide/doc` returns nothing.

Loop: fix → rebuild → re-verify until every box in the plan's Phases 4–5 and Validation section
is `[x]`.

## Step 6 — Ship (plan Phase 6)

Mark plan statuses, append a dated Amendment summarizing the build (include any `[f]` items and
why), then: `git add` everything listed in Deliverables + the plan + `.rumdl.toml`, commit as
`feat: add Pi coding harness field guide` (body: sections, research provenance, verification
summary), push, and `gh pr create` against `main` with a test-plan checklist mirroring Phases 4–5.
Report the PR URL.
