# Animations — Keyframe Library

All animations are defined either in `shared.css` (common library) or inline
in slide-specific `<style>` blocks (decorative one-offs on cover / quote /
qa-intro / closing). This file enumerates the common ones so new slides
reuse the right vocabulary.

## Common keyframes (in `shared.css`)

| Name | Duration | Easing | Purpose | Applied to |
|---|---|---|---|---|
| `bg-shift` | 28s | `ease` (infinite) | Subtle background gradient drift | `body` (global) |
| `breathe` | 2.6s | `ease-in-out` (infinite) | Scale pulse for breathing elements | `.breathe`, `.phase-num-block`, `.demo-num-block`, `.pattern-icon`, `.kicker .dot`, `.eyebrow .dot` |
| `flow-dash` | 1s | `linear` (infinite) | Animated dashed stroke on SVG arrows | `.flow-arrow` |
| `gate-flash` | 4s | `ease-in-out` (infinite) | GATE diamond colour flip amber↔green | `.gate-diamond` SVG fill |
| `fade-in-up` | 0.6s | `ease both` | Entrance from below with fade | `.stagger-item` (with delays 0.05–0.85s) |
| `fade-in` | default | `ease both` | Pure opacity fade | decorative entrances |
| `shimmer` | 4s | `ease-in-out` (infinite) | Panel border gradient opacity flicker | `.panel::before` |
| `typewriter-blink` | 1s | `step-end` (infinite) | Cursor block blink | `.terminal-cursor` |

## Slide-local keyframes (frequent)

These are defined inside the slide's `<style>` block. When creating a new
slide of a given archetype, copy the declarations from the reference example.

| Name | Where defined | Purpose |
|---|---|---|
| `title-shimmer` | cover, closing | Gradient title horizontal drift (6s) |
| `orbit-a`, `orbit-b`, `orbit-c` | cover | Orbiting satellites at 24/38/52s with varying radius + reverse |
| `fall` | quote, qa-intro, closing | Vertical particle fall (14s linear) |
| `drift` | qa-intro, closing | Lazy decorative float (18-22s ease-in-out) |
| `pulse-red` | comparison | Red glow pulse on a highlighted risk row (2.4s) |

## Stagger animation pattern

When several items should enter sequentially, use `.stagger-item` with nth
delays. Built-in support in `shared.css` for children 1-9:

```html
<ul>
  <li class="stagger-item">First (0.05s delay)</li>
  <li class="stagger-item">Second (0.15s delay)</li>
  <li class="stagger-item">Third (0.25s delay)</li>
  <!-- up to nth-child(9) → 0.85s -->
</ul>
```

For more than 9 siblings, add per-index `animation-delay` rules inline.

## Entrance rhythm

- Cover / closing: 0.2s per element — dramatic reveal
- Phase slide: no entrance animation — they render instantly (presenter is
  already mid-talk when they arrive)
- Terminal demo: terminal body has no entrance; terminal itself can pulse
  via `var(--glow-cyan)` shadow
- Quote: lines drop in 0.3s apart for emphasis

Pick the rhythm that matches the narrative energy. Fast decks feel frantic;
slow decks feel deliberate.

## Reduced motion — required

`shared.css` includes this block:

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.001ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.001ms !important;
  }
  body { animation: none; }
  .run-btn { transition: none; }
}
```

**Never remove this.** Accessibility requires respecting `prefers-reduced-motion`.
If you add a new infinite animation, verify the block still disables it
(the wildcard rule catches anything with `animation-name`, so new animations
work by default — do not name an animation with inline `style=` bypass).

## Red flags

- An animation that runs on more than 30 elements simultaneously (e.g.
  particle field > 50 particles) — browser can drop frames
- `animation-iteration-count: infinite` on anything the viewer has to read
  (text content shifting under their eyes = cognitive load)
- Duration < 200ms — feels like a glitch, not an animation
- `transform: translate3d(0,0,0)` scatter-bombed everywhere as a "GPU hack"
  — only needed for genuinely janky compositing; cluttering markup otherwise
