# Archetype Catalog — one line each, for planning

The full catalog of slide archetypes, one line per archetype — enough to
draft a slide plan without loading the DOM skeletons. The build-side
blueprints (DOM, CSS, content shape) live in the deck-build skill:
`archetypes.md` (core), `archetypes-lecture.md`, `archetypes-talk.md`.

Every archetype name used in a `deck-spec.md` slide-plan line MUST come
from this list, spelled exactly as below.

## Core 15 (all deck types)

| Archetype | One-liner |
|---|---|
| `cover` | Opening slide: gradient title, speaker · date · venue pills, orbital decoration. |
| `quote` | A single killer quote or stat, giant type, attribution line. |
| `comparison` | Two mindsets / approaches side by side (A vs B columns). |
| `concept` | A concept introduced via 3-4 cards (definition, aspects, example). |
| `diagram` | A pipeline or system diagram as inline SVG. |
| `flow` | A vertical chain of steps / gates / artifacts (scroll-tolerant). |
| `phase` | One phase of a multi-phase process: goal card, I/O flow, GATE checklist. |
| `terminal-demo` | Live terminal demo driven by DemoRunner steps (workshop backbone). |
| `table` | 5-10 row lookup table with badge-coded cells (scroll-tolerant). |
| `formula` | Hero equation or KPI reveal, big mono type, before/after cards. |
| `tabs` | Multi-variant content behind a tab switcher (scroll-tolerant). |
| `sizing-flow` | Horizontal connector chain (XS → S → M → L → XL) with per-node cards. |
| `wheel` | 12-segment circular SVG reference with hover detail panel (most complex — budget accordingly). |
| `closing` | Final slide: takeaways, CTA block, contacts. |
| `qa-intro` | Q&A section break: giant question mark, FAQ pills. |

## Workshop add-on (1)

| Archetype | One-liner |
|---|---|
| `gate-review` | Explicit GATE checkpoint between phases: approval checklist, pulsing "awaiting human confirmation" badge. |

## Lecture add-ons (4)

| Archetype | One-liner |
|---|---|
| `learning-objectives` | Up-front "by the end you will…" bullets with outcome verbs. |
| `chapter-break` | Full-screen chapter divider: number, title, progress dots. |
| `recap` | End-of-chapter summary: 3-4 numbered recap cards. |
| `references-list` | Sources table (#, author · year · title · link), 6-20 rows. |

## Talk add-ons (4)

| Archetype | One-liner |
|---|---|
| `hook` | Attention-grabbing opener: one rhetorical question or claim, huge type. |
| `thesis` | The single central statement of the talk, formula-like layout. |
| `memorable-moment` | The quotable line the audience takes home, poster-styled. |
| `cta-simple` | Minimal call-to-action: one ask, one link/QR, contacts. |

## Planning guidance

- A deck opens with `cover` and closes with `closing` (workshop/lecture)
  or `cta-simple` (talk) — deviations are deliberate choices.
- Talks: keep the relative order hook → thesis → … → memorable-moment →
  cta-simple. The memorable moment lands in the back half.
- Lectures: `learning-objectives` is slide 02; each chapter gets a
  `chapter-break`; a `recap` before the `references-list`.
- Workshops: alternate exposition (concept/phase) with interaction
  (terminal-demo, gate-review) every 3-5 slides.
- Scroll-tolerant archetypes (`flow`, `table`, `tabs`) may exceed 1080px
  height; everything else must fit the viewport — plan content
  accordingly (3-5 bullets, not 10).
