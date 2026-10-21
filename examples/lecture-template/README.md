# Lecture Template

5-slide skeleton for live lectures using the deck-kit design system. Covers the full lecture archetype sequence: cover, learning objectives, concept, recap, references-list.

## Slide Map

| # | File | Archetype | Notes |
|---|---|---|---|
| 01 | 01-cover.html | cover | Adapted workshop cover, simpler pill row |
| 02 | 02-learning-objectives.html | learning-objectives (lecture) | 4 bullets, progressive reveal |
| 03 | 03-concept.html | concept | 3 paradigm cards |
| 04 | 04-recap.html | recap (lecture) | End of Chapter 1 summary |
| 05 | 05-references.html | references-list (lecture) | 6 source rows |

## How This Differs from the Workshop Template

- No phase cards, no terminal demos, no GATE semantics.
- Deck opens with `learning-objectives` immediately after cover (workshop opens with a quote).
- `references-list` closes the deck instead of `closing-takeaways`.
- Presenter scale is `1.25×` default (set in body rules for lecture archetypes); workshop uses `1.15×`.
- Source markers used in lecture scripts: `[EXPLAIN]` / `[EXAMPLE]` / `[OBJECTIVE]` / `[RECAP]` / `[JUMP]`.
- Index groups slides into 3 sections: Cover, Lecture Chapter 1, References.

## Running Locally

```bash
# from the repo root
node scripts/serve.mjs examples/lecture-template 8080
# open http://127.0.0.1:8080
```

Add `?presenter` to any URL for presenter mode (1.25× scale, progress bar, keyboard nav).

## Audit Checks

```bash
# All 4 gates in order (static, tokens, http, visual)
bash "${CLAUDE_PLUGIN_ROOT}/scripts/audit-all.sh" .
```
