#!/usr/bin/env node
/* serve.mjs <deck-dir> [port]
 * Minimal static file server for a deck — used by Gate 3 (HTTP smoke),
 * Gate 4 (visual), and for presenting.
 *
 * - Binds 127.0.0.1 only (no IPv6 / localhost resolution surprises).
 * - Port 0 (the default) lets the OS pick a free port, so no fixed range
 *   can collide with ports Windows reserves (e.g. Hyper-V's 8751-8850).
 * - Prints exactly one line on start:  listening http://127.0.0.1:<port>
 *   Callers read the port from that line.
 * - Serves files only from inside <deck-dir>; "/" maps to index.html.
 *
 * Library use:  import { startServer } from "./serve.mjs";
 *               const { server, port } = await startServer(dir);
 */

import http from "node:http";
import { readFile, stat } from "node:fs/promises";
import path from "node:path";
import process from "node:process";
import { fileURLToPath } from "node:url";

const TYPES = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".mjs": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".md": "text/markdown; charset=utf-8",
  ".svg": "image/svg+xml",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".gif": "image/gif",
  ".webp": "image/webp",
  ".ico": "image/x-icon",
  ".woff": "font/woff",
  ".woff2": "font/woff2",
};

export function startServer(dir, port = 0) {
  const root = path.resolve(dir);
  const server = http.createServer(async (req, res) => {
    let rel;
    try {
      rel = decodeURIComponent(new URL(req.url, "http://x").pathname);
    } catch {
      res.writeHead(400).end();
      return;
    }
    if (rel.endsWith("/")) rel += "index.html";
    const file = path.join(root, rel);
    // Refuse anything that resolves outside the deck directory.
    if (file !== root && !file.startsWith(root + path.sep)) {
      res.writeHead(403).end();
      return;
    }
    try {
      if (!(await stat(file)).isFile()) throw new Error("not a file");
      const body = await readFile(file);
      res.writeHead(200, {
        "content-type": TYPES[path.extname(file).toLowerCase()] || "application/octet-stream",
        "cache-control": "no-store",
      });
      res.end(body);
    } catch {
      res.writeHead(404).end();
    }
  });
  return new Promise((resolve, reject) => {
    server.once("error", reject);
    server.listen(port, "127.0.0.1", () => {
      resolve({ server, port: server.address().port });
    });
  });
}

// CLI entry — only when run directly, not when imported.
if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const [dir, portArg] = process.argv.slice(2);
  if (!dir) {
    console.error("usage: serve.mjs <deck-dir> [port]");
    process.exit(2);
  }
  const { port } = await startServer(dir, Number(portArg ?? 0));
  console.log(`listening http://127.0.0.1:${port}`);
}
