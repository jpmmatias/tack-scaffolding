#!/usr/bin/env bats
# B-05: Regression tests for skills/tack-bootstrap/scripts/detect-stack.sh

load helpers

setup() {
  setup_tmp_git_repo
}

teardown() {
  teardown_tmp_repo
}

@test "detect-stack: empty consumer (no manifest) yields null language and project_class new" {
  git rm -q README.md
  git commit -q -m "empty tree"
  run bash "$DETECT_STACK"
  [[ "$status" -eq 0 ]]
  assert_json_field_eq "language" "" "$output"
  assert_json_field_eq "project_class" "new" "$output"
}

@test "detect-stack: package.json only → javascript + npm" {
  printf '%s\n' '{}' >package.json
  run bash "$DETECT_STACK"
  [[ "$status" -eq 0 ]]
  assert_json_field_eq "language" "javascript" "$output"
  assert_json_field_eq "package_manager" "npm" "$output"
}

@test "detect-stack: tsconfig.json upgrades Node detection to typescript" {
  printf '%s\n' '{}' >package.json
  printf '%s\n' '{}' >tsconfig.json
  run bash "$DETECT_STACK"
  assert_json_field_eq "language" "typescript" "$output"
}

@test "detect-stack: pnpm-lock.yaml selects pnpm" {
  printf '%s\n' '{}' >package.json
  : >pnpm-lock.yaml
  run bash "$DETECT_STACK"
  assert_json_field_eq "package_manager" "pnpm" "$output"
}

@test "detect-stack: react dependency sets framework react" {
  printf '%s\n' '{"dependencies":{"react":"18.0.0"}}' >package.json
  run bash "$DETECT_STACK"
  assert_json_field_eq "framework" "react" "$output"
}

@test "detect-stack: pyproject.toml with poetry + pytest" {
  cat >pyproject.toml <<'EOF'
[tool.poetry]
name = "x"
version = "0.1.0"

[tool.poetry.dependencies]
python = "^3.11"
pytest = "^7.0.0"
EOF
  run bash "$DETECT_STACK"
  assert_json_field_eq "language" "python" "$output"
  assert_json_field_eq "package_manager" "poetry" "$output"
  assert_json_field_eq "test_command" "pytest -q" "$output"
}

@test "detect-stack: setup.py only → python pip" {
  printf '%s\n' '# setup' >setup.py
  run bash "$DETECT_STACK"
  assert_json_field_eq "language" "python" "$output"
  assert_json_field_eq "package_manager" "pip" "$output"
}

@test "detect-stack: Cargo.toml → rust / cargo / cargo test" {
  cat >Cargo.toml <<'EOF'
[package]
name = "crate_x"
version = "0.1.0"
edition = "2021"
EOF
  run bash "$DETECT_STACK"
  assert_json_field_eq "language" "rust" "$output"
  assert_json_field_eq "package_manager" "cargo" "$output"
  assert_json_field_eq "test_command" "cargo test" "$output"
}

@test "detect-stack: go.mod → go" {
  printf '%s\n' 'module example.com/x' >go.mod
  run bash "$DETECT_STACK"
  assert_json_field_eq "language" "go" "$output"
  assert_json_field_eq "package_manager" "go" "$output"
}

@test "detect-stack: Gemfile with rails" {
  printf '%s\n' "gem 'rails'" >Gemfile
  run bash "$DETECT_STACK"
  assert_json_field_eq "language" "ruby" "$output"
  assert_json_field_eq "framework" "rails" "$output"
}

@test "detect-stack: pom.xml → java maven" {
  printf '%s\n' '<project><modelVersion>4.0.0</modelVersion></project>' >pom.xml
  run bash "$DETECT_STACK"
  assert_json_field_eq "language" "java" "$output"
  assert_json_field_eq "package_manager" "maven" "$output"
}

@test "detect-stack: build.gradle.kts → kotlin gradle" {
  printf '%s\n' '// gradle kts' >build.gradle.kts
  run bash "$DETECT_STACK"
  assert_json_field_eq "language" "kotlin" "$output"
  assert_json_field_eq "package_manager" "gradle" "$output"
}

@test "detect-stack: composer.json → php" {
  printf '%s\n' '{}' >composer.json
  run bash "$DETECT_STACK"
  assert_json_field_eq "language" "php" "$output"
  assert_json_field_eq "package_manager" "composer" "$output"
}

@test "detect-stack: project_class existing when threshold exceeded and src/ has files" {
  export SDD_BOOTSTRAP_SOURCE_THRESHOLD=5
  mkdir -p src
  local i
  for i in 1 2 3 4 5 6; do
    printf 'x\n' >"src/f$i.ts"
  done
  run bash "$DETECT_STACK"
  assert_json_field_eq "project_class" "existing" "$output"
}

@test "detect-stack: project_class new when only a few root files (no well-known source dir)" {
  export SDD_BOOTSTRAP_SOURCE_THRESHOLD=5
  printf 'a\n' >a.txt
  printf 'b\n' >b.txt
  printf 'c\n' >c.txt
  printf 'd\n' >d.txt
  printf 'e\n' >e.txt
  printf 'f\n' >f.txt
  run bash "$DETECT_STACK"
  assert_json_field_eq "project_class" "new" "$output"
}
