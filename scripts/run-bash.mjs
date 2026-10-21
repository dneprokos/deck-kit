#!/usr/bin/env node
/* run-bash.mjs <script.sh> [args…]
 * Runs a bash script with the right bash on every OS. Used by the npm
 * scripts: npm runs them through cmd.exe on Windows, where a bare `bash`
 * usually resolves to C:\Windows\System32\bash.exe — WSL's launcher, not
 * Git Bash — and fails or runs the script in a different environment.
 *
 * On Windows, Git Bash is located from `git --exec-path`
 * (<git-root>/mingw64/libexec/git-core → <git-root>/bin/bash.exe).
 * Elsewhere, `bash` from PATH is used.
 */

import { spawnSync, execFileSync } from "node:child_process";
import { existsSync } from "node:fs";
import path from "node:path";
import process from "node:process";

function findBash() {
  if (process.platform !== "win32") return "bash";
  try {
    const execPath = execFileSync("git", ["--exec-path"], { encoding: "utf8" }).trim();
    const gitRoot = path.resolve(execPath, "..", "..", "..");
    for (const candidate of [path.join(gitRoot, "bin", "bash.exe"), path.join(gitRoot, "usr", "bin", "bash.exe")]) {
      if (existsSync(candidate)) return candidate;
    }
  } catch { /* fall through */ }
  console.error("Git Bash not found. Install Git for Windows (https://git-scm.com/download/win)");
  console.error("and make sure `git` is on PATH — deck-kit's gate scripts need its bash.");
  process.exit(2);
}

const [script, ...args] = process.argv.slice(2);
if (!script) {
  console.error("usage: run-bash.mjs <script.sh> [args…]");
  process.exit(2);
}
const result = spawnSync(findBash(), [script, ...args], { stdio: "inherit" });
if (result.error) {
  console.error(result.error.message);
  process.exit(2);
}
process.exit(result.status ?? 1);
