# Design Tokens — Frozen Palette

The entire visual language of a deck lives in `:root` inside
`shared.css`. **Never hardcode these values** — reference them via `var(...)`.
Adding a new token requires a deliberate decision, not casual expansion.

## Why tokens are frozen

Cyberpunk workshop look emerges from a narrow palette plus discipline. If
every slide picks its own shade of cyan, you lose the shimmer coherence. The
`audit-tokens.sh` gate will fail a deck that introduces unregistered hex
values outside `:root`.

## The `:root` block (verbatim)

```css
:root {
  /* Core surfaces */
  --bg-deep: #050912;       /* Page background · near-black navy */
  --bg-panel: #0d1424;      /* Cards, terminal body, tiles */
  --bg-elev: #162040;       /* Elevated secondary surfaces */
  --bg-grid: rgba(0, 229, 255, 0.03);  /* Fixed grid overlay */

  /* Accents — semantic colour coding */
  --accent-cyan:   #00e5ff; /* Concept / process / primary */
  --accent-blue:   #2979ff; /* Human / decisions */
  --accent-green:  #00e676; /* Positive / complete / OK */
  --accent-amber:  #ffab40; /* GATE / checkpoint / warn */
  --accent-red:    #ff5252; /* Feedback / error / negation */
  --accent-purple: #d500f9; /* AI / agent pool / emphasis */
  --accent-gold:   #ffd740; /* Bonus / rare highlight */

  /* Text */
  --text-primary:   #e0e6f0;
  --text-secondary: rgba(224, 230, 240, 0.72);
  --text-muted:     rgba(224, 230, 240, 0.45);
  --text-faint:     rgba(224, 230, 240, 0.25);

  /* Typography */
  --font-sans: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
  --font-mono: "SF Mono", "Fira Code", "JetBrains Mono", Menlo, monospace;
  --base-font: 16px;

  /* Layout */
  --min-width: 1280px;    /* Desktop-only — do not support smaller */
  --max-content: 1400px;  /* Inner frame */
  --slide-padding: 32px;

  /* Glows (for box-shadow on accented cards) */
  --glow-cyan:   0 0 22px rgba(0, 229, 255, 0.25);
  --glow-amber:  0 0 22px rgba(255, 171, 64, 0.35);
  --glow-green:  0 0 22px rgba(0, 230, 118, 0.28);
  --glow-purple: 0 0 26px rgba(213, 0, 249, 0.30);

  /* Radii */
  --radius-sm: 6px;
  --radius-md: 10px;
  --radius-lg: 16px;
}
```

## Semantic legend — which colour for what

| Accent | Use for | Don't use for |
|---|---|---|
| `--accent-cyan`   | Primary action, concepts, commands, tech-forward cards | Negative affordance |
| `--accent-blue`   | Human-in-the-loop moments, decisions, "you" states | Background fill |
| `--accent-green`  | Success, completed, passing gate, OK output | Titles |
| `--accent-amber`  | GATE labels, warnings, awaiting-human states | Primary titles (compete with cyan) |
| `--accent-red`    | Errors, anti-patterns, warnings, "wasted / broken" | Positive content |
| `--accent-purple` | AI agent pool, orchestration, cross-cutting concerns | Timing / metadata |
| `--accent-gold`   | Bonus slides, rare highlights (≤1 per deck) | Body text |

Apply these semantically, not decoratively. A green colour on an error badge
breaks reader expectations even if it "looks nice."

## Text colour hierarchy

- `--text-primary` — body copy, card body, headings (except gradient titles)
- `--text-secondary` — secondary descriptions, card taglines
- `--text-muted` — eyebrow labels, timestamps, captions
- `--text-faint` — footer meta, file numbers, decorative data

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
4. Update this reference file in the same change so future generations stay
   consistent.

## Red flags (caught by `audit-tokens.sh`)

- Any `#[0-9a-f]{3,6}` in slide HTML outside `<svg>` `fill=` attributes that
  match known palette colours.
- `font-family` outside `:root` (anywhere except terminal `.dot.r/.y/.g` that
  use traffic-light literals documented here).
- Inline `color: #XXX` or `background: #XXX` in slide `<style>` blocks —
  always reference `var(--...)`.

## Intentional literal exceptions

These hex literals appear intentionally and are allow-listed by the auditor:

- `#080d18` — terminal background surface (darker than `--bg-panel` for
  contrast inside the terminal card).
- `#10182a`, `#0a1020` — terminal titlebar gradient stops.
- `#ff5f56`, `#ffbd2e`, `#27c93f` — macOS traffic-light dots on terminal
  titlebar (convention — users pattern-match these as "a terminal").
- `#fff` — used in a handful of hero titles that need extra contrast against
  the gradient.
- `#dfe6f0` — terminal text (slightly brighter than `--text-primary` for
  code readability).
- `#00e5ff`, `#2979ff`, `#d500f9` inline in `<svg>` `fill=` / `stroke=`
  attributes — allowed because SVG doesn't inherit CSS variables cleanly
  across all browsers. The auditor recognises these as palette-member hexes.

### Muted variants (allowed)

A small set of muted palette variants ship as second-stops in gradients or
as SVG-text fills where `--text-muted` (rgba) doesn't work cleanly:

- `#cfd4dc` — softer neutral gray (alternative to `--text-secondary`).
- `#8899bb` — blue-tinted muted gray for SVG annotation text.
- `#5a95ff` — softer blue variant (gradient second-stop for blue systems).
- `#c75bff` — softer purple variant (gradient second-stop for purple systems).
- `#34e684` — softer green variant (gradient second-stop for green systems).

These are locked — don't invent new muted variants without a clear reason.
If you need one, add it here + to the auditor allow-list in one change.

### Font-family exceptions

Slide-level `<style>` blocks may use these outside `var(--font-sans|mono)`:

- `Georgia, serif` — for giant decorative quote glyphs (`&ldquo;` on quote
  slides, `◆` on qa-intro). Pure decoration, not body text.
- `monospace`, `Menlo`, `"SF Mono"` inside SVG `<text font-family=...>` —
  SVG text doesn't inherit CSS vars reliably. Use these literal stacks in
  SVG only.

Anywhere else: only `var(--font-sans)` and `var(--font-mono)` are allowed.
