# Talk Archetypes — Slide Blueprints (type-specific add-ons)

These 4 archetypes are specific to the **talk** deck type (conference /
keynote / short speech). Use them in addition to the core 15 archetypes
defined in `archetypes.md`.

Talks differ from workshops and lectures in rhetorical density: fewer
slides, higher stakes per slide, strong hook up front, one memorable
moment, clear CTA at the end.

All archetypes reuse `shared.css` tokens. Type-specific classes are
defined inline in the prototype example slides under
`examples/talk-template/` and can be promoted to a shared CSS file later
if they prove reusable.

## 1 · hook

**Purpose:** opening attention-grab. Comes right after cover. A big
rhetorical question, a stark claim, or a provocative thesis. One line,
centered, dark background, minimum decoration. Forces the audience to
lean in.

**Vibe:** pure focus. Single sentence, huge type, centered. No pills,
no eyebrow. Optional subtle ambient glow behind text.

**Body class:** `talk hook`.

**Content shape:**
- one statement or question (5-15 words)
- optional tiny tag line below (3-6 words, much smaller)

**DOM skeleton:**
```html
<body class="talk hook">
<div class="hook-slide">
  <div class="hook-text">{{big_question_or_claim}}</div>
  <div class="hook-sub">{{optional_tiny_line}}</div>
</div>
<script src="shared.js" defer></script>
</body>
```

**CSS sketch:**
```css
body.hook { align-items: center; justify-content: center; }
.hook-slide { text-align: center; max-width: 1400px;
  padding: 40px; position: relative; z-index: 1; }
.hook-text { font-size: 4.5rem; font-weight: 900;
  letter-spacing: -0.03em; line-height: 1.05;
  background: linear-gradient(120deg,
    var(--accent-cyan) 0%, var(--accent-purple) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  animation: fade-in-up 1s ease both; }
.hook-sub { margin-top: 40px; font-family: var(--font-mono);
  font-size: 0.9rem; letter-spacing: 4px; color: var(--text-muted);
  text-transform: uppercase; animation: fade-in-up 1s ease 0.4s both; }
```

**Source mapping:** `[HOOK] …` marker in the talk source, or the first
rhetorical question in the script.

---

## 2 · thesis

**Purpose:** one central thesis statement of the whole talk. Formula-like
hero treatment: a bordered mono-font block, one equation-style line, with
an optional subtext "Why it matters".

**Vibe:** academic paper meets keynote. A claim presented as if it were
the T=F·d of your argument. Monospace, bordered, centered.

**Body class:** `talk thesis`.

**Content shape:**
- eyebrow (optional): `"THE THESIS"`
- hero equation line (mono font, could be a short aphorism or formula-like)
- subtext: "Why it matters" + 1-2 sentence explanation

**DOM skeleton:**
```html
<body class="talk thesis">
<div class="slide">
  <div class="thesis-hero">
    <div class="thesis-eyebrow">◆ THE THESIS</div>
    <div class="thesis-line">{{central_claim}}</div>
    <div class="thesis-why">
      <div class="thesis-why-label">WHY IT MATTERS</div>
      <p class="thesis-why-text">{{two_sentence_explanation}}</p>
    </div>
  </div>
</div>
<script src="shared.js" defer></script>
</body>
```

**CSS sketch:**
```css
.thesis-hero { max-width: 1200px; margin: 60px auto 0;
  text-align: center; }
.thesis-eyebrow { font-family: var(--font-mono); color: var(--accent-cyan);
  font-size: 0.85rem; letter-spacing: 4px; margin-bottom: 28px; }
.thesis-line { font-family: var(--font-mono); font-size: 2.4rem;
  font-weight: 700; line-height: 1.3; padding: 40px 60px;
  border: 1px solid var(--accent-cyan); border-radius: var(--radius-lg);
  background: rgba(0, 229, 255, 0.04); box-shadow: var(--glow-cyan); }
.thesis-why { margin-top: 48px; max-width: 800px;
  margin-left: auto; margin-right: auto; }
.thesis-why-label { font-family: var(--font-mono);
  color: var(--accent-amber); font-size: 0.78rem;
  letter-spacing: 3px; margin-bottom: 12px; }
.thesis-why-text { font-size: 1.25rem; line-height: 1.5;
  color: var(--text-secondary); }
```

**Source mapping:** `[THESIS] …` marker in the talk source.

---

## 3 · memorable-moment

**Purpose:** the one phrase you want the audience to tweet / remember /
repeat. Quotable line, quadratic composition (not horizontal banner),
gradient title treatment, optional meta-line below.

**Vibe:** tweetable. Should feel like the screenshot that makes it onto
social media. Distinct from `thesis` (which is the intellectual core) —
`memorable-moment` is the emotional or rhetorical peak.

**Body class:** `talk memorable`.

**Content shape:**
- a memorable phrase (10-25 words)
- meta-line: speaker · timestamp · context (small, mono, uppercase)

**DOM skeleton:**
```html
<body class="talk memorable">
<div class="memorable-slide">
  <div class="memorable-mark">"</div>
  <div class="memorable-text">{{quotable_phrase}}</div>
  <div class="memorable-meta">
    <span>{{speaker}}</span>
    <span class="sep"></span>
    <span>{{context_tag}}</span>
  </div>
</div>
<script src="shared.js" defer></script>
</body>
```

**CSS sketch:**
```css
body.memorable { align-items: center; justify-content: center;
  overflow: hidden; }
.memorable-slide { text-align: center; max-width: 1100px;
  padding: 40px; position: relative; z-index: 1; }
.memorable-mark { font-family: Georgia, serif; font-size: 10rem;
  line-height: 0.8; color: var(--accent-purple);
  text-shadow: 0 0 40px rgba(213, 0, 249, 0.5); margin-bottom: 20px; }
.memorable-text { font-size: 3.2rem; font-weight: 700;
  letter-spacing: -0.02em; line-height: 1.15;
  background: linear-gradient(120deg,
    var(--accent-purple) 0%, var(--accent-blue) 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text; }
.memorable-meta { margin-top: 44px; display: inline-flex;
  align-items: center; gap: 14px; font-family: var(--font-mono);
  font-size: 0.82rem; letter-spacing: 3px; color: var(--text-muted);
  text-transform: uppercase; }
.memorable-meta .sep { width: 4px; height: 4px; border-radius: 50%;
  background: var(--text-muted); }
```

**Source mapping:** `[MEMORABLE] …` marker in the talk source, or the
strongest rhetorical line in the script.

---

## 4 · cta-simple

**Purpose:** closing slide with ONE action. No takeaway cards, no 3×3
grid — just the single ask. URL, contact, QR code, or invitation.

**Vibe:** minimalist. Contrast with `closing` (core) which is the
workshop/lecture style with 3-4 takeaway cards. `cta-simple` is for
talks where the attention budget is spent and you get exactly one
concrete next step.

**Body class:** `talk cta`.

**Content shape:**
- eyebrow: small pill `"ONE ACTION"`
- big verb phrase (e.g. `"Follow for more"`, `"Join the waitlist"`)
- the action target: URL, handle, or QR-code image

**DOM skeleton:**
```html
<body class="talk cta">
<div class="cta-slide">
  <div class="cta-eyebrow">◆ ONE ACTION</div>
  <div class="cta-verb">{{call_to_action}}</div>
  <div class="cta-target">
    <a href="{{url}}" class="cta-link">{{display_url}}</a>
  </div>
  <!-- optional: <img class="cta-qr" src="qr.png" alt=""> -->
</div>
<script src="shared.js" defer></script>
</body>
```

**CSS sketch:**
```css
body.cta { align-items: center; justify-content: center; }
.cta-slide { text-align: center; max-width: 1100px; padding: 40px; }
.cta-eyebrow { font-family: var(--font-mono); color: var(--accent-amber);
  font-size: 0.85rem; letter-spacing: 4px; margin-bottom: 28px; }
.cta-verb { font-size: 4rem; font-weight: 900; letter-spacing: -0.02em;
  line-height: 1.1; color: var(--text-primary); margin-bottom: 40px; }
.cta-target { font-family: var(--font-mono); font-size: 1.55rem;
  padding: 18px 32px; border: 1px solid var(--accent-amber);
  border-radius: var(--radius-md); display: inline-block;
  background: rgba(255, 171, 64, 0.04);
  box-shadow: var(--glow-amber); }
.cta-link { color: var(--accent-amber); text-decoration: none; }
.cta-qr { margin-top: 40px; width: 200px; height: 200px;
  border-radius: var(--radius-sm); }
```

**Source mapping:** `[CTA] …` marker in the talk source, or the final
paragraph of the script.

---

## When to use which

Typical talk deck sequence (15-30 min, 10-18 slides):

1. `cover` (core) — title slide
2. `hook` (talk) — attention grab
3. `quote` / `concept` (core) — context / motivation
4. `thesis` (talk) — central claim
5. `diagram` / `flow` / `phase` (core) — body of argument (3-6 slides)
6. `memorable-moment` (talk) — the quotable line
7. `comparison` (core) — optional "before/after" or "wrong/right"
8. `cta-simple` (talk) — closing action

For a keynote (30-45 min), add more body slides. For a lightning talk
(10-15 min), drop `memorable-moment` or `comparison` to keep the deck
short and punchy.

Never use all four type-specific archetypes in a 10-min talk — pick 2
(always `hook` + `cta-simple`, optionally `thesis` or `memorable-moment`).
