#!/usr/bin/env bash
# audit-static.sh <deck-dir>
# Gate 1: static structure checks.
# Exit 0 pass, 1 fail. Prints offending file + reason on fail.

set -euo pipefail

DECK="${1:-}"
if [[ -z "$DECK" || ! -d "$DECK" ]]; then
  echo "usage: audit-static.sh <deck-dir>" >&2
  exit 2
fi

cd "$DECK"

fail_count=0
fail() { echo "✗ $1"; fail_count=$((fail_count + 1)); }

# ----- 1. Closing tags on every HTML file -----
for f in *.html; do
  [[ -e "$f" ]] || continue
  if ! grep -q "</body>" "$f"; then fail "$f: missing </body>"; fi
  if ! grep -q "</html>" "$f"; then fail "$f: missing </html>"; fi
done

# ----- 2. shared.css + shared.js in every slide (non-index) -----
for f in [0-9][0-9]-*.html; do
  [[ -e "$f" ]] || continue
  if ! grep -q 'href="shared\.css"' "$f"; then fail "$f: missing shared.css link"; fi
  if ! grep -q 'src="shared\.js"' "$f"; then fail "$f: missing shared.js script"; fi
done

# ----- 2b. theme.css present and imported by shared.css -----
# shared.css defines no colours; without theme.css every token is unset.
if [[ ! -f theme.css ]]; then
  fail "theme.css missing (scaffold with new-skeleton.sh --theme=<name>)"
fi
if [[ -f shared.css ]] && ! grep -qE '@import url\("theme\.css"\)' shared.css; then
  fail "shared.css: missing @import url(\"theme.css\")"
fi

# ----- 3. index.html must NOT use defer on shared.js (gotcha) -----
if [[ -f index.html ]]; then
  if grep -E 'src="shared\.js"[^>]*\bdefer\b' index.html >/dev/null 2>&1; then
    fail "index.html: shared.js has 'defer' — inline script will see undefined WORKSHOP_SLIDES"
  fi
  if ! grep -q 'src="shared\.js"' index.html; then
    fail "index.html: missing shared.js script tag"
  fi
fi

# ----- 4. SLIDES array length == slide file count -----
if [[ -f shared.js ]]; then
  # Count files — pipefail makes `ls ... | wc -l` fail when no match, add `|| true`.
  slide_count=$( (ls [0-9][0-9]-*.html 2>/dev/null || true) | wc -l | tr -d ' ')
  array_count=$(grep -cE '^\s*\{\s*file:\s*"[0-9]{2}-' shared.js 2>/dev/null || true)
  # Normalise to plain integers (guard against empty strings).
  slide_count=${slide_count:-0}
  array_count=${array_count:-0}
  if [[ "${slide_count}" != "${array_count}" ]]; then
    fail "SLIDES count mismatch: ${array_count} entries in shared.js vs ${slide_count} files on disk"
  fi

  # ----- 5. Each filename referenced in SLIDES exists -----
  # Strip commented-out lines first (template may carry // { file: "..." } examples).
  while IFS= read -r fname; do
    [[ -z "${fname}" ]] && continue
    if [[ ! -f "${fname}" ]]; then
      fail "SLIDES references non-existent file: ${fname}"
    fi
  done < <(grep -v '^\s*//' shared.js | grep -oE 'file:\s*"[0-9]{2}-[^"]+\.html"' 2>/dev/null | sed -E 's/.*"([^"]+)"/\1/' || true)
fi

if [[ "${fail_count}" -gt 0 ]]; then
  echo ""
  echo "Gate 1 (static): FAIL - ${fail_count} issue(s)"
  exit 1
fi

echo "Gate 1 (static): PASS"
