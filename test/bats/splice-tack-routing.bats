#!/usr/bin/env bats
# B-10: splice-tack-routing.sh — replace/append the `## Tack routing` H2.

load helpers

setup() {
  TMP_DIR="$(mktemp -d "${BATS_TEST_TMPDIR:-/tmp}/splice-XXXXXX")"
  export TMP_DIR
  cd "$TMP_DIR" || exit 1
}

teardown() {
  cd "$REPO_ROOT" || true
  if [[ -n "${TMP_DIR:-}" && -d "$TMP_DIR" ]]; then
    rm -rf "$TMP_DIR"
  fi
}

@test "splice: AGENTS.md.template is byte-equal after splice (no-op)" {
  cp "$REPO_ROOT/skills/tack-bootstrap/template/AGENTS.md.template" AGENTS.md
  run bash "$SPLICE_TACK_ROUTING" --snippet "$ROUTING_SNIPPET" --check AGENTS.md
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"unchanged"* ]]
}

@test "splice: CLAUDE.md.template is byte-equal after splice (no-op)" {
  cp "$REPO_ROOT/skills/tack-bootstrap/template/CLAUDE.md.template" CLAUDE.md
  run bash "$SPLICE_TACK_ROUTING" --snippet "$ROUTING_SNIPPET" --check CLAUDE.md
  [[ "$status" -eq 0 ]]
}

@test "splice: appends section when target lacks ## Tack routing" {
  printf '# Hi\n\n## Project layout\n\n- foo\n' > AGENTS.md
  run bash "$SPLICE_TACK_ROUTING" --snippet "$ROUTING_SNIPPET" AGENTS.md
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"updated"* ]]
  grep -q '^## Tack routing$' AGENTS.md
  grep -q 'auto-orchestrator.md' AGENTS.md
  # Original content preserved
  grep -q '^# Hi$' AGENTS.md
  grep -q '^- foo$' AGENTS.md
}

@test "splice: append is idempotent" {
  printf '# Hi\n\n- foo\n' > AGENTS.md
  bash "$SPLICE_TACK_ROUTING" --snippet "$ROUTING_SNIPPET" AGENTS.md >/dev/null
  cp AGENTS.md AGENTS.md.first
  bash "$SPLICE_TACK_ROUTING" --snippet "$ROUTING_SNIPPET" AGENTS.md >/dev/null
  cmp AGENTS.md AGENTS.md.first
}

@test "splice: replaces stale routing in middle, preserves trailing section byte-for-byte" {
  cat > AGENTS.md <<'EOF'
# Hi

## Project layout

- foo

## Tack routing

OUTDATED CONTENT.

- old bullet
- another stale bullet

## Extra notes

Important — must survive byte-for-byte.

- keep me
EOF
  run bash "$SPLICE_TACK_ROUTING" --snippet "$ROUTING_SNIPPET" AGENTS.md
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"updated"* ]]
  ! grep -q 'OUTDATED CONTENT' AGENTS.md
  ! grep -q 'old bullet' AGENTS.md
  grep -q '^## Extra notes$' AGENTS.md
  grep -q 'must survive byte-for-byte' AGENTS.md
  grep -q '^- keep me$' AGENTS.md
  # Idempotent
  run bash "$SPLICE_TACK_ROUTING" --snippet "$ROUTING_SNIPPET" --check AGENTS.md
  [[ "$status" -eq 0 ]]
}

@test "splice: replaces routing that is the last section (no trailing H2)" {
  cat > AGENTS.md <<'EOF'
# Hi

## Tack routing

stale.

- a
- b
EOF
  bash "$SPLICE_TACK_ROUTING" --snippet "$ROUTING_SNIPPET" AGENTS.md >/dev/null
  ! grep -q '^stale\.$' AGENTS.md
  ! grep -q '^- a$' AGENTS.md
  grep -q 'auto-orchestrator.md' AGENTS.md
  # Idempotent
  run bash "$SPLICE_TACK_ROUTING" --snippet "$ROUTING_SNIPPET" --check AGENTS.md
  [[ "$status" -eq 0 ]]
}

@test "splice: --check exits 1 with diff on drift" {
  printf '# Hi\n' > AGENTS.md
  run bash "$SPLICE_TACK_ROUTING" --snippet "$ROUTING_SNIPPET" --check AGENTS.md
  [[ "$status" -eq 1 ]]
  [[ "${output}" == *"would change"* ]]
}

@test "splice: rejects snippet that does not start with ## Tack routing" {
  printf '## Wrong heading\n\n- x\n' > bad-snippet.md
  printf '# Hi\n' > AGENTS.md
  run bash "$SPLICE_TACK_ROUTING" --snippet bad-snippet.md AGENTS.md
  [[ "$status" -eq 2 ]]
}

@test "splice: missing target file exits 1" {
  run bash "$SPLICE_TACK_ROUTING" --snippet "$ROUTING_SNIPPET" does-not-exist.md
  [[ "$status" -eq 1 ]]
}

@test "splice: missing snippet file exits 1" {
  printf '# Hi\n' > AGENTS.md
  run bash "$SPLICE_TACK_ROUTING" --snippet does-not-exist.md AGENTS.md
  [[ "$status" -eq 1 ]]
}

@test "splice: --help prints usage and exits 0" {
  run bash "$SPLICE_TACK_ROUTING" --help
  [[ "$status" -eq 0 ]]
  [[ "$output" == *"Usage:"* ]]
}

@test "splice: H1 heading after routing terminates replacement" {
  cat > AGENTS.md <<'EOF'
## Tack routing

stale

- a

# Appendix

keep me
EOF
  bash "$SPLICE_TACK_ROUTING" --snippet "$ROUTING_SNIPPET" AGENTS.md >/dev/null
  ! grep -q '^stale$' AGENTS.md
  grep -q '^# Appendix$' AGENTS.md
  grep -q '^keep me$' AGENTS.md
}
