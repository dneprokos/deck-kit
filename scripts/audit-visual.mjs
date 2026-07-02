#!/usr/bin/env node
/* audit-visual.mjs <deck-dir>
 * Gate 4: visual rendering with Playwright.
 * - Boots http.server, headless Chromium at 1920x1080.
 * - Screenshots each slide into .audit/screenshots/.
 * - Asserts no horizontal overflow + no JS errors on load.
 *
 * Usage:  node scripts/audit-visual.mjs <deck-dir>
 * Exits 0 on pass, 1 on failure, 2 on environment / install issues.
 */

import { spawn } from "node:child_process";
import { readdir, mkdir } from "node:fs/promises";
import { existsSync } from "node:fs";
import { createRequire } from "node:module";
import path from "node:path";
import process from "node:process";
import net from "node:net";

/* Resolve playwright in three steps:
 * 1. bare import — works when this script's own tree has node_modules
 *    (repo checkout after `npm install`);
 * 2. resolve from the CALLER's cwd — works when the script runs from the
 *    Claude Code plugin cache (no node_modules there) but the user's
 *    project has playwright installed;
 * 3. neither → exit 2 with install instructions (distinct from a real
 *    visual failure, which exits 1).
 */
let chromium;
for (const spec of ["playwright", "@playwright/test"]) {
  try {
    ({ chromium } = await import(spec));
    break;
  } catch (_) { /* keep trying */ }
}
if (!chromium) {
  // require(), not import(resolve(...)): playwright's entry is CJS, and the
  // ESM named-export lexer can't always surface `chromium` from it.
  const cwdRequire = createRequire(path.join(process.cwd(), "package.json"));
  for (const spec of ["playwright", "@playwright/test"]) {
    try {
      ({ chromium } = cwdRequire(spec));
      break;
    } catch (_) { /* keep trying */ }
  }
}
if (!chromium) {
  console.error("");
  console.error("Playwright not found (neither next to deck-kit's scripts");
  console.error("nor in the current project's node_modules). Install it in");
  console.error("the project you run the audit from:");
  console.error("  npm i -D playwright");
  console.error("  npx playwright install chromium");
  console.error("");
  console.error("Then rerun audit-visual.mjs from that project directory.");
  console.error("");
  console.error("To skip this gate explicitly (not recommended),");
  console.error("rerun the audit pipeline with --skip-visual and record");
  console.error("the skip in the deck manifest.");
  process.exit(2);
}

const deckArg = process.argv[2];
if (!deckArg) {
  console.error("usage: audit-visual.mjs <deck-dir>");
  process.exit(2);
}

const deckDir = path.resolve(deckArg);
if (!existsSync(deckDir)) {
  console.error(`deck dir not found: ${deckDir}`);
  process.exit(2);
}

// ----- Pick a free port ---------------------------------------------------

function pickPort(start = 8765, end = 8800) {
  return new Promise((resolve, reject) => {
    const tryPort = (p) => {
      if (p > end) return reject(new Error("no free port"));
      const srv = net.createServer();
      srv.once("error", () => tryPort(p + 1));
      srv.once("listening", () => {
        srv.close(() => resolve(p));
      });
      srv.listen(p, "127.0.0.1");
    };
    tryPort(start);
  });
}

const port = await pickPort();
const base = `http://localhost:${port}`;

// ----- Boot python3 http.server -------------------------------------------

const server = spawn("python3", ["-m", "http.server", String(port)], {
  cwd: deckDir,
  stdio: ["ignore", "ignore", "ignore"],
});

const killServer = () => {
  try { server.kill("SIGTERM"); } catch { /* noop */ }
};
process.on("exit", killServer);
process.on("SIGINT", () => { killServer(); process.exit(130); });
process.on("SIGTERM", () => { killServer(); process.exit(143); });

// Wait briefly for server boot.
await new Promise((r) => setTimeout(r, 1000));

// ----- Collect slides to test ---------------------------------------------

const entries = await readdir(deckDir);
const slides = entries
  .filter((f) => /^\d{2}-.+\.html$/.test(f))
  .sort();

if (slides.length === 0) {
  console.log("[info] no NN-*.html slides yet - checking index.html only (empty scaffold)");
}

const shotsDir = path.join(deckDir, ".audit", "screenshots");
await mkdir(shotsDir, { recursive: true });

// ----- Launch browser & run checks ----------------------------------------

const browser = await chromium.launch({ headless: true });
const context = await browser.newContext({ viewport: { width: 1920, height: 1080 } });

let failCount = 0;
// Archetypes that may legitimately be taller than viewport.
// index.html is always a scrolling grid. Flow / table / tabs / routing
// archetypes are inherently vertical.
const SCROLL_OK_PATTERNS = [
  /^index\.html$/,
  // Match archetype keywords as trailing slug component: "-flow.html",
  // "-artifact-flow.html", "some-table.html" all count as scrollable.
  /-(flow|flows|table|tabs?|prd|routing|overview|scale|master|chain|enterprise)(-[\w-]+)?\.html$/,
];
// Hard ceiling — above this height, something is genuinely broken even for
// scroll-OK archetypes. Catches run-away layouts.
const MAX_SCROLL_HEIGHT = 8000;

async function checkSlide(file) {
  const page = await context.newPage();
  const errors = [];
  page.on("pageerror", (e) => errors.push(`pageerror: ${e.message}`));
  page.on("console", (msg) => {
    if (msg.type() === "error") errors.push(`console.error: ${msg.text()}`);
  });

  try {
    await page.goto(`${base}/${file}`, { waitUntil: "domcontentloaded", timeout: 10000 });
    // Give animations a short beat to start (not finish — infinite loops).
    await page.waitForTimeout(200);

    const dims = await page.evaluate(() => ({
      sw: document.body.scrollWidth,
      sh: document.body.scrollHeight,
    }));

    await page.screenshot({
      path: path.join(shotsDir, file.replace(/\.html$/, ".png")),
      fullPage: false,
    });

    let issue = "";
    if (dims.sw > 1920 + 1) {
      issue = `overflow-x ${dims.sw}px`;
    }
    const allowScroll = SCROLL_OK_PATTERNS.some((r) => r.test(file));
    // Non-scrolling archetypes must fit within 1200px (1080 viewport + 120
    // slack for pattern-card growth). Scroll-OK archetypes may be tall but
    // not run-away tall.
    const yLimit = allowScroll ? MAX_SCROLL_HEIGHT : 1200;
    if (dims.sh > yLimit) {
      issue = issue
        ? `${issue}; overflow-y ${dims.sh}px (limit ${yLimit})`
        : `overflow-y ${dims.sh}px (limit ${yLimit})`;
    }
    if (errors.length > 0) {
      issue = issue ? `${issue}; ${errors[0]}` : errors[0];
    }

    if (issue) {
      console.log(`✗ ${file} (${issue})`);
      failCount++;
    } else {
      console.log(`✓ ${file} (${dims.sw}x${dims.sh})`);
    }
  } catch (e) {
    console.log(`✗ ${file} (exception: ${e.message})`);
    failCount++;
  } finally {
    await page.close();
  }
}

// Also spot-check the index.
slides.unshift("index.html");

for (const slide of slides) {
  await checkSlide(slide);
}

await browser.close();
killServer();

if (failCount > 0) {
  console.log("");
  console.log(`Gate 4 (visual): FAIL — ${failCount} slide(s) with issues`);
  console.log(`Screenshots in ${shotsDir}`);
  process.exit(1);
}

console.log("");
console.log(`Gate 4 (visual): PASS — ${slides.length} slide(s) OK`);
console.log(`Screenshots in ${shotsDir}`);
