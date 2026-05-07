#!/usr/bin/env bash
# Fail if committed editor mirrors differ from skills/sdd-bootstrap/ (canonical).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

SRC="skills/sdd-bootstrap"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

for DEST in .claude/skills/sdd-bootstrap .cursor/skills/sdd-bootstrap .agents/skills/sdd-bootstrap; do
  if [[ ! -d "$DEST" ]]; then
    echo "check-skills-sync: missing directory $DEST — run: npm run sync" >&2
    exit 1
  fi
  mkdir -p "$TMP/expected/$(dirname "$DEST")"
  cp -R "$SRC" "$TMP/expected/$DEST"
  if ! diff -rq "$TMP/expected/$DEST" "$DEST" >/dev/null 2>&1; then
    echo "check-skills-sync: drift detected for $DEST" >&2
    diff -ru "$TMP/expected/$DEST" "$DEST" >&2 || true
    echo "check-skills-sync: run from repo root: npm run sync" >&2
    exit 1
  fi
done

echo "check-skills-sync: mirrors match $SRC"
