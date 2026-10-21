#!/usr/bin/env bash
# new-skeleton.sh [--type=workshop|lecture|talk] [--theme=<name>] <target-dir>
#
# Scaffold an empty presentation deck directory by copying assets/* from the
# skill install into <target-dir>. Leaves SLIDES empty so the skill can
# populate incrementally per-slide.
#
# --type flag routes which assets get copied:
#   workshop (default) — full set: shared.css/js, phase-shared.css,
#                        demo-runner.js, demo-shared.css, index.html
#   lecture            — shared.css/js, phase-shared.css, index.html
#                        (no demo-runner by default; can be added later if a
#                         terminal-demo slide is requested)
#   talk               — shared.css/js, index.html
#                        (no phase or demo assets)
#
# --theme picks assets/themes/<name>.css, copied to <target-dir>/theme.css
# (shared.css @imports it). Default: cyberpunk.
#
# Idempotent: running again on the same dir refreshes shared files but
# does not clobber existing slide files, index.html, or theme.css — an
# existing theme.css is replaced only when --theme is passed explicitly.

set -euo pipefail

TYPE="workshop"
THEME=""
TARGET=""

for arg in "$@"; do
  case "$arg" in
    --type=*)
      TYPE="${arg#*=}"
      ;;
    --type)
      echo "error: --type requires value, e.g. --type=workshop" >&2
      exit 2
      ;;
    --theme=*)
      THEME="${arg#*=}"
      ;;
    --theme)
      echo "error: --theme requires value, e.g. --theme=cyberpunk" >&2
      exit 2
      ;;
    -*)
      echo "error: unknown flag: $arg" >&2
      exit 2
      ;;
    *)
      if [[ -z "$TARGET" ]]; then
        TARGET="$arg"
      else
        echo "error: unexpected extra argument: $arg" >&2
        exit 2
      fi
      ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  echo "usage: new-skeleton.sh [--type=workshop|lecture|talk] [--theme=<name>] <target-dir>" >&2
  exit 2
fi

case "$TYPE" in
  workshop|lecture|talk) ;;
  *)
    echo "error: invalid --type=$TYPE (must be workshop|lecture|talk)" >&2
    exit 2
    ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
ASSETS="$SKILL_DIR/assets"

if [[ ! -d "$ASSETS" ]]; then
  echo "error: assets dir not found at $ASSETS" >&2
  exit 1
fi

if [[ -n "$THEME" && ! -f "$ASSETS/themes/$THEME.css" ]]; then
  available=$(cd "$ASSETS/themes" && ls *.css | sed 's/\.css$//' | paste -sd '|' -)
  echo "error: unknown --theme=$THEME (available: $available)" >&2
  exit 2
fi

mkdir -p "$TARGET"
mkdir -p "$TARGET/.planning"
mkdir -p "$TARGET/.audit/screenshots"

# Always-copied core assets.
cp "$ASSETS/shared.css" "$TARGET/shared.css"
cp "$ASSETS/shared.js"  "$TARGET/shared.js"

# Theme: explicit --theme always wins; otherwise keep an existing theme.css
# (it may be hand-tuned) and seed the default only when none exists.
if [[ -n "$THEME" ]]; then
  cp "$ASSETS/themes/$THEME.css" "$TARGET/theme.css"
elif [[ ! -f "$TARGET/theme.css" ]]; then
  THEME="cyberpunk"
  cp "$ASSETS/themes/$THEME.css" "$TARGET/theme.css"
fi

# Type-specific asset subsets.
case "$TYPE" in
  workshop)
    cp "$ASSETS/demo-runner.js"   "$TARGET/demo-runner.js"
    cp "$ASSETS/demo-shared.css"  "$TARGET/demo-shared.css"
    cp "$ASSETS/phase-shared.css" "$TARGET/phase-shared.css"
    ;;
  lecture)
    cp "$ASSETS/phase-shared.css" "$TARGET/phase-shared.css"
    # demo assets can be added later with a separate copy if terminal-demo
    # slides are requested mid-deck.
    ;;
  talk)
    # Minimal — no phase or demo assets.
    ;;
esac

# Only write index.html template if missing (don't clobber a populated one).
if [[ ! -f "$TARGET/index.html" ]]; then
  cp "$ASSETS/index.html" "$TARGET/index.html"
fi

# Seed deck-spec marker so the skill knows this is a deck-kit deck.
# Format contract: skills/_shared/deck-spec-format.md
if [[ ! -f "$TARGET/.planning/deck-spec.md" ]]; then
  cat > "$TARGET/.planning/deck-spec.md" <<EOF
# Deck Spec

<!-- Populated by the deck-kit plan skill during scoping.
     Format contract: _shared/deck-spec-format.md -->

- deck_type: $TYPE
- title:
- speaker:
- date:
- venue:
- source:
- sections:
- archetypes:
- terminal_demos:
- presenter_scale:
- output_dir:
- language:
- theme: ${THEME:-custom}
- marker_map:

## Slide plan

<!-- One line per slide: "NN. <archetype> · <title> · <message> · <source>" -->

EOF
fi

echo "scaffold ok (type=$TYPE, theme=${THEME:-kept existing theme.css}): $TARGET"
ls -1 "$TARGET"
