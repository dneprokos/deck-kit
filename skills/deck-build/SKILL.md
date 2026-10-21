---
name: deck-build
description: "Use when the user wants to BUILD or AUDIT an HTML presentation deck — workshop (hands-on, terminal demos), lecture (live educational), or talk (conference keynote). Three modes: (1) spec mode — a .planning/deck-spec.md exists (written by deck-plan) → scaffold + per-slide Socratic generation; (2) audit mode — an existing deck dir with index.html and no new-slide request → run only the 4 validation gates (static + tokens + HTTP smoke + Playwright visual); (3) standalone — no spec → recommend deck-plan, or run a 4-question mini-scoping. Triggers on 'build the deck', 'generate slides', 'make a workshop/lecture/talk deck', 'deck audit', 'validate my deck', 'add a slide'. Every deck must pass all 4 gates before it is declared done."
user_invocable: true
argument-hint: "[deck dir with .planning/deck-spec.md | existing deck dir | empty]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

# deck-build — Socratic HTML deck generator + 4-gate auditor

## What this skill does

Generates presenter-grade HTML decks (one `NN-slug.html` per slide +
`index.html` grid, keyboard nav, presenter mode) slide-by-slide with
per-slide confirmation, then validates through 4 independent gates.
Planning lives in the sibling skill **deck-plan**; the contract between
them is [`../_shared/deck-spec-format.md`](../_shared/deck-spec-format.md).

```
deck-plan  →  .planning/deck-spec.md  →  deck-build  →  HTML deck + 4 gates
```

## Mode selection — decide FIRST, from the argument

Inspect the argument / context in this order:

1. **Spec mode** — `<dir>/.planning/deck-spec.md` exists with slide-plan
   lines → scaffold (if needed) and run the per-slide loop with PS1-PS3
   pre-filled from the spec. This is the happy path.
2. **Audit mode** — `<dir>/index.html` exists and the user did NOT ask
   for new/changed slides (words like "audit", "validate", "check") →
   run only the 4 gates against the directory, report, stop. Touch no
   content.
3. **Standalone** — no spec, no existing deck → recommend running
   `/deck-kit:plan` first (it produces a reviewed slide plan; decks
   built from a plan come out more coherent). If the user declines, run
   the mini-scoping below and write the spec incrementally as slides
   are confirmed.

Editing an existing deck (insert / reorder / swap a slide) is spec mode
if the spec exists, standalone otherwise — the per-slide loop applies
to the affected slides only.

## Non-negotiables

1. **Socratic per-slide.** NEVER batch-generate slides without
   per-slide confirmation. Default: 3-5 `AskUserQuestion` prompts per
   slide (PS1-PS5). The user can opt into fast mode after slide 3 by
   explicit request. In spec mode PS1-PS3 are confirmations pre-filled
   from the spec line, not open questions.
2. **Design tokens frozen.** All colour / font / radius / glow values
   come from `:root` in `shared.css`, referenced by role name
   (`--accent-primary`, `--accent-warn`, …). No hardcoded hex and no
   `rgb()/rgba()/hsl()` in slides — translucent colours are
   `color-mix(in srgb, var(--token) N%, transparent)`, and inline SVG uses
   `style="fill: var(--token)"` (see
   [`references/design-tokens.md`](references/design-tokens.md)).
   Gate 2 fails the deck otherwise.
3. **Content sourced, never invented.** Quote exact spans from the
   source named in the spec. Do not rewrite factual claims. If a fact
   is not in the source, ask before inventing.
4. **Every deck MUST pass all 4 gates** before being declared done:
   static → tokens → HTTP smoke → Playwright visual. See
   [`references/validation-pipeline.md`](references/validation-pipeline.md).
5. **Desktop-only, 1920×1080 canonical.** `min-width: 1280px` is locked.
   Do not design for mobile.
6. **Slide language per spec.** Body text in the `language:` from the
   spec (or mini-scoping). Design-system labels `GOAL`, `INPUT`,
   `OUTPUT`, `GATE`, `COMMANDS` stay uppercase English — they are
   tokens, not content.

## Standalone mini-scoping (4 questions)

Only when the user declined `/deck-kit:plan`:

1. **Deck type** — workshop / lecture / talk (payload: Q0 in deck-plan's
   scoping bank).
2. **Source** — file path, pasted content, or co-drafted outline. Never
   generate from nothing. If the source has bracketed markers, map them
   once per [`../_shared/content-markers.md`](../_shared/content-markers.md).
3. **Identity** — title · speaker · date · venue (free-text).
4. **Output dir + language** — combined question; defaults `deck/`, `en`.

Then scaffold and enter the per-slide loop. After EACH confirmed slide,
append its plan line to `.planning/deck-spec.md` (see "Incremental
writing" in [`../_shared/deck-spec-format.md`](../_shared/deck-spec-format.md))
— the spec doubles as the build log.

## Scaffold

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/new-skeleton.sh" --type=<workshop|lecture|talk> <output-dir>
```

The type flag routes which assets get copied:
- `workshop` — full set (shared.css, shared.js, demo-runner.js,
  demo-shared.css, phase-shared.css, index.html).
- `lecture` — shared.css, shared.js, phase-shared.css, index.html (no
  demo-runner by default; add it if a terminal-demo slide is requested).
- `talk` — shared.css, shared.js, index.html (minimal).

Replace placeholders in `index.html`: `{{lang}}` (BCP-47 code from the
spec's `language:`), `{{title}}`, `{{speaker}}`, `{{date}}`,
`{{duration}}`, `{{lede}}`, `{{slides_total}}`. Populate the `SECTIONS`
array from the spec's `sections:` field.

## Per-slide Socratic loop

For slide `N` of `TOTAL`, ask PS1-PS5 from
[`references/per-slide-questions.md`](references/per-slide-questions.md):

1. **PS1 archetype** — options reflect deck type; in spec mode the
   spec's archetype leads, marked "(from plan)". Blueprints:
   [`references/archetypes.md`](references/archetypes.md) (core 15 +
   gate-review), [`references/archetypes-lecture.md`](references/archetypes-lecture.md),
   [`references/archetypes-talk.md`](references/archetypes-talk.md).
2. **PS2 title** — in the deck language.
3. **PS3 source span** — line range / marker anchor / free-text.
4. **PS4 hero visual** — varies by archetype.
5. **PS5 archetype drill-down** — phase colour, demo command,
   comparison labels, hook question, etc.

Then:

- Read the source span with `Read`.
- Generate `NN-slug.html` filling the archetype's DOM skeleton
  (animations: [`references/animations.md`](references/animations.md);
  terminal demos: [`references/terminal-demo-dsl.md`](references/terminal-demo-dsl.md)).
- Append to `SLIDES` in `shared.js` — keep in visit order, keep
  `SLIDES.length` == files on disk
  ([`references/navigation-contract.md`](references/navigation-contract.md)).
- Update the `SECTIONS` range in `index.html` if needed.
- Confirm: "✓ generated `NN-slug.html` — ready for slide N+1?"

After slide 3, offer fast mode (payload in per-slide-questions.md).
Default stays Socratic.

## Validation pipeline — 4 gates, strict order

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/audit-static.sh"  <output-dir>
bash "${CLAUDE_PLUGIN_ROOT}/scripts/audit-tokens.sh"  <output-dir>
bash "${CLAUDE_PLUGIN_ROOT}/scripts/audit-http.sh"    <output-dir>
node "${CLAUDE_PLUGIN_ROOT}/scripts/audit-visual.mjs" <output-dir>
```

(Or all four: `bash "${CLAUDE_PLUGIN_ROOT}/scripts/audit-all.sh" <output-dir>`.)

Show the user each gate's ✓/✗ (VGate/VFix payloads in
per-slide-questions.md). All four MUST be green before shipping. Gate
details and re-run rules:
[`references/validation-pipeline.md`](references/validation-pipeline.md).

Gate 4 needs Playwright + Chromium. `audit-visual.mjs` resolves
playwright from its own install OR from the deck project's
`node_modules`; if neither exists it exits with code 2 and prints
install instructions — surface them to the user, do not silently skip.

## Ship

1. Write `<output-dir>/.planning/deck-manifest.md`:
   - deck type
   - slide order (file → archetype → source span)
   - archetypes used (distinct list)
   - validation result per gate + timestamp (and any explicitly
     user-approved `--skip-visual`)
2. Tell the user how to present:
   `cd <output-dir> && python3 -m http.server 8765` → open
   `http://localhost:8765` (grid) — arrows/Space to navigate, Esc back
   to index, PRESENTER MODE toggle in the grid header.
3. Point at `.audit/screenshots/` for visual review.

## Red flags — stop and reconsider

- "Batch-generate 5 slides in one go for efficiency." → No. Per-slide
  dialog + confirm is the whole point.
- "Hardcoded hex is faster than tokens." → No. Gate 2 forces a rewrite
  anyway. Use `var(--…)` from the start.
- "SLIDES.length mismatch — ignore." → No. It silently breaks keyboard
  nav beyond the array length.
- "Playwright missing, skip Gate 4." → No. Surface the install
  instructions; skipping needs explicit user consent recorded in the
  manifest.
- "Content can be AI-written, no source reading needed." → No. Slides
  trace to source spans; the author's voice is preserved.
- "3/4 gates green is good enough." → No. Fix the fourth or stop.
- "The spec's archetype seems wrong, I'll silently swap it." → No.
  Propose the swap in PS1 — the user decides, the spec line is updated.

## References

Read on demand when the workflow enters that phase — do not pre-load all.

- [`references/archetypes.md`](references/archetypes.md) — core 15
  blueprints + gate-review, DOM skeletons, decision table.
- [`references/archetypes-lecture.md`](references/archetypes-lecture.md) /
  [`references/archetypes-talk.md`](references/archetypes-talk.md) —
  type add-ons.
- [`references/design-tokens.md`](references/design-tokens.md) — frozen
  palette, `color-mix` and SVG colour rules, typography, literal exceptions.
- [`references/animations.md`](references/animations.md) — keyframe
  library + reduced-motion policy.
- [`references/navigation-contract.md`](references/navigation-contract.md)
  — SLIDES array + defer gotcha + keyboard + presenter mode + naming.
- [`references/terminal-demo-dsl.md`](references/terminal-demo-dsl.md) —
  DemoRunner step types, terminal CSS, rhythm.
- [`references/validation-pipeline.md`](references/validation-pipeline.md)
  — the 4 gates in detail.
- [`references/per-slide-questions.md`](references/per-slide-questions.md)
  — PS1-PS5, fast mode, VGate/VFix, recovery payloads.
- [`../_shared/deck-spec-format.md`](../_shared/deck-spec-format.md) —
  spec contract (shared with deck-plan).
- [`../_shared/content-markers.md`](../_shared/content-markers.md) —
  marker set + custom mapping + quoting policy.

## Examples

- `examples/workshop-example/` — compact workshop deck built by this
  skill (dogfood): cover, quote, concept, phase, terminal-demo, flow,
  gate-review, closing.
- `examples/lecture-template/` — 5-slide lecture skeleton (cover →
  learning-objectives → concept → recap → references).
- `examples/talk-template/` — 5-slide talk skeleton (cover → hook →
  thesis → memorable-moment → cta).

When the user references "a slide like #N", read the matching example
file and lift the pattern.
