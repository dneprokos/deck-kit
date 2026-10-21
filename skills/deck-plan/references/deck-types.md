# Deck Types — Routing Table

deck-kit produces three deck types. Each type has its own presenter
defaults, length expectations, and archetype mix. Pick the type first
(Q0 in scoping), then everything downstream routes off that choice.
All three types produce the same output format: an HTML deck (one file
per slide + `index.html` grid).

## Routing table

| Deck type | Pipeline | Presenter scale | Length | Key archetypes |
|---|---|---|---|---|
| **workshop** | plan → build, 4 gates | 1.15× | 60-120 min | phase, terminal-demo, gate-review, flow |
| **lecture** | plan → build, 4 gates | 1.25× | 30-120 min | cover, learning-objectives, concept, chapter-break, recap, references-list |
| **talk** | plan → build, 4 gates | 1.35× | 15-45 min | cover, hook, thesis, memorable-moment, cta-simple |

## Deck type descriptions

### Workshop

Hands-on technical training. Audience follows along, sometimes runs
commands. Long-form (60-120 min), interactive beats every 3-5 slides,
live terminal demos are the backbone.

**Signals:** user says "workshop", "training", mentions `[SHOW]` /
`[RUN]` markers (or their own equivalents), references live demos.

**Canonical example:** `examples/workshop-example/`.

### Lecture

Educational content for a course or classroom, delivered live (webinar
or in-room). Tighter structure than workshop: learning objectives up
front, chapter breaks, periodic recaps, references list at the end.

**Signals:** user says "lecture", "course", mentions "learning
objectives", "chapters", references Module N / Lesson N structure.

**Canonical example:** `examples/lecture-template/` (5 slides).

### Talk

Conference keynote or short speech. 15-45 min delivered format, tighter
than workshop, more rhetorical than lecture. Strong hook, one central
thesis, memorable moment, clear CTA.

**Signals:** user says "talk", "keynote", "conference", mentions
`[HOOK]` / `[THESIS]` markers (or their own equivalents).

**Canonical example:** `examples/talk-template/` (5 slides).

## Archetype mix per type

Core 15 archetypes (cover, quote, comparison, concept, diagram, flow,
phase, terminal-demo, table, formula, tabs, sizing-flow, wheel,
closing, qa-intro) are shared. Each type adds specific archetypes:

| Deck type | Type-specific archetypes | Reference file (in deck-build) |
|---|---|---|
| workshop | gate-review | `references/archetypes.md` (inline) |
| lecture | learning-objectives, chapter-break, recap, references-list | `references/archetypes-lecture.md` |
| talk | hook, thesis, memorable-moment, cta-simple | `references/archetypes-talk.md` |

The one-line planning catalog (all 23 archetypes, no DOM) lives in
`archetype-catalog.md` — use it when drafting the slide plan.

## Presenter scale defaults (Q6)

Presenter mode multiplies base font sizes for readability during live
presentation. Default per deck type:

- **workshop 1.15×** — small group, close screen, laptop-width OK.
- **lecture 1.25×** — classroom or webinar, middle viewing distance.
- **talk 1.35×** — conference hall or large monitor, far viewing distance.

User can override via Q6 (`AskUserQuestion`).

## Scoping flow

```
Q0 deck_type?  (workshop | lecture | talk)
   └── Q1-Q9 (source, identity, sections, archetypes, demos*,
              presenter scale, output dir, language, theme)
       * Q5 demos asked only for workshop
```

After Q0-Q9 complete, the slide plan is drafted and written to
`.planning/deck-spec.md` (format: `_shared/deck-spec-format.md`).
