# Scoping Questions — Prepared Dialog Bank

This file is the plan skill's canned question bank. Every
`AskUserQuestion` payload the skill issues during scoping should come
from here (or be a small adaptation). Consistency matters: if the skill
invents new question wording every run, the user can't build muscle
memory.

Questions are English by default. If the user is clearly conversing in
another language, translate the question and options into that language
on the fly — keep the internal labels and recorded answer keys English.

Format: each entry shows the `question`, `header`, and `options`. Copy
verbatim (or translated) when issuing `AskUserQuestion`.

---

## Upfront scoping (9 questions, one at a time)

### Q0 — Deck type

**question:** "What type of deck are we building?"
**header:** "Deck type"
**options:**
1. **Workshop** — hands-on training, live terminal demos, 60-120 min.
2. **Lecture** — educational content, learning objectives, chapters, 30-120 min.
3. **Talk** — conference keynote or short speech, 15-45 min.

Cross-reference: see `deck-types.md` for how Q0 routes the rest of
scoping.

### Q1 — Source material

**question:** "Where is the source material for this deck?"
**header:** "Source"
**options:**
1. **A file (I'll give the path)** — paste the absolute or relative path next.
2. **I'll paste the content right here** — an outline, bullet list, or draft script.
3. **Nothing yet** — the skill drafts a headline-level outline WITH the user, one section at a time. It never generates a full deck from nothing.

### Q2 — Deck identity

**question:** "What are the title · speaker · date · venue?"
**header:** "Deck identity"
Issue as free-text; the `AskUserQuestion` options are:
1. **Take them from the source file** — if the source names them.
2. **Enter values now** — I'll ask one by one.

### Q3 — Section count

**question:** "How many logical parts does the deck have (Part 0, Part 1, …)?"
**header:** "Sections"
**options:**
1. **1 part** — a single pass, no dividers.
2. **3-5 parts** — classic opening → body → closing with Q&A.
3. **6+ parts** — long workshop with scaling / bonus blocks.

### Q4 — Archetypes needed

Options adapt to `deck_type` from Q0. Full one-line catalog:
`archetype-catalog.md`.

**Common question stem:** "Which slide archetypes will we need? (multi-select)"
**header:** "Archetypes"
**multiSelect:** true

**When Q0 = workshop:**
1. **Core 7 workshop** — cover / quote / comparison / concept / phase /
   terminal-demo / closing.
2. **+ Diagram / Flow** — SVG pipelines, artifact chains.
3. **+ Table / Formula / Tabs** — data-forward slides.
4. **+ Wheel / Sizing-flow / QA-intro / gate-review** — advanced.

**When Q0 = lecture:**
1. **Core 6 lecture** — cover / learning-objectives / concept / recap /
   references-list / closing.
2. **+ Chapter-break / Diagram / Flow** — multi-chapter structure + visuals.
3. **+ Table / Formula / Tabs / QA-intro** — data-forward + Q&A break.
4. **+ Quote / Comparison / Wheel** — rhetorical + specialty.

**When Q0 = talk:**
1. **Core 5 talk** — cover / hook / thesis / memorable-moment / cta-simple.
2. **+ Quote / Comparison / Concept** — argumentation support.
3. **+ Diagram / Flow** — visual pipelines in body.
4. **+ Formula / Table** — data-backed claims.

### Q5 — Live demos (workshop only; skipped otherwise)

**Skip this question entirely if Q0 ≠ workshop.**

**question:** "Will there be live terminal demos?"
**header:** "Demos"
**options:**
1. **Yes, 1-3 demos** — modest, default demo styling.
2. **Yes, 5-10 demos** — a full demo track through the deck.
3. **No** — everything static.

### Q6 — Presenter mode scale

Default depends on Q0: workshop 1.15×, lecture 1.25×, talk 1.35×.

**question:** "Presenter mode — font scale for live delivery?"
**header:** "Presenter"

**When Q0 = workshop:**
1. **1.15× (workshop default)** — small group, close screen.
2. **1.25×** — bigger rooms.
3. **No scaling** — display = review.

**When Q0 = lecture:**
1. **1.25× (lecture default)** — classroom / webinar.
2. **1.15×** — small group, laptop-width.
3. **1.35×** — large monitor, distant viewer.

**When Q0 = talk:**
1. **1.35× (talk default)** — conference hall, distant viewer.
2. **1.25×** — mid-size room.
3. **1.15×** — camera-close delivery (webinar).

### Q7 — Output directory

**question:** "Where should the generated deck live?"
**header:** "Output dir"
**options:**
1. **`deck/` (cwd-relative)** — default for quick iteration.
2. **`docs/decks/<topic>/`** — repo-structured.
3. **Another directory** — I'll give the path.

### Q8 — Slide language

**question:** "Language of the slide content?"
**header:** "Language"
**options:**
1. **English** — default.
2. **Same language as the source material** — the skill mirrors it.
3. **Mixed** — headings in one language, body in another (say which).

Design-system labels (`GOAL`, `INPUT`, `OUTPUT`, `GATE`, `COMMANDS`,
`LIVE DEMO`, …) stay uppercase English regardless of Q8 — they are
design tokens, not content.

---

## Content markers follow-up (after Q1, when a source file exists)

If the source file uses inline stage-direction markers (any bracketed
tags like `[SHOW]`, `[SAY]`, or the user's own convention in any
language), map them ONCE here — see `_shared/content-markers.md`:

**question:** "I see bracketed markers in your source (e.g. `[…]` on
lines N, M). Do they follow the deck-kit convention ([SHOW]/[SAY]/[RUN]/…),
or should I map your own tags?"
**header:** "Markers"
**options:**
1. **They match the standard convention** — no mapping needed.
2. **Map my tags** — I'll tell you what each of my markers means.
3. **No markers / ignore them** — plan from headings and structure only.

Record the resulting mapping in `.planning/deck-spec.md` so deck-build
reuses it without re-asking.

---

## Plan review (batch — this is a plan, not slides)

After drafting the full slide plan, present it as one block (all lines
in `NN. archetype · title · message · source` format) and ask:

**question:** "Here is the slide plan (N slides). Approve, or adjust?"
**header:** "Plan review"
**options:**
1. **Approve** — write `.planning/deck-spec.md` and finish.
2. **Adjust specific slides** — I'll name the numbers to change.
3. **Restructure** — wrong split, let's revisit sections (back to Q3).
