# File template — `AGENTS.md` / `CLAUDE.md` routing

**DEPRECATED.** Tack keeps SDD entry points and routing in repo-root **`TACK.md`** only. Bootstrap **no longer** splices `AGENTS.md` or `CLAUDE.md`. This document is an archive of the old merge workflow.

## Status

The steps below describe the **historical** splice workflow (manual `splice-tack-routing.sh` or hand-edits). **Current Phase 5** does **not** create or update **`AGENTS.md`** / **`CLAUDE.md`**; use [`../bootstrap-phase-05-artifacts.md`](../bootstrap-phase-05-artifacts.md) for what bootstrap actually writes. Keep this file only as a **migration and shape reference** for repos that still carry those filenames.

Worked example, **anonymized and trimmed** from the OrderFlow sample. Use as a shape guide only. ~~The bootstrap skill must **splice surgically**~~ Historical note: previously replaced only the `## Tack routing` H2 section (from `template/routing-snippet.md`).

## Case A — brand-new file (create) (historical)

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
- **`TACK.md`** (repo root) — **primary** IDE-agnostic source for invariants, `<TEST_COMMAND>`, `<LINT_COMMAND>`, `tack.worktree.*`, `tack.routing.*`. Optional **`.cursorrules`** for Cursor-only hints; read **`TACK.md` first**, then **`.cursorrules`** if absent.

## Tack routing

Follow the SDD pipeline end-to-end for every feature, bug, or task in this repo unless explicitly told otherwise.

- **Explicit skill entry points:** use the **`tack-run`** skill for the full pipeline (same dispatch contract as `@project/prompts/auto-orchestrator.md`). Use the **`tack-agent`** skill to run **one** prompt under `project/prompts/` (e.g. architect, qa-tester, reviewer). `@`-mentions remain valid.
- **Default entry point:** dispatch the request through `@project/prompts/auto-orchestrator.md`. It runs the 7-step pipeline (product-manager → architect → qa-tester red → optional harness → worker/specialists → qa-tester green → reviewer, plus optional security audit) as isolated subagents.
- **Passive fallback:** if subagent dispatch is unavailable, follow `@project/prompts/orchestrator.md` instead — same pipeline, but the human runs each step in a fresh chat window.
- **Configuration:** read `<TEST_COMMAND>`, `<LINT_COMMAND>`, parity invariants, and `tack.worktree.*` from **`TACK.md`** at the repo root **first**; if **`TACK.md`** is absent, read **`.cursorrules`** instead. Never invent values not in whichever file holds those keys.
- **Worktrees:** honor `tack.worktree.mode`/`naming`/`base`/`dir`/`cleanup` from **`TACK.md`** or **`.cursorrules`** (same resolution order). The orchestrator decides whether to isolate and whether to offer end-of-run cleanup; do not bypass it. `tack-worktree.sh remove` refuses protected branches (`main`, `master`, `develop`, `staging`, `release/*`, `hotfix/*`, …) unconditionally.
- **Escape hatch:** trivial chores (typo fixes, doc-only edits, comment tweaks) may bypass the orchestrator. Anything that changes behaviour, public contracts, schemas, infra, or business rules must go through `@project/prompts/auto-orchestrator.md`.
- **One chat inlining / `/agents`:** if the lead agent runs every role inline or UI “agent libraries” seem required, read [project/docs/sdd.md](project/docs/sdd.md) → **Multi-platform agent support** — use the optional orchestrator-only preamble with the epic, embed full `project/prompts/<name>.md` per **Dispatch protocol** in `auto-orchestrator.md`, and fall back to `@orchestrator.md` or stepwise **`tack-agent`** when subagent tools are unavailable.
```

**Historical splice workflow:** when migrating older repos only, the `## Tack routing` section was expected to match `template/routing-snippet.md` verbatim (today’s archive file). Do **not** treat the bullets below as current bootstrap instructions.

## Case B — existing file (splice / replace only the H2) (historical)

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
- **Configuration:** read `<TEST_COMMAND>`, `<LINT_COMMAND>`, parity invariants, and `tack.worktree.*` from **`TACK.md`** at the repo root **first**; if **`TACK.md`** is absent, read **`.cursorrules`** instead. Never invent values not in whichever file holds those keys.
- **Worktrees:** honor `tack.worktree.mode`/`naming`/`base`/`dir`/`cleanup` from **`TACK.md`** or **`.cursorrules`** (same resolution order). The orchestrator decides whether to isolate and whether to offer end-of-run cleanup; do not bypass it. `tack-worktree.sh remove` refuses protected branches (`main`, `master`, `develop`, `staging`, `release/*`, `hotfix/*`, …) unconditionally.
- **Escape hatch:** trivial chores (typo fixes, doc-only edits, comment tweaks) may bypass the orchestrator. Anything that changes behaviour, public contracts, schemas, infra, or business rules must go through `@project/prompts/auto-orchestrator.md`.
- **One chat inlining / `/agents`:** if the lead agent runs every role inline or UI “agent libraries” seem required, read [project/docs/sdd.md](project/docs/sdd.md) → **Multi-platform agent support** — use the optional orchestrator-only preamble with the epic, embed full `project/prompts/<name>.md` per **Dispatch protocol** in `auto-orchestrator.md`, and fall back to `@orchestrator.md` or stepwise **`tack-agent`** when subagent tools are unavailable.

## Extra notes

Everything after the routing section must remain byte-for-byte identical.
```

### If the heading is missing

If the file does **not** contain an H2 titled `## Tack routing`, append the full section from `template/routing-snippet.md` at the **end** of the file (after a blank line).

## Idempotency requirement (historical only)

Under the legacy splice workflow, re-running splice with unchanged `template/routing-snippet.md` was expected to yield a **no-op diff** for `AGENTS.md` and/or `CLAUDE.md` when routing keys were unchanged. **Modern bootstrap never performs this splice.**
