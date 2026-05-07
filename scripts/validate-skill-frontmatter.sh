#!/usr/bin/env bash
# Validate YAML frontmatter on every skills/*/SKILL.md (CI + local).
# Version must match package.json (single source of truth).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PKG="$ROOT/package.json"
if [[ ! -f "$PKG" ]]; then
  echo "validate-skill-frontmatter: missing $PKG" >&2
  exit 1
fi

pkg_version="$(sed -n 's/^[[:space:]]*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$PKG" | head -1)"
if [[ -z "${pkg_version// }" ]]; then
  echo "validate-skill-frontmatter: could not read version from package.json" >&2
  exit 1
fi

shopt -s nullglob
skills=(skills/*/SKILL.md)
if [[ ${#skills[@]} -eq 0 ]]; then
  echo "validate-skill-frontmatter: no skills/*/SKILL.md found" >&2
  exit 1
fi

overall_err=0
for SKILL in "${skills[@]}"; do
  if [[ ! -f "$SKILL" ]]; then
    echo "validate-skill-frontmatter: missing $SKILL" >&2
    overall_err=1
    continue
  fi

  # First --- ... --- block
  BODY="$(awk 'BEGIN{p=0} /^---$/{p++; if(p==2)exit} p==1 && NR>1{print}' "$SKILL")"

  name="$(echo "$BODY" | sed -n 's/^name:[[:space:]]*//p' | head -1 | tr -d '\r')"
  description="$(echo "$BODY" | sed -n 's/^description:[[:space:]]*//p' | head -1 | tr -d '\r')"
  version="$(echo "$BODY" | sed -n 's/^version:[[:space:]]*//p' | head -1 | tr -d '\r' | tr -d '[:space:]')"

  err=0
  if [[ -z "${name// }" ]]; then
    echo "validate-skill-frontmatter: $SKILL — missing or empty 'name'" >&2
    err=1
  fi
  if [[ -z "${description// }" ]]; then
    echo "validate-skill-frontmatter: $SKILL — missing or empty 'description'" >&2
    err=1
  fi
  case "$description" in
    *"Use when"*) ;;
    *)
      echo "validate-skill-frontmatter: $SKILL — description should contain 'Use when' (skills convention)" >&2
      err=1
      ;;
  esac
  if [[ -z "${version// }" ]]; then
    echo "validate-skill-frontmatter: $SKILL — missing or empty 'version' (must match package.json)" >&2
    err=1
  elif [[ "$version" != "$pkg_version" ]]; then
    echo "validate-skill-frontmatter: $SKILL — version '$version' != package.json version '$pkg_version'" >&2
    err=1
  fi

  if [[ "$err" -ne 0 ]]; then
    overall_err=1
    continue
  fi

  echo "validate-skill-frontmatter: OK (name=$name, version=$version)"
done

if [[ "$overall_err" -ne 0 ]]; then
  exit 1
fi
