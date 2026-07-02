# Deck Spec

- deck_type: workshop
- title: Test-Driven Refactoring
- speaker: Alex Morgan
- date: 2026
- venue: —
- source: none
- sections: 3 (Opening, Phase 1 - Pin Behaviour, Refactor Loop & Ship)
- archetypes: cover, quote, concept, phase, terminal-demo, flow, gate-review, closing
- terminal_demos: 1
- presenter_scale: 1.15
- output_dir: examples/workshop-example
- language: en
- marker_map: none

## Slide plan

01. cover · Test-Driven Refactoring · Frame the workshop - reshape code without changing behaviour, held up by a test net · free-text
02. quote · Code for Humans · Fowler reframes refactoring as writing code for the next human reader · free-text
03. concept · The Refactoring Safety Net · Safe refactoring needs three things at once - characterization tests, small steps, continuous green · free-text
04. phase · Pin Current Behaviour · Phase 1 records the module's real output in tests before a single line changes · free-text
05. terminal-demo · Pinning Behaviour - Red to Green · A characterization test fails on a guessed value, then passes once the real output is pinned · free-text
06. flow · The Refactor Loop · The inner loop runs smell to commit, one small verified move at a time · free-text
07. gate-review · Ready to Ship? · A human gate confirms behaviour is identical and the diff is pure restructuring before shipping · free-text
08. closing · Refactor with a Net · Three takeaways plus one action - refactor one module this week · free-text
