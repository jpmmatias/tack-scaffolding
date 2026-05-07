#!/usr/bin/env bash
# B-28: Ensure tack-agent catalog → template prompts exist and model-routing docs agree.
set -euo pipefail

# Tests may set TACK_DISPATCH_CONTRACT_ROOT to a temp copy of the repo (Bats drift case).
ROOT="${TACK_DISPATCH_CONTRACT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
CATALOG="$ROOT/skills/tack-agent/references/agent-catalog.md"
PIPELINE="$ROOT/skills/tack-run/references/pipeline-state-machine.md"
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
    | grep -oE '`[a-zA-Z0-9_-]+\.md`' \
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

python3 - "$PIPELINE" "$AUTO" "$CATALOG" <<'PY'
import difflib
import re
import sys
from pathlib import Path


def read(p: Path) -> str:
    return p.read_text(encoding="utf-8")


def norm_step_line(line: str) -> str:
    s = line.strip()
    s = s.replace("**", "").replace("`", "")
    s = re.sub(r"\s+$", "", s)
    return s


def extract_step_bullets_pipeline(text: str) -> list[str]:
    m = re.search(r"^## Step → model\n\n((?:- .+\n)+)", text, re.MULTILINE)
    if not m:
        raise SystemExit("pipeline-state-machine.md: missing ## Step → model bullets")
    return sorted(norm_step_line(x) for x in m.group(1).strip().splitlines())


def extract_step_bullets_auto(text: str) -> list[str]:
    m = re.search(
        r"^Step → tag mapping:\n\n(.+?)^---\s*$",
        text,
        re.MULTILINE | re.DOTALL,
    )
    if not m:
        raise SystemExit("auto-orchestrator.md: missing Step → tag mapping block before ---")
    body = m.group(1).strip()
    lines = [x for x in body.splitlines() if x.strip().startswith("- ")]
    if not lines:
        raise SystemExit("auto-orchestrator.md: no step bullets under Step → tag mapping")
    return sorted(norm_step_line(x) for x in lines)


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
    # [0] header, [1] |---|---|, [2:] data
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


def extract_tldr_dispatch_tags(text: str) -> list[str]:
    """Tags from '# Default pipeline order' numbered list + optional security line."""
    m = re.search(
        r"^# Default pipeline order.*?\n\n((?:[0-9]+\..+\n)+)",
        text,
        re.MULTILINE | re.DOTALL,
    )
    if not m:
        raise SystemExit("auto-orchestrator.md: missing Default pipeline order block")
    block = m.group(1)
    tags = re.findall(r"\*\*`(\[[^]]+\])`\*\*", block)
    opt = re.search(r"^Optional:\s+\*\*`(\[[^]]+\])`\*\*", text, re.MULTILINE)
    if opt:
        tags.append(opt.group(1))
    return tags


pipeline_path, auto_path, catalog_path = map(Path, sys.argv[1:4])
pipeline = read(pipeline_path)
auto = read(auto_path)
catalog = read(catalog_path)

pb = extract_step_bullets_pipeline(pipeline)
ab = extract_step_bullets_auto(auto)
if pb != ab:
    sys.stderr.write("Step → model drift between pipeline-state-machine and auto-orchestrator:\n")
    sys.stderr.write(
        "".join(difflib.unified_diff(pb, ab, lineterm="\n", fromfile="pipeline", tofile="auto"))
    )
    raise SystemExit(1)

cat_rows = extract_model_table_by_heading(catalog, "## Model routing convention")
pipe_rows = extract_model_table_by_heading(pipeline, "## Model routing (Cursor slugs)")
auto_rows = extract_model_table_by_heading(auto, "# Model routing")

nc = norm_table_rows(cat_rows)
np = norm_table_rows(pipe_rows)
na = norm_table_rows(auto_rows)
if nc != np or nc != na:
    sys.stderr.write("Model routing table drift (normalized cell comparison failed).\n")
    raise SystemExit(1)

expected_tags: list[str] = []
for line in pb:
    for m in re.finditer(r"(\[[A-Za-z]+\])", line):
        expected_tags.append(m.group(1))
# Unique preserve order not needed for membership
tag_set = set(expected_tags)

tldr_tags = extract_tldr_dispatch_tags(auto)
for t in tldr_tags:
    if t not in tag_set:
        sys.stderr.write(
            f"TL;DR tag {t!r} not found in Step → model bullets (pipeline copy).\n"
        )
        raise SystemExit(1)

PY

echo "OK: ${#AGENT_FILES[@]} stock agent prompts resolved; model tables + step maps match."
