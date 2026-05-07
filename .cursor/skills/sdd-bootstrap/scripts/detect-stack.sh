#!/usr/bin/env bash
# detect-stack.sh — Phase 1 helper for the sdd-bootstrap skill.
#
# Prints a single-line JSON object to stdout with the keys:
#   language, framework, test_command, lint_command, build_command,
#   package_manager, project_class
#
# Missing values are reported as JSON null. Run from the repository root.
#
# Detection priority (first match wins for language / package manager):
#   1. package.json    -> javascript / typescript / Node
#   2. pyproject.toml  -> python (poetry / pdm / hatch / pip)
#   3. setup.cfg / setup.py / requirements.txt -> python (pip)
#   4. Cargo.toml      -> rust
#   5. go.mod          -> go
#   6. Gemfile         -> ruby
#   7. pom.xml         -> java (maven)
#   8. build.gradle    -> java/kotlin (gradle)
#   9. composer.json   -> php (composer)
# Anything else        -> language=null, framework=null
#
# project_class:
#   - "existing" if non_empty_source_files > THRESHOLD AND at least one of
#     src/, app/, lib/, domain/, services/, tests/ contains files
#   - "new"      otherwise

set -euo pipefail

THRESHOLD="${SDD_BOOTSTRAP_SOURCE_THRESHOLD:-5}"

ROOT="$(pwd)"

have_jq() {
  command -v jq >/dev/null 2>&1
}

# json_escape: escape a string for safe embedding in JSON.
# Falls back to a simple escaper when jq is not available.
json_escape() {
  local s="${1-}"
  if have_jq; then
    printf '%s' "$s" | jq -Rsa .
  else
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '"%s"' "$s"
  fi
}

# Emit a JSON value: null when input is empty, otherwise an escaped string.
json_value() {
  local v="${1-}"
  if [[ -z "$v" ]]; then
    printf 'null'
  else
    json_escape "$v"
  fi
}

# read_json_field FILE PATH
#   Reads a dotted path from a JSON file using jq. Returns empty if jq
#   is unavailable, the file is missing, or the path is not present.
read_json_field() {
  local file="$1"
  local path="$2"
  if [[ ! -f "$file" ]] || ! have_jq; then
    return 0
  fi
  jq -r "$path // empty" "$file" 2>/dev/null || true
}

# has_dep PACKAGE_JSON NAME
#   Returns 0 when NAME appears in dependencies / devDependencies / peerDependencies.
has_dep() {
  local file="$1"
  local name="$2"
  if [[ ! -f "$file" ]]; then
    return 1
  fi
  if have_jq; then
    jq -e --arg n "$name" '
      (.dependencies // {}) + (.devDependencies // {}) + (.peerDependencies // {})
      | has($n)
    ' "$file" >/dev/null 2>&1
  else
    grep -q "\"${name}\"[[:space:]]*:" "$file"
  fi
}

# count_non_empty_source_files: count files outside common artifact dirs.
count_non_empty_source_files() {
  find . \
    -type d \( \
      -name node_modules -o -name vendor -o -name .venv -o -name venv \
      -o -name dist -o -name build -o -name .git -o -name coverage \
      -o -name .next -o -name .turbo -o -name target -o -name __pycache__ \
    \) -prune -o \
    -type f -size +0c -print 2>/dev/null \
    | wc -l \
    | tr -d ' '
}

# has_source_dir: returns 0 if any well-known source dir contains files.
has_source_dir() {
  local d
  for d in src app lib domain services tests test spec; do
    if [[ -d "$ROOT/$d" ]]; then
      if find "$ROOT/$d" -type f -size +0c -not -path '*/node_modules/*' -not -path '*/.git/*' 2>/dev/null \
        | head -n 1 | grep -q .; then
        return 0
      fi
    fi
  done
  return 1
}

LANGUAGE=""
FRAMEWORK=""
TEST_COMMAND=""
LINT_COMMAND=""
BUILD_COMMAND=""
TYPECHECK_COMMAND=""
FORMAT_COMMAND=""
PACKAGE_MANAGER=""

# 1) Node ecosystem
if [[ -f "$ROOT/package.json" ]]; then
  LANGUAGE="javascript"
  if [[ -f "$ROOT/tsconfig.json" ]] || has_dep "$ROOT/package.json" "typescript"; then
    LANGUAGE="typescript"
  fi

  if [[ -f "$ROOT/pnpm-lock.yaml" ]]; then
    PACKAGE_MANAGER="pnpm"
  elif [[ -f "$ROOT/yarn.lock" ]]; then
    PACKAGE_MANAGER="yarn"
  elif [[ -f "$ROOT/bun.lockb" || -f "$ROOT/bun.lock" ]]; then
    PACKAGE_MANAGER="bun"
  else
    PACKAGE_MANAGER="npm"
  fi

  if has_dep "$ROOT/package.json" "next"; then
    FRAMEWORK="nextjs"
  elif has_dep "$ROOT/package.json" "@remix-run/react"; then
    FRAMEWORK="remix"
  elif has_dep "$ROOT/package.json" "@nestjs/core"; then
    FRAMEWORK="nestjs"
  elif has_dep "$ROOT/package.json" "fastify"; then
    FRAMEWORK="fastify"
  elif has_dep "$ROOT/package.json" "express"; then
    FRAMEWORK="express"
  elif has_dep "$ROOT/package.json" "vue"; then
    FRAMEWORK="vue"
  elif has_dep "$ROOT/package.json" "svelte"; then
    FRAMEWORK="svelte"
  elif has_dep "$ROOT/package.json" "react"; then
    FRAMEWORK="react"
  fi

  TEST_SCRIPT="$(read_json_field "$ROOT/package.json" '.scripts.test')"
  LINT_SCRIPT="$(read_json_field "$ROOT/package.json" '.scripts.lint')"
  BUILD_SCRIPT="$(read_json_field "$ROOT/package.json" '.scripts.build')"
  TYPECHECK_SCRIPT="$(read_json_field "$ROOT/package.json" '.scripts.typecheck')"
  if [[ -z "$TYPECHECK_SCRIPT" ]]; then
    TYPECHECK_SCRIPT="$(read_json_field "$ROOT/package.json" '.scripts."type-check"')"
  fi
  FORMAT_SCRIPT="$(read_json_field "$ROOT/package.json" '.scripts.format')"

  if [[ -n "$TEST_SCRIPT" ]]; then
    TEST_COMMAND="$PACKAGE_MANAGER run test"
  fi
  if [[ -n "$LINT_SCRIPT" ]]; then
    LINT_COMMAND="$PACKAGE_MANAGER run lint"
  fi
  if [[ -n "$BUILD_SCRIPT" ]]; then
    BUILD_COMMAND="$PACKAGE_MANAGER run build"
  fi
  if [[ -n "$TYPECHECK_SCRIPT" ]]; then
    TYPECHECK_COMMAND="$PACKAGE_MANAGER run typecheck"
  fi
  if [[ -n "$FORMAT_SCRIPT" ]]; then
    FORMAT_COMMAND="$PACKAGE_MANAGER run format"
  fi

# 2) Python via pyproject.toml
elif [[ -f "$ROOT/pyproject.toml" ]]; then
  LANGUAGE="python"
  if grep -q '\[tool\.poetry\]' "$ROOT/pyproject.toml" 2>/dev/null; then
    PACKAGE_MANAGER="poetry"
  elif grep -q '\[tool\.pdm\]' "$ROOT/pyproject.toml" 2>/dev/null; then
    PACKAGE_MANAGER="pdm"
  elif grep -q '\[tool\.hatch\]' "$ROOT/pyproject.toml" 2>/dev/null; then
    PACKAGE_MANAGER="hatch"
  else
    PACKAGE_MANAGER="pip"
  fi

  if grep -qE '(^|[^a-zA-Z_])fastapi' "$ROOT/pyproject.toml" 2>/dev/null; then
    FRAMEWORK="fastapi"
  elif grep -qE '(^|[^a-zA-Z_])django' "$ROOT/pyproject.toml" 2>/dev/null; then
    FRAMEWORK="django"
  elif grep -qE '(^|[^a-zA-Z_])flask' "$ROOT/pyproject.toml" 2>/dev/null; then
    FRAMEWORK="flask"
  fi

  if grep -qE '(^|[^a-zA-Z_])pytest' "$ROOT/pyproject.toml" 2>/dev/null; then
    TEST_COMMAND="pytest -q"
  fi
  if grep -qE '(^|[^a-zA-Z_])ruff' "$ROOT/pyproject.toml" 2>/dev/null; then
    LINT_COMMAND="ruff check ."
  elif grep -qE '(^|[^a-zA-Z_])flake8' "$ROOT/pyproject.toml" 2>/dev/null; then
    LINT_COMMAND="flake8"
  fi
  if grep -qE '(^|[^a-zA-Z_])mypy' "$ROOT/pyproject.toml" 2>/dev/null; then
    TYPECHECK_COMMAND="mypy ."
  fi
  if grep -qE '(^|[^a-zA-Z_])black' "$ROOT/pyproject.toml" 2>/dev/null; then
    FORMAT_COMMAND="black ."
  fi

# 3) Python via setup.cfg / setup.py / requirements.txt
elif [[ -f "$ROOT/setup.cfg" || -f "$ROOT/setup.py" || -f "$ROOT/requirements.txt" ]]; then
  LANGUAGE="python"
  PACKAGE_MANAGER="pip"
  if grep -qiE '(^|[^a-zA-Z_])pytest' "$ROOT"/{setup.cfg,setup.py,requirements.txt} 2>/dev/null; then
    TEST_COMMAND="pytest -q"
  fi
  if grep -qiE '(^|[^a-zA-Z_])ruff' "$ROOT"/{setup.cfg,setup.py,requirements.txt} 2>/dev/null; then
    LINT_COMMAND="ruff check ."
  elif grep -qiE '(^|[^a-zA-Z_])flake8' "$ROOT"/{setup.cfg,setup.py,requirements.txt} 2>/dev/null; then
    LINT_COMMAND="flake8"
  fi

# 4) Rust
elif [[ -f "$ROOT/Cargo.toml" ]]; then
  LANGUAGE="rust"
  PACKAGE_MANAGER="cargo"
  TEST_COMMAND="cargo test"
  LINT_COMMAND="cargo clippy --all-targets -- -D warnings"
  BUILD_COMMAND="cargo build"
  FORMAT_COMMAND="cargo fmt"
  if grep -q '^name *= *"' "$ROOT/Cargo.toml" 2>/dev/null; then
    FRAMEWORK="$(grep -m1 '^name *= *"' "$ROOT/Cargo.toml" | sed -E 's/^name *= *"([^"]+)".*/\1/')"
  fi

# 5) Go
elif [[ -f "$ROOT/go.mod" ]]; then
  LANGUAGE="go"
  PACKAGE_MANAGER="go"
  TEST_COMMAND="go test ./..."
  LINT_COMMAND="go vet ./..."
  BUILD_COMMAND="go build ./..."
  FORMAT_COMMAND="gofmt -w ."

# 6) Ruby
elif [[ -f "$ROOT/Gemfile" ]]; then
  LANGUAGE="ruby"
  PACKAGE_MANAGER="bundler"
  if grep -q "rails" "$ROOT/Gemfile" 2>/dev/null; then
    FRAMEWORK="rails"
    TEST_COMMAND="bundle exec rspec"
    LINT_COMMAND="bundle exec rubocop"
  fi

# 7) Java/Kotlin via Maven
elif [[ -f "$ROOT/pom.xml" ]]; then
  LANGUAGE="java"
  PACKAGE_MANAGER="maven"
  TEST_COMMAND="mvn test"
  BUILD_COMMAND="mvn package"

# 8) Java/Kotlin via Gradle
elif [[ -f "$ROOT/build.gradle" || -f "$ROOT/build.gradle.kts" ]]; then
  LANGUAGE="java"
  PACKAGE_MANAGER="gradle"
  TEST_COMMAND="./gradlew test"
  BUILD_COMMAND="./gradlew build"
  if [[ -f "$ROOT/build.gradle.kts" ]]; then
    LANGUAGE="kotlin"
  fi

# 9) PHP / Composer
elif [[ -f "$ROOT/composer.json" ]]; then
  LANGUAGE="php"
  PACKAGE_MANAGER="composer"
  TEST_COMMAND="composer test"
fi

# project_class classification
COUNT="$(count_non_empty_source_files)"
PROJECT_CLASS="new"
if [[ "${COUNT:-0}" -gt "$THRESHOLD" ]] && has_source_dir; then
  PROJECT_CLASS="existing"
fi

# Emit JSON
printf '{'
printf '"language":%s,'         "$(json_value "$LANGUAGE")"
printf '"framework":%s,'        "$(json_value "$FRAMEWORK")"
printf '"test_command":%s,'     "$(json_value "$TEST_COMMAND")"
printf '"lint_command":%s,'     "$(json_value "$LINT_COMMAND")"
printf '"typecheck_command":%s,' "$(json_value "$TYPECHECK_COMMAND")"
printf '"build_command":%s,'    "$(json_value "$BUILD_COMMAND")"
printf '"format_command":%s,'   "$(json_value "$FORMAT_COMMAND")"
printf '"package_manager":%s,'  "$(json_value "$PACKAGE_MANAGER")"
printf '"non_empty_source_files":%s,' "${COUNT:-0}"
printf '"project_class":%s'     "$(json_value "$PROJECT_CLASS")"
printf '}\n'
