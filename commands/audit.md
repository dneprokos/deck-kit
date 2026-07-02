---
description: Audit an existing deck — run the 4 validation gates (static, tokens, HTTP, visual) without touching content
argument-hint: "<path-to-deck-dir>"
---

Use the **deck-build** skill (skills/deck-build/SKILL.md) in **audit
mode** against the directory: $ARGUMENTS

Run only the 4 gates, report ✓/✗ per gate with failing details, and do
not modify any deck content. If Gate 4 exits with code 2 (Playwright
missing), surface the install instructions verbatim.
