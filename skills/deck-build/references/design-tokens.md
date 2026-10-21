# Design Tokens — Frozen Palette

The entire visual language of a deck lives in tokens. Colours, glows and
font families are in the deck's `theme.css` (a copy of one of
`assets/themes/*.css`); layout, radii and base font size are in `:root`
inside `shared.css`, which `@import`s `theme.css`. **Never hardcode colour
values** — reference them via `var(...)`. Adding a new token requires a
deliberate decision, not casual expansion.

## Why tokens are frozen

A deck's look emerges from a narrow palette plus discipline. If every slide
picks its own shade of the primary accent, the deck loses its coherence. And
because every colour on every slide resolves to a token, swapping
`theme.css` re-themes the whole deck at once — but only if no slide bypasses
the tokens. The `audit-tokens.sh` gate fails a deck that introduces hex or
`rgb()/rgba()/hsl()/hsla()` literals in slide HTML, redefines a theme token
in a slide, or ships a `theme.css` missing a token.

## Themes

- Shipped themes live in `assets/themes/<name>.css`; each is one `:root`
  block and nothing else. `new-skeleton.sh --theme=<name>` copies the
  chosen one to `<deck>/theme.css`.
- `cyberpunk.css` is the **reference theme**: the set of tokens it defines
  is the required set. Every other theme, and every deck's `theme.css`,
  must define all of them (Gate 2 and `validate_plugin.py` check).
- A theme may change any value, including the font families and the glows
  (a flat theme sets `--glow-*: none`). It never renames or drops a token.
- To add a shipped theme: copy `cyberpunk.css`, change the values and the
  header comment (the first line after `Theme:` is what deck-plan's Q9
  shows the user), then run `npm run validate`.
- To customise one deck: edit its `theme.css` directly. Re-running
  `new-skeleton.sh` without `--theme` keeps it.

## The reference theme (`assets/themes/cyberpunk.css`, verbatim tokens)

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

  /* Glows (box-shadow on accented cards; a flat theme sets these to none) */
  --glow-primary: 0 0 22px color-mix(in srgb, var(--accent-primary) 25%, transparent);
  --glow-warn:    0 0 22px color-mix(in srgb, var(--accent-warn) 35%, transparent);
  --glow-success: 0 0 22px color-mix(in srgb, var(--accent-success) 28%, transparent);
  --glow-ai:      0 0 26px color-mix(in srgb, var(--accent-ai) 30%, transparent);
}
```

## Theme-independent tokens (`shared.css` `:root`)

```css
:root {
  --base-font: 16px;
  --min-width: 1280px;    /* Desktop-only — do not support smaller */
  --max-content: 1400px;  /* Inner frame */
  --slide-padding: 32px;
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
3. If the answer is still "no new accent", the new colour token lands in
   the deck's `theme.css`, not inline on a slide. A token meant for every
   deck goes into **every** file in `assets/themes/` in the same change —
   the reference theme defines the required set, so adding it only to
   `cyberpunk.css` fails every other theme.
4. A softer or darker variant of an existing colour is not a new token —
   write it as `color-mix(in srgb, var(--token) N%, transparent)` (a
   translucent wash) or `color-mix(in srgb, var(--token) N%, var(--bg-deep))`
   (an opaque blend toward the background).
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
