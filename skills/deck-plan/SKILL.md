---
name: deck-plan
description: "Use when the user wants to PLAN a presentation deck from a thesis, outline, article, or script — before any HTML is generated. Turns source material of any kind into a reviewed slide plan (.planning/deck-spec.md): deck type (workshop / lecture / talk), scoping dialog (source, identity, sections, archetypes, demos, presenter scale, output dir, language), then one plan line per slide (archetype · title · key message · source span). Triggers on 'plan a deck', 'plan my slides', 'slide plan', 'outline a presentation', 'deck spec', 'prepare a workshop/lecture/talk from this doc'. Hands off to deck-build, which generates the HTML."
user_invocable: true
argument-hint: "[source.md path | empty]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

# deck-plan — from source material to a reviewed slide plan

## What this skill does

Takes a thesis, outline, article, script, or nothing at all — and turns
it into a **slide plan** the user has reviewed and approved, written to
`<output-dir>/.planning/deck-spec.md`. It never generates HTML; that is
deck-build's job. The two skills share exactly one contract:
[`../_shared/deck-spec-format.md`](../_shared/deck-spec-format.md).

Pipeline position:

```
deck-plan  →  .planning/deck-spec.md  →  deck-build  →  HTML deck + 4 gates
```

## When to use

- User asks to "plan a deck", "outline a presentation", "prepare slides
  from this document" — planning intent, not build intent.
- User has a source (article, script, README, meeting notes) and wants
  to see the slide breakdown before committing to generation.
- User invoked `/deck-kit:plan`.

If the user clearly wants finished slides right now and a
`.planning/deck-spec.md` already exists, hand over to deck-build
(`/deck-kit:build`) instead of re-planning.

## Non-negotiables

1. **One scoping question at a time.** Use `AskUserQuestion` with the
   canned payloads from
   [`references/scoping-questions.md`](references/scoping-questions.md)
   — Q0 through Q8, in order. Skip only the questions the reference
   marks skippable (Q5 for non-workshops).
2. **Content is sourced, never invented.** Every planned slide cites a
   source span (line range, marker anchor, or explicit `free-text`
   supplied by the user). If there is no source, build the outline WITH
   the user — never fabricate facts to fill slides.
3. **Archetypes come from the catalog.** Every plan line uses a name
   from [`references/archetype-catalog.md`](references/archetype-catalog.md),
   spelled exactly.
4. **The plan is reviewed as a batch.** Unlike deck-build's per-slide
   loop, the slide plan is presented and approved as one block — it's a
   plan, cheap to regenerate, and the user needs to see the whole arc.
5. **The spec is the deliverable.** The skill is done when
   `.planning/deck-spec.md` is written in the format of
   [`../_shared/deck-spec-format.md`](../_shared/deck-spec-format.md)
   and the user has approved it.

## Flow

### 1 · Scoping (Q0-Q8)

Ask Q0 (deck type) → Q1 (source) → Q2-Q8, one at a time, payloads from
[`references/scoping-questions.md`](references/scoping-questions.md).
Routing details per type: [`references/deck-types.md`](references/deck-types.md).

On Q1:
- **Path given** → Read the file fully (chunked if >1000 lines).
- **Pasted content** → treat the paste as the source; save it to
  `<output-dir>/.planning/source.md` so spans stay citable.
- **Nothing yet** → co-draft an outline with the user, one section at a
  time, then treat that outline as the source.

If the source contains bracketed stage markers, run the marker-mapping
follow-up (see
[`../_shared/content-markers.md`](../_shared/content-markers.md)):
confirm the standard set (`[SHOW]`/`[SAY]`/`[RUN]`/…) or map the user's
own tags once, and record the mapping in the spec's `marker_map:` field.

### 2 · Draft the slide plan

- Parse the source per the strategy in
  [`../_shared/content-markers.md`](../_shared/content-markers.md):
  markers first, then headings, callouts, tables, lists.
- Draft one line per slide:
  `NN. <archetype> · <title> · <key message> · <source span>`.
- Respect the planning guidance at the bottom of
  [`references/archetype-catalog.md`](references/archetype-catalog.md)
  (cover first, closing/cta last, talk ordering, scroll-tolerant
  archetypes for dense content).
- Target slide counts by type: workshop ≈ 1 slide / 3 min, lecture ≈ 1
  slide / 2-3 min, talk ≈ 1 slide / 1.5-2 min of planned duration.

### 3 · Batch review

Present the entire plan and ask the plan-review question (see
"Plan review" in
[`references/scoping-questions.md`](references/scoping-questions.md)).
Iterate on the numbered lines the user calls out. Re-present until
approved.

### 4 · Write the spec

Write `<output-dir>/.planning/deck-spec.md` exactly per
[`../_shared/deck-spec-format.md`](../_shared/deck-spec-format.md):
header fields from Q0-Q8 answers + marker map + the approved slide-plan
lines. Then tell the user:

> Plan approved and saved to `<output-dir>/.planning/deck-spec.md`.
> Next: run `/deck-kit:build <output-dir>` to generate the deck
> slide-by-slide with the 4-gate validation.

## Red flags — stop and reconsider

- "The topic is familiar, I can skip scoping." → No. Always run Q0-Q8.
  Plan quality depends on scoping precision.
- "User said 'slides' without a type — I'll assume workshop." → No.
  Ask Q0 first; lecture/talk have different defaults and archetypes.
- "The source is thin, I'll pad the plan with invented slides." → No.
  Every line cites a span or an explicit user-provided `free-text`.
- "I'll write the plan and start generating HTML right away." → No.
  HTML belongs to deck-build; the handoff is the spec file.
- "The plan looks long, I'll trim slides silently." → No. Propose cuts
  in the batch review; the user decides.

## References

- [`references/scoping-questions.md`](references/scoping-questions.md) —
  canned `AskUserQuestion` payloads Q0-Q8 + marker follow-up + plan review.
- [`references/deck-types.md`](references/deck-types.md) — the three
  deck types, signals, defaults, archetype mixes.
- [`references/archetype-catalog.md`](references/archetype-catalog.md) —
  all archetypes, one line each, + planning guidance.
- [`../_shared/deck-spec-format.md`](../_shared/deck-spec-format.md) —
  the spec format contract (shared with deck-build).
- [`../_shared/content-markers.md`](../_shared/content-markers.md) —
  standard marker set, custom-marker mapping, parsing strategy.
