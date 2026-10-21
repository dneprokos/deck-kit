# Validation Pipeline — the 4 gates

Every deck declared "done" must pass all four gates, in this order.
Stop on first failure; don't fake progress by running later gates while
earlier ones are red.

The gates are deliberately independent — each checks something the others
cannot. Skipping any gate is a red flag, not an optimisation.

Run all four in sequence with one command:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/audit-all.sh" <deck-dir>
```

Or run them individually, as documented per gate below.

## Gate 1 — Static (structure & consistency)

**Command:**
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/audit-static.sh" <deck-dir>
```

**What it checks:**
1. Every `.html` file (slides + index) has closing `</body>` and `</html>`.
2. Every slide file (not index) has `<link rel="stylesheet" href="shared.css">`
   and `<script src="shared.js"` in the body / head.
2b. `theme.css` exists and `shared.css` contains `@import url("theme.css")`
   — without it every colour token is unset.
3. `index.html` includes `shared.js` **without** `defer` (see the gotcha
   in `navigation-contract.md`).
4. `SLIDES.length` in `shared.js` equals the count of `NN-*.html` files in
   the deck directory.
5. All filenames referenced in `SLIDES` exist on disk.

**Exit codes:** 0 pass, 1 fail. Prints the offending filename/line on fail.

## Gate 2 — Tokens (design-system integrity)

**Command:**
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/audit-tokens.sh" <deck-dir>
```

**What it checks:**
1. No hardcoded hex colours (e.g. `#ff0000`, `#abc`) anywhere in `.html`
   files, inline SVG included. The only allowed literals are the terminal
   titlebar dots (`#ff5f56`, `#ffbd2e`, `#27c93f`), a fixed convention.
2. No `rgb()`, `rgba()`, `hsl()` or `hsla()` with numeric arguments —
   translucent colours are `color-mix(in srgb, var(--token) N%, transparent)`.
3. `theme.css` defines every token of the reference theme
   (`assets/themes/cyberpunk.css`), and no slide redefines one of those
   tokens (e.g. `:root { --accent-primary: … }` in a slide `<style>`).
4. No `font-family:` outside `:root` (inside `<style>` blocks should use
   `var(--font-sans)` or `var(--font-mono)` only).
5. No `!important` in slide-level `<style>` blocks (framework styles own
   specificity; slide overrides should be naturally more specific).

Checks 1–3 keep every colour on a theme token, so swapping `theme.css`
re-themes the deck. A colour no token covers is a new token in
`theme.css` (see `design-tokens.md`), never a literal on the slide.

## Gate 3 — HTTP smoke (runtime reachability)

**Command:**
```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/audit-http.sh" <deck-dir>
```

**What it does:**
1. Starts `scripts/serve.mjs` on the deck in the background, port 0 —
   the OS assigns a free port, so no fixed range can collide with ports
   the OS reserves (Windows reserves 8751-8850 under Hyper-V/WSL).
2. Waits (up to 10s) for its `listening http://127.0.0.1:<port>` line.
3. `curl` the following URLs, expect HTTP 200 on every one:
   - `/index.html`
   - `/shared.css`
   - `/theme.css`
   - `/shared.js`
   - `/demo-runner.js` (if the deck uses it — check by grepping for
     `demo-runner.js` in any slide)
   - 5 random slide files from the `NN-*.html` glob
4. Kill the server before exit (`trap EXIT`).

**Why this exists:** catches filename typos, wrong paths, missing files.
A file that 404s here also broke the deck silently in the browser.

## Gate 4 — Visual (Playwright rendering)

**Command:**
```bash
node "${CLAUDE_PLUGIN_ROOT}/scripts/audit-visual.mjs" <deck-dir>
```

**What it does:**
1. Boots a local HTTP server (same as Gate 3).
2. Spawns Chromium headless via Playwright at viewport 1920×1080.
3. For each slide file:
   - `page.goto(url)`, wait for `domcontentloaded`.
   - Screenshot → `.audit/screenshots/NN-name.png`.
   - Assert `document.body.scrollWidth <= 1920` (no horizontal overflow).
   - Assert `document.body.scrollHeight <= 1200` for non-scrolling
     archetypes (cover, quote, phase, terminal-demo) — but allow taller
     for flow / table / tabs archetypes (inherent scroll is OK).
   - Catch JS errors fired during load → fail with the error message.
4. Emit a summary line per slide: `✓ 01-cover.html (1920×960)` or
   `✗ 07-phase-1.html (overflow 2140×980, JS error: ...)`.
5. Exit non-zero on any failure.

**Prerequisites:**
- Node 18+
- `playwright` installed — the script resolves it in this order:
  1. bare `import("playwright")` / `import("@playwright/test")` (works
     when the plugin cache has its own `node_modules`);
  2. resolution from the **deck project's** `package.json` (works when
     the user's project has playwright installed — the common case for a
     plugin install);
  3. neither found → exit code 2 with install instructions.
- Chromium browser downloaded: `npx playwright install chromium`.

If Playwright is missing, `audit-visual.mjs` prints a clear install command
and exits with code 2 (distinguishable from real failure). Do not skip this
gate silently; ask the user for explicit consent to skip with a CLI flag
(`--skip-visual`) and record it in the deck manifest.

## Gate execution order

```
Gate 1 (static)  → ✓/✗
Gate 2 (tokens)  → ✓/✗
Gate 3 (http)    → ✓/✗
Gate 4 (visual)  → ✓/✗
```

The user MUST see green across all four before the deck is declared
"done". Reporting 3/4 green + "the last one is almost passing" is not
acceptable — fix it or stop.

## Re-runs

All scripts are idempotent. After fixing a failure, re-run the failing gate
plus every gate after it (an edit that fixes a static issue might introduce
a token issue). static → tokens → http → visual — in that order each time.

## Running manually against any deck

`/deck-kit:audit <path>` runs the 4-gate pipeline against an existing
deck directory without touching content. Useful for verifying a
hand-authored deck before presenting.
