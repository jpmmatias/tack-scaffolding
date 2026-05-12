#!/usr/bin/env bash
# B-28: Ensure tack-agent catalog → template prompts exist and model-routing docs agree.
set -euo pipefail

# Tests may set TACK_DISPATCH_CONTRACT_ROOT to a temp copy of the repo (Bats drift case).
ROOT="${TACK_DISPATCH_CONTRACT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
CATALOG="$ROOT/skills/tack-agent/references/agent-catalog.md"
AUTO="$ROOT/skills/tack-bootstrap/template/prompts/auto-orchestrator.md"
PROMPTS="$ROOT/skills/tack-bootstrap/template/prompts"

die() {
  echo "check-dispatch-contract: $*" >&2
  exit 1
}

# --- Stock agent prompt files (## Stock agents table) ---
AGENT_FILES=()
while IFS= read -r line; do
  AGENT_FILES+=("$line")
done < <(
  sed -n '/^## Stock agents$/,/^## /p' "$CATALOG" \
    | grep -oE "\`[a-zA-Z0-9_-]+\.md\`" \
    | tr -d '`' | sort -u
)

[[ ${#AGENT_FILES[@]} -ge 1 ]] || die "no .md prompt files parsed from agent-catalog.md (## Stock agents)"

missing=0
for f in "${AGENT_FILES[@]}"; do
  if [[ ! -f "$PROMPTS/$f" ]]; then
    echo "missing prompt: skills/tack-bootstrap/template/prompts/$f (from agent-catalog stock table)" >&2
    missing=1
  fi
done
[[ $missing -eq 0 ]] || die "one or more stock agent prompts missing under template/prompts/"

python3 - "$AUTO" "$CATALOG" <<'PY'
import re
import sys
from pathlib import Path


def read(p: Path) -> str:
    return p.read_text(encoding="utf-8")


def first_markdown_table_rows_after(lines: list[str], start_idx: int) -> list[str]:
    """Scan forward from start_idx; return data rows of the first pipe-table found."""
    i = start_idx + 1
    while i < len(lines) and not lines[i].lstrip().startswith("|"):
        i += 1
    if i >= len(lines):
        raise SystemExit("expected a markdown table after heading")
    table_lines: list[str] = []
    while i < len(lines) and lines[i].lstrip().startswith("|"):
        table_lines.append(lines[i].rstrip())
        i += 1
    if len(table_lines) < 3:
        raise SystemExit("table too short (need header, divider, ≥1 data row)")
    return table_lines[2:]


def extract_model_table_by_heading(text: str, heading: str) -> list[str]:
    lines = text.splitlines()
    for idx, line in enumerate(lines):
        if line == heading:
            return first_markdown_table_rows_after(lines, idx)
    raise SystemExit(f"heading not found: {heading!r}")


def norm_table_rows(rows: list[str]) -> list[str]:
    out: list[str] = []
    for r in rows:
        cells = [c.strip() for c in r.strip().strip("|").split("|")]
        out.append("|".join(cells))
    return sorted(out)


auto_path, catalog_path = map(Path, sys.argv[1:3])
auto = read(auto_path)
catalog = read(catalog_path)

cat_rows = extract_model_table_by_heading(catalog, "## Model routing (default slugs)")
auto_rows = extract_model_table_by_heading(auto, "# Model routing")

nc = norm_table_rows(cat_rows)
na = norm_table_rows(auto_rows)
if nc != na:
    sys.stderr.write("Model routing table drift between agent-catalog and auto-orchestrator (normalized cell comparison failed).\n")
    sys.stderr.write(f"catalog: {nc}\nauto:    {na}\n")
    raise SystemExit(1)

# Sanity: every Pipeline-key referenced in the agent-catalog (Pipeline model file table)
# must appear at least once in the auto-orchestrator step→key bullets.
def extract_catalog_keys(text: str) -> set[str]:
    m = re.search(r"^## Pipeline model file \(override\)\n(.+?)(?=^## )", text, re.MULTILINE | re.DOTALL)
    if not m:
        raise SystemExit("agent-catalog.md: missing ## Pipeline model file (override) section")
    keys = set()
    for token in re.findall(r"`([a-z_]+)`", m.group(1)):
        if "_" in token or token in {"worker", "architect", "reviewer"}:
            keys.add(token)
    keys.discard("auto")
    return keys


def extract_auto_keys(text: str) -> set[str]:
    m = re.search(r"^Step → \*\*key\*\*[^\n]*\n\n((?:- .+\n)+)", text, re.MULTILINE)
    if not m:
        raise SystemExit("auto-orchestrator.md: missing Step → **key** bullets")
    return set(re.findall(r"`([a-z_]+)`", m.group(1)))


cat_keys = extract_catalog_keys(catalog)
auto_keys = extract_auto_keys(auto)
missing_in_auto = cat_keys - auto_keys
# Out-of-band agents (diagnose, domain-modeler, event-stormer) intentionally have no
# stock pipeline key — they reuse architect/qa_tester or require user-added keys.
out_of_band = {"diagnose", "domain_modeler", "event_stormer"}
missing_in_auto -= out_of_band
if missing_in_auto:
    sys.stderr.write(
        f"agent-catalog Pipeline keys not in auto-orchestrator Step→key bullets: {sorted(missing_in_auto)}\n"
    )
    raise SystemExit(1)

PY

echo "OK: ${#AGENT_FILES[@]} stock agent prompts resolved; model table + pipeline keys match."
