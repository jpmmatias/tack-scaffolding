# Agents

## Skills

- [`skills/tack-bootstrap/`](skills/tack-bootstrap/) — Bootstrap **Tack** (the spec-driven multi-agent template) into a new or existing repository (governance docs, prompts, specialist routing, optional **parallel git worktrees** via `project/scripts/tack-worktree.sh` and `tack.worktree.*` in `.cursorrules`). Invoke when the user wants to set up spec-driven development with this template.
- [`skills/tack-run/`](skills/tack-run/) — Run the full Tack SDD/TDD pipeline end-to-end via `project/prompts/auto-orchestrator.md` (subagent dispatch). Use in repos that already have `project/` installed.
- [`skills/tack-agent/`](skills/tack-agent/) — Invoke a **single** Tack prompt under `project/prompts/` (PM, architect, QA, worker, reviewer, security, worktree coordinator, **`diagnose`** for disciplined debugging, or a specialist). Use when you need one step only; use `tack-run` for the full pipeline.
