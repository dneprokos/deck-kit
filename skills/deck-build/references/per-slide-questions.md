# Per-slide Questions — Prepared Dialog Bank

This file is the build skill's canned question bank for the per-slide
Socratic loop and the validation gates. Copy payloads verbatim (or
translated into the user's conversation language) when issuing
`AskUserQuestion`.

When building from a `.planning/deck-spec.md` (spec mode), PS1-PS3 come
pre-filled from the spec line — present them as confirmations, not open
questions. PS4-PS5 still run in full.

---

## Per-slide dialog (3-5 questions per slide)

Issue in sequence. After the 3rd successful slide, ask the `Fast mode`
toggle question below to see if the user wants to shortcut the remaining.

### PS1 — Archetype pick

**question:** "Slide N of TOTAL — which archetype?"
**header:** "Archetype"
**options** (present 4 that fit the remaining deck plan; in spec mode the
spec's archetype goes first, marked "(from plan)"):
1. **cover** / **phase** / **terminal-demo** / **closing** — pick from
   context-appropriate set.
Always include "Other" via fallback to a full picker.

Provide each option with a **preview** showing a short ASCII mock:

```
┌── cover ──────────┐
│      TITLE        │
│  subtitle         │
│  [pill] [pill]    │
│  speaker · date   │
└───────────────────┘
```

### PS2 — Title

**question:** "Slide title (in the deck language)?"
**header:** "Title"
Free-text — use fallback "Other". In spec mode: confirm the spec's title.

### PS3 — Source span

**question:** "Where does the content come from?"
**header:** "Content source"
**options:**
1. **Lines X-Y in the source file** — I'll give the range.
2. **Marker `[SHOW] …` (or mapped equivalent) at line Z** — one-slide group.
3. **Free text (this slide is not from the source)** — I'll give 1-2 sentences now.

### PS4 — Key visual element

**question:** "What is the hero visual element?"
**header:** "Hero element"
Options depend on archetype:
- **cover:** gradient title · orbital field · hero pill row
- **phase:** I/O flow · goal card · GATE checklist
- **terminal-demo:** DemoRunner steps · left ctx-cards · progress bars
- **table:** row count, highlight column, badge-coded cells
- **wheel:** 12-segment reference · hover details

### PS5 — Archetype-specific drill-down

Examples:
- **phase colour** — cyan / blue / green / amber / red / purple
- **terminal-demo command** — free-text (e.g. `npm run deploy`)
- **terminal-demo step count** — 5-10 / 10-20 / 20+
- **comparison sides** — label for A / B
- **quote attribution** — free-text name

---

## Fast mode toggle

**question:** "Lock the archetype for the next 3 slides without per-slide questions?"
**header:** "Fast mode"
**options:**
1. **Yes, continue with the same archetype automatically** — minimal prompts.
2. **No, ask slide by slide** — default safety.
3. **Yes, but with one confirmation before the audit** — hybrid.

Activate fast mode only if the user explicitly chose option 1. The default
stays Socratic per-slide.

---

## Validation gate prompts

### VGate

**question:** "Gate {N} — {name} — {pass/fail}. Continue?"
**header:** "Gate check"
**options:**
1. **Yes, next gate** — proceed.
2. **Show details of the failing check** — dump raw output.
3. **Pause, I'll review the screenshots** — stop, let the user look at `.audit/`.

### VFix

When a gate fails:

**question:** "Gate {N} failed in {file}: {summary}. Fix it?"
**header:** "Fix failure"
**options:**
1. **Yes, propose a patch** — show the diff, wait for confirm.
2. **I'll fix it myself** — pause.
3. **Skip this file** — only if the user explicitly confirms.

---

## Recovery questions (when the skill is stuck)

### R1 — Missing marker mapping

**question:** "Marker `[SHOW]` (or mapped equivalent) at line {X} doesn't match any planned slide. What should happen to it?"
**options:**
1. **Create an extra slide between N and N+1** — I'll adjust SLIDES.
2. **Merge into the previous slide's body** — fold into N.
3. **Ignore this marker** — non-blocking.

### R2 — Archetype mismatch detected

**question:** "Slide {N} with the chosen archetype doesn't fit 1920×1080 (overflow {px}). What do we do?"
**options:**
1. **Trim the content** — I'll propose what to cut.
2. **Change the archetype** — back to PS1.
3. **Allow scroll** — explicit opt-in (not every archetype tolerates it).
