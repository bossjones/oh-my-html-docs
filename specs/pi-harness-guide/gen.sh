#!/usr/bin/env zsh
# Image batch for the Pi harness field guide (herdr-guide pipeline).
#
# IMPORTANT: run with the MAIN CHECKOUT as cwd so python-dotenv finds its .env
# (the worktree has none):
#   cd /Users/bossjones/dev/bossjones/oh-my-html-docs && zsh <worktree>/specs/pi-harness-guide/gen.sh
#
# 13 images: 6 guide figures -> doc/images/, 7 plan figures -> spec root.
# All 1536x1024 high quality, parallel, per-image logs in png-src/.
set -u

GEN="$HOME/.claude/plugins/cache/boss-skills/agent-harness/0.31.3/skills/planf3/scripts/generate_gpt_image.py"
OUT="/Users/bossjones/dev/bossjones/oh-my-html-docs/.claude/worktrees/pi-harness-html-page-2fba0c/specs/pi-harness-guide"

# Shared visual identity — matches the plan's :root (paper / ink / steel blue / rust).
STYLE="Professional minimal flat geometric vector illustration on a warm paper background (#F4F2ED) with a faint graph-paper grid. Ink (#1C222B) line work, steel-blue (#6A9FCC) as the single primary accent, rust (#8F3222) used sparingly for one emphasis detail. Engineer's notebook aesthetic with elegant serif italic caption lettering. Under 8 words of text in the whole image. No gradients, no photorealism, generous whitespace, centered composition."

mkdir -p "$OUT/doc/images" "$OUT/png-src"

gen() { # gen <outdir> <name> <prompt>
  local dir=$1 name=$2 prompt=$3
  uv run "$GEN" "$prompt $STYLE" "$dir/$name.png" --size 1536x1024 --quality high \
    > "$OUT/png-src/$name.gen.log" 2>&1 &
}

# ---- guide figures (doc/images/) ----
gen "$OUT/doc/images" hero \
  "One dark ink terminal window with a small serif italic pi glyph as its prompt, thin steel-blue circuit traces radiating outward to six small plug-in module blocks. Serif italic caption below: THE HARNESS THAT IS YOURS."
gen "$OUT/doc/images" core \
  "A small central ring containing four simple tool glyphs (page, pencil, diff, shell chevron), surrounded by an outer orbit of socket notches, three sockets filled by plugged-in module blocks. Caption: MINIMAL CORE. EVERYTHING ELSE PLUGS IN."
gen "$OUT/doc/images" ladder \
  "Three ascending ladder rungs drawn in ink rising left to right, from a small empty terminal at the bottom to a fully wired terminal with plug-in modules at the top. Caption words on the rungs: QUICKSTART, RECOMMENDED, ADVANCED."
gen "$OUT/doc/images" tree \
  "A session tree: one ink trunk line of conversation nodes branching into three limbs, one abandoned limb folding into a small summary card that rejoins the trunk. Caption: SESSIONS ARE TREES."
gen "$OUT/doc/images" events \
  "A circular agent loop diagram: arrows cycling through four stages, with small steel-blue socket points attached around the ring where extensions hook in. Caption: EVERY EVENT IS YOURS."
gen "$OUT/doc/images" ecosystem \
  "An ink map: a central island holding a pi terminal, linked by steel-blue dotted paths to four labeled islands: DOCS, PACKAGES, DAN, EDITOR. No other text."

# ---- plan figures (spec root) ----
gen "$OUT" hero \
  "One dark ink terminal window with a small serif italic pi glyph as its prompt, thin steel-blue circuit traces radiating outward to plug-in module blocks. Serif italic caption: THE HARNESS THAT IS YOURS."
gen "$OUT" problem \
  "Scattered loose paper notes and documentation pages drifting apart across a graph-paper desk, one small empty dark terminal window alone in the middle. Caption: SCATTERED KNOWLEDGE, NO MAP."
gen "$OUT" solution \
  "A three-rung ladder drawn in ink rising across graph paper from a small empty terminal to a fully wired terminal with plugged-in modules. Caption: QUICKSTART, RECOMMENDED, ADVANCED."
gen "$OUT" phase-identity \
  "An ink wireframe of a webpage on graph paper: a serif italic headline block, two small dark terminal-style code blocks, steel-blue link underlines. Caption: PAPER, INK, TERMINAL."
gen "$OUT" phase-sections \
  "Thirteen small ink index cards fanned in an arc across graph paper, three of them highlighted in steel blue forming ascending steps. Caption: THIRTEEN SECTIONS, ONE LADDER."
gen "$OUT" questionables \
  "A paper checklist with ink checkboxes, half stamped with steel-blue YES marks, one rust question mark hovering above the list. Caption: YES OR NO."
gen "$OUT" notes-map \
  "An ink map on graph paper: a central pi terminal node linked by steel-blue paths to four labeled islands: DOCS, PACKAGES, DAN, EDITOR. Caption: ONE PAGE, FOUR TERRITORIES."

wait
echo "--- generation complete ---"
ls -la "$OUT/doc/images" "$OUT"/*.png 2>/dev/null
