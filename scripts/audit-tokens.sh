#!/usr/bin/env bash
# audit-tokens.sh <deck-dir>
# Gate 2: design-token integrity.
# Fails on hardcoded hex colours outside the allow-list, font-family
# declarations outside :root, and !important in slide styles.

set -euo pipefail

DECK="${1:-}"
if [[ -z "$DECK" || ! -d "$DECK" ]]; then
  echo "usage: audit-tokens.sh <deck-dir>" >&2
  exit 2
fi

cd "$DECK"

fail_count=0
fail() { echo "✗ $1"; fail_count=$((fail_count + 1)); }

# Allow-list of hex literals permitted in slide HTML.
#
# Every palette colour is a token in shared.css :root, so slides (inline SVG
# included — use style="fill: var(--token)") reference var(--...) only.
# The one exception is the macOS traffic-light dots on terminal titlebars:
# a fixed convention, not part of any theme.
ALLOWED='#ff5f56|#ffbd2e|#27c93f'

# ----- 1. Hardcoded hex colours outside allow-list -----
for f in *.html; do
  [[ -e "$f" ]] || continue
  # Grep every 3 or 6-char hex token, strip allowed ones, anything left fails.
  # Skip files that are auto-generated (index.html uses hex literals inline
  # for kind tiles — all are palette members, allow).
  offending=$(grep -oE '#[0-9a-fA-F]{3,6}\b' "$f" \
    | awk -v allow="$ALLOWED" 'BEGIN{n=split(allow,A,"|"); for(i=1;i<=n;i++)OK[tolower(A[i])]=1}
                              {h=tolower($0); if (!OK[h]) print h}' \
    | sort -u || true)
  if [[ -n "$offending" ]]; then
    while IFS= read -r hex; do
      fail "$f: hardcoded hex $hex (use var(--token); add a token to :root in shared.css if none fits)"
    done <<< "$offending"
  fi
done

# ----- 1b. Raw colour functions -----
# Translucent palette colours are written as
# color-mix(in srgb, var(--token) N%, transparent), so a theme swap reaches
# them. rgb()/rgba()/hsl()/hsla() literals bypass the tokens.
for f in *.html; do
  [[ -e "$f" ]] || continue
  # Require a digit inside the parens so prose like "rgba()" is not flagged.
  offending=$(grep -noE '\b(rgba?|hsla?)\([^)]*[0-9][^)]*\)' "$f" || true)
  if [[ -n "$offending" ]]; then
    while IFS= read -r hit; do
      fail "$f: raw colour function → $hit (use color-mix(in srgb, var(--token) N%, transparent))"
    done <<< "$offending"
  fi
done

# ----- 2. font-family declarations outside shared.css / phase-shared.css / demo-shared.css -----
# Slide-level <style> blocks should only use var(--font-sans|mono).
# Exception: Georgia, serif — used for decorative giant quote marks and ◆ diamonds.
# Exception: monospace / Menlo / "SF Mono" inline in SVG <text> font-family= (SVG
# text elements inherit CSS vars poorly across browsers).
for f in *.html; do
  [[ -e "$f" ]] || continue
  # Look for font-family: that does NOT use var(--font- and not on the allow-list.
  offending=$(grep -nE 'font-family:\s*[^v]' "$f" \
    | grep -v 'var(--font-' \
    | grep -vE 'Georgia' \
    | grep -vE 'font-family="(monospace|Menlo|SF Mono|Georgia)' \
    || true)
  if [[ -n "$offending" ]]; then
    while IFS= read -r line; do
      fail "$f: raw font-family (use var(--font-sans|mono)) → $line"
    done <<< "$offending"
  fi
done

# ----- 3. !important inside slide <style> blocks -----
# (shared.css uses !important in the prefers-reduced-motion block — that's allowed.)
for f in *.html; do
  [[ -e "$f" ]] || continue
  if grep -q '!important' "$f"; then
    fail "$f: !important detected in slide <style> (specificity should come naturally)"
  fi
done

if [[ "$fail_count" -gt 0 ]]; then
  echo ""
  echo "Gate 2 (tokens): FAIL — $fail_count issue(s)"
  exit 1
fi

echo "Gate 2 (tokens): PASS"
