# Content Markers — Source Markdown Conventions

Deck source files use markdown with inline stage-direction markers.
deck-plan reads them to draft the slide plan; deck-build maps them to
slide slots. Neither skill invents content — they quote the source.

## The standard marker set (English)

Marker sets differ per deck type:

- **Workshop** — `[SHOW]` / `[SAY]` / `[RUN]` / `[EXPECT]` / `[ASK]` /
  `[FALLBACK]` / `[BEAT]`.
- **Lecture** — `[EXPLAIN]` / `[EXAMPLE]` / `[CHECK]` / `[OBJECTIVE]` /
  `[RECAP]` / `[JUMP]`.
- **Talk** — `[HOOK]` / `[THESIS]` / `[STORY]` / `[MEMORABLE]` / `[CTA]`.

### Marker vocabulary — Workshop

| Marker | Meaning | Maps to |
|---|---|---|
| `[SHOW] …` | "I show" — visual cue | Slide anchor (one marker ≈ one slide minimum) |
| `[SAY] …` | "I say" — spoken narration | Slide body text (tagline, key point, subtitle) |
| `[EXPECT] …` | Expected output | `terminal-demo` steps (what the viewer sees) |
| `[RUN] …` | Command to execute | `DemoRunner` `command` field |
| `[ASK] …` | Question to the audience | Q&A pill or interactive beat |
| `[FALLBACK] …` | Plan B if the live demo fails | Fallback content / pre-recorded screencast reference |
| `[BEAT]` | Deliberate pause | Slide seam — previous beat ends one slide, the next starts a new one |

### Marker vocabulary — Lecture

| Marker | Meaning | Maps to |
|---|---|---|
| `[EXPLAIN] …` | Exposition | Body text of `concept` / `diagram` slide |
| `[EXAMPLE] …` | Concrete illustration | Example card within `concept` archetype |
| `[CHECK] …` | Comprehension check | `qa-intro` or interactive beat |
| `[OBJECTIVE] …` | Learning objective | `learning-objectives` archetype bullet |
| `[RECAP] …` | Chapter recap | `recap` archetype card |
| `[JUMP] …` | Chapter transition | `chapter-break` archetype seed |

### Marker vocabulary — Talk

| Marker | Meaning | Maps to |
|---|---|---|
| `[HOOK] …` | Attention grab, opening | `hook` archetype |
| `[THESIS] …` | Central thesis statement | `thesis` archetype |
| `[STORY] …` | Personal story / anecdote | `quote` or `concept` variant |
| `[MEMORABLE] …` | Memorable, quotable line | `memorable-moment` archetype |
| `[CTA] …` | Call to action | `cta-simple` archetype |

## Map your own markers — once, during scoping

Sources written in other languages or with home-grown conventions are
first-class. If the source uses different bracketed tags (any language:
`[РОЗПОВІДАЮ]`, `[ZEIGEN]`, `[DEMO-STEP]`, …), do NOT ask the user to
rewrite the source. Instead, during scoping (deck-plan) or the
standalone mini-scoping (deck-build), ask the user to map their tags to
the standard set **once**, and record the mapping in
`.planning/deck-spec.md` under `marker_map:`. Example:

```
- marker_map: [ZEIGEN]=[SHOW], [SAGEN]=[SAY], [STARTEN]=[RUN]
```

From then on, every reference to `[SHOW]` in either skill means "the
user's mapped equivalent". Never re-ask for a mapping that is already
in the spec.

## Markdown constructs that become slide elements

- `## Heading` → slide title candidate (the skill asks to confirm)
- `### Sub-heading` → section divider in long scripts
- `> [!quote] …` callouts → **quote** archetype seed
- `> [!tip] …`, `> [!note] …`, `> [!warning] …` → body callout box inside a
  slide (e.g. `.pattern-card` variant)
- `| col | col |` markdown tables → **table** archetype seed
- ` ```mermaid … ` fenced blocks → inline SVG (the skill asks whether to
  render via mermaid or hand-draw)
- `- [ ]` task list → `.gate-checklist` candidate on a phase slide
- Numbered lists `1. … 2. … 3. …` → **concept** or **comparison** archetype
  candidate when there are 2-4 entries

## Parsing strategy

When the user points the skill at a source file, follow this sequence:

1. **Read the whole file** with the `Read` tool. If > 1000 lines, read in
   chunks and keep notes. Do not skim.
2. **Extract markers** with `Grep` for each marker tag (standard set +
   mapped equivalents) in parallel.
3. **Cluster by proximity** — a `[SHOW]` + nearby `[SAY]` + `[RUN]` +
   `[EXPECT]` group is typically one slide (often a terminal-demo
   archetype).
4. **Present the slide plan** to the user: "I see 23 `[SHOW]` anchors →
   roughly 23 slides. Want me to propose the archetype for each, or would
   you rather group differently?"
5. **Never infer** content that isn't in the source. If a slot is empty,
   ask. If the user wants a new slide not in the source, ask for 1-2
   sentences of content before generating.

## Dual-language sources

Sources may mix a natural language with English code comments and
commands. Keep that split:
- Slide text → the deck language from scoping Q8.
- Commands / filenames / API paths → original (usually English).
- Eyebrow / label tokens like `GOAL`, `INPUT`, `OUTPUT`, `GATE`,
  `COMMANDS`, `LIVE DEMO` → uppercase English (design-system convention,
  not content).

## Quoting policy

Lift factual claims verbatim from the source. If the source says "wasted
$1M over 2.5 years", the slide says exactly that — not "spent a lot of
money over a long period". Aphorisms stay in their original language.
Do not rewrite the author's voice.

## When the source is missing

If the skill is invoked with no source file, ask during scoping: "Paste
the section headings / bullet list you want to cover, or point me at a
file." Then treat that paste as the source.

Never generate a deck from nothing — even with elaborate Socratic
questioning, you risk hallucinating facts. Slides reference reality;
reality lives in the source the user provides.
