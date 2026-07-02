# Workshop Example — Test-Driven Refactoring

A compact, 8-slide **workshop** deck built with the deck-kit `deck-build`
skill (this is the dogfood example the skill points at). It walks a hands-on
session on refactoring a legacy module behind a test safety net.

## What it demonstrates

The full workshop archetype sequence on the frozen design-token system:

| # | File | Archetype | Shows |
|---|---|---|---|
| 01 | `01-cover.html` | cover | Orbit-field title, kicker, pills, speaker meta |
| 02 | `02-quote.html` | quote | Giant quote mark, highlighted phrase, attribution, bottom hook |
| 03 | `03-concept.html` | concept | Three equally-weighted concept cards |
| 04 | `04-phase-1.html` | phase (cyan) | `phase-shared.css` GOAL / INPUT→OUTPUT / COMMANDS / GATE |
| 05 | `05-demo-1-tests.html` | terminal-demo | `demo-runner.js` scripted red→green characterization run |
| 06 | `06-refactor-flow.html` | flow | Scroll-tolerant vertical chain smell → pin → extract → verify → commit |
| 07 | `07-gate-review.html` | gate-review | Amber approval checklist + awaiting-confirmation badge |
| 08 | `08-closing.html` | closing | Three takeaways + one-action CTA + contact line |

It also shows the two supporting artifacts every deck-kit deck ships with:
`.planning/deck-spec.md` (the machine-checkable slide plan) and
`.planning/deck-manifest.md` (slide order, archetypes, gate results).

All content is neutral: fictional speaker "Alex Morgan", no real people,
companies, or private data. The quote is a real, correctly attributed line
from Martin Fowler's *Refactoring* (1999).

## How to present it

```bash
cd examples/workshop-example
python3 -m http.server 8765
# open http://localhost:8765
```

- The grid at `/` lists all slides in three sections. Click a tile to open it.
- Arrow keys / Space move between slides; `Esc` returns to the grid.
- Add `?presenter` to any URL (or hit `P`) for presenter mode: 1.15× scale,
  progress bar, and a slide counter.
- On the demo slide, click **RUN DEMO** to play the scripted terminal session.

## Re-running the gates

From the repository root (Playwright resolves from the repo's `node_modules`):

```bash
bash scripts/audit-static.sh  examples/workshop-example
bash scripts/audit-tokens.sh  examples/workshop-example
bash scripts/audit-http.sh    examples/workshop-example
node scripts/audit-visual.mjs examples/workshop-example
```

All four gates must be green. Latest results are recorded in
`.planning/deck-manifest.md`.
