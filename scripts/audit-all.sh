#!/usr/bin/env bash
# audit-all.sh <deck-dir>
# Runs all 4 validation gates in strict order, stopping on the first
# failure. Exit code: 0 all green, 1 a gate failed, 2 environment issue
# (bad usage, or Gate 4 without playwright).

set -euo pipefail

DECK="${1:-}"
if [[ -z "$DECK" || ! -d "$DECK" ]]; then
  echo "usage: audit-all.sh <deck-dir>" >&2
  exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "═══ Gate 1 · static ═══"
bash "$SCRIPT_DIR/audit-static.sh" "$DECK"

echo ""
echo "═══ Gate 2 · tokens ═══"
bash "$SCRIPT_DIR/audit-tokens.sh" "$DECK"

echo ""
echo "═══ Gate 3 · http ═══"
bash "$SCRIPT_DIR/audit-http.sh" "$DECK"

echo ""
echo "═══ Gate 4 · visual ═══"
node "$SCRIPT_DIR/audit-visual.mjs" "$DECK"

echo ""
echo "All 4 gates: PASS"
