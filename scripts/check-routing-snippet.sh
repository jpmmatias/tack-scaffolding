#!/usr/bin/env bash
# routing-snippet.md is deprecated (SDD entry points live in TACK.md.template).
# This check only ensures the archive file exists and still carries a Tack routing heading.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CANON="$ROOT/skills/tack-bootstrap/template/routing-snippet.md"
if [[ ! -f "$CANON" ]]; then
  echo "check-routing-snippet: missing $CANON" >&2
  exit 1
fi
if ! grep -q '^## Tack routing[[:space:]]*$' "$CANON"; then
  echo "check-routing-snippet: $CANON must contain '## Tack routing' H2" >&2
  exit 1
fi

echo "check-routing-snippet: OK (archive file present; consumer routing is TACK.md only)"
