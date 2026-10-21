#!/usr/bin/env bash
# audit-http.sh <deck-dir>
# Gate 3: HTTP smoke. Boots serve.mjs (Node static server, OS-assigned
# port on 127.0.0.1), curls index + 5 random slides + shared files, expects
# HTTP 200 everywhere. Kills the server on exit.

set -euo pipefail

DECK="${1:-}"
if [[ -z "$DECK" || ! -d "$DECK" ]]; then
  echo "usage: audit-http.sh <deck-dir>" >&2
  exit 2
fi

# Resolve before cd — BASH_SOURCE may be a relative path.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$DECK"

# serve.mjs prints "listening http://127.0.0.1:<port>" once it is bound.
SERVER_LOG="$(mktemp)"
node "$SCRIPT_DIR/serve.mjs" . 0 > "$SERVER_LOG" 2>&1 &
SERVER_PID=$!
# Ensure cleanup on any exit path.
trap 'kill "${SERVER_PID}" 2>/dev/null || true; wait "${SERVER_PID}" 2>/dev/null || true; rm -f "${SERVER_LOG}"' EXIT

BASE=""
for _ in $(seq 1 100); do
  BASE=$(grep -oE 'http://127\.0\.0\.1:[0-9]+' "$SERVER_LOG" 2>/dev/null || true)
  [[ -n "$BASE" ]] && break
  sleep 0.1
done
if [[ -z "$BASE" ]]; then
  echo "[FAIL] deck server did not start within 10s"
  cat "$SERVER_LOG"
  exit 1
fi
echo "Serving deck at ${BASE}"

# Basic sanity: server is responding.
if ! curl -sf -o /dev/null "${BASE}/"; then
  echo "[FAIL] deck server not reachable at ${BASE}"
  exit 1
fi

fail_count=0
check_url() {
  local path="$1"
  local code
  code=$(curl -s -o /dev/null -w "%{http_code}" "${BASE}${path}" || true)
  if [[ "${code}" != "200" ]]; then
    echo "[FAIL] ${path} -> HTTP ${code}"
    fail_count=$((fail_count + 1))
  else
    echo "[OK] ${path}"
  fi
}

# Always-checked entries.
check_url "/index.html"
check_url "/shared.css"
check_url "/theme.css"
check_url "/shared.js"

# demo-runner.js only if any slide references it.
if grep -lq "demo-runner\.js" [0-9][0-9]-*.html 2>/dev/null; then
  check_url "/demo-runner.js"
  check_url "/demo-shared.css"
fi

# phase-shared.css if any phase slides exist.
if grep -lq 'href="phase-shared\.css"' [0-9][0-9]-*.html 2>/dev/null; then
  check_url "/phase-shared.css"
fi

# 5 random slides (or all slides if there are <=5, or none if empty deck).
slides=()
while IFS= read -r sfile; do
  [[ -z "${sfile}" ]] && continue
  slides+=("${sfile}")
done < <(ls [0-9][0-9]-*.html 2>/dev/null || true)

if [[ "${#slides[@]}" -eq 0 ]]; then
  echo "[info] no slide files yet - skipping slide sampling"
elif [[ "${#slides[@]}" -le 5 ]]; then
  for s in "${slides[@]}"; do
    check_url "/${s}"
  done
else
  # Shuffle and take 5.
  sampled=$(printf '%s\n' "${slides[@]}" | awk 'BEGIN{srand()} {print rand()"\t"$0}' | sort -k1,1n | head -5 | cut -f2)
  while IFS= read -r s; do
    check_url "/${s}"
  done <<< "${sampled}"
fi

if [[ "${fail_count}" -gt 0 ]]; then
  echo ""
  echo "Gate 3 (http): FAIL - ${fail_count} non-200 response(s)"
  exit 1
fi

echo "Gate 3 (http): PASS"
