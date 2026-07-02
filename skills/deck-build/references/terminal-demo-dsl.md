# Terminal Demo DSL — `DemoRunner`

`demo-runner.js` provides a tiny state machine that renders animated fake
terminal sessions inside a slide's terminal card. Every demo slide uses it.

## Initialisation

Each demo slide ends with:

```html
<script src="shared.js" defer></script>
<script src="demo-runner.js" defer></script>
<script>
document.addEventListener("DOMContentLoaded", function () {
  DemoRunner.init({
    prompt: "user@deck",
    command: "/your:command",
    commandSpeed: 45,           // ms per character · default 60
    steps: [ /* see below */ ]
  });
});
</script>
```

`DemoRunner.init()` wires the `#run` button (inside `.run-overlay`) to fire
the demo, and the `#reset` button to clear the terminal body. No demo plays
until the user clicks RUN — this is intentional so presenter can narrate
first.

## Required DOM (part of the terminal-demo archetype)

```html
<div class="terminal">
  <div class="terminal-titlebar">
    <span class="dot r"></span><span class="dot y"></span><span class="dot g"></span>
    <span class="title">session label</span>
  </div>
  <div class="terminal-body" id="body"></div>
  <div class="run-overlay" id="overlay">
    <button class="run-btn" id="run">▶ RUN DEMO</button>
    <div class="run-hint">/command</div>
  </div>
  <button class="reset-btn" id="reset">↻ RESET</button>
</div>
```

## Step types

Each step is an object in the `steps` array. The runner iterates them
sequentially, awaiting each one.

### `line` — single output line

```js
{ type: "line", class: "terminal-ok", text: "✓ all checks passed" }
```

Options:
- `class` — any of `.terminal-prompt`, `.terminal-command`, `.terminal-muted`,
  `.terminal-ok`, `.terminal-warn`, `.terminal-err`, `.terminal-label`,
  or plain (no class) for default colour.
- `text` — string, inserted as textContent (no HTML).
- `typewrite` — boolean. If true, text types one char at a time via
  `await typewriter(el, text, speed)`.
- `speed` — ms per char when typewriting (default 35).
- `delayBefore` — ms to wait before this step emits.

### `blank` — empty line

```js
{ type: "blank", delayBefore: 100 }
```

Inserts an `&nbsp;` div. Use for breathing room between sections.

### `pause` — no output, just delay

```js
{ type: "pause", duration: 500 }
```

Use for rhythm between visually active steps.

### `multi` — batch of lines with gap

```js
{ type: "multi", gap: 90, lines: [
  { class: "terminal-command", text: '<span>HTML is allowed here</span>' },
  { class: "terminal-muted",   text: "second line" }
]}
```

Options:
- `lines` — array of `{ class, text }`. **`text` is inserted as `innerHTML`**,
  so you can embed `<span>` wrappers for partial colour. This is the only
  step type that accepts HTML.
- `gap` — ms between lines (default 45).
- `delayBefore` — prelude delay.

Use for chorus-style reveals (e.g. A / B / C options).

### `progress` — animated progress bar

```js
{ type: "progress", label: "Running tests", pct: 100, duration: 1200,
  doneLabel: "Done" }
```

Renders an inline progress bar with label + percentage. Animates from 0 to
`pct` over `duration` ms. If `doneLabel` is set, replaces the percentage
with this label at completion.

Options:
- `label` — left-aligned label text (e.g. "Building…").
- `pct` — final percentage (default 100).
- `duration` — animation time in ms (default 1200).
- `doneLabel` — optional string shown instead of the final %.
- `delayBefore` — prelude delay.

### `raw` — arbitrary HTML block

```js
{ type: "raw", html: "<pre>{\"key\": \"value\"}</pre>", class: "terminal-muted" }
```

Escape hatch — only use when other step types don't fit (e.g. embedding a
formatted JSON block or a small inline table). Keep `html` trusted; the
string goes into `innerHTML`.

## Terminal CSS classes (from `shared.css`)

| Class | Colour | Use for |
|---|---|---|
| `terminal-prompt` | green | Prompt prefix `$`, `claude>`, user shell |
| `terminal-command` | cyan | Typed commands, code spans |
| `terminal-muted` | muted | System messages, non-critical output |
| `terminal-ok` | green | Success messages, completed checks |
| `terminal-warn` | amber | GATE-awaiting, checkpoints, cautions |
| `terminal-err` | red | Errors, failures |
| `terminal-label` | amber | Section delimiters (`┌─ Phase 1 ───`) |

Mix freely with `<span>` wrappers inside `multi.lines[].text` for partial
colour on one line.

## Rhythm guidelines

- Total runtime of a single demo: aim for 45–90 seconds.
- Command typing: speed 45-60 is comfortable. 25 feels frantic.
- Between logical sections (detected / validated / output), insert
  `{ type: "blank" }` or `{ type: "pause", duration: 400 }`.
- Progress bars should be 1-2s — longer than that and the viewer gets bored.
- After `gate` warn lines, `pause` 400ms to let it land before the next line.

## Anti-patterns

- **Embedding real multi-line command output via `\n`.** Use `multi` with
  one line per entry instead. Newlines in `text` render literally.
- **Using `raw` for everything.** Ties you to inline HTML instead of the
  step structure; harder to re-time.
- **No RUN overlay.** Never auto-play — the viewer needs to know when the
  demo starts, and presenter needs control of the narrative beat.
- **Hardcoding sleep durations that total > 120s.** Presenter will have to
  reload the slide to re-run. If the demo is that long, split into two
  slides.
- **Trying to make the terminal actually execute code.** It doesn't. It's a
  scripted animation. If you need real execution, that's a different tool.

See `05-demo-1-tests.html` in `examples/workshop-example/` for a
canonical demo slide.
