#!/usr/bin/env bash
# recon.sh — Phase 2.1 helper for the tack-bootstrap skill.
#
# Walks the repository from the cwd and buckets files into the six layers
# defined in the skill's Phase 2.1. Writes the result as JSON either to
# stdout or to a file (default: ./recon.json).
#
# Output shape:
#   {
#     "layer1_domain_core":  [ "<path>", ... ],
#     "layer2_boundaries":   [ "<path>", ... ],
#     "layer3_persistence":  [ "<path>", ... ],
#     "layer4_tests":        [ "<path>", ... ],
#     "layer5_config":       [ "<path>", ... ],
#     "layer6_docs":         [ "<path>", ... ],
#     "truncated":           { "layer1_domain_core": false, ... },
#     "cap":                 200
#   }
#
# Each list is capped (default 200 entries) and a parallel "truncated"
# object reports per-layer truncation.
#
# Usage:
#   ./recon.sh                # writes ./recon.json
#   ./recon.sh -              # writes JSON to stdout
#   ./recon.sh path/out.json  # writes to path/out.json

set -euo pipefail

CAP="${SDD_BOOTSTRAP_RECON_CAP:-200}"
OUT="${1-./recon.json}"

# Pruned directories (artifacts, vendored deps, VCS).
PRUNE=(
  ./node_modules
  ./vendor
  ./.venv
  ./venv
  ./dist
  ./build
  ./.git
  ./coverage
  ./.next
  ./.turbo
  ./.cache
  ./.parcel-cache
  ./target
  ./__pycache__
  ./.pytest_cache
  ./.mypy_cache
  ./.ruff_cache
  ./.gradle
  ./out
)

# Build a find(1) argument list that prunes the artifact directories above.
build_find_args() {
  local first=1
  FIND_ARGS=( "(" )
  for d in "${PRUNE[@]}"; do
    if [[ $first -eq 1 ]]; then
      FIND_ARGS+=( -path "$d" )
      first=0
    else
      FIND_ARGS+=( -o -path "$d" )
    fi
  done
  FIND_ARGS+=( ")" -prune -o -type f -size +0c -print )
}

build_find_args

# all_files: every regular file under cwd, minus pruned dirs.
all_files() {
  find . "${FIND_ARGS[@]}" 2>/dev/null | sed 's|^\./||'
}

ALL="$(all_files)"

# match_layer_assign PATTERN RESULT_VAR TRUNC_VAR
#   Filter ALL by an extended regex, sort, dedupe, cap. Writes the (possibly
#   truncated) newline-separated paths into RESULT_VAR and sets TRUNC_VAR to
#   true/false. Must run in the current shell (not inside $(...)) so TRUNC_VAR
#   updates survive — command substitution would run in a subshell and lose flags.
match_layer_assign() {
  local pattern="$1"
  local result_var="$2"
  local trunc_var="$3"
  local matched total
  matched="$(printf '%s\n' "$ALL" | grep -E "$pattern" || true)"
  matched="$(printf '%s' "$matched" | sort -u)"
  total="$(printf '%s' "$matched" | grep -c . || true)"
  if (( total > CAP )); then
    eval "${trunc_var}=true"
    matched="$(printf '%s' "$matched" | head -n "$CAP")"
  else
    eval "${trunc_var}=false"
  fi
  printf -v "${result_var}" '%s' "$matched"
}

# Layer 1 — domain core
LAYER1_PATTERN='(^|/)(domain|core|entities|models|aggregates|value-?objects|services|usecases|application|commands|handlers|interactors|policies|rules|validators|specifications|guards)(/|$)'
TR1=false
LAYER1=""
match_layer_assign "$LAYER1_PATTERN" LAYER1 TR1

# Layer 2 — boundaries (HTTP/RPC, async, contracts)
LAYER2_PATTERN='(^|/)(controllers|routes|api|endpoints|webhooks|events|subscribers|consumers|jobs|workers|tasks|schemas|dto|contracts)(/|$)|\.(proto|graphql|gql)$|openapi\.(yaml|yml|json)$'
TR2=false
LAYER2=""
match_layer_assign "$LAYER2_PATTERN" LAYER2 TR2

# Layer 3 — persistence
LAYER3_PATTERN='(^|/)(migrations|prisma|alembic|flyway|liquibase|db|schema|seeds|fixtures)(/|$)|\.sql$|prisma/schema\.prisma$'
TR3=false
LAYER3=""
match_layer_assign "$LAYER3_PATTERN" LAYER3 TR3

# Layer 4 — tests as specs
LAYER4_PATTERN='(^|/)(tests?|spec|e2e|cypress|playwright|__tests__)(/|$)|\.(test|spec)\.(t|j)sx?$|_test\.go$|_spec\.rb$|test_.+\.py$'
TR4=false
LAYER4=""
match_layer_assign "$LAYER4_PATTERN" LAYER4 TR4

# Layer 5 — config & feature flags
LAYER5_PATTERN='(^|/)(\.env(\..*)?|config|configs|i18n|locales)(/|$)|(^|/)\.env(\.|$)|(^|/)(launchdarkly|unleash|flagsmith|optimizely)\.|(^|/)tsconfig\.json$|(^|/)next\.config\.(t|j)s$|(^|/)tailwind\.config\.(t|j)s$|(^|/)vite\.config\.(t|j)s$|(^|/)vitest\.config\.(t|j)s$|(^|/)jest\.config\.(t|j)s$|(^|/)pyproject\.toml$|(^|/)setup\.cfg$|(^|/)Cargo\.toml$|(^|/)go\.mod$|(^|/)Gemfile$|(^|/)pom\.xml$|(^|/)build\.gradle(\.kts)?$|(^|/)composer\.json$|(^|/)package\.json$'
TR5=false
LAYER5=""
match_layer_assign "$LAYER5_PATTERN" LAYER5 TR5

# Layer 6 — documentation traces
LAYER6_PATTERN='(^|/)(README\.md|README\.MD|README|CHANGELOG\.md|CONTRIBUTING\.md|CODE_OF_CONDUCT\.md|SECURITY\.md|docs|adr|\.github/(ISSUE_TEMPLATE|PULL_REQUEST_TEMPLATE))($|/)'
TR6=false
LAYER6=""
match_layer_assign "$LAYER6_PATTERN" LAYER6 TR6

# JSON helpers (no jq dependency)
emit_string_array() {
  local payload="$1"
  printf '['
  if [[ -n "$payload" ]]; then
    local first=1
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      local escaped="${line//\\/\\\\}"
      escaped="${escaped//\"/\\\"}"
      escaped="${escaped//$'\t'/\\t}"
      escaped="${escaped//$'\r'/\\r}"
      escaped="${escaped//$'\n'/\\n}"
      if [[ $first -eq 1 ]]; then
        printf '"%s"' "$escaped"
        first=0
      else
        printf ',"%s"' "$escaped"
      fi
    done <<<"$payload"
  fi
  printf ']'
}

emit_truncation() {
  printf '{"layer1_domain_core":%s,"layer2_boundaries":%s,"layer3_persistence":%s,"layer4_tests":%s,"layer5_config":%s,"layer6_docs":%s}' \
    "$TR1" "$TR2" "$TR3" "$TR4" "$TR5" "$TR6"
}

emit_json() {
  printf '{'
  printf '"layer1_domain_core":'
  emit_string_array "$LAYER1"
  printf ','
  printf '"layer2_boundaries":'
  emit_string_array "$LAYER2"
  printf ','
  printf '"layer3_persistence":'
  emit_string_array "$LAYER3"
  printf ','
  printf '"layer4_tests":'
  emit_string_array "$LAYER4"
  printf ','
  printf '"layer5_config":'
  emit_string_array "$LAYER5"
  printf ','
  printf '"layer6_docs":'
  emit_string_array "$LAYER6"
  printf ','
  printf '"truncated":'
  emit_truncation
  printf ','
  printf '"cap":%d' "$CAP"
  printf '}\n'
}

if [[ "$OUT" == "-" ]]; then
  emit_json
else
  emit_json >"$OUT"
  printf 'recon written to %s\n' "$OUT" >&2
fi
