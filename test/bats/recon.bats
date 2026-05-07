#!/usr/bin/env bats
# B-07: recon.sh layer buckets + truncation.

load helpers

setup() {
  RECON_FIXTURE="$(mktemp -d "${BATS_TEST_TMPDIR:-/tmp}/tack-recon-XXXXXX")"
  export RECON_FIXTURE
  mkdir -p "$RECON_FIXTURE/domain" \
    "$RECON_FIXTURE/controllers" \
    "$RECON_FIXTURE/migrations" \
    "$RECON_FIXTURE/tests" \
    "$RECON_FIXTURE/config" \
    "$RECON_FIXTURE/docs/adr" \
    "$RECON_FIXTURE/node_modules"
  printf 'l1\n' >"$RECON_FIXTURE/domain/order.ts"
  printf 'l2a\n' >"$RECON_FIXTURE/controllers/api.ts"
  printf 'l2b\n' >"$RECON_FIXTURE/schema.graphql"
  printf 'l3\n' >"$RECON_FIXTURE/migrations/001.sql"
  printf 'l4\n' >"$RECON_FIXTURE/tests/order.test.ts"
  printf 'l5\n' >"$RECON_FIXTURE/package.json"
  printf 'l6a\n' >"$RECON_FIXTURE/README.md"
  printf 'l6b\n' >"$RECON_FIXTURE/docs/adr/0001.md"
  printf 'pruned\n' >"$RECON_FIXTURE/node_modules/ignored.js"
  cd "$RECON_FIXTURE" || exit 1
}

teardown() {
  cd "$REPO_ROOT" || true
  [[ -n "${RECON_FIXTURE:-}" ]] && rm -rf "$RECON_FIXTURE"
  unset RECON_FIXTURE
}

@test "recon: layers receive expected members and prune node_modules" {
  run bash "$RECON_SH" -
  [[ "$status" -eq 0 ]]
  printf '%s' "$output" | python3 -c "
import json, sys
d = json.load(sys.stdin)
assert 'domain/order.ts' in d['layer1_domain_core']
assert 'controllers/api.ts' in d['layer2_boundaries']
assert 'schema.graphql' in d['layer2_boundaries']
assert 'migrations/001.sql' in d['layer3_persistence']
assert 'tests/order.test.ts' in d['layer4_tests']
assert 'package.json' in d['layer5_config']
assert 'README.md' in d['layer6_docs']
assert 'docs/adr/0001.md' in d['layer6_docs']
for k, v in d.items():
    if isinstance(v, list):
        for path in v:
            assert 'node_modules' not in path, path
"
}

@test "recon: truncation flag when layer exceeds cap" {
  printf 'third\n' >CHANGELOG.md
  export SDD_BOOTSTRAP_RECON_CAP=2
  run bash "$RECON_SH" -
  [[ "$status" -eq 0 ]]
  printf '%s' "$output" | python3 -c "import json,sys; d=json.load(sys.stdin); assert d['cap']==2; assert d['truncated']['layer6_docs'] is True; assert len(d['layer6_docs'])==2"
}
