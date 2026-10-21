# deck-spec.md — Format Contract

`<output-dir>/.planning/deck-spec.md` is the single artifact that
connects the two deck-kit skills: **deck-plan** writes it, **deck-build**
reads it. Both sides must honour this exact format — the slide-plan
lines are machine-checkable (evals and CI parse them with a regex).

## File layout

```markdown
# Deck Spec

- deck_type: workshop | lecture | talk
- title: <deck title>
- speaker: <speaker name>
- date: <date as the user gave it>
- venue: <venue / event / "—">
- source: <path to source file | "inline" | "none">
- sections: <N> (<comma-separated section names>)
- archetypes: <comma-separated planned archetype names>
- terminal_demos: <N | none>
- presenter_scale: 1.15 | 1.25 | 1.35 | none
- output_dir: <path>
- language: <BCP-47 code, e.g. en, uk, de>
- theme: <shipped theme name, e.g. cyberpunk | "custom (<colours as given>)">
- marker_map: <"standard" | comma-separated pairs like "[ZEIGEN]=[SHOW], [SAGEN]=[SAY]" | "none">

## Slide plan

01. cover · <title> · <key message> · <source span>
02. <archetype> · <title> · <key message> · <source span>
…
```

## Slide-plan line grammar

One line per slide, strictly:

```
NN. <archetype> · <title> · <key message> · <source span>
```

- `NN` — two-digit slide number, zero-padded, sequential from 01,
  followed by `.` and a space.
- `<archetype>` — one name from `archetype-catalog.md`
  (deck-plan side) / `archetypes*.md` (deck-build side). Lowercase,
  hyphenated, exactly as catalogued.
- `<title>` — the slide title in the deck language. No `·` inside
  (replace with `-` if the title needs a separator).
- `<key message>` — one sentence: what the audience must take away
  from this slide. Not a repeat of the title.
- `<source span>` — where the content comes from, one of:
  - `source:L120-L145` — line range in the source file;
  - `source:L88 [SHOW]` — a marker anchor (mapped markers allowed);
  - `free-text` — content supplied in dialog, not from the source.
- Separator is ` · ` (space, U+00B7 middle dot, space) — exactly three
  characters between fields, four fields total.

Machine check (what evals and validators run):

```
^\d{2}\. [a-z][a-z0-9-]* · [^·]+ · [^·]+ · [^·]+$
```

## Incremental writing (standalone mode)

When deck-build runs standalone (no prior deck-plan), it appends one
slide-plan line to the spec **after each slide is confirmed and
generated** — the spec is then a build log that a future resumption or
audit can still parse. Header fields it didn't scope stay empty rather
than invented.

## What deck-build may change

- Append/adjust the line of the slide currently being built (archetype
  swap during PS1, title refinement during PS2).
- Never renumber silently: inserting a slide means rewriting subsequent
  `NN.` prefixes AND the `SLIDES` array together.
- Header fields are read-only for deck-build except `output_dir`
  (fill if empty) and `marker_map` (fill after a mapping dialog).
