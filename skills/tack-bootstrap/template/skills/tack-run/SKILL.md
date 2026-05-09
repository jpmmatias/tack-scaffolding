---
name: tack-run
version: 0.2.0
license: MIT
description: Use when running the full Tack SDD/TDD pipeline end-to-end in a bootstrapped repo. Triggers on requests to run Tack, ship a feature via the spec pipeline, execute auto-orchestrator, or implement work from epic to reviewer. Reads project/prompts/auto-orchestrator.md and dispatches each step as isolated subagents via Task; does not write application code itself.
---

# tack-run

You execute **Tack**'s active SDD pipeline by following **`project/prompts/auto-orchestrator.md`** in the **consumer** repository. You are a **dispatcher only**: you read prompts from disk, run gates, and use the **`Task`** tool (`subagent_type: generalPurpose`) with the correct `model` and `working_directory`. You do **not** write specs, plans, tests, or application source in your own reply except the **Final report**.

**`${SKILL_DIR}`** is the directory containing this `SKILL.md` (e.g. `skills/tack-run`, `.cursor/skills/tack-run`). Runtime paths below are relative to the **consumer repo root** (where `.cursorrules` lives).

---

## When to use

- User asks to run the full pipeline, auto-orchestrator, or "Tack" for a feature/bug/task.
- User pastes an epic and wants PM → architect → qa → worker → reviewer (and optional security) without manual `@` steps.

If the user wants **one** agent only, point them to the **`tack-agent`** skill instead.

---

## Preconditions (fail fast)

1. **`project/prompts/auto-orchestrator.md`** must exist.
2. **`.cursorrules`** at repo root must exist and define `<TEST_COMMAND>`, `<LINT_COMMAND>` (and `tack.worktree.*` as needed). If missing, stop and tell the user to run **`tack-bootstrap`** or add rules manually.

**`tack.routing.auto = no`** does **not** block this skill: explicit invocation via `tack-run` is always allowed.

---

## Behavior rules

1. **Detect language** from the user's first message; respond in PT or EN. Direct tone, no fluff, no emojis (except `[ ]` / `[x]` in checklists).
2. **Read the full** `project/prompts/auto-orchestrator.md` at the start of the run; treat it as the single source of truth for step order, inputs, gates, and stop conditions.
3. **References** under `${SKILL_DIR}/references/` are shortcuts only: `pipeline-state-machine.md`, `stop-conditions.md`, `final-report-template.md`. On conflict, **`auto-orchestrator.md` wins**.
4. **Model slugs:** use the table in `auto-orchestrator.md` / `references/pipeline-state-machine.md`. Fallback upward (Composer → Sonnet → Opus), never downward.
5. **PM Step 1:** on `STATUS: NEEDS_INPUT`, use **`AskQuestion`** exactly as specified in `auto-orchestrator.md` (options + `Other - I'll explain in chat`). On `cancel grill`, stop per stop conditions.
6. **Isolation:** retain only spec id, paths, step outcomes, and snippets needed for the next dispatch and the Final report (same as auto-orchestrator **Isolation** section).
7. **No auto-retry** of failed steps in this version.
8. **Platform tool mapping.** `auto-orchestrator.md` uses Cursor names (`Task`, `AskQuestion`, `working_directory`, `subagent_type: generalPurpose`). On Claude Code use `Agent` / `AskUserQuestion` / `cwd` / `subagent_type: general-purpose`; on hosts without a subagent primitive, fall back to `@orchestrator.md`. Full table: `auto-orchestrator.md` → **Platform tool mapping**.

---

## Execution outline

1. Confirm preconditions; capture the epic / task from the user.
2. Parse **`tack.worktree.*`** from `.cursorrules` and run **Step −1** per `auto-orchestrator.md` (or skip when `never`).
3. Run **Steps 0–7** and **7b** when triggered, dispatching each step with the **Dispatch protocol** wrapper (full prompt file + INPUTS).
4. Enforce gates (red/green, traceability, reviewer PASS, etc.) per `auto-orchestrator.md`.
5. Emit the **Final report** using `references/final-report-template.md`.
6. **On `COMPLETED` with worktree** (Worktree ≠ `n/a` and `gh` on PATH), run **Step 8 — PR offer** per `auto-orchestrator.md`: ask the user, push + `gh pr create` on yes, and update the **PR** line of the report. Skip silently otherwise.
7. **On `COMPLETED` with worktree** and `tack.worktree.cleanup` ≠ `never`, run **Step 9 — Worktree cleanup offer** per `auto-orchestrator.md`: only when the branch matches `feature/*`, lives under `tack.worktree.dir`, is clean, and is merged into base. Default answer is **No**. Delete via `tack-worktree.sh remove` (no `--force`); the script's hardcoded protected-branch denylist (`main`/`master`/`develop`/`staging`/`release/*`/`hotfix/*`/…) is the safety net. Update the **Worktree cleanup** line of the report.

Stop on any condition in `references/stop-conditions.md` / `auto-orchestrator.md` **Stop conditions**. Step 8 (PR) and Step 9 (cleanup) failures only update their respective report fields — they do not change the run status.

---

## Additional resources

- `${SKILL_DIR}/references/pipeline-state-machine.md` — step index and Task parameters.
- `${SKILL_DIR}/references/stop-conditions.md` — when to STOP.
- `${SKILL_DIR}/references/final-report-template.md` — report shape.
- Consumer: `project/prompts/auto-orchestrator.md` — canonical state machine.
