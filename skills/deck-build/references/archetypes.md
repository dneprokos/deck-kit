# Archetypes — Slide Blueprints

An archetype is a named slide pattern: a DOM skeleton, a CSS contract, and a
content shape. The deck-build skill asks the user to pick one per
slide and then fills the template from the source material.

This file documents the **core 15 archetypes** shared across all deck types
(workshop / lecture / talk). Deck-type-specific archetypes live in:

- `archetypes-lecture.md` — 4 lecture archetypes (learning-objectives,
  chapter-break, recap, references-list).
- `archetypes-talk.md` — 4 talk archetypes (hook, thesis, memorable-moment,
  cta-simple).
- Workshop-specific (gate-review) is described inline at the bottom of
  this file.

Treat `examples/workshop-example/` as the ground truth for workshop
visuals. For lectures, see `examples/lecture-template/`. For talks, see
`examples/talk-template/`. When a user says "I want a slide like #03 but
for Phase 4", invoke the **phase** archetype and lift the skeleton from
the matching example file.

## Pick the right archetype

Use this decision table first (example files refer to
`examples/workshop-example/`; — means no shipped specimen — build from
the DOM skeleton below):

| If the slide is about… | Use archetype | Example file |
|---|---|---|
| Opening hook, title + speaker | **cover** | `01-cover.html` |
| A single killer quote / stat | **quote** | `02-quote.html` |
| Two mindsets / approaches compared | **comparison** | — |
| A concept introduced via 3-4 cards | **concept** | `03-concept.html` |
| A pipeline or system diagram (SVG) | **diagram** | — |
| A vertical chain of steps/gates | **flow** | `06-refactor-flow.html` |
| One phase of a multi-phase process | **phase** | `04-phase-1.html` |
| A live terminal demo | **terminal-demo** | `05-demo-1-tests.html` |
| A reference / lookup table | **table** | — |
| A hero equation or KPI | **formula** | — |
| Tab-switcher for multi-variant content | **tabs** | — |
| Flow of connector nodes (t-shirt sizing) | **sizing-flow** | — |
| Circular 12-segment reference | **wheel** | — |
| Closing takeaways + CTA | **closing** | `08-closing.html` |
| Q&A section break | **qa-intro** | — |

## Universal requirements

Every slide archetype:

1. Starts with the canonical `<head>`:
   ```html
   <!DOCTYPE html>
   <html lang="{{lang}}">  <!-- BCP-47 code of the deck language from scoping Q8 -->
   <head>
   <meta charset="UTF-8">
   <meta name="viewport" content="width=device-width, initial-scale=1.0">
   <title>{{slide_title}}</title>
   <link rel="stylesheet" href="shared.css">
   <!-- optional: <link rel="stylesheet" href="{phase,demo}-shared.css"> -->
   </head>
   ```
2. Ends with `<script src="shared.js" defer></script>` before `</body>`.
3. Uses only tokens from `design-tokens.md` — no inline hex colours.
4. Fits within `max-width: var(--max-content)` (1400px) with sensible
   padding (`var(--slide-padding)` = 32px, more for covers).
5. Renders at 1920×1080 without horizontal overflow (desktop-only, `min-width`
   is locked at 1280px).

---

## 1 · cover

**Purpose:** opening slide with workshop title, speaker, meta line.
**Hero vibe:** gradient title, orbiting satellites behind everything, ambient
particles.

**Body class:** `cover` (disables standard flex layout, centers everything).

**Content shape:**
- kicker (pill with dot) — e.g. `"Workshop · ~80 min · Hands-on"`
- title (1-2 lines, `<br>` between)
- subtitle with 1-2 strong-emphasised noun phrases
- pill-row with 3-4 pills (counts + key concepts)
- meta-line: speaker · date · role

**DOM skeleton:**
```html
<body class="cover">
<div class="orbit-field">
  <div class="orbit a"><div class="satellite sat-a"></div></div>
  <div class="orbit b"><div class="satellite sat-b"></div></div>
  <div class="orbit c"><div class="satellite sat-c"></div></div>
</div>
<div class="cover-card">
  <div class="kicker"><span class="dot"></span>{{kicker_text}}</div>
  <h1 class="cover-title">{{title_line_1}}<br>{{title_line_2}}</h1>
  <p class="cover-subtitle">{{subtitle_with_strong_tags}}</p>
  <div class="pill-row">
    <div class="pill"><strong>{{n}}</strong> {{label}}</div>
    <!-- 3-4 pills, add .amber/.green/.purple modifier -->
  </div>
  <div class="meta-line">
    <span class="speaker">{{speaker}}</span>
    <span class="sep"></span>
    <span>{{date}}</span>
    <span class="sep"></span>
    <span>{{venue_or_role}}</span>
  </div>
</div>
```

Cover CSS is inline (not in shared.css) — copy the `<style>` block from
`examples/workshop-example/01-cover.html` verbatim, only change text.

---

## 2 · quote

**Purpose:** punchy quote with optional stat counters beneath.
**Vibe:** giant opening quote mark, red-accented "hit" spans, 3 counter cards,
ambient falling particles.

**Body class:** `quote`.

**Content shape:**
- eyebrow (red pill with "Anti-pattern · Founder confession" style)
- big Georgia `&ldquo;` quote mark
- blockquote with 2-3 `<span class="line">` rows; wrap key phrases in
  `<span class="hit">...</span>` to red-highlight with a boxed outline
- `.attr` line with em-dash + attribution
- optional `.counters` grid (3 cards with `.big` number + `.label`)
- optional `.bottom-hook` paragraph for the twist reveal

See `examples/workshop-example/02-quote.html` for the particle fall
animation and timing.

---

## 3 · comparison

**Purpose:** two side-by-side mindsets or approaches with a highlight row.
**Vibe:** two-column grid, each column with its own colour band,
"vs." separator in the middle, anti-pattern side usually red-tinted.

**Body class:** none special; uses `.slide` container.

**Content shape:**
- slide header (eyebrow + gradient title)
- 2-column grid with:
  - side A: title, subtitle, list of 4-6 traits with icons
  - side B: title, subtitle, list of 4-6 traits with icons
- optional centre divider showing `vs.` or an arrow
- optional bottom "key difference" callout band

Grid setup: two `.comparison-col` columns inside a `.comparison-grid`.

---

## 4 · concept

**Purpose:** introduce a concept via 3-4 equally-weighted cards.
**Vibe:** title at top, grid of cards below, each card has icon + title +
description + optional meta line.

**Body class:** none special.

**Content shape:**
- slide-header (eyebrow + title + optional subtitle)
- `.grid-concept` with 3-4 `.concept-card` elements
- each card: number or icon, title, description, optional tag

See `examples/workshop-example/03-concept.html` for card spacing and
hover state.

---

## 5 · diagram

**Purpose:** custom SVG pipeline / architecture diagram.
**Vibe:** large SVG dominant, annotations around it, optional inline legend.

**Body class:** none special.

**Content shape:**
- slide-header
- SVG element (inline, viewBox `0 0 1200 600` or similar)
- use `.flow-arrow` class on dashed-animated arrows
- use `<marker id="ah">` defs for arrowheads
- annotations in `<text>` elements using `font-family: var(--font-mono)`

SVG presentation attributes (`fill="…"`, `stroke="…"`) cannot take `var()`,
so colour SVG through a `style` attribute or a class:
`style="stroke: var(--accent-primary)"`, `style="fill: var(--text-muted)"`.
Never write hex in the SVG — Gate 2 fails it.

Build the SVG stages left-to-right with token-coloured strokes.

---

## 6 · flow

**Purpose:** vertical chain of artifacts → gates → next stage.
**Vibe:** stacked rows with connecting arrows between rows; each row shows
artifact + gate diamond + output.

**Body class:** none special.

**Content shape:**
- slide-header
- `.flow-chain` with alternating `.flow-node` + `.flow-arrow` rows
- gates rendered as `.gate-diamond` with amber colour, flashing via
  `@keyframes gate-flash`
- each node: icon + label + 1-line description

See `examples/workshop-example/06-refactor-flow.html` for the chain
layout.

---

## 7 · phase ⭐ (canonical — `phase-shared.css`)

**Purpose:** one slide for one phase of a multi-phase process (discovery,
impl, test, ship, etc.).

**Body class:** `phase phase-{cyan|blue|green|amber|red|purple}` — the
suffix picks the accent.

**Layout** (all in `phase-shared.css`):

```html
<body class="phase phase-cyan">
<div class="phase-slide">
  <header class="phase-header">
    <div class="phase-num-block">
      <div class="phase-num">01</div>
      <div class="phase-of">/ 09</div>
    </div>
    <div class="phase-title-block">
      <div class="phase-eyebrow">{{emoji}} PHASE {{N}} · {{KEYWORD}}</div>
      <h1 class="phase-title">{{phase_title}}</h1>
      <div class="phase-tagline">{{one_line_summary}}</div>
    </div>
    <div class="phase-meta-block">
      <span class="badge badge-{color}">{{actor_label}}</span>
      <span class="time-pill"><strong>{{N-M}}</strong> {{unit}}</span>
    </div>
  </header>

  <div class="phase-body">
    <div class="goal-card">
      <div class="goal-label">GOAL</div>
      <div class="goal-text">{{goal_markdown_with_strong}}</div>
    </div>

    <div class="io-flow">
      <div class="io-card io-input">
        <div class="io-label">INPUT</div>
        <div class="io-icon">{{emoji}}</div>
        <div class="io-title">{{input_name}}</div>
        <div class="io-desc">{{input_desc}}</div>
      </div>
      <div class="io-arrow"><!-- inline SVG dashed arrow --></div>
      <div class="io-card io-output">
        <div class="io-label">OUTPUT</div>
        <div class="io-icon">{{emoji}}</div>
        <div class="io-title">{{output_artifact_names}}</div>
        <div class="io-desc">{{output_desc}}</div>
      </div>
    </div>

    <div class="bottom-grid">
      <div class="commands-card">
        <div class="cmd-label">COMMANDS</div>
        <div class="cmd">
          <span class="cmd-prompt">$</span>
          <span class="cmd-name">{{command}}</span>
          <div class="cmd-desc">{{what_it_does}}</div>
        </div>
        <!-- repeat .cmd -->
      </div>
      <div class="gate-card">
        <div class="gate-label">GATE</div>
        <div class="gate-name">{{gate_name}}</div>
        <ul class="gate-checklist">
          <li>{{check_1}}</li>
          <!-- 3-6 items -->
        </ul>
      </div>
    </div>

    <div class="pattern-card">
      <div class="pattern-icon">◆</div>
      <div class="pattern-body">
        <div class="pattern-title">{{pattern_heading}}</div>
        <div class="pattern-text">{{pattern_body}}</div>
      </div>
    </div>
  </div>
</div>
<script src="shared.js" defer></script>
</body>
```

**Colour variants** (body class sets `--phase-accent`):
- `phase-cyan` — discovery / process phases
- `phase-blue` — analysis / mapping phases
- `phase-green` — planning / approval phases
- `phase-amber` — execution / impl phases
- `phase-red` — review / stabilisation phases
- `phase-purple` — docs / archive / meta phases

Sequence tip: walk the spectrum across phases, not re-use one colour twice
in a row. The example deck uses cyan → cyan → cyan → green → amber → blue →
red → green → purple.

**Pattern card variants:** `.pattern-card.warn` (red), `.pattern-card.green`,
`.pattern-card.purple` — pick by pattern tone.

---

## 8 · terminal-demo ⭐ (canonical — `demo-shared.css`)

**Purpose:** live-runnable terminal demo with left context column and right
terminal. See `references/terminal-demo-dsl.md` for DSL details.

**Body class:** plain `<body>`. Layout is in `demo-shared.css`.

**DOM skeleton:**
```html
<body>
<div class="demo-slide">
  <header class="demo-header">
    <div class="demo-num-block">
      <div class="demo-num">{{NN}}</div>
      <div class="demo-of">/ {{total}} DEMO</div>
    </div>
    <div class="demo-title-block">
      <div class="eyebrow">▶ LIVE DEMO · {{phase_ref}}</div>
      <h1>{{demo_title}}</h1>
      <div class="tagline">{{one_line_summary}}</div>
    </div>
    <div class="demo-meta-block">
      <span class="badge badge-green">~{{minutes}} min</span>
    </div>
  </header>

  <div class="demo-main">
    <aside class="demo-context">
      <!-- 3-4 .ctx-card blocks: Command, What you see, Key Point, GATE -->
    </aside>
    <section class="demo-terminal-wrap">
      <div class="terminal">
        <div class="terminal-titlebar">
          <span class="dot r"></span><span class="dot y"></span><span class="dot g"></span>
          <span class="title">{{session_label}}</span>
        </div>
        <div class="terminal-body" id="body"></div>
        <div class="run-overlay" id="overlay">
          <button class="run-btn" id="run">▶ RUN DEMO</button>
          <div class="run-hint">{{command}}</div>
        </div>
        <button class="reset-btn" id="reset">↻ RESET</button>
      </div>
    </section>
  </div>
</div>

<script src="shared.js" defer></script>
<script src="demo-runner.js" defer></script>
<script>
document.addEventListener("DOMContentLoaded", function () {
  DemoRunner.init({
    prompt: "{{prompt_label}}",
    command: "{{command}}",
    commandSpeed: 45,
    steps: [ /* see terminal-demo-dsl.md */ ]
  });
});
</script>
</body>
```

**Left column `ctx-card` blocks** (pick 3-4):
- `Command` — `.ctx-card.accent` with `<code>` inside `<h3>`
- `What you see` — bulleted list with what the demo reveals
- `Key Point` — `.key-quote` styled quote
- `GATE` — phase-chip + awaiting-state description

See `examples/workshop-example/05-demo-1-tests.html` for a complete
reference.

---

## 9 · table

**Purpose:** 5-10 row lookup table with colour-coded cells.

Uses `.data-table` from `shared.css`. Common pattern:
```html
<table class="data-table">
  <thead>
    <tr>
      <th>Input pattern</th><th>Phase</th><th>Command</th><th>Agent</th>
    </tr>
  </thead>
  <tbody>
    <tr><td>...</td><td><span class="badge badge-cyan">Phase 1</span></td>...</tr>
  </tbody>
</table>
```

Colour-code cells via inline `<span class="badge badge-X">` wrappers, not
row backgrounds (rows should hover uniformly).

---

## 10 · formula

**Purpose:** hero equation or KPI reveal.
**Vibe:** big mono-font equation centred, small explanatory subtitle,
optional before/after cards below.

Pattern:
```html
<div class="formula-hero">
  <div class="formula-eyebrow">THE TRUTH</div>
  <div class="formula-line mono">{{equation}}</div>
  <div class="formula-note">{{explanation}}</div>
</div>
```

---

## 11 · tabs

**Purpose:** multi-variant content behind a tab switcher (e.g. PRD sections,
persona comparisons).

**Pattern:**
```html
<div class="tabs-container">
  <div class="tabs-nav">
    <button class="tab active" data-target="tab-1">{{label}}</button>
    <!-- ... -->
  </div>
  <div class="tab-panels">
    <div class="tab-panel active" id="tab-1">...</div>
    <!-- ... -->
  </div>
</div>
```

Inline `<script>` at the bottom wires click handlers.

---

## 12 · sizing-flow

**Purpose:** horizontal connector chain (XS → S → M → L → XL) with per-size
card below each node.

Uses inline SVG for connectors between nodes plus a row of sizing cards.

---

## 13 · wheel

**Purpose:** 12-segment circular reference (e.g. Arc42 chapters).
**Vibe:** large SVG wheel centred, with interactive hover states showing
detail panel on the side.

Uses inline SVG with 12 `<path>` segments, each with a `data-chapter`
attribute. Inline `<script>` handles hover + panel swap. This is the most
complex archetype; budget accordingly.

---

## 14 · closing

**Purpose:** final slide with takeaways + CTA + contacts.
**Vibe:** gradient title similar to cover but inverse tempo, 3-4 takeaway
cards, CTA block, meta/contact line.

Body class: `closing`. See `examples/workshop-example/08-closing.html`.

---

## 15 · qa-intro

**Purpose:** section break for Q&A, giant question mark, FAQ pills.
**Vibe:** hero question mark SVG, drifting decoration, pill chips with
anticipated questions.

Body class: `qa`.

---

## Workshop-specific · gate-review

**Purpose:** explicit GATE checkpoint slide between workshop phases. Shows
the name of the gate, the approval checklist, and an "awaiting human
confirmation" badge. Use when the flow is paused for an explicit human
decision before proceeding.

**Vibe:** amber diamond icon, bordered card, pulsing "awaiting" state.

**Body class:** `gate-review`.

**Content shape:**
- eyebrow: `"GATE · AWAITING APPROVAL"`
- title: gate name (e.g. `"GATE 3 · Plan Approval"`)
- approval checklist (3-6 items)
- status line: `"◆ Awaiting human confirmation"`

**DOM skeleton:**
```html
<body class="gate-review">
<div class="slide">
  <header class="slide-header">
    <div class="eyebrow">◆ GATE · AWAITING APPROVAL</div>
    <h1 class="gradient-title">{{gate_name}}</h1>
  </header>
  <div class="gate-card gate-review-card">
    <div class="gate-diamond">◆</div>
    <div class="gate-content">
      <div class="gate-label">APPROVAL CHECKLIST</div>
      <ul class="gate-checklist">
        <li>{{check_1}}</li>
        <li>{{check_2}}</li>
        <li>{{check_3}}</li>
      </ul>
      <div class="gate-status">
        <span class="status-dot"></span>
        Awaiting human confirmation
      </div>
    </div>
  </div>
</div>
<script src="shared.js" defer></script>
</body>
```

Reuses `.gate-card` + `.gate-checklist` from `phase-shared.css`, plus
`.gate-diamond` + amber status indicator inline.

---

## Type-specific additions (quick reference)

| Deck type | Adds these archetypes | Reference |
|---|---|---|
| workshop | gate-review | this file ↑ |
| lecture | learning-objectives, chapter-break, recap, references-list | `archetypes-lecture.md` |
| talk | hook, thesis, memorable-moment, cta-simple | `archetypes-talk.md` |

When scoping captures `deck_type`, the skill loads the corresponding
add-on reference file in addition to this core file.

## Generating from scratch

When creating a new archetype on request (e.g. "make a roadmap archetype"),
update this file (if it's universal) or the type-specific add-on file (if
it's workshop/lecture/talk only), add a canonical example to the matching
`examples/` subdirectory, and bump the decision table above.
