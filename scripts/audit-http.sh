#!/usr/bin/env bash
# audit-http.sh <deck-dir>
# Gate 3: HTTP smoke. Boots python3 http.server, curls index + 5 random
# slides + shared files, expects HTTP 200 everywhere. Kills the server on
# exit.

set -euo pipefail

DECK="${1:-}"
if [[ -z "$DECK" || ! -d "$DECK" ]]; then
  echo "usage: audit-http.sh <deck-dir>" >&2
  exit 2
fi

cd "$DECK"

# Pick a free port starting at 8765.
PORT=8765
while lsof -i ":$PORT" >/dev/null 2>&1; do
  PORT=$((PORT + 1))
  if [[ "$PORT" -gt 8800 ]]; then
    echo "no free port in 8765-8800 range" >&2
    exit 1
  fi
done

echo "Booting http.server on port ${PORT}..."
python3 -m http.server "${PORT}" >/dev/null 2>&1 &
SERVER_PID=$!
# Ensure cleanup on any exit path.
trap 'kill "${SERVER_PID}" 2>/dev/null || true; wait "${SERVER_PID}" 2>/dev/null || true' EXIT

# Give the server a moment to come up.
sleep 1

# Basic sanity: server is responding.
if ! curl -sfI "http://localhost:${PORT}/" >/dev/null 2>&1; then
  echo "[FAIL] http.server not reachable on :${PORT}"
  exit 1
fi

fail_count=0
check_url() {
  local path="$1"
  local code
  code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${PORT}${path}" || true)
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
