# Deck Manifest

- deck_type: workshop
- title: Test-Driven Refactoring
- speaker: Alex Morgan
- language: en
- slides_total: 8
- source: none (free-text, neutral content)

## Slide order

| # | File | Archetype | Source span |
|---|---|---|---|
| 01 | 01-cover.html | cover | free-text |
| 02 | 02-quote.html | quote | free-text |
| 03 | 03-concept.html | concept | free-text |
| 04 | 04-phase-1.html | phase (primary) | free-text |
| 05 | 05-demo-1-tests.html | terminal-demo | free-text |
| 06 | 06-refactor-flow.html | flow | free-text |
| 07 | 07-gate-review.html | gate-review | free-text |
| 08 | 08-closing.html | closing | free-text |

## Archetypes used (distinct)

cover, quote, concept, phase, terminal-demo, flow, gate-review, closing

## Validation results

Run 2026-07-02 11:57 CEST — all four gates green.

| Gate | Script | Result |
|---|---|---|
| 1 · static | audit-static.sh | PASS |
| 2 · tokens | audit-tokens.sh | PASS |
| 3 · http smoke | audit-http.sh | PASS |
| 4 · visual (Playwright, 1920×1080) | audit-visual.mjs | PASS (9/9 incl. index) |

Notes:
- `06-refactor-flow.html` renders at 1119px tall — allowed: the `-flow`
  filename matches the scroll-tolerant archetype pattern (ceiling 8000px).
  All other slides fit within the 1080 viewport (1200px non-scroll limit).
- No `--skip-visual` was used; every gate ran.
