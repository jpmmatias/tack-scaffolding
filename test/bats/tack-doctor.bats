#!/usr/bin/env bats
# B-11 / B-12: tack-doctor.sh — uppercase placeholders in repo-root TACK.md
# (default), plus `<fill>` in auto-orchestrator Specialist routing.

load helpers

setup() {
  TMP_DIR="$(mktemp -d "${BATS_TEST_TMPDIR:-/tmp}/doctor-XXXXXX")"
  export TMP_DIR
  cd "$TMP_DIR" || exit 1
  mkdir -p project/prompts project/docs
  cat > project/docs/tack-pipeline-models.md <<'EOF'
---
worktree_coordinator: composer-2-fast
product_manager: claude-opus-4-7-thinking-xhigh
architect: claude-opus-4-7-thinking-xhigh
qa_tester: claude-4.6-sonnet-medium-thinking
harness_engineer: claude-4.6-sonnet-medium-thinking
worker: composer-2-fast
reviewer: claude-opus-4-7-thinking-xhigh
security_engineer: claude-opus-4-7-thinking-xhigh
---

# Test fixture
EOF
  # Minimal "clean" fixtures — no uppercase placeholders, no <fill>.
  cat > TACK.md <<'EOF'
# Project: orderflow

## Tech stack

- TypeScript

## Quality commands

- Lint: npm run lint
- Tests: npm test

## Auto-orchestration routing

- `tack.routing.auto`: `<yes | no>` — default **`yes`**.
EOF
  cat > project/prompts/auto-orchestrator.md <<'EOF'
# Specialist routing

| Condition | Prompt |
|-----------|--------|
| `path:src/api/**` | `@api.md` |
| (default) | `@worker.md` |
EOF
}

teardown() {
  cd "$REPO_ROOT" || true
  if [[ -n "${TMP_DIR:-}" && -d "$TMP_DIR" ]]; then
    rm -rf "$TMP_DIR"
  fi
}

@test "doctor: clean fixtures pass" {
  run bash "$TACK_DOCTOR"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"all checks passed"* ]]
}

@test "doctor: --quiet suppresses success notes" {
  run bash "$TACK_DOCTOR" --quiet
  [[ "$status" -eq 0 ]]
  [[ -z "$output" ]]
}

@test "doctor: schema annotations like <yes | no> do NOT trip the placeholder check" {
  # Re-run on clean fixtures; ensure schema lines containing lowercase angle
  # brackets pass.
  run bash "$TACK_DOCTOR"
  [[ "$status" -eq 0 ]]
}

@test "doctor: leftover <UPPERCASE> in TACK.md fails with line cite" {
  echo '- Tests: <TEST_COMMAND>' >> TACK.md
  run bash "$TACK_DOCTOR"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"uppercase placeholders"* ]]
  [[ "$output" == *"<TEST_COMMAND>"* ]]
}

@test "doctor: leftover <PROJECT_NAME> in TACK.md fails" {
  printf '# Project: <PROJECT_NAME>\n' > TACK.md
  run bash "$TACK_DOCTOR"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"<PROJECT_NAME>"* ]]
}

@test "doctor: leftover <fill> row in orchestrator fails with line cite" {
  cat > project/prompts/auto-orchestrator.md <<'EOF'
| Condition | Prompt |
|-----------|--------|
| `<fill>` | `@worker.md` (default) |
EOF
  run bash "$TACK_DOCTOR"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"<fill>"* ]]
}

@test "doctor: missing files fail with actionable message" {
  rm TACK.md project/prompts/auto-orchestrator.md
  run bash "$TACK_DOCTOR"
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"missing TACK.md"* ]]
  [[ "$output" == *"missing project/prompts/auto-orchestrator.md"* ]]
}

@test "doctor: --rules / --orchestrator override defaults" {
  cat > my-rules.txt <<'EOF'
- Lint: <LINT_COMMAND>
EOF
  cat > my-orch.md <<'EOF'
| `<fill>` | `@x.md` |
EOF
  run bash "$TACK_DOCTOR" --rules my-rules.txt --orchestrator my-orch.md
  [[ "$status" -eq 1 ]]
  [[ "$output" == *"my-rules.txt"* ]]
  [[ "$output" == *"my-orch.md"* ]]
}

@test "doctor: --help prints usage and exits 0" {
  run bash "$TACK_DOCTOR" --help
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"Usage:"* ]]
}

@test "doctor: unknown flag exits 2" {
  run bash "$TACK_DOCTOR" --bogus
  [[ "$status" -eq 2 ]]
}

@test "doctor: stray .cursorrules with placeholders does not fail doctor (ignored)" {
  printf '%s\n' '# Legacy' '- Tests: <TEST_COMMAND>' > .cursorrules
  run bash "$TACK_DOCTOR"
  [[ "$status" -eq 0 ]]
}

@test "doctor: TACK.md only (no .cursorrules) passes when filled" {
  rm -f .cursorrules
  cat > TACK.md <<'EOF'
# Project

## Quality commands

- Lint: npm run lint
- Tests: npm test

## Auto-orchestration routing

- `tack.routing.auto`: yes
EOF
  run bash "$TACK_DOCTOR"
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"TACK.md placeholders OK"* ]]
  [[ "$output" == *"all checks passed"* ]]
}

@test "doctor: stock template TACK.md.template DOES contain placeholders (sanity)" {
  # Sanity check the template — the validator's whole point is to flag these
  # before bootstrap rewrites them. If this ever fails, either the template
  # was post-processed or our regex needs updating.
  run grep -E '<[A-Z][A-Z0-9_]*>' "$REPO_ROOT/skills/tack-bootstrap/template/TACK.md.template"
  [[ "$status" -eq 0 ]]
}

@test "doctor: stock auto-orchestrator.md template DOES contain <fill> rows (sanity)" {
  run grep -F '<fill>' "$REPO_ROOT/skills/tack-bootstrap/template/prompts/auto-orchestrator.md"
  [[ "$status" -eq 0 ]]
}
