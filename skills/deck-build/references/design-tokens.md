# Design Tokens — Frozen Palette

The entire visual language of a deck lives in `:root` inside
`shared.css`. **Never hardcode colour values** — reference them via `var(...)`.
Adding a new token requires a deliberate decision, not casual expansion.

## Why tokens are frozen

A deck's look emerges from a narrow palette plus discipline. If every slide
picks its own shade of the primary accent, the deck loses its coherence. And
because every colour on every slide resolves to a token, swapping the values
in `:root` re-themes the whole deck at once — but only if no slide bypasses
the tokens. The `audit-tokens.sh` gate fails a deck that introduces hex or
`rgb()/rgba()/hsl()/hsla()` literals in slide HTML.

## The `:root` block (verbatim)

```css
:root {
  /* Core surfaces */
  --bg-deep: #050912;         /* Page background · near-black navy */
  --bg-panel: #0d1424;        /* Cards, tiles */
  --bg-elev: #162040;         /* Elevated secondary surfaces */
  --bg-gradient-mid: #0a1628; /* Middle stop of the animated body gradient */
  --bg-grid: color-mix(in srgb, var(--accent-primary) 3%, transparent);  /* Fixed grid overlay */
  --surface-tint: #fff;       /* Hairline borders, hover washes, inset fills */
  --shadow-color: #000;       /* Drop shadows, dimmed backdrops */

  /* Terminal surfaces */
  --term-bg: #080d18;         /* Darker than --bg-panel for contrast inside the card */
  --term-bar-top: #10182a;    /* Titlebar gradient stops */
  --term-bar-bottom: #0a1020;
  --term-text: #dfe6f0;       /* Slightly brighter than --text-primary for code */

  /* Accents — semantic colour coding, named by role */
  --accent-primary:   #00e5ff; /* Concept / process / primary */
  --accent-human:     #2979ff; /* Human / decisions */
  --accent-success:   #00e676; /* Positive / complete / OK */
  --accent-warn:      #ffab40; /* GATE / checkpoint / warn */
  --accent-danger:    #ff5252; /* Feedback / error / negation */
  --accent-ai:        #d500f9; /* AI / agent pool / emphasis */
  --accent-highlight: #ffd740; /* Bonus / rare highlight */

  /* Text */
  --text-primary:   #e0e6f0;
  --text-strong:    #fff;      /* Hero titles that need extra contrast */
  --text-secondary: color-mix(in srgb, var(--text-primary) 72%, transparent);
  --text-muted:     color-mix(in srgb, var(--text-primary) 45%, transparent);
  --text-faint:     color-mix(in srgb, var(--text-primary) 25%, transparent);

  /* Typography */
  --font-sans: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
  --font-mono: "SF Mono", "Fira Code", "JetBrains Mono", Menlo, monospace;
  --base-font: 16px;

  /* Layout */
  --min-width: 1280px;    /* Desktop-only — do not support smaller */
  --max-content: 1400px;  /* Inner frame */
  --slide-padding: 32px;

  /* Glows (for box-shadow on accented cards) */
  --glow-primary: 0 0 22px color-mix(in srgb, var(--accent-primary) 25%, transparent);
  --glow-warn:    0 0 22px color-mix(in srgb, var(--accent-warn) 35%, transparent);
  --glow-success: 0 0 22px color-mix(in srgb, var(--accent-success) 28%, transparent);
  --glow-ai:      0 0 26px color-mix(in srgb, var(--accent-ai) 30%, transparent);

  /* Radii */
  --radius-sm: 6px;
  --radius-md: 10px;
  --radius-lg: 16px;
}
```

`shared.css` also defines the old hue-named tokens (`--accent-cyan`,
`--accent-blue`, `--accent-green`, `--accent-amber`, `--accent-red`,
`--accent-purple`, `--accent-gold`, `--glow-cyan`, `--glow-amber`,
`--glow-green`, `--glow-purple`) as aliases of the role names, so decks built
before the rename keep rendering. **Never use them in new slides** — they are
removed in the next minor release.

## Semantic legend — which colour for what

| Accent | Use for | Don't use for |
|---|---|---|
| `--accent-primary`   | Primary action, concepts, commands, tech-forward cards | Negative affordance |
| `--accent-human`     | Human-in-the-loop moments, decisions, "you" states | Background fill |
| `--accent-success`   | Success, completed, passing gate, OK output | Titles |
| `--accent-warn`      | GATE labels, warnings, awaiting-human states | Primary titles (compete with `--accent-primary`) |
| `--accent-danger`    | Errors, anti-patterns, warnings, "wasted / broken" | Positive content |
| `--accent-ai`        | AI agent pool, orchestration, cross-cutting concerns | Timing / metadata |
| `--accent-highlight` | Bonus slides, rare highlights (≤1 per deck) | Body text |

Apply these semantically, not decoratively. A success colour on an error badge
breaks reader expectations even if it "looks nice."

## Text colour hierarchy

- `--text-strong` — hero titles that need maximum contrast (cover, phase, closing)
- `--text-primary` — body copy, card body, headings (except gradient titles)
- `--text-secondary` — secondary descriptions, card taglines
- `--text-muted` — eyebrow labels, timestamps, captions
- `--text-faint` — footer meta, file numbers, decorative data

## Translucent colours — `color-mix`, never `rgba()`

Tints, borders, washes and glows are a token at partial opacity:

```css
border: 1px solid color-mix(in srgb, var(--accent-primary) 22%, transparent);
background: color-mix(in srgb, var(--surface-tint) 4%, transparent);
box-shadow: 0 10px 30px color-mix(in srgb, var(--shadow-color) 40%, transparent);
```

`rgba(0, 229, 255, 0.22)` renders the same today but is invisible to a theme
swap, and Gate 2 fails it.

**Gradients with a `color-mix` stop must say `in srgb`.** `color-mix()`
returns a non-legacy colour, and a gradient with any non-legacy stop
interpolates in oklab by default — its midpoints shift visibly. Pin it:

```css
background: linear-gradient(135deg in srgb,
  color-mix(in srgb, var(--accent-primary) 15%, transparent),
  color-mix(in srgb, var(--accent-ai) 18%, transparent));
/* no direction argument → linear-gradient(in srgb, <stop>, <stop>) */
```

Gradients built only from plain `var(--accent-*)` stops need nothing extra.

## Inline SVG

SVG presentation attributes (`fill="…"`, `stroke="…"`) cannot take `var()`.
Put the colour in a `style` attribute or a class instead — CSS properties in
inline SVG resolve custom properties like any other element:

```html
<line x1="6" y1="20" x2="82" y2="20" style="stroke: var(--accent-primary)" stroke-width="2"></line>
<path d="M78 13 L90 20 L78 27 Z" style="fill: var(--accent-primary)"></path>
```

## Typography rules

- `--font-sans` is the default; everything inherits it from `body`.
- `--font-mono` is reserved for: eyebrows, commands, timer pills, labels,
  counter numbers, terminal content, badge labels. It signals "machine /
  identifier", not "content".
- Never introduce a third family.
- Never use `font-size` values outside the established scale:
  `0.72rem`, `0.75rem`, `0.78rem`, `0.8rem`, `0.82rem`, `0.85rem`, `0.88rem`,
  `0.9rem`, `0.92rem`, `0.95rem`, `1rem`, `1.05rem`, `1.08rem`, `1.1rem`,
  `1.25rem`, `1.35rem`, `1.55rem`, `2.2rem`, `2.4rem`, `2.6rem`, `2.8rem`,
  `3rem`, `3.2rem`, `6rem`. (Presenter mode multiplies some of these by hand.)

## Adding new tokens — rules

1. Open an explicit discussion with the user (`AskUserQuestion`).
2. Never add a new accent without first asking: "Can one of the existing
   accents carry the new meaning?"
3. If the answer is still "no new accent", the new variable lands in
   `:root` inside `shared.css`, not inline on a slide.
4. A softer or darker variant of an existing colour is not a new token —
   write it as `color-mix(in srgb, var(--token) N%, transparent)` (lighter
   on the dark background) or `color-mix(in srgb, var(--token) N%, var(--bg-deep))`.
5. Update this reference file in the same change so future generations stay
   consistent.

## Red flags (caught by `audit-tokens.sh`)

- Any `#[0-9a-f]{3,6}` hex in slide HTML — including inline SVG — except
  the terminal traffic-light dots below.
- Any `rgb()`, `rgba()`, `hsl()` or `hsla()` with numeric arguments in
  slide HTML.
- `font-family` outside `var(--font-sans|mono)` (exceptions below).
- `!important` in slide `<style>` blocks.

## Intentional literal exceptions

- `#ff5f56`, `#ffbd2e`, `#27c93f` — macOS traffic-light dots on the terminal
  titlebar (`.dot.r/.y/.g`). A fixed convention — users pattern-match these
  as "a terminal" — so they are not tokens and do not change with the
  palette. They are the only hex literals Gate 2 allows in slide HTML.

### Font-family exceptions

Slide-level `<style>` blocks may use these outside `var(--font-sans|mono)`:

- `Georgia, serif` — for giant decorative quote glyphs (`&ldquo;` on quote
  slides, `◆` on qa-intro). Pure decoration, not body text.
- `monospace`, `Menlo`, `"SF Mono"` inside SVG `<text font-family=...>` —
  presentation attributes cannot take `var()`. Use these literal stacks in
  SVG `font-family=` attributes only, or set
  `style="font-family: var(--font-mono)"` instead.

Anywhere else: only `var(--font-sans)` and `var(--font-mono)` are allowed.
