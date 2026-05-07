# File template — `AGENTS.md` / `CLAUDE.md` routing

Worked example, **anonymized and trimmed** from the OrderFlow sample. Use as a shape guide. The bootstrap skill must **splice surgically**: replace only the `## Tack routing` H2 section (verbatim from `template/routing-snippet.md`) and preserve every other byte.

## Case A — brand-new file (create)

If `AGENTS.md` (or `CLAUDE.md`) does not exist at the consumer repo root, create it from the matching template:

- `template/AGENTS.md.template` → `AGENTS.md`
- `template/CLAUDE.md.template` → `CLAUDE.md`

Example (`AGENTS.md`, new):

```markdown
# Agents

This repository uses **Tack** (spec-driven multi-agent template) and is read by every agent surface that honors `AGENTS.md`.

## Project layout

- `project/specs/S-XXX-<slug>.md` — product specs with numbered ACs.
- `project/docs/adr/ADR-NNNN-*.md` — architecture decisions.
- `project/docs/{domain-glossary,architecture,sdd}.md` — canonical vocabulary, topology, and pipeline.
- `project/prompts/*.md` — agent prompts (orchestrators, PM, architect, qa-tester, harness-engineer, worker, reviewer, security-engineer, specialists).
- `.cursorrules` (repo root) — invariants, quality commands, `tack.worktree.*`, `tack.routing.*`.

## Tack routing

Follow the SDD pipeline end-to-end for every feature, bug, or task in this repo unless explicitly told otherwise.

- **Explicit skill entry points:** use the **`tack-run`** skill for the full pipeline (same dispatch contract as `@project/prompts/auto-orchestrator.md`). Use the **`tack-agent`** skill to run **one** prompt under `project/prompts/`. `@`-mentions remain valid.
- **Default entry point:** dispatch the request through `@project/prompts/auto-orchestrator.md`.
- **Passive fallback:** if subagent dispatch is unavailable, follow `@project/prompts/orchestrator.md` instead.
- **Configuration:** read `<TEST_COMMAND>`, `<LINT_COMMAND>`, parity invariants, and `tack.worktree.*` from `.cursorrules` at the repo root.
- **Worktrees:** honor `tack.worktree.mode`/`naming`/`base`/`dir` from `.cursorrules`.
- **Escape hatch:** trivial chores (typo fixes, doc-only edits, comment tweaks) may bypass the orchestrator.
```

Notes for the bootstrap skill:

- The exact `## Tack routing` section content must come from `template/routing-snippet.md` (single source of truth). Do not hand-edit it per repo.

## Case B — existing file (splice / replace only the H2)

If the file already exists, do **not** overwrite it. Only replace the section titled `## Tack routing` (H2) and preserve everything else.

### Example input (existing `AGENTS.md`)

```markdown
# Agents

This repo has local conventions and notes above the routing section.

## Project layout

- `project/` contains prompts and governance docs.

## Tack routing

Old content that drifted and must be replaced.

- Old bullet 1
- Old bullet 2

## Extra notes

Everything after the routing section must remain byte-for-byte identical.
```

### Example output (after splice)

Only the `## Tack routing` section is replaced, verbatim from `template/routing-snippet.md`:

```markdown
# Agents

This repo has local conventions and notes above the routing section.

## Project layout

- `project/` contains prompts and governance docs.

## Tack routing

Follow the SDD pipeline end-to-end for every feature, bug, or task in this repo unless explicitly told otherwise.

- **Explicit skill entry points:** use the **`tack-run`** skill for the full pipeline (same dispatch contract as `@project/prompts/auto-orchestrator.md`). Use the **`tack-agent`** skill to run **one** prompt under `project/prompts/` (e.g. architect, qa-tester, reviewer). `@`-mentions remain valid.
- **Default entry point:** dispatch the request through `@project/prompts/auto-orchestrator.md`. It runs the 7-step pipeline (product-manager → architect → qa-tester red → optional harness → worker/specialists → qa-tester green → reviewer, plus optional security audit) as isolated subagents.
- **Passive fallback:** if subagent dispatch is unavailable, follow `@project/prompts/orchestrator.md` instead — same pipeline, but the human runs each step in a fresh chat window.
- **Configuration:** read `<TEST_COMMAND>`, `<LINT_COMMAND>`, parity invariants, and `tack.worktree.*` from `.cursorrules` at the repo root. Never invent values not in that file.
- **Worktrees:** honor `tack.worktree.mode`/`naming`/`base`/`dir` from `.cursorrules`. The orchestrator decides whether to isolate; do not bypass it.
- **Escape hatch:** trivial chores (typo fixes, doc-only edits, comment tweaks) may bypass the orchestrator. Anything that changes behaviour, public contracts, schemas, infra, or business rules must go through `@project/prompts/auto-orchestrator.md`.

## Extra notes

Everything after the routing section must remain byte-for-byte identical.
```

### If the heading is missing

If the file does **not** contain an H2 titled `## Tack routing`, append the full section from `template/routing-snippet.md` at the **end** of the file (after a blank line).

## Idempotency requirement

Re-running the bootstrap skill with unchanged `tack.routing.*` values and unchanged `template/routing-snippet.md` must produce a **no-op diff** for `AGENTS.md` and/or `CLAUDE.md`.
