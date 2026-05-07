#!/usr/bin/env bash
# Copy canonical skill at skills/sdd-bootstrap/ into per-editor mirror directories.
# Run from repository root after editing the canonical skill only.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SRC="skills/sdd-bootstrap"
if [[ ! -d "$SRC" ]] || [[ ! -f "$SRC/SKILL.md" ]]; then
  echo "sync-skills: missing $SRC/SKILL.md (run from repo root)" >&2
  exit 1
fi

for DEST in .claude/skills/sdd-bootstrap .cursor/skills/sdd-bootstrap .agents/skills/sdd-bootstrap; do
  mkdir -p "$(dirname "$DEST")"
  rm -rf "$DEST"
  cp -R "$SRC" "$DEST"
done

echo "sync-skills: mirrored $SRC -> .claude/skills/sdd-bootstrap, .cursor/skills/sdd-bootstrap, .agents/skills/sdd-bootstrap"
