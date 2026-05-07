#!/usr/bin/env bash
# Fail if:
#   1. Any bundled skill under skills/tack-bootstrap/template/skills/<name>/
#      differs from canonical skills/<name>/.
#   2. Any committed editor mirror (.claude/.cursor/.agents/skills/<name>/)
#      differs from its canonical skills/<name>/.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

shopt -s nullglob

# Phase A — bundled dispatcher skills inside tack-bootstrap (B-26).
bundled_checked=()
for BUNDLED_SKILL_MD in skills/tack-bootstrap/template/skills/*/SKILL.md; do
  BUNDLED_DIR="$(dirname "$BUNDLED_SKILL_MD")"
  NAME="$(basename "$BUNDLED_DIR")"
  SRC="skills/$NAME"
  if [[ ! -d "$SRC" ]] || [[ ! -f "$SRC/SKILL.md" ]]; then
    echo "check-skills-sync: bundled skill $BUNDLED_DIR has no canonical $SRC/SKILL.md" >&2
    exit 1
  fi
  if ! diff -rq "$SRC" "$BUNDLED_DIR" >/dev/null 2>&1; then
    echo "check-skills-sync: bundled drift detected for $BUNDLED_DIR" >&2
    diff -ru "$SRC" "$BUNDLED_DIR" >&2 || true
    echo "check-skills-sync: run from repo root: npm run sync" >&2
    exit 1
  fi
  bundled_checked+=("$NAME")
done

# Phase B — canonical skills/*/ vs each editor mirror (B-25).
mirror_checked=()
for SRC_SKILL_MD in skills/*/SKILL.md; do
  SRC="$(dirname "$SRC_SKILL_MD")"
  NAME="$(basename "$SRC")"
  for DEST in ".claude/skills/$NAME" ".cursor/skills/$NAME" ".agents/skills/$NAME"; do
    if [[ ! -d "$DEST" ]]; then
      echo "check-skills-sync: missing directory $DEST — run: npm run sync" >&2
      exit 1
    fi
    if ! diff -rq "$SRC" "$DEST" >/dev/null 2>&1; then
      echo "check-skills-sync: drift detected for $DEST" >&2
      diff -ru "$SRC" "$DEST" >&2 || true
      echo "check-skills-sync: run from repo root: npm run sync" >&2
      exit 1
    fi
  done
  mirror_checked+=("$NAME")
done

if [[ ${#bundled_checked[@]} -gt 0 ]]; then
  echo "check-skills-sync: bundled OK in skills/tack-bootstrap/template/skills/: ${bundled_checked[*]}"
fi
if [[ ${#mirror_checked[@]} -gt 0 ]]; then
  echo "check-skills-sync: editor mirrors OK for: ${mirror_checked[*]}"
fi
