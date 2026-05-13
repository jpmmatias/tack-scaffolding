#!/usr/bin/env bash
# Check that any Markdown file under skills/ using Cursor-specific tool names
# also carries either:
#   (a) the platform-tool-mapping marker block (BEGIN/END comments), or
#   (b) an explicit "Platform tool mapping" reference pointing to a file that
#       has the block (e.g. a SKILL.md or auto-orchestrator.md).
#
# Without one of those, a Claude Code / SDK / Copilot / Codex / Antigravity
# reader has no anchor to translate `Task`, `AskQuestion`, `working_directory`,
# or `generalPurpose` into their host's primitive. This lint catches the
# drift before it ships into a consumer repo.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Cursor-canonical tool names tracked by this lint. Each appears verbatim in
# Cursor's tool surface and has a different name on at least one other host.
#
# `Task` is a common English word, so we only flag the backtick-wrapped form
# (`` `Task` ``) which is the project's convention when referring to the tool.
# The other three (`AskQuestion`, `working_directory`, `generalPurpose`) are
# typographically unique (camelCase / underscore) so we match the bare word.
CURSOR_TERM_BARE='AskQuestion|working_directory|generalPurpose'
# shellcheck disable=SC2016  # backticks here are literal markdown, not command substitution
CURSOR_TERM_TASK='`Task`'

# The shared file is itself the mapping — it can't reference itself.
EXEMPT_FILES=(
  'skills/_shared/platform-tool-mapping.md'
)

is_exempt() {
  local file="$1"
  for exempt in "${EXEMPT_FILES[@]}"; do
    [[ "$file" == "$exempt" ]] && return 0
  done
  return 1
}

mapfile -t TARGETS < <(git ls-files 'skills/' | grep -E '\.md$' || true)

violations=0
for FILE in "${TARGETS[@]}"; do
  if is_exempt "$FILE"; then
    continue
  fi
  if ! grep -qE "\\b($CURSOR_TERM_BARE)\\b" "$FILE" \
     && ! grep -qF "$CURSOR_TERM_TASK" "$FILE"; then
    continue
  fi
  if grep -q '<!-- BEGIN: shared/platform-tool-mapping' "$FILE"; then
    continue
  fi
  if grep -q 'Platform tool mapping' "$FILE"; then
    continue
  fi
  echo "check-platform-terms: $FILE uses Cursor-specific tool names without a Platform tool mapping anchor:" >&2
  {
    grep -nE "\\b($CURSOR_TERM_BARE)\\b" "$FILE" || true
    grep -nF "$CURSOR_TERM_TASK" "$FILE" || true
  } | sort -t: -k1n -u | head -10 >&2
  echo "" >&2
  violations=$((violations + 1))
done

if (( violations > 0 )); then
  cat >&2 <<'MSG'
check-platform-terms: failed.

A file under skills/ uses Cursor-specific tool names (`Task`, `AskQuestion`,
`working_directory`, or `generalPurpose`) without an anchor that tells a
non-Cursor host how to translate them. Fix by either:

  (a) Add `<!-- BEGIN: shared/platform-tool-mapping ... -->` / `<!-- END -->`
      markers and run `npm run sync` to splice the canonical mapping in, or

  (b) Add a short prose reference like
      "see **Platform tool mapping** in `tack-run/SKILL.md`"
      pointing readers to the table.
MSG
  exit 1
fi

echo "check-platform-terms: scanned ${#TARGETS[@]} markdown file(s) under skills/, all OK."
