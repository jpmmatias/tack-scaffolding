#!/usr/bin/env bash
# Sync canonical skills under skills/*/ into:
#   0. (Phase 0) splice shared blocks from skills/_shared/*.md into canonical
#      SKILL.md files between BEGIN/END markers so each block has one source
#      of truth.
#   A. Bundled bootstrap install source (skills/tack-bootstrap/template/skills/<name>/)
#      for each <name> already present there (today: tack-run, tack-agent).
#   B. Per-editor mirrors (.claude/skills/<name>/, .cursor/skills/<name>/,
#      .agents/skills/<name>/) for every canonical skills/<name>/SKILL.md.
# Run from repository root after editing the canonical skill or a _shared file.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

shopt -s nullglob

# Phase 0 — splice shared blocks into canonical SKILL.md files.
# Marker pattern in each consuming SKILL.md:
#   <!-- BEGIN: shared/<name> ... -->
#   <!-- END: shared/<name> -->
# Anything between the markers is replaced by the shared file contents.
SHARED_MAPPING="skills/_shared/platform-tool-mapping.md"
shared_spliced=0
if [[ -f "$SHARED_MAPPING" ]]; then
  for SKILL_MD in skills/*/SKILL.md; do
    if grep -q '<!-- BEGIN: shared/platform-tool-mapping' "$SKILL_MD"; then
      awk -v shared_file="$SHARED_MAPPING" '
        BEGIN {
          while ((getline line < shared_file) > 0) {
            shared = (shared == "" ? line : shared "\n" line)
          }
          close(shared_file)
        }
        /<!-- BEGIN: shared\/platform-tool-mapping/ { print; print shared; in_block=1; next }
        /<!-- END: shared\/platform-tool-mapping/   { in_block=0; print; next }
        !in_block                                   { print }
      ' "$SKILL_MD" > "$SKILL_MD.tmp"
      mv "$SKILL_MD.tmp" "$SKILL_MD"
      shared_spliced=$((shared_spliced + 1))
    fi
  done
fi
if (( shared_spliced > 0 )); then
  echo "sync-skills: spliced skills/_shared/platform-tool-mapping.md into $shared_spliced canonical SKILL.md file(s)"
fi

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
