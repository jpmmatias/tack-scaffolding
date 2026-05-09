#!/usr/bin/env bash
# tack-doctor.sh — post-bootstrap validations for a Tack consumer repo.
# Run from the repository root. Currently checks:
#   1. .cursorrules contains no <UPPERCASE_PLACEHOLDER> tokens left over from
#      .cursorrules.template (matches `<[A-Z][A-Z0-9_]*>`).
#   2. project/prompts/auto-orchestrator.md Specialist routing table contains
#      no `<fill>` rows.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tack-doctor.sh [--rules PATH] [--orchestrator PATH] [--quiet]

Validates a bootstrapped Tack repo:
  1. <UPPERCASE_PLACEHOLDER> tokens removed from .cursorrules.
  2. `<fill>` rows removed from project/prompts/auto-orchestrator.md
     Specialist routing table.

Defaults:
  --rules         .cursorrules
  --orchestrator  project/prompts/auto-orchestrator.md

Options:
  --quiet         Suppress per-check OK lines on success.
  -h, --help      Show this help.

Exit codes:
  0  All checks pass
  1  One or more checks failed
  2  Invalid invocation
EOF
}

RULES=".cursorrules"
ORCH="project/prompts/auto-orchestrator.md"
QUIET=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --quiet) QUIET=1; shift ;;
    --rules)
      [[ $# -ge 2 ]] || { echo "tack-doctor: --rules needs a value" >&2; exit 2; }
      RULES="$2"; shift 2
      ;;
    --rules=*) RULES="${1#--rules=}"; shift ;;
    --orchestrator)
      [[ $# -ge 2 ]] || { echo "tack-doctor: --orchestrator needs a value" >&2; exit 2; }
      ORCH="$2"; shift 2
      ;;
    --orchestrator=*) ORCH="${1#--orchestrator=}"; shift ;;
    -*) echo "tack-doctor: unknown option: $1" >&2; usage >&2; exit 2 ;;
    *) echo "tack-doctor: unexpected argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

errors=0

note() { [[ "$QUIET" -eq 1 ]] || echo "tack-doctor: $*"; }
fail() { echo "tack-doctor: $*" >&2; errors=$((errors + 1)); }

if [[ ! -f "$RULES" ]]; then
  fail "missing $RULES (run tack-bootstrap or set --rules)"
else
  matches="$(grep -nE '<[A-Z][A-Z0-9_]*>' "$RULES" || true)"
  if [[ -n "$matches" ]]; then
    fail "$RULES still contains uppercase placeholders:"
    echo "$matches" | sed 's/^/  /' >&2
  else
    note "$RULES placeholders OK"
  fi
fi

if [[ ! -f "$ORCH" ]]; then
  fail "missing $ORCH (run tack-bootstrap or set --orchestrator)"
else
  matches="$(grep -nF '<fill>' "$ORCH" || true)"
  if [[ -n "$matches" ]]; then
    fail "$ORCH still contains <fill> rows in Specialist routing table:"
    echo "$matches" | sed 's/^/  /' >&2
  else
    note "$ORCH Specialist routing OK"
  fi
fi

if [[ "$errors" -gt 0 ]]; then
  echo "tack-doctor: $errors check(s) failed" >&2
  exit 1
fi
note "all checks passed"
