# Talk Template — 5-slide Conference Talk Skeleton

A minimal, high-impact skeleton for DevConf-style conference talks (~25 min).
Use this as the starting point whenever you need a talk deck, not a workshop
or lecture deck.

## What this example is

A 5-slide arc that demonstrates the four talk-specific archetypes from
`references/archetypes-talk.md`, plus the core `cover` archetype from
`references/archetypes.md`. The content is a sample talk titled
"Why Agentic Programming Changes Everything" — swap in your own talk's material.

## Slide → Archetype map

| # | File | Archetype | Body class | Content marker |
|---|---|---|---|---|
| 01 | `01-cover.html` | cover (core) | `cover` | — |
| 02 | `02-hook.html` | hook (talk) | `talk hook` | `[HOOK]` |
| 03 | `03-thesis.html` | thesis (talk) | `talk thesis` | `[THESIS]` |
| 04 | `04-memorable-moment.html` | memorable-moment (talk) | `talk memorable` | `[MEMORABLE]` |
| 05 | `05-cta.html` | cta-simple (talk) | `talk cta` | `[CTA]` |

## How talk decks differ from workshop / lecture decks

**No phase cards.** Workshop decks (e.g. `agentic-workshop/`) have 9 phase
slides each with a full `phase-shared.css` layout: INPUT/OUTPUT/GATE/COMMANDS
grid. Talks have none — every slide is a single visual statement.

**No terminal demos.** Workshop decks embed live-runnable terminals via
`demo-shared.css` + `demo-runner.js`. Talk decks ship neither file.

**No learning objectives.** Lecture decks open with a `learning-objectives`
slide listing what the audience will learn. Talks skip this — the hook does
the motivational work.

**Rhetorical density, not information density.** Each slide has one message.
Cover states the topic. Hook provokes. Thesis anchors. Memorable moment peaks.
CTA closes. No bullets, no 3-column grids, no long lists.

**Minimal decoration.** The cover uses only 2 orbits (vs 3 in workshop).
Hook and memorable-moment use ambient radial glows. Thesis uses a single
bordered card. CTA is pure typography + one amber pill. This restraint keeps
attention on the words.

**Presenter default is 1.35×.** All four archetypes scale the key text element
in `body.presenter` — hook at 5.4rem, thesis at 2.8rem, memorable at 3.8rem,
CTA verb at 4.8rem. The cover title scales to 7.2rem. No change needed in
`shared.css`; each slide has its own presenter rule inline.

**Content markers in source.** When generating slides from a script, look for
`[HOOK]`, `[THESIS]`, `[MEMORABLE]`, `[CTA]` markers in the text source. These
map 1-to-1 to the four talk archetypes above.

## How to run

Open `index.html` in a browser (Chrome / Safari / Firefox). All assets are
local — no build step, no server required for basic preview.

For best results serve over HTTP (avoids browser restrictions on local file
loading):

```
npx serve .
# → http://localhost:3000
```

Press `→` / `Space` to advance, `←` to go back, `Esc` to return to index,
`P` to toggle presenter mode.

## Audit commands

Run all four gates from the skill's `scripts/` directory:

```bash
# Gate 1 — static structure (DOCTYPE, head, shared.css link, shared.js)
bash ../../scripts/audit-structure.sh .

# Gate 2 — token audit (no bare hex outside allow-list)
bash ../../scripts/audit-tokens.sh .

# Gate 3 — HTTP check (serve + curl 200 on all 5 slides + index)
bash ../../scripts/audit-http.sh .

# Gate 4 — visual screenshots (Playwright, saves to .audit/screenshots/)
bash ../../scripts/audit-visual.sh .
```

All five slides plus `index.html` must pass gates 1–3 before shipping.
Gate 4 requires Playwright installed (`npm i -D @playwright/test`).
