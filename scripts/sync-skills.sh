#!/usr/bin/env bash
# Copy canonical skill at skills/tack-bootstrap/ into per-editor mirror directories.
# Run from repository root after editing the canonical skill only.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SRC="skills/tack-bootstrap"
if [[ ! -d "$SRC" ]] || [[ ! -f "$SRC/SKILL.md" ]]; then
  echo "sync-skills: missing $SRC/SKILL.md (run from repo root)" >&2
  exit 1
fi

for DEST in .claude/skills/tack-bootstrap .cursor/skills/tack-bootstrap .agents/skills/tack-bootstrap; do
  mkdir -p "$(dirname "$DEST")"
  rm -rf "$DEST"
  cp -R "$SRC" "$DEST"
done

echo "sync-skills: mirrored $SRC -> .claude/skills/tack-bootstrap, .cursor/skills/tack-bootstrap, .agents/skills/tack-bootstrap"
