# Lecture Archetypes — Slide Blueprints (type-specific add-ons)

These 4 archetypes are specific to the **lecture** deck type. Use them
in addition to the core 15 archetypes defined in `archetypes.md`.

Lectures differ from workshops in structure: they open with explicit
learning objectives, break into chapters with named transitions, summarise
periodically via recap cards, and close with a references list.

All archetypes reuse `shared.css` tokens and the `phase-shared.css`
pattern for cards. Type-specific classes are defined inline in the
prototype example slides under `examples/lecture-template/` and can be
promoted to a shared CSS file later if they prove reusable across decks.

## 1 · learning-objectives

**Purpose:** 3-5 bullets describing what the learner will understand /
be able to do by the end of the lecture. Placed after cover, before
first chapter.

**Vibe:** checklist with progressive reveal on click (or auto-reveal
after 400ms each). Each bullet has a small cyan check icon and a brief
(5-12 word) learning outcome.

**Body class:** `lecture` (sets layout padding, presenter scale).

**Content shape:**
- eyebrow (pill): `"LEARNING OBJECTIVES · BY THE END"`
- title (1 line): e.g. `"What you'll know after this lecture"`
- 3-5 objective bullets, each: icon + bold outcome verb + noun phrase

**DOM skeleton:**
```html
<body class="lecture">
<div class="slide">
  <header class="slide-header">
    <div class="eyebrow">◆ LEARNING OBJECTIVES · BY THE END</div>
    <h1 class="gradient-title">{{slide_title}}</h1>
  </header>
  <ul class="objectives-list">
    <li class="objective">
      <span class="objective-icon">✓</span>
      <span class="objective-text">
        <strong>{{verb}}</strong> {{noun_phrase}}
      </span>
    </li>
    <!-- 2-4 more .objective items -->
  </ul>
</div>
<script src="shared.js" defer></script>
</body>
```

**CSS sketch (inline in prototype):**
```css
.objectives-list { list-style: none; padding: 0; margin-top: 40px; }
.objective { display: flex; gap: 18px; padding: 16px 20px;
  border-left: 2px solid var(--accent-cyan);
  background: rgba(0, 229, 255, 0.04);
  margin-bottom: 14px; border-radius: var(--radius-sm);
  opacity: 0; animation: fade-in-up 0.6s ease forwards; }
.objective:nth-child(1) { animation-delay: 0.1s; }
.objective:nth-child(2) { animation-delay: 0.3s; }
.objective:nth-child(3) { animation-delay: 0.5s; }
.objective:nth-child(4) { animation-delay: 0.7s; }
.objective:nth-child(5) { animation-delay: 0.9s; }
.objective-icon { color: var(--accent-cyan); font-weight: bold;
  font-family: var(--font-mono); }
.objective-text { font-size: 1.35rem; line-height: 1.4; }
```

**Source mapping:** lift from `[OBJECTIVE] …` markers in the lecture
source markdown.

---

## 2 · chapter-break

**Purpose:** visual transition between lecture chapters. Like `phase`
but without GATE semantics or I/O flow — just a numeric marker and a
tagline. Use when the lecture has ≥3 chapters.

**Vibe:** giant chapter number (e.g. `03`) as a semi-transparent
backdrop, small eyebrow label "Chapter · 03 / 09", bold chapter title,
one-line summary.

**Body class:** `lecture chapter-break`.

**Content shape:**
- huge chapter number (SVG text or giant CSS font) behind content
- eyebrow: `"CHAPTER 03 · 09"`
- title: chapter name
- tagline: one-line summary / teaser of chapter content

**DOM skeleton:**
```html
<body class="lecture chapter-break">
<div class="chapter-slide">
  <div class="chapter-num-bg">{{NN}}</div>
  <div class="chapter-content">
    <div class="eyebrow">CHAPTER {{N}} · {{TOTAL}}</div>
    <h1 class="chapter-title">{{chapter_title}}</h1>
    <p class="chapter-tagline">{{tagline}}</p>
  </div>
</div>
<script src="shared.js" defer></script>
</body>
```

**CSS sketch:**
```css
.chapter-num-bg { position: absolute; top: 50%; left: 50%;
  transform: translate(-50%, -50%); font-size: 32rem;
  font-weight: 900; color: rgba(0, 229, 255, 0.04);
  z-index: 0; font-family: var(--font-mono); line-height: 1; }
.chapter-content { position: relative; z-index: 1; text-align: center;
  max-width: 1200px; }
.chapter-title { font-size: 4rem; font-weight: 900;
  letter-spacing: -0.03em; margin-top: 20px; }
.chapter-tagline { font-size: 1.55rem; color: var(--text-secondary);
  margin-top: 24px; }
```

**Source mapping:** `[JUMP] …` markers or numbered section headings.

---

## 3 · recap

**Purpose:** "What we just covered" summary cards between chapters or
before Q&A. 3-4 cards, each summarising one key idea from the preceding
chapter.

**Vibe:** cyan-themed card grid, each card has a numbered anchor (01, 02,
03) and 1-2 sentences. Reinforces retention.

**Body class:** `lecture recap`.

**Content shape:**
- eyebrow: `"RECAP · CHAPTER N"`
- title: e.g. `"What we covered"`
- 3-4 recap cards, each: number + short title + 1-2 sentence summary

**DOM skeleton:**
```html
<body class="lecture recap">
<div class="slide">
  <header class="slide-header">
    <div class="eyebrow">◆ RECAP · CHAPTER {{N}}</div>
    <h1 class="gradient-title">{{slide_title}}</h1>
  </header>
  <div class="recap-grid">
    <div class="recap-card">
      <div class="recap-num">01</div>
      <div class="recap-title">{{key_point_1}}</div>
      <div class="recap-body">{{one_sentence_summary}}</div>
    </div>
    <!-- 2-3 more .recap-card items -->
  </div>
</div>
<script src="shared.js" defer></script>
</body>
```

**CSS sketch:**
```css
.recap-grid { display: grid; grid-template-columns: repeat(auto-fit,
  minmax(280px, 1fr)); gap: 20px; margin-top: 36px; }
.recap-card { padding: 28px 24px; border-radius: var(--radius-md);
  background: var(--bg-panel);
  border: 1px solid rgba(0, 229, 255, 0.2);
  box-shadow: var(--glow-cyan); }
.recap-num { font-family: var(--font-mono); color: var(--accent-cyan);
  font-size: 0.85rem; letter-spacing: 3px; margin-bottom: 14px; }
.recap-title { font-size: 1.25rem; font-weight: 700;
  margin-bottom: 10px; }
.recap-body { font-size: 1rem; color: var(--text-secondary);
  line-height: 1.5; }
```

**Source mapping:** `[RECAP] …` markers in the lecture source.

---

## 4 · references-list

**Purpose:** final slide with numbered list of sources (papers, URLs,
DOIs, timestamps). Stylised like `data-table` but with two columns: `#`
and reference text.

**Vibe:** monospace numbering, dense two-column layout, each row a
citation. Hover reveals URL if different from display text.

**Body class:** `lecture references`.

**Content shape:**
- eyebrow: `"REFERENCES · FURTHER READING"`
- title: e.g. `"References"`
- table with 2 columns (#, Reference), 6-20 rows

**DOM skeleton:**
```html
<body class="lecture references">
<div class="slide">
  <header class="slide-header">
    <div class="eyebrow">◆ REFERENCES · FURTHER READING</div>
    <h1 class="gradient-title">References</h1>
  </header>
  <table class="data-table references-table">
    <thead>
      <tr><th>#</th><th>Reference</th></tr>
    </thead>
    <tbody>
      <tr>
        <td><span class="ref-num">01</span></td>
        <td>
          <strong>{{author}} · {{year}}</strong>
          · <em>{{title}}</em>
          · <a href="{{url}}">{{short_url}}</a>
        </td>
      </tr>
      <!-- N-1 more rows -->
    </tbody>
  </table>
</div>
<script src="shared.js" defer></script>
</body>
```

**CSS sketch:**
```css
.references-table { width: 100%; border-collapse: separate;
  border-spacing: 0 4px; }
.references-table th { text-align: left; font-family: var(--font-mono);
  font-size: 0.75rem; letter-spacing: 3px; color: var(--text-muted);
  padding: 8px 16px; text-transform: uppercase; }
.references-table td { padding: 14px 16px;
  background: rgba(13, 20, 36, 0.5);
  border-top: 1px solid rgba(0, 229, 255, 0.1);
  border-bottom: 1px solid rgba(0, 229, 255, 0.1); }
.references-table td:first-child { border-left: 2px solid
  var(--accent-cyan); border-radius: var(--radius-sm) 0 0
  var(--radius-sm); width: 60px; }
.references-table td:last-child { border-radius: 0
  var(--radius-sm) var(--radius-sm) 0; }
.ref-num { font-family: var(--font-mono); color: var(--accent-cyan);
  font-size: 1rem; }
.references-table a { color: var(--accent-blue); }
```

**Source mapping:** typically compiled from the source material's
`## References` section or a bibliography file; not marker-driven.

---

## When to use which

Sequence within a typical lecture:

1. `cover` (core) — title slide
2. `learning-objectives` (lecture) — what you'll learn
3. `chapter-break` (lecture) — Chapter 1
4. `concept` / `diagram` / `flow` (core) — chapter body
5. `recap` (lecture) — end of chapter
6. `chapter-break` (lecture) — Chapter 2
7. … repeat 4-6 per chapter
8. `qa-intro` (core) — optional Q&A break
9. `references-list` (lecture) — closing
10. `closing` (core) — CTA / thanks

Type-specific archetypes aren't mandatory — a short lecture (30 min, 1
chapter) may skip `chapter-break` and `recap`, for example.
