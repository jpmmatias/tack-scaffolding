#!/usr/bin/env bats
# B-28 smoke + optional drift fixture (missing prompt under a temp repo root).

load helpers

@test "check-dispatch-contract: passes on canonical tree" {
  run bash "$CHECK_DISPATCH_CONTRACT"
  [[ "$status" -eq 0 ]]
  [[ "$output" == OK:* ]]
}

@test "check-dispatch-contract: fails when a stock prompt is missing" {
  local fake_root
  fake_root="$(mktemp -d "${BATS_TEST_TMPDIR:-/tmp}/tack-contract-XXXXXX")"
  cp -a "$REPO_ROOT/skills" "$fake_root/"
  rm -f "$fake_root/skills/tack-bootstrap/template/prompts/worker.md"
  run env TACK_DISPATCH_CONTRACT_ROOT="$fake_root" bash "$CHECK_DISPATCH_CONTRACT"
  [[ "$status" -ne 0 ]]
  rm -rf "$fake_root"
}
