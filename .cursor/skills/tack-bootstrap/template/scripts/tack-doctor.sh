#!/usr/bin/env bash
# tack-doctor.sh — post-bootstrap validations for a Tack consumer repo.
# Run from the repository root. Currently checks:
#   1. .cursorrules contains no <UPPERCASE_PLACEHOLDER> tokens left over from
#      .cursorrules.template (matches `<[A-Z][A-Z0-9_]*>`).
#   2. project/prompts/auto-orchestrator.md Specialist routing table contains
#      no `<fill>` rows.
#   3. When tack.routing.auto is not explicitly "no", project/docs/tack-pipeline-models.md
#      exists and YAML front matter lists every required pipeline key.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tack-doctor.sh [--rules PATH] [--orchestrator PATH] [--models PATH] [--quiet]

Validates a bootstrapped Tack repo:
  1. <UPPERCASE_PLACEHOLDER> tokens removed from .cursorrules.
  2. `<fill>` rows removed from project/prompts/auto-orchestrator.md
     Specialist routing table.
  3. project/docs/tack-pipeline-models.md (or --models) is complete when
     tack.routing.auto is not explicitly `no` in .cursorrules.

Defaults:
  --rules         .cursorrules
  --orchestrator  project/prompts/auto-orchestrator.md
  --models        project/docs/tack-pipeline-models.md

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
MODELS="project/docs/tack-pipeline-models.md"
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
    --models)
      [[ $# -ge 2 ]] || { echo "tack-doctor: --models needs a value" >&2; exit 2; }
      MODELS="$2"; shift 2
      ;;
    --models=*) MODELS="${1#--models=}"; shift ;;
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
    printf '  %s\n' "${matches//$'\n'/$'\n  '}" >&2
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
    printf '  %s\n' "${matches//$'\n'/$'\n  '}" >&2
  else
    note "$ORCH Specialist routing OK"
  fi
fi

routing_no=0
if [[ -f "$RULES" ]] && grep -qE 'tack\.routing\.auto:[[:space:]]*no' "$RULES"; then
  routing_no=1
fi

if [[ "$routing_no" -eq 1 ]]; then
  note "skip $MODELS (tack.routing.auto = no)"
else
  if [[ ! -f "$MODELS" ]]; then
    fail "missing $MODELS (bootstrap Phase 1b / Phase 5 step 1b; required when tack.routing.auto is not no)"
  else
    fm="$(awk '/^---$/ { c++; if (c == 2) exit; next } c == 1 { print }' "$MODELS")"
    missing=0
    for key in worktree_coordinator product_manager architect qa_tester harness_engineer worker reviewer security_engineer; do
      if ! printf '%s\n' "$fm" | grep -qE "^${key}:"; then
        fail "$MODELS YAML front matter missing key: ${key}"
        missing=1
      fi
    done
    if [[ "$missing" -eq 0 ]]; then
      note "$MODELS pipeline keys OK"
    fi
  fi
fi

if [[ "$errors" -gt 0 ]]; then
  echo "tack-doctor: $errors check(s) failed" >&2
  exit 1
fi
note "all checks passed"
