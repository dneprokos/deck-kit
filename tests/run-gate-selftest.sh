#!/usr/bin/env bash
# run-gate-selftest.sh — proves the 4 validation gates work and stay independent.
#
# A. Positive: examples/workshop-example passes all 4 gates.
# B. Negative per gate: each tests/fixtures/broken-* deck fails EXACTLY its
#    own gate while every earlier gate passes — gates are independent.
# C. Playwright resolution: audit-visual.mjs copied outside the repo
#    (simulating the Claude Code plugin cache, which has no node_modules)
#    exits 2 from a bare cwd, and passes when cwd is a project that has
#    playwright installed (the createRequire(cwd) fallback).
#
# Prereqs: npm install && npx playwright install chromium (repo root).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

PASS=0
FAIL=0
ok()   { echo "  ✓ $1"; PASS=$((PASS + 1)); }
bad()  { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }

# Register slide files in a scaffolded shared.js SLIDES array.
register_slides() { # <deck-dir> <file1> [file2 …]
  local deck="$1"; shift
  python3 - "$deck/shared.js" "$@" <<'PY'
import re, sys
path, files = sys.argv[1], sys.argv[2:]
text = open(path).read()
entries = "\n".join(f'    {{ file: "{f}", title: "{f}" }},' for f in files)
text = re.sub(r"var SLIDES = \[.*?\];", f"var SLIDES = [\n{entries}\n  ];", text, count=1, flags=re.S)
open(path, "w").write(text)
PY
}

# Build a broken deck: scaffold + overlay one fixture slide + register it.
make_fixture_deck() { # <fixture-name>
  local name="$1" deck="$TMP/$1"
  bash "$ROOT/scripts/new-skeleton.sh" --type=talk "$deck" >/dev/null
  cp "$ROOT/tests/fixtures/$name"/*.html "$deck/"
  register_slides "$deck" $(cd "$ROOT/tests/fixtures/$name" && ls *.html)
  echo "$deck"
}

run_gate() { # <gate-number> <deck-dir>  → echoes exit code
  local gate="$1" deck="$2" rc=0
  case "$gate" in
    1) bash "$ROOT/scripts/audit-static.sh" "$deck" >/dev/null 2>&1 || rc=$? ;;
    2) bash "$ROOT/scripts/audit-tokens.sh" "$deck" >/dev/null 2>&1 || rc=$? ;;
    3) bash "$ROOT/scripts/audit-http.sh"   "$deck" >/dev/null 2>&1 || rc=$? ;;
    4) node "$ROOT/scripts/audit-visual.mjs" "$deck" >/dev/null 2>&1 || rc=$? ;;
  esac
  echo "$rc"
}

echo "== A · positive: examples/workshop-example passes 4/4 =="
EXAMPLE="$ROOT/examples/workshop-example"
if [[ ! -d "$EXAMPLE" ]]; then
  bad "examples/workshop-example missing"
else
  for g in 1 2 3 4; do
    rc="$(run_gate "$g" "$EXAMPLE")"
    if [[ "$rc" == "0" ]]; then ok "gate $g passes on workshop-example"
    else bad "gate $g exited $rc on workshop-example (expected 0)"; fi
  done
fi

echo "== B · negative: each fixture fails exactly its own gate =="
declare -a NAMES=(broken-static broken-tokens broken-visual)
declare -a GATES=(1 2 4)
for i in 0 1 2; do
  name="${NAMES[$i]}"; target="${GATES[$i]}"
  deck="$(make_fixture_deck "$name")"
  for (( g=1; g<target; g++ )); do
    rc="$(run_gate "$g" "$deck")"
    if [[ "$rc" == "0" ]]; then ok "$name: earlier gate $g passes"
    else bad "$name: earlier gate $g exited $rc (expected 0)"; fi
  done
  rc="$(run_gate "$target" "$deck")"
  if [[ "$rc" == "1" ]]; then ok "$name: gate $target fails as designed"
  else bad "$name: gate $target exited $rc (expected 1)"; fi
done

echo "== C · playwright resolution from a plugin-cache-like location =="
CACHE_SIM="$TMP/cache-sim"
mkdir -p "$CACHE_SIM" "$TMP/bare-cwd"
cp "$ROOT/scripts/audit-visual.mjs" "$CACHE_SIM/"
CLEAN_DECK="$TMP/clean-deck"
bash "$ROOT/scripts/new-skeleton.sh" --type=talk "$CLEAN_DECK" >/dev/null

rc=0
( cd "$TMP/bare-cwd" && node "$CACHE_SIM/audit-visual.mjs" "$CLEAN_DECK" >/dev/null 2>&1 ) || rc=$?
if [[ "$rc" == "2" ]]; then ok "no playwright anywhere → exit 2 with install instructions"
else bad "expected exit 2 without playwright, got $rc"; fi

rc=0
( cd "$ROOT" && node "$CACHE_SIM/audit-visual.mjs" "$CLEAN_DECK" >/dev/null 2>&1 ) || rc=$?
if [[ "$rc" == "0" ]]; then ok "playwright resolved from cwd project → gate runs (createRequire fallback)"
else bad "expected exit 0 resolving playwright from cwd, got $rc"; fi

echo ""
echo "self-test: $PASS passed, $FAIL failed"
[[ "$FAIL" -eq 0 ]] || exit 1
echo "GATE SELF-TEST: PASS"
