# Agents

## Skills

- [`skills/tack-bootstrap/`](skills/tack-bootstrap/) — Bootstrap **Tack** into a new or existing repository (governance docs, `project/` prompts, specialist routing, optional **parallel git worktrees** via `project/scripts/tack-worktree.sh` and `tack.worktree.*` in repo-root **`TACK.md`**). Invoke when the user wants to set up spec-driven development with this template.
- [`skills/tack-run/`](skills/tack-run/) — Run the full Tack SDD/TDD pipeline end-to-end via `project/prompts/auto-orchestrator.md` (subagent dispatch). Use in consumer repos that already have `project/` installed and repo-root **`TACK.md`**.
- [`skills/tack-agent/`](skills/tack-agent/) — Invoke a **single** Tack prompt under `project/prompts/` (PM, architect, QA, worker, reviewer, security, worktree coordinator, **`diagnose`**, **`event-stormer`**, **`domain-modeler`**, or a specialist). Use when you need one step only; use `tack-run` for the full pipeline.

**Consumer repositories:** Tack configuration and SDD entry points live only in repo-root **`TACK.md`** (not `.cursorrules`, `AGENTS.md`, or `CLAUDE.md`). Skills read **`TACK.md`** for `<TEST_COMMAND>`, `<LINT_COMMAND>`, and `tack.worktree.*`.

## When tack run / tack agent stops or errors

See [`skills/tack-run/references/troubleshooting.md`](skills/tack-run/references/troubleshooting.md) — CLI vs IDE skill, Preflight, gate failures, **STOPPED at Step N**, and recovery (tack-agent rerun, `tack doctor`).
