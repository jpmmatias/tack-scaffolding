#!/usr/bin/env bash
# tack-resolve-config.sh — resolve IDE-agnostic Tack config path (sourced by tack-worktree.sh, tack-doctor.sh).
# Priority: repo-root TACK.md, then repo-root .cursorrules.

tack_config_primary_file() {
  local root="${1:-}"
  [[ -n "$root" ]] || return 1
  if [[ -f "$root/TACK.md" ]]; then
    printf '%s\n' "$root/TACK.md"
    return 0
  fi
  if [[ -f "$root/.cursorrules" ]]; then
    printf '%s\n' "$root/.cursorrules"
    return 0
  fi
  return 1
}

tack_config_warn_if_both() {
  local root="${1:-}"
  [[ -z "$root" ]] && return 0
  if [[ -f "$root/TACK.md" && -f "$root/.cursorrules" ]]; then
    echo "tack: both TACK.md and .cursorrules exist — TACK.md is authoritative for tack.worktree.*, tack.routing.*, and quality commands; align or remove duplicates from .cursorrules." >&2
  fi
}

# Repo-root .cursorrules scanned by tack-doctor for <UPPERCASE> placeholders when TACK.md
# is the primary config, so stale Cursor stubs cannot drift from a filled TACK.md.
# When --rules is passed to the doctor, this companion is skipped.
tack_config_placeholder_companion_cursorrules() {
  local root="$1"
  local primary="$2"
  local rules_from_cli="${3:-0}"
  local tack_md canon_primary
  [[ "$rules_from_cli" -eq 1 ]] && return 1
  tack_md="$(cd "$root" && pwd)/TACK.md"
  [[ -f "$tack_md" && -f "$root/.cursorrules" ]] || return 1
  canon_primary="$(cd "$(dirname "$primary")" && pwd)/$(basename "$primary")"
  [[ "$canon_primary" == "$tack_md" ]] || return 1
  printf '%s\n' "$(cd "$root" && pwd)/.cursorrules"
}

tack_config_line_for_key() {
  local root="$1"
  local needle="$2"
  local f
  f="$(tack_config_primary_file "$root")" || return 1
  grep -F "$needle" "$f" | head -n1 || return 1
}

# Strip common Markdown noise and trailing prose after an em dash (template lines).
tack_config_value_after_colon() {
  local line="$1"
  local val="${line#*:}"
  val="${val//\`/}"
  val="${val//\*\*/}"
  val="${val//\"/}"
  val="${val#"${val%%[![:space:]]*}"}"
  val="${val%"${val##*[![:space:]]}"}"
  case "$val" in
    *" — "*)
      val="${val%% — *}"
      val="${val%"${val##*[![:space:]]}"}"
      ;;
  esac
  [[ -n "$val" ]] || return 1
  printf '%s' "$val"
}
