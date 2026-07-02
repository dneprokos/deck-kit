# Navigation Contract

Every deck is a set of static HTML files glued by `shared.js`. No bundler,
no router, no SPA. This file describes the invariants that must hold for
keyboard nav, presenter mode, and the index page to work.

## File naming

- Slide files: `NN-slug.html` where `NN` is zero-padded (`01`, `02`, …, `99`).
- The index: `index.html` at the deck root.
- Slug is a short kebab-case identifier (`cover`, `phase-1`, `demo-1-brainstorm`).
- The numeric prefix **must match** the slide's position in the `SLIDES`
  array (1-indexed, zero-padded). Renumbering requires updating both the
  filename and the array.

## The SLIDES array

Lives in `shared.js`, one entry per slide, in **visit order**:

```js
var SLIDES = [
  { file: "01-cover.html",     title: "Cover" },
  { file: "02-intro.html",     title: "Intro" },
  // ...
];
window.WORKSHOP_SLIDES = SLIDES;
```

Rules:
1. `file` is the bare filename — no path prefix, no query string.
2. `title` is a human-readable label (goes into tile titles and nav tooltips).
3. Adding a slide means: (a) create file with correct `NN-` prefix,
   (b) append to `SLIDES`, (c) update `SECTIONS` in `index.html` if the
   new slide belongs in a named part.
4. Length of `SLIDES` must equal count of `NN-*.html` files in the deck.
   `audit-static.sh` enforces this.

## Script tag placement — the defer gotcha

```html
<!-- In slide files -->
<script src="shared.js" defer></script>

<!-- In index.html -->
<script src="shared.js"></script>   <!-- NO defer -->
<script>
(function () {
  /* inline code that reads window.WORKSHOP_SLIDES to build tiles */
})();
</script>
```

**Why:** slide files have no code that depends on `WORKSHOP_SLIDES` at
parse time, so deferring `shared.js` is fine and even preferred (HTML
renders first). `index.html` contains inline script that reads
`WORKSHOP_SLIDES` immediately. `defer` reorders scripts to run *after*
HTML parsing — so the deferred `shared.js` would execute **after** the
inline script, and `WORKSHOP_SLIDES` would be `undefined` when the inline
script runs.

This mistake silently breaks the index page (empty grid, no error in
console unless you look). `audit-static.sh` catches it by grepping for
`defer` in `index.html`'s shared.js tag.

## Keyboard bindings

Implemented by `bindKeyboard()` in `shared.js`:

| Key | Action |
|---|---|
| `→`, `Space`, `PageDown` | Next slide (uses `SLIDES[idx+1]`) |
| `←`, `PageUp` | Previous slide |
| `Esc` | Jump to `index.html` |
| `P` or `p` | Toggle `?presenter` URL param |

Ignored when the event target is `INPUT`, `TEXTAREA`, or `contenteditable` —
so search box on the index doesn't hijack space.

## Presenter mode

- Activated via `?presenter` query string (no value needed, just the param).
- Adds `body.presenter` class globally.
- Slides bump `--base-font` by 15% (handled in `shared.css`) and specific
  text sizes in `phase-shared.css` / `demo-shared.css`.
- Progress bar + "3 / 35" label appear fixed at bottom (slide-level only,
  not the index).
- Links within the deck preserve `?presenter` via `withSearch()` helper in
  `shared.js`. Don't remove this — otherwise clicking a nav arrow drops
  presenter mode.

## Disabling injected navigation

The index page should not show prev/next arrows. Set `data-nav-disabled`
on the body:

```html
<body class="index" data-nav-disabled>
```

`renderNavigation()` in `shared.js` checks this attribute and bails out.

## Return-to-index affordance

Every slide gets an auto-injected `.nav-index` button (top-right) that links
to `index.html`. User can also hit `Esc`. Both are wired up in `shared.js`.

## Browser target

- Chromium 120+, Safari 17+, Firefox 120+.
- No IE / legacy Edge support.
- `min-width: 1280px` is locked. Do not try to support narrower viewports —
  the decks are for desktop presentation, not mobile. Explicitly communicate
  this when someone asks "will this work on my iPad?"
- The Playwright gate runs at 1920×1080 as the canonical viewport.
