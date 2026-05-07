#!/usr/bin/env bash
# Sync canonical skills under skills/*/ into:
#   1. Bundled bootstrap install source (skills/tack-bootstrap/template/skills/<name>/)
#      for each <name> already present there (today: tack-run, tack-agent).
#   2. Per-editor mirrors (.claude/skills/<name>/, .cursor/skills/<name>/,
#      .agents/skills/<name>/) for every canonical skills/<name>/SKILL.md.
# Run from repository root after editing the canonical skill only.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

shopt -s nullglob

# Phase A — bundled dispatcher skills inside tack-bootstrap (B-26).
# Auto-discover any subdir of skills/tack-bootstrap/template/skills/ that has a
# SKILL.md, and require a matching canonical skills/<name>/.
bundled_synced=()
for BUNDLED_SKILL_MD in skills/tack-bootstrap/template/skills/*/SKILL.md; do
  BUNDLED_DIR="$(dirname "$BUNDLED_SKILL_MD")"
  NAME="$(basename "$BUNDLED_DIR")"
  SRC="skills/$NAME"
  if [[ ! -f "$SRC/SKILL.md" ]]; then
    echo "sync-skills: bundled skill $BUNDLED_DIR has no canonical $SRC/SKILL.md" >&2
    exit 1
  fi
  rm -rf "$BUNDLED_DIR"
  cp -R "$SRC" "$BUNDLED_DIR"
  bundled_synced+=("$NAME")
done

# Phase B — canonical skills/*/ → editor mirrors (B-25).
mirror_synced=()
for SRC_SKILL_MD in skills/*/SKILL.md; do
  SRC="$(dirname "$SRC_SKILL_MD")"
  NAME="$(basename "$SRC")"
  for DEST in ".claude/skills/$NAME" ".cursor/skills/$NAME" ".agents/skills/$NAME"; do
    mkdir -p "$(dirname "$DEST")"
    rm -rf "$DEST"
    cp -R "$SRC" "$DEST"
  done
  mirror_synced+=("$NAME")
done

if [[ ${#bundled_synced[@]} -gt 0 ]]; then
  echo "sync-skills: bundled into skills/tack-bootstrap/template/skills/: ${bundled_synced[*]}"
fi
if [[ ${#mirror_synced[@]} -gt 0 ]]; then
  echo "sync-skills: mirrored canonical skills/* into .claude/skills/, .cursor/skills/, .agents/skills/: ${mirror_synced[*]}"
fi
