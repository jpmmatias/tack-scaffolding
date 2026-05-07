#!/usr/bin/env bash
# Shared helpers for Theme 2 Bats tests (sourced by *.bats).

# shellcheck disable=SC2030,SC2031
# Bats runs each test in subshells; exported REPO_ROOT / script paths are intentional.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export REPO_ROOT

export DETECT_STACK="$REPO_ROOT/skills/tack-bootstrap/scripts/detect-stack.sh"
export RECON_SH="$REPO_ROOT/skills/tack-bootstrap/scripts/recon.sh"
export TACK_WORKTREE="$REPO_ROOT/skills/tack-bootstrap/template/scripts/tack-worktree.sh"
export CHECK_DISPATCH_CONTRACT="$REPO_ROOT/scripts/check-dispatch-contract.sh"

# Create an isolated git repo; sets TMP_REPO and cds into it.
setup_tmp_git_repo() {
  TMP_REPO="$(mktemp -d "${BATS_TEST_TMPDIR:-/tmp}/tack-test-XXXXXX")"
  export TMP_REPO
  cd "$TMP_REPO" || exit 1
  git init -q
  git config user.email "bats@example.com"
  git config user.name "Bats Test"
  # Prefer main as default branch name (matches tack-worktree detect_base_branch).
  git checkout -q -b main 2>/dev/null || true
  printf 'initial\n' >README.md
  git add README.md
  git commit -q -m "init"
}

teardown_tmp_repo() {
  cd "$REPO_ROOT" || true
  if [[ -n "${TMP_REPO:-}" && -d "$TMP_REPO" ]]; then
    rm -rf "$TMP_REPO"
  fi
  unset TMP_REPO
}

# Read a top-level JSON string or null from stdin; prints raw string or empty for null.
json_field() {
  local key="$1"
  local json="${2-}"
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$json" | jq -r --arg k "$key" '.[$k] | if . == null then "" else tostring end'
  else
    python3 -c 'import json,sys; k=sys.argv[1]; d=json.loads(sys.argv[2]); v=d.get(k); print("" if v is None else str(v))' "$key" "$json"
  fi
}

# Assert JSON field equals expected string (empty means null or "").
assert_json_field_eq() {
  local key="$1"
  local expected="$2"
  local json="$3"
  local got
  got="$(json_field "$key" "$json")"
  if [[ "$got" != "$expected" ]]; then
    echo "json .$key: expected $(printf '%q' "$expected") got $(printf '%q' "$got")" >&2
    echo "json was: $json" >&2
    return 1
  fi
}
