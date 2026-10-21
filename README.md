# deck-kit

Plan and build presenter-grade HTML slide decks with Claude Code — as a
dialog, not a dump.

Two skills split the work the way a speaker actually prepares:

- **`deck-plan`** — turns any source (thesis, outline, article, script)
  into a reviewed slide plan: one `archetype · title · key message ·
  source span` line per slide, saved to `.planning/deck-spec.md`.
- **`deck-build`** — turns that plan into an HTML deck slide-by-slide
  through a Socratic dialog (never batch-generated), on a frozen
  design-token system, and refuses to call the deck done until it passes
  **4 independent validation gates**.

The output is plain HTML — no framework, no build step. `python3 -m
http.server` and present: keyboard navigation, presenter mode, a grid
index of every slide.

## Install

```
/plugin marketplace add genkovich/deck-kit
/plugin install deck-kit@deck-kit
```

## Prerequisites

- **Python 3** — serves the deck locally (`http.server`) and runs the
  HTTP smoke gate.
- **Node 18+** — runs the visual validation gate.
- **Playwright + Chromium** — Gate 4 renders every slide at 1920×1080 in
  headless Chromium, screenshots it, and fails on overflow or JS errors.
  Install it **in the project where you build decks** (the plugin finds
  it via your project's `node_modules`):

  ```bash
  npm i -D playwright
  npx playwright install chromium
  ```

  Without it, Gates 1-3 still run; Gate 4 exits with install
  instructions instead of silently passing.

## Quickstart

```
/deck-kit:plan my-talk-outline.md
```

Answer the scoping questions (deck type, identity, sections, archetypes,
language, theme, …), review the drafted slide plan as one block, approve. The
plan lands in `deck/.planning/deck-spec.md`.

```
/deck-kit:build deck
```

The build walks the plan slide-by-slide — archetype, title, and source
span come pre-filled from the spec; you confirm or adjust each slide as
it is generated. After the last slide, the 4 gates run. All green:

```
cd deck && python3 -m http.server 8765
# open http://localhost:8765 — arrows/Space to navigate, Esc for the grid
```

## Themes

All colours, glows and font families come from the deck's `theme.css`,
copied from `assets/themes/<name>.css` at scaffold time and loaded by
`shared.css`. Slides reference tokens only (`var(--accent-primary)`), so
replacing `theme.css` re-themes the whole deck. Pick a theme during
scoping, or ask for a custom palette and the build fills in the rest of
the tokens with you.

| Theme | Look |
|---|---|
| `cyberpunk` (default) | Near-black navy, neon accents, soft glows |

Add a theme by copying `assets/themes/cyberpunk.css` and changing the
values. It must keep every token — `npm run validate` and Gate 2 check.

Already have a deck? Validate it without touching content:

```
/deck-kit:audit deck
```

## The three deck types

| Type | Length | Backbone archetypes | Presenter scale |
|---|---|---|---|
| **workshop** | 60-120 min | phase, terminal-demo, gate-review | 1.15× |
| **lecture** | 30-120 min | learning-objectives, chapter-break, recap, references-list | 1.25× |
| **talk** | 15-45 min | hook, thesis, memorable-moment, cta-simple | 1.35× |

## Archetypes

24 slide blueprints — each a DOM skeleton + CSS contract + content
shape, all on the same cyberpunk design-token system:

**Core 15:** cover · quote · comparison · concept · diagram · flow ·
phase · terminal-demo · table · formula · tabs · sizing-flow · wheel ·
closing · qa-intro

**Workshop:** gate-review — **Lecture:** learning-objectives ·
chapter-break · recap · references-list — **Talk:** hook · thesis ·
memorable-moment · cta-simple

See them assembled in `examples/`:

- [`examples/workshop-example/`](examples/workshop-example/) — 8-slide
  workshop built by the skill itself (cover, quote, concept, phase,
  terminal-demo, flow, gate-review, closing).
- [`examples/lecture-template/`](examples/lecture-template/) — 5-slide
  lecture skeleton.
- [`examples/talk-template/`](examples/talk-template/) — 5-slide talk
  skeleton.

## The 4 validation gates

A deck ships only when all four are green, in order:

1. **Static** — closing tags, shared.css/js wiring, `SLIDES` array in
   sync with files on disk, no `defer` on the index script.
2. **Tokens** — no hardcoded hex (terminal traffic-light dots excepted)
   and no `rgb()/rgba()/hsl()` in slides, no raw `font-family`, no
   `!important`. Every colour resolves to a `:root` token, so the palette
   can be swapped in one place.
3. **HTTP smoke** — boots a local server, curls index + assets + sampled
   slides, expects 200s. Catches typos and missing files.
4. **Visual** — Playwright renders every slide at 1920×1080, screenshots
   to `.audit/screenshots/`, fails on horizontal overflow, runaway
   height, or JS errors.

The gates are deliberately independent — each catches what the others
cannot. `tests/run-gate-selftest.sh` proves it: three broken fixture
decks each fail exactly their own gate while earlier gates pass.

## Commands

| Command | What it does |
|---|---|
| `/deck-kit:plan [source]` | Scoping dialog → reviewed slide plan → `.planning/deck-spec.md` |
| `/deck-kit:build [dir]` | Spec → scaffold → per-slide Socratic generation → 4 gates |
| `/deck-kit:audit <dir>` | 4 gates against an existing deck, no content changes |

`deck-build` picks its mode from context: **spec mode** when a
`deck-spec.md` exists, **audit mode** when you only asked to validate,
**standalone** otherwise (it will suggest planning first, or run a
4-question mini-scoping).

## Content markers

Write your source with inline stage directions and the planner clusters
them into slides:

- Workshop: `[SHOW]` `[SAY]` `[RUN]` `[EXPECT]` `[ASK]` `[FALLBACK]` `[BEAT]`
- Lecture: `[EXPLAIN]` `[EXAMPLE]` `[CHECK]` `[OBJECTIVE]` `[RECAP]` `[JUMP]`
- Talk: `[HOOK]` `[THESIS]` `[STORY]` `[MEMORABLE]` `[CTA]`

Your own convention (any language) works too — the skill asks you to map
your tags to the standard set once during scoping and remembers the
mapping in the spec. Details:
[`skills/_shared/content-markers.md`](skills/_shared/content-markers.md).

## Updating

```
/plugin marketplace update deck-kit
```

## Development

```bash
git clone https://github.com/genkovich/deck-kit && cd deck-kit
npm install && npx playwright install chromium

npm run validate   # plugin structure, manifests, forbidden tokens, link + archetype consistency
npm run selftest   # gate self-test: positive example 4/4 + per-gate broken fixtures
```

Both run in CI on every push (`.github/workflows/validate.yml`); the
gate self-test runs on ubuntu **and** macos (the HTTP gate exercises
`lsof`/BSD differences).

Skill evals live in `skills/*/evals/evals.json` (skill-creator format):
plan-from-source, plan-from-thesis, build-from-spec, audit-broken-deck.

## License

MIT
