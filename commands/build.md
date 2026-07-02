---
description: Build an HTML deck slide-by-slide (from a deck-spec if present) and validate through the 4 gates
argument-hint: "[deck dir | empty]"
---

Use the **deck-build** skill (skills/deck-build/SKILL.md) with the argument: $ARGUMENTS

Pick the mode per the skill's mode-selection rules: spec mode if
`.planning/deck-spec.md` exists, audit mode if the user only asked to
validate an existing deck, standalone otherwise (recommend
`/deck-kit:plan` first).
