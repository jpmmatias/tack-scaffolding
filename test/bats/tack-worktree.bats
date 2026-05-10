#!/usr/bin/env bats
# B-06 / B-09: tack-worktree.sh behavior in a throwaway git repository.

load helpers

# Extract the single JSON object line (git/worktree may print non-JSON lines to stdout/stderr).
tw_json_line() {
  bash "$TACK_WORKTREE" "$@" 2>&1 | grep '^{' | head -1
}

setup() {
  setup_tmp_git_repo
}

teardown() {
  teardown_tmp_repo
}

@test "tack-worktree: next-spec-id in fresh repo is S-001" {
  run bash "$TACK_WORKTREE" next-spec-id
  [[ "$status" -eq 0 ]]
  [[ "$output" == "S-001" ]]
}

@test "tack-worktree: next-spec-id bumps after specs in primary tree" {
  mkdir -p project/specs
  printf 'x\n' >project/specs/S-007-seed.md
  git add project/specs/S-007-seed.md
  git commit -q -m "add spec"
  run bash "$TACK_WORKTREE" next-spec-id
  [[ "$status" -eq 0 ]]
  [[ "$output" == "S-008" ]]
}

@test "tack-worktree: next-spec-id considers linked worktrees" {
  mkdir -p project/specs
  printf 'a\n' >project/specs/S-007-a.md
  git add project/specs/S-007-a.md
  git commit -q -m "spec primary"

  local create_json wt_path
  create_json="$(tw_json_line create linked-slug --spec S-008)"
  wt_path="$(printf '%s' "$create_json" | python3 -c "import json,sys; print(json.load(sys.stdin)['path'])")"

  mkdir -p "$wt_path/project/specs"
  printf 'b\n' >"$wt_path/project/specs/S-010-b.md"
  git -C "$wt_path" add project/specs/S-010-b.md
  git -C "$wt_path" commit -q -m "spec in worktree"

  cd "$TMP_REPO" || exit 1
  run bash "$TACK_WORKTREE" next-spec-id
  [[ "$status" -eq 0 ]]
  [[ "$output" == "S-011" ]]
}

@test "tack-worktree: create sanitizes slug (Foo Bar/Baz → foo-bar-baz)" {
  local create_json slug branch
  create_json="$(tw_json_line create "Foo Bar/Baz")"
  slug="$(printf '%s' "$create_json" | python3 -c "import json,sys; print(json.load(sys.stdin)['slug'])")"
  branch="$(printf '%s' "$create_json" | python3 -c "import json,sys; print(json.load(sys.stdin)['branch'])")"
  [[ "$slug" == "foo-bar-baz" ]]
  [[ "$branch" == "feature/S-001-foo-bar-baz" ]]
}

@test "tack-worktree: create rejects empty slug" {
  run bash "$TACK_WORKTREE" create ""
  [[ "$status" -ne 0 ]]
}

@test "tack-worktree: create appends default .worktrees/ to .gitignore" {
  tw_json_line create plain-slug >/dev/null
  grep -qF '.worktrees/' .gitignore
}

@test "tack-worktree: create --wt-dir custom-wt uses directory and gitignore (B-09)" {
  local create_json wt_path
  create_json="$(tw_json_line create custom-slug --wt-dir custom-wt)"
  grep -qF 'custom-wt/' .gitignore
  wt_path="$(printf '%s' "$create_json" | python3 -c "import json,sys; print(json.load(sys.stdin)['path'])")"
  # JSON uses pwd -P (symlink-resolved); compare by suffix, not raw TMP_REPO string.
  [[ "$wt_path" == */custom-wt/* ]]
}

@test "tack-worktree: list emits valid JSON array" {
  tw_json_line create list-slug >/dev/null
  local list_json
  list_json="$(bash "$TACK_WORKTREE" list 2>/dev/null)"
  printf '%s' "$list_json" | python3 -c "import json,sys; json.load(sys.stdin)"
}

@test "tack-worktree: remove refuses dirty worktree without --force" {
  local create_json wt_path
  create_json="$(tw_json_line create dirty-slug)"
  wt_path="$(printf '%s' "$create_json" | python3 -c "import json,sys; print(json.load(sys.stdin)['path'])")"
  printf '\n' >>"$wt_path/README.md"
  cd "$TMP_REPO" || exit 1
  run bash -c 'bash "$1" remove dirty-slug 2>&1' bash "$TACK_WORKTREE"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"uncommitted"* ]]
}

@test "tack-worktree: remove refuses unmerged branch without --force" {
  local create_json wt_path
  create_json="$(tw_json_line create unmerged-slug --spec S-020)"
  wt_path="$(printf '%s' "$create_json" | python3 -c "import json,sys; print(json.load(sys.stdin)['path'])")"
  printf 'wt-only-change\n' >>"$wt_path/README.md"
  git -C "$wt_path" add README.md
  git -C "$wt_path" commit -q -m "only in worktree"
  cd "$TMP_REPO" || exit 1
  run bash -c 'bash "$1" remove unmerged-slug 2>&1' bash "$TACK_WORKTREE"
  [[ "$status" -ne 0 ]]
  [[ "$output" == *"not merged"* ]]
}

@test "tack-worktree: remove --force succeeds on dirty worktree" {
  local create_json wt_path out
  create_json="$(tw_json_line create force-slug)"
  wt_path="$(printf '%s' "$create_json" | python3 -c "import json,sys; print(json.load(sys.stdin)['path'])")"
  printf '\n' >>"$wt_path/README.md"
  cd "$TMP_REPO" || exit 1
  # remove prints JSON to stdout; errors to stderr
  out="$(bash "$TACK_WORKTREE" remove "$wt_path" --force 2>/dev/null)"
  [[ "$out" == *"\"removed\""* ]]
}

@test "tack-worktree: create --dry-run prints JSON without worktree, branch, or gitignore mutation" {
  [[ ! -f .gitignore ]]
  local out branch safe_path
  out="$(tw_json_line create --dry-run dry-run-slug)"
  branch="$(printf '%s' "$out" | python3 -c "import json,sys; print(json.load(sys.stdin)['branch'])")"
  [[ "$branch" == "feature/S-001-dry-run-slug" ]]
  safe_path="$TMP_REPO/.worktrees/feature-S-001-dry-run-slug"
  [[ ! -e "$safe_path" ]]
  run git rev-parse --verify --quiet "refs/heads/feature/S-001-dry-run-slug"
  [[ "$status" -ne 0 ]]
  [[ ! -f .gitignore ]]
}

@test "tack-worktree: prefers TACK.md over .cursorrules for tack.worktree.dir" {
  printf '%s\n' '- `tack.worktree.dir`: **`.wrong`** — legacy.' >.cursorrules
  printf '%s\n' '- `tack.worktree.dir`: **`.from-tack`** — canonical.' >TACK.md
  local create_json wt_path
  create_json="$(tw_json_line create tackpref-slug)"
  wt_path="$(printf '%s' "$create_json" | python3 -c "import json,sys; print(json.load(sys.stdin)['path'])")"
  [[ "$wt_path" == */.from-tack/* ]]
}

@test "tack-worktree: create applies tack.worktree.dir from TACK.md when --wt-dir omitted" {
  printf '%s\n' '- `tack.worktree.dir`: **`.tack-wt`** — custom parent.' >TACK.md
  local create_json wt_path
  create_json="$(tw_json_line create crs-dir-slug)"
  grep -qF '.tack-wt/' .gitignore
  wt_path="$(printf '%s' "$create_json" | python3 -c "import json,sys; print(json.load(sys.stdin)['path'])")"
  [[ "$wt_path" == */.tack-wt/* ]]
}

@test "tack-worktree: create applies tack.worktree.base from TACK.md" {
  git branch develop HEAD
  printf '%s\n' '- `tack.worktree.base`: **develop**' >TACK.md
  local create_json base br
  create_json="$(tw_json_line create crs-base-slug --spec S-003)"
  base="$(printf '%s' "$create_json" | python3 -c "import json,sys; print(json.load(sys.stdin)['base'])")"
  [[ "$base" == "develop" ]]
  br="$(printf '%s' "$create_json" | python3 -c "import json,sys; print(json.load(sys.stdin)['branch'])")"
  git merge-base --is-ancestor "refs/heads/$br" "refs/heads/develop"
}

@test "tack-worktree: create applies tack.worktree.naming feature/<slug> from TACK.md" {
  printf '%s\n' '- `tack.worktree.naming`: **`feature/<slug>`** no spec id.' >TACK.md
  local create_json branch
  create_json="$(tw_json_line create crs-name-slug --spec S-002)"
  branch="$(printf '%s' "$create_json" | python3 -c "import json,sys; print(json.load(sys.stdin)['branch'])")"
  [[ "$branch" == "feature/crs-name-slug" ]]
}
