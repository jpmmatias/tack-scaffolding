#!/usr/bin/env bash
# Validate YAML frontmatter on skills/sdd-bootstrap/SKILL.md (CI + local).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILL="$ROOT/skills/sdd-bootstrap/SKILL.md"

if [[ ! -f "$SKILL" ]]; then
  echo "validate-skill-frontmatter: missing $SKILL" >&2
  exit 1
fi

# First --- ... --- block
BODY="$(awk 'BEGIN{p=0} /^---$/{p++; if(p==2)exit} p==1 && NR>1{print}' "$SKILL")"

name="$(echo "$BODY" | sed -n 's/^name:[[:space:]]*//p' | head -1 | tr -d '\r')"
description="$(echo "$BODY" | sed -n 's/^description:[[:space:]]*//p' | head -1 | tr -d '\r')"

err=0
if [[ -z "${name// }" ]]; then
  echo "validate-skill-frontmatter: missing or empty 'name'" >&2
  err=1
fi
if [[ -z "${description// }" ]]; then
  echo "validate-skill-frontmatter: missing or empty 'description'" >&2
  err=1
fi
case "$description" in
  *"Use when"*) ;;
  *)
    echo "validate-skill-frontmatter: description should contain 'Use when' (skills convention)" >&2
    err=1
    ;;
esac

if [[ "$err" -ne 0 ]]; then
  exit 1
fi

echo "validate-skill-frontmatter: OK (name=$name)"
