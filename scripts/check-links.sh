#!/usr/bin/env bash
# Offline link check with lychee (https://github.com/lycheeverse/lychee).
# Uses `lychee` on PATH if present; otherwise downloads a pinned release into the user cache.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

LYCHEE_VERSION="0.22.0"
LYCHEE_TAG="lychee-v${LYCHEE_VERSION}"

resolve_lychee_bin() {
  if command -v lychee >/dev/null 2>&1; then
    command -v lychee
    return
  fi

  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/tack-lychee"
  local os arch name dest tmp
  os="$(uname -s)"
  arch="$(uname -m)"
  case "${os}-${arch}" in
    Darwin-arm64 | Darwin-aarch64) name="lychee-arm64-macos" ;;
    Darwin-x86_64)
      echo "check-links: install lychee on Intel macOS (e.g. brew install lychee) or add to PATH" >&2
      exit 1
      ;;
    Linux-x86_64) name="lychee-x86_64-unknown-linux-gnu" ;;
    Linux-aarch64 | Linux-arm64) name="lychee-aarch64-unknown-linux-gnu" ;;
    *)
      echo "check-links: unsupported platform ${os} ${arch}; install lychee or add to PATH" >&2
      exit 1
      ;;
  esac

  dest="${cache}/${name}-${LYCHEE_VERSION}/lychee"
  if [[ -x "$dest" ]]; then
    echo "$dest"
    return
  fi

  mkdir -p "${cache}/${name}-${LYCHEE_VERSION}"
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  local url="https://github.com/lycheeverse/lychee/releases/download/${LYCHEE_TAG}/${name}.tar.gz"
  echo "check-links: downloading lychee ${LYCHEE_TAG} (${name})…" >&2
  curl -fsSL "$url" | tar xz -C "$tmp"
  install -m 0755 "$tmp/lychee" "$dest"
  trap - EXIT
  rm -rf "$tmp"
  echo "$dest"
}

LYCHEE_BIN="$(resolve_lychee_bin)"

exec "$LYCHEE_BIN" --offline --no-progress --config lychee.toml \
  skills/tack-bootstrap skills/tack-run skills/tack-agent \
  README.md AGENTS.md CHANGELOG.md CONTRIBUTING.md BACKLOG.md CODE_OF_CONDUCT.md SECURITY.md
