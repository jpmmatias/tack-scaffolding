#!/usr/bin/env bash
# tack-worktree.sh — isolated git worktrees for Tack parallel features.
# Run from the repository root (consumer repo). See project/docs/sdd.md § Parallel features.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=tack-resolve-config.sh
source "$SCRIPT_DIR/tack-resolve-config.sh"

SPECS_GLOB="project/specs/S-*.md"
WT_DIR_DEFAULT=".worktrees"

# Branches that must NEVER be deleted by this script. Not bypassable by any flag.
# Adjust only if your repo has a non-standard trunk; never relax to allow main/master/etc.
PROTECTED_BRANCHES_RE='^(main|master|develop|dev|staging|stage|production|prod|trunk|HEAD|release(/.*)?|hotfix(/.*)?)$'

die() {
  echo "tack-worktree: $*" >&2
  exit 1
}

require_git() {
  command -v git >/dev/null 2>&1 || die "git not found in PATH"
}

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || die "not inside a git repository"
}

# Optional defaults from repo-root **`TACK.md`** (same keys as `worktree-coordinator.md`).
apply_worktree_dir_from_config() {
  local root="$1"
  local line val
  line="$(tack_config_line_for_key "$root" "tack.worktree.dir")" || return 0
  val="$(tack_config_value_after_colon "$line")" || return 0
  [[ -n "$val" ]] || return 0
  WT_DIR_DEFAULT="$val"
}

# Branch fork target: `detect` / placeholders → leave unset (caller runs detect_base_branch).
parse_base_branch_cursorrules() {
  local raw="$1"
  [[ -z "$raw" ]] && return 1
  if [[ "$raw" == *"<"*"|"*">"* ]]; then
    return 1
  fi
  local compact="${raw// /}"
  compact="$(printf '%s' "$compact" | tr '[:upper:]' '[:lower:]')"
  if [[ "$compact" == "detect" ]]; then
    return 1
  fi
  local br="${raw%% *}"
  br="${br//</}"
  br="${br//>/}"
  [[ -n "$br" ]] || return 1
  printf '%s' "$br"
}

# Resolve naming scheme string for `case "$naming"` in cmd_create.
parse_naming_scheme_cursorrules() {
  local raw="$1"
  [[ "$raw" == *"feature/S-XXX-<slug>"* ]] && printf '%s' 'feature/S-XXX-<slug>' && return 0
  [[ "$raw" == *"feature/<slug>"* ]] && printf '%s' 'feature/<slug>' && return 0
  return 1
}

json_escape() {
  local s="${1-}"
  python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$s" 2>/dev/null || {
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    printf '"%s"' "$s"
  }
}

# Sanitize epic slug for branch segment (lowercase, alnum + hyphen).
sanitize_slug() {
  local raw="${1-}"
  raw="$(echo "$raw" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9-' '-' | sed 's/^-*//;s/-*$//')"
  [[ -n "$raw" ]] || die "slug is empty after sanitization"
  printf '%s' "$raw"
}

# Highest NNN from filenames matching project/specs/S-NNN-*.md under DIR.
max_spec_num_in_dir() {
  local dir="$1"
  local max=0
  local f base num
  shopt -s nullglob 2>/dev/null || true
  for f in "$dir"/$SPECS_GLOB; do
    [[ -f "$f" ]] || continue
    base="$(basename "$f")"
    [[ "$base" == _* ]] && continue
    if [[ "$base" =~ ^S-([0-9]{3})- ]]; then
      num=$((10#${BASH_REMATCH[1]}))
      (( num > max )) && max=$num
    fi
  done
  printf '%d' "$max"
}

# Next free S-XXX as zero-padded string (e.g. S-007).
next_spec_id() {
  local root
  root="$(repo_root)"
  local max=0
  local path n

  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    n="$(max_spec_num_in_dir "$path")"
    (( n > max )) && max=$n
  done < <(list_worktree_paths "$root")

  local next=$((max + 1))
  (( next > 999 )) && die "spec id overflow (> S-999)"
  printf 'S-%03d' "$next"
}

# Print absolute paths of all linked worktrees (primary + linked).
list_worktree_paths() {
  local root="${1:-}"
  [[ -n "$root" ]] || root="$(repo_root)"
  git -C "$root" worktree list --porcelain 2>/dev/null | awk '
    /^worktree / { print substr($0, 10); next }
  '
}

detect_base_branch() {
  local root="$1"
  local br
  for br in main master develop; do
    if git -C "$root" show-ref --verify --quiet "refs/heads/$br" 2>/dev/null; then
      printf '%s' "$br"
      return 0
    fi
  done
  # Fallback: current branch if not detached
  br="$(git -C "$root" branch --show-current 2>/dev/null || true)"
  if [[ -n "$br" ]]; then
    printf '%s' "$br"
    return 0
  fi
  die "could not detect base branch (try --base <branch>)"
}

ensure_gitignore_worktrees() {
  local root="$1"
  local gi="$root/.gitignore"
  local line="${WT_DIR_DEFAULT}/"
  if [[ -f "$gi" ]] && grep -qF "$line" "$gi" 2>/dev/null; then
    return 0
  fi
  printf '\n# Tack parallel features (git worktrees)\n%s\n' "$line" >>"$gi"
  echo "tack-worktree: appended $line to .gitignore (review and commit)" >&2
}

safe_dir_from_branch() {
  local branch="$1"
  echo "$branch" | tr '/' '-'
}

cmd_next_spec_id() {
  require_git
  local id
  id="$(next_spec_id)"
  printf '%s\n' "$id"
}

resolve_wt_path_by_slug() {
  local root="$1"
  local slug="$2"
  local d bname
  for d in "$root/$WT_DIR_DEFAULT"/*; do
    [[ -d "$d" ]] || continue
    bname="$(git -C "$d" branch --show-current 2>/dev/null || true)"
    [[ -z "$bname" ]] && continue
    if [[ "$bname" =~ ^feature/S-[0-9]{3}-${slug}$ ]] || [[ "$bname" == "feature/$slug" ]]; then
      (cd "$d" && pwd -P)
      return 0
    fi
  done
  return 1
}

cmd_path() {
  require_git
  local root slug out
  root="$(repo_root)"
  apply_worktree_dir_from_config "$root"
  [[ -z "${1:-}" ]] && die "usage: tack-worktree.sh path <slug>"
  slug="$(sanitize_slug "$1")"
  out="$(resolve_wt_path_by_slug "$root" "$slug")" || die "no worktree under $WT_DIR_DEFAULT matching slug '$slug'"
  printf '%s\n' "$out"
}

cmd_list() {
  require_git
  local root wt_dir
  root="$(repo_root)"
  apply_worktree_dir_from_config "$root"
  wt_dir="$root/$WT_DIR_DEFAULT"
  echo '['
  local first=1
  local d path branch
  if [[ -d "$wt_dir" ]]; then
    for d in "$wt_dir"/*; do
      [[ -d "$d" ]] || continue
      path="$(cd "$d" && pwd -P)"
      branch="$(git -C "$d" branch --show-current 2>/dev/null || echo "?")"
      [[ $first -eq 1 ]] || echo ','
      first=0
      printf '  {"path":%s,"branch":%s}' "$(json_escape "$path")" "$(json_escape "$branch")"
      echo
    done
  fi
  echo ']'
}

is_worktree_clean() {
  local path="$1"
  git -C "$path" diff --quiet && git -C "$path" diff --cached --quiet
}

cmd_remove() {
  require_git
  local root="${TACK_REPO_ROOT:-}"
  [[ -z "$root" ]] && root="$(repo_root)"
  apply_worktree_dir_from_config "$root"
  local target="${1:-}"
  [[ -n "$target" ]] || die "usage: tack-worktree.sh remove <path-or-slug> [--force]"
  shift || true
  local force=0
  [[ "${1:-}" == "--force" ]] && force=1

  local wt_path=""
  if [[ -d "$target" ]]; then
    wt_path="$(cd "$target" && pwd -P)"
  else
    wt_path="$(resolve_wt_path_by_slug "$root" "$(sanitize_slug "$target")")" \
      || die "could not resolve worktree for slug '$target' — pass the absolute path under $WT_DIR_DEFAULT"
  fi

  git -C "$wt_path" rev-parse --git-dir >/dev/null 2>&1 || die "not a git worktree: $wt_path"

  # Refuse to remove the primary worktree (the main checkout itself).
  local primary_root
  primary_root="$(git -C "$wt_path" rev-parse --show-toplevel)"
  local common_dir
  common_dir="$(git -C "$wt_path" rev-parse --git-common-dir)"
  case "$common_dir" in
    /*) ;;
    *) common_dir="$primary_root/$common_dir" ;;
  esac
  local primary_checkout
  primary_checkout="$(dirname "$common_dir")"
  if [[ "$wt_path" == "$primary_checkout" ]]; then
    die "refusing to remove the primary worktree (main checkout): $wt_path"
  fi

  local branch
  branch="$(git -C "$wt_path" branch --show-current 2>/dev/null || true)"
  [[ -z "$branch" ]] && die "detached HEAD in $wt_path — remove manually"

  # Hard protected-branch guard. Not bypassable by --force.
  if [[ "$branch" =~ $PROTECTED_BRANCHES_RE ]]; then
    die "refusing to delete protected branch: $branch (this guard is not bypassable; use raw git if you really mean it)"
  fi

  if [[ $force -eq 0 ]]; then
    is_worktree_clean "$wt_path" || die "worktree has uncommitted changes (commit/stash or use --force)"
    local base
    base="$(detect_base_branch "$(git -C "$wt_path" rev-parse --show-toplevel)")"
    if ! git -C "$wt_path" merge-base --is-ancestor "refs/heads/$branch" "refs/heads/$base" 2>/dev/null; then
      die "branch $branch is not merged into $base (merge or use --force)"
    fi
  fi

  git -C "$wt_path" worktree remove "${wt_path}" --force
  if [[ $force -eq 1 ]]; then
    git --git-dir="$common_dir" branch -D "$branch" 2>/dev/null || true
  else
    git --git-dir="$common_dir" branch -d "$branch" 2>/dev/null || echo "tack-worktree: branch $branch not deleted (not fully merged?)" >&2
  fi
  echo "{\"removed\":$(json_escape "$wt_path"),\"branch\":$(json_escape "$branch")}"
}

cmd_create() {
  require_git
  local root
  root="$(repo_root)"
  local slug="" spec="" base="" naming="feature/S-XXX-<slug>"
  local wt_dir_explicit=0 base_explicit=0 naming_explicit=0 dry_run=0
  local line cr_val parsed=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --spec)
        spec="$2"
        shift 2
        ;;
      --base)
        base="$2"
        base_explicit=1
        shift 2
        ;;
      --naming)
        naming="$2"
        naming_explicit=1
        shift 2
        ;;
      --wt-dir)
        WT_DIR_DEFAULT="$2"
        wt_dir_explicit=1
        shift 2
        ;;
      --dry-run)
        dry_run=1
        shift
        ;;
      *)
        slug="$1"
        shift
        ;;
    esac
  done

  [[ -n "$slug" ]] || die "usage: tack-worktree.sh create <slug> [--spec S-XXX] [--base <branch>] [--naming <scheme>] [--wt-dir DIR] [--dry-run]"

  if [[ $wt_dir_explicit -eq 0 ]]; then
    apply_worktree_dir_from_config "$root"
  fi

  slug="$(sanitize_slug "$slug")"

  if [[ -z "$spec" ]]; then
    spec="$(next_spec_id)"
  else
    [[ "$spec" =~ ^S-[0-9]{3}$ ]] || die "--spec must look like S-001"
  fi

  if [[ $base_explicit -eq 0 ]]; then
    line="$(tack_config_line_for_key "$root" "tack.worktree.base")" || true
    if [[ -n "${line:-}" ]]; then
      cr_val="$(tack_config_value_after_colon "$line")" || cr_val=""
      parsed="$(parse_base_branch_cursorrules "${cr_val:-}")" || parsed=""
      [[ -n "$parsed" ]] && base="$parsed"
    fi
  fi
  if [[ -z "$base" ]]; then
    base="$(detect_base_branch "$root")"
  fi

  if [[ $naming_explicit -eq 0 ]]; then
    line="$(tack_config_line_for_key "$root" "tack.worktree.naming")" || true
    if [[ -n "${line:-}" ]]; then
      cr_val="$(tack_config_value_after_colon "$line")" || cr_val=""
      parsed="$(parse_naming_scheme_cursorrules "${cr_val:-}")" || parsed=""
      [[ -n "$parsed" ]] && naming="$parsed"
    fi
  fi

  local branch=""
  case "$naming" in
    "feature/S-XXX-<slug>"|feature/S-XXX-*)
      branch="feature/${spec}-${slug}"
      ;;
    "feature/<slug>"|feature/*\<slug\>*)
      branch="feature/${slug}"
      ;;
    *)
      branch="feature/${spec}-${slug}"
      ;;
  esac

  local safe
  safe="$(safe_dir_from_branch "$branch")"
  local wt_path="$root/$WT_DIR_DEFAULT/$safe"

  [[ ! -e "$wt_path" ]] || die "worktree path already exists: $wt_path"

  local abs
  if [[ $dry_run -eq 1 ]]; then
    abs="$(python3 -c 'import os,sys; print(os.path.abspath(os.path.join(sys.argv[1],sys.argv[2],sys.argv[3])))' "$root" "$WT_DIR_DEFAULT" "$safe")"
  else
    ensure_gitignore_worktrees "$root"

    if ! git -C "$root" worktree add "$wt_path" -b "$branch" "$base" 2>/dev/null; then
      die "git worktree add failed (sandbox/permissions/conflict?). Work in main checkout or fix git state. base=$base branch=$branch"
    fi

    abs="$(cd "$wt_path" && pwd -P)"
  fi

  printf '{"path":%s,"branch":%s,"spec_id":%s,"base":%s,"slug":%s}\n' \
    "$(json_escape "$abs")" \
    "$(json_escape "$branch")" \
    "$(json_escape "$spec")" \
    "$(json_escape "$base")" \
    "$(json_escape "$slug")"
}

usage() {
  cat <<'EOF'
Usage:
  tack-worktree.sh create <slug> [--spec S-XXX] [--base <branch>] [--naming <scheme>] [--wt-dir DIR] [--dry-run]
  tack-worktree.sh next-spec-id
  tack-worktree.sh list
  tack-worktree.sh path <slug>
  tack-worktree.sh remove <path-or-slug> [--force]

Environment:
  TACK_REPO_ROOT  optional absolute path to repo root when invoking from subshells
EOF
}

main() {
  require_git
  local cmd="${1:-}"
  shift || true
  case "$cmd" in
    create) cmd_create "$@" ;;
    next-spec-id) cmd_next_spec_id ;;
    list) cmd_list ;;
    path) cmd_path "$@" ;;
    remove) cmd_remove "$@" ;;
    -h|--help|help) usage ;;
    *) usage; exit 1 ;;
  esac
}

main "$@"
