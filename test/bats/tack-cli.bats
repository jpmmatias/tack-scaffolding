#!/usr/bin/env bats
# tack CLI — smoke tests for bin/tack.mjs (doctor, init, specialist add).

load helpers

export TACK_CLI="$REPO_ROOT/bin/tack.mjs"

setup() {
  TMP_DIR="$(mktemp -d "${BATS_TEST_TMPDIR:-/tmp}/tack-cli-XXXXXX")"
  export TMP_DIR
  cd "$TMP_DIR" || exit 1
}

teardown() {
  cd "$REPO_ROOT" || true
  if [[ -n "${TMP_DIR:-}" && -d "$TMP_DIR" ]]; then
    rm -rf "$TMP_DIR"
  fi
}

@test "cli: --help lists subcommands" {
  run node "$TACK_CLI" --help
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"tack doctor"* ]]
  [[ "$output" == *"tack init"* ]]
  [[ "$output" == *"specialist add"* ]]
}

@test "cli: unknown command exits 2" {
  run node "$TACK_CLI" nonsense
  [[ "$status" -eq 2 ]]
  [[ "$output" == *"unknown command"* ]]
}

@test "cli: doctor proxies to tack-doctor.sh" {
  mkdir -p project/prompts project/scripts
  cp "$REPO_ROOT/skills/tack-bootstrap/template/scripts/tack-doctor.sh" project/scripts/
  cat > .cursorrules <<'EOF'
# Project

## Tech stack

- TypeScript

## Quality commands

- Lint: npm run lint
- Tests: npm test

## Auto-orchestration routing

- `tack.routing.auto`: `<yes | no>` — default **`yes`**.
EOF
  cat > project/prompts/auto-orchestrator.md <<'EOF'
| Condition | Prompt |
|-----------|--------|
| `path:src/**` | `@worker.md` |
EOF

  run node "$TACK_CLI" doctor
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"all checks passed"* ]]
}

@test "cli: doctor fails when script missing" {
  run node "$TACK_CLI" doctor
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"missing"* ]] || [[ "$output" == *"project/scripts/tack-doctor.sh"* ]]
}

@test "cli: init creates project tree" {
  run node "$TACK_CLI" init --target "$TMP_DIR"
  [[ "$status" -eq 0 ]]
  [[ -d "$TMP_DIR/project/prompts" ]]
  [[ -f "$TMP_DIR/project/scripts/tack-doctor.sh" ]]
}

@test "cli: init refuses existing project without --force" {
  mkdir -p "$TMP_DIR/project"
  printf 'x\n' >"$TMP_DIR/project/README.md"
  run node "$TACK_CLI" init --target "$TMP_DIR"
  [[ "$status" -eq 2 ]]
  [[ "$output" == *"already exists"* ]]
}

@test "cli: init --force replaces project" {
  mkdir -p "$TMP_DIR/project"
  printf 'old\n' >"$TMP_DIR/project/stale.txt"
  run node "$TACK_CLI" init --target "$TMP_DIR" --force
  [[ "$status" -eq 0 ]]
  [[ -f "$TMP_DIR/project/scripts/tack-doctor.sh" ]]
}

@test "cli: specialist add writes prompt stub" {
  mkdir -p project
  run node "$TACK_CLI" specialist add payments
  [[ "$status" -eq 0 ]]
  [[ -f "$TMP_DIR/project/prompts/payments.md" ]]
  grep -q 'Specialist prompt template' "$TMP_DIR/project/prompts/payments.md"
}

@test "cli: specialist add rejects invalid slug" {
  mkdir -p project
  run node "$TACK_CLI" specialist add 'BadSlug'
  [[ "$status" -eq 2 ]]
}
