#!/usr/bin/env bash
# splice-tack-routing.sh — replace or append the `## Tack routing` H2 section
# in a target file (typically AGENTS.md or CLAUDE.md) using a routing snippet
# (canonical: project/routing-snippet.md, derived from
# skills/tack-bootstrap/template/routing-snippet.md). Idempotent: re-running
# with no input change produces no change.
#
# Replaces from the `## Tack routing` H2 line until the next H1/H2 (`^# ` or
# `^## `) or EOF. Appends the snippet at the end if no such heading exists.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: splice-tack-routing.sh [--check] [--snippet PATH] TARGET_FILE

Splice the `## Tack routing` H2 section from a snippet into TARGET_FILE.
Replaces an existing section in place; appends one at the end if absent.
Idempotent.

Options:
  --snippet PATH   Routing snippet file. Default: <script_dir>/../routing-snippet.md.
  --check          Do not modify TARGET_FILE; exit 1 (diff on stderr) if a write
                   would change it.
  -h, --help       Show this help.

Exit codes:
  0  TARGET_FILE matches snippet (no-op or applied)
  1  TARGET_FILE differs in --check mode, or invalid input
  2  Snippet does not start with `## Tack routing` H2
EOF
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DEFAULT_SNIPPET="$SCRIPT_DIR/../routing-snippet.md"
SNIPPET=""
TARGET=""
CHECK=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --check) CHECK=1; shift ;;
    --snippet)
      [[ $# -ge 2 ]] || { echo "splice-tack-routing: --snippet needs a value" >&2; exit 1; }
      SNIPPET="$2"; shift 2
      ;;
    --snippet=*) SNIPPET="${1#--snippet=}"; shift ;;
    --) shift; break ;;
    -*) echo "splice-tack-routing: unknown option: $1" >&2; usage >&2; exit 1 ;;
    *)
      if [[ -z "$TARGET" ]]; then
        TARGET="$1"
      else
        echo "splice-tack-routing: unexpected argument: $1" >&2
        exit 1
      fi
      shift
      ;;
  esac
done

if [[ -z "$TARGET" && $# -gt 0 ]]; then
  TARGET="$1"
fi

if [[ -z "$TARGET" ]]; then
  usage >&2
  exit 1
fi

[[ -n "$SNIPPET" ]] || SNIPPET="$DEFAULT_SNIPPET"

if [[ ! -f "$SNIPPET" ]]; then
  echo "splice-tack-routing: snippet not found: $SNIPPET" >&2
  exit 1
fi
if [[ ! -f "$TARGET" ]]; then
  echo "splice-tack-routing: target not found: $TARGET" >&2
  exit 1
fi

if ! head -n 1 "$SNIPPET" | grep -q '^## Tack routing[[:space:]]*$'; then
  echo "splice-tack-routing: snippet $SNIPPET must begin with '## Tack routing' H2" >&2
  exit 2
fi

NEW="$(mktemp)"
trap 'rm -f "$NEW"' EXIT

# Probe whether $1 ends with a newline. $(...) strips trailing newlines, so we
# append a marker, capture, then strip the marker — leaving the original final
# byte intact.
ends_with_newline() {
  local file="$1"
  local last
  [[ -s "$file" ]] || return 0
  last="$(tail -c1 "$file"; printf 'x')"
  last="${last%x}"
  [[ "$last" == $'\n' ]]
}

if grep -q '^## Tack routing[[:space:]]*$' "$TARGET"; then
  awk -v snippet_file="$SNIPPET" '
    BEGIN {
      n = 0
      while ((getline line < snippet_file) > 0) snippet[++n] = line
      close(snippet_file)
      while (n > 0 && snippet[n] == "") n--
    }
    /^## Tack routing[[:space:]]*$/ && !inserted {
      for (i = 1; i <= n; i++) print snippet[i]
      replacing = 1
      inserted = 1
      next
    }
    replacing && /^##? / {
      print ""
      replacing = 0
    }
    !replacing { print }
  ' "$TARGET" > "$NEW"
else
  cp "$TARGET" "$NEW"
  if [[ -s "$NEW" ]]; then
    ends_with_newline "$NEW" || printf '\n' >> "$NEW"
    printf '\n' >> "$NEW"
  fi
  cat "$SNIPPET" >> "$NEW"
fi

ends_with_newline "$NEW" || printf '\n' >> "$NEW"

if cmp -s "$TARGET" "$NEW"; then
  echo "splice-tack-routing: $TARGET unchanged"
  exit 0
fi

if [[ "$CHECK" -eq 1 ]]; then
  echo "splice-tack-routing: $TARGET would change. Re-run without --check to apply." >&2
  diff -u "$TARGET" "$NEW" >&2 || true
  exit 1
fi

cp "$NEW" "$TARGET"
echo "splice-tack-routing: $TARGET updated"
