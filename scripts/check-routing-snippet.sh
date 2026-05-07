#!/usr/bin/env bash
# Fail if ## Tack routing content differs from template/routing-snippet.md anywhere it is duplicated.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

CANON="$ROOT/skills/tack-bootstrap/template/routing-snippet.md"
if [[ ! -f "$CANON" ]]; then
  echo "check-routing-snippet: missing $CANON" >&2
  exit 1
fi

# Extract ## Tack routing … until next H2 (^## ) or EOF (for standalone template files).
# Omit one trailing blank line before the closing H2 so fenced examples match routing-snippet.md (no spacer before following section).
extract_routing_section() {
  local file="$1"
  awk '
    /^## Tack routing[[:space:]]*$/ { s = 1; print; next }
    s && /^## / { exit }
    s && /^$/ { pending_blank = 1; next }
    s {
      if (pending_blank) { print ""; pending_blank = 0 }
      print
      next
    }
  ' "$file"
}

# Extract the ## Tack routing section from the Nth ```markdown … ``` fence (1-based).
extract_routing_from_nth_markdown_fence() {
  local file="$1"
  local want="$2"
  awk -v want="$want" '
    BEGIN { fence = 0 }
    /^```markdown$/ {
      fence++
      infence = (fence == want) ? 1 : 0
      next
    }
    infence && /^```$/ { exit }
    !infence { next }
    /^## Tack routing[[:space:]]*$/ { sec = 1; print; next }
    sec && /^```$/ { exit }
    sec && /^## / { exit }
    sec && /^$/ { pending_blank = 1; next }
    sec {
      if (pending_blank) { print ""; pending_blank = 0 }
      print
      next
    }
  ' "$file"
}

compare_to_canonical() {
  local label="$1"
  shift
  local tmp
  tmp="$(mktemp)"
  "$@" >"$tmp"
  if ! diff -q "$CANON" "$tmp" >/dev/null 2>&1; then
    echo "check-routing-snippet: mismatch — $label" >&2
    diff -u "$CANON" "$tmp" >&2 || true
    rm -f "$tmp"
    return 1
  fi
  rm -f "$tmp"
  return 0
}

err=0
AGENTS_T="$ROOT/skills/tack-bootstrap/template/AGENTS.md.template"
CLAUDE_T="$ROOT/skills/tack-bootstrap/template/CLAUDE.md.template"
AGENTS_R="$ROOT/skills/tack-bootstrap/references/file-templates/agents-routing.md"

for f in "$AGENTS_T" "$CLAUDE_T" "$AGENTS_R"; do
  if [[ ! -f "$f" ]]; then
    echo "check-routing-snippet: missing $f" >&2
    exit 1
  fi
done

compare_to_canonical "$AGENTS_T" extract_routing_section "$AGENTS_T" || err=1
compare_to_canonical "$CLAUDE_T" extract_routing_section "$CLAUDE_T" || err=1
compare_to_canonical "$AGENTS_R (Case A, 1st fenced example)" extract_routing_from_nth_markdown_fence "$AGENTS_R" 1 || err=1
compare_to_canonical "$AGENTS_R (Case B, 3rd fenced example)" extract_routing_from_nth_markdown_fence "$AGENTS_R" 3 || err=1

if [[ "$err" -ne 0 ]]; then
  echo "check-routing-snippet: fix drift or edit only skills/tack-bootstrap/template/routing-snippet.md then sync copies." >&2
  exit 1
fi

echo "check-routing-snippet: OK (routing-snippet.md matches all canonical copies)"
