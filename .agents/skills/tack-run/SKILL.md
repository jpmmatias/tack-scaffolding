---
name: tack-run
version: 0.2.0
license: MIT
description: Use when running the full Tack SDD/TDD pipeline in a bootstrapped repo. Triggers on run Tack, auto-orchestrator, epic-to-reviewer flow, or shipping via the spec pipeline.
---

# tack-run

You execute **Tack**'s active SDD pipeline by following **`project/prompts/auto-orchestrator.md`** in the **consumer** repository. You are a **dispatcher only**: read prompts from disk, run gates, use **`Task`** (`subagent_type: generalPurpose`) with the right `model` and `working_directory`. Do **not** create specs, plans, tests, or application code yourself — subagents do, per that file’s **Outputs**. Do **not** write specs, plans, tests, or app source in your reply except the **Final report**. You **may** use shell and read-only access for **implementation verification**: **`<TEST_COMMAND>`** / **`<LINT_COMMAND>`** from repo-root **`TACK.md`**, `git diff`, governing spec — per **`references/post-completion-verification.md`**.

**`${SKILL_DIR}`** contains this `SKILL.md`. Paths below are relative to the **consumer repo root** (**`TACK.md`**, `tack.worktree.*`).

---

## When to use

- Full pipeline, auto-orchestrator, or "Tack" for a feature/bug/task; epic → PM → … → reviewer (optional security).
- For **one** agent only → **`tack-agent`**.

**Errors, stops, CLI vs chat:** **`${SKILL_DIR}/references/troubleshooting.md`**.

---

## Preconditions (fail fast)

1. **`project/prompts/auto-orchestrator.md`** exists.
2. **`project/docs/tack-pipeline-models.md`** has required pipeline keys when using per-step slugs (same **Preflight** as `auto-orchestrator.md`). Do not improvise slugs without that file unless the user overrides.
3. Repo-root **`TACK.md`** defines `<TEST_COMMAND>`, `<LINT_COMMAND>` (and `tack.worktree.*` as needed). **`project/scripts/tack-resolve-config.sh`** / **`tack-worktree.sh`** read **`TACK.md` only**. If missing → stop; **`tack-bootstrap`** or `project/TACK.md.template`.

**`tack.routing.auto = no`** does **not** block explicit **`tack-run`**.

---

## Behavior rules

1. **Detect language** (PT or EN). Direct tone, no fluff, no emojis (except `[ ]` / `[x]` in checklists).
2. **Read the full** `project/prompts/auto-orchestrator.md` at run start — source of truth for order, inputs, gates, stops.
3. **`${SKILL_DIR}/references/`** shortcuts: `pipeline-state-machine.md`, `stop-conditions.md`, `final-report-template.md`, **`post-completion-verification.md`**. On conflict → **`auto-orchestrator.md` wins**.
4. **Model slugs:** **Preflight** → every key from **`project/docs/tack-pipeline-models.md`**; **Upward fallback** per **Model routing** in `auto-orchestrator.md`. Legacy tier notes → `pipeline-state-machine.md` only.
5. **PM Step 1:** `STATUS: NEEDS_INPUT` → **`AskQuestion`** per `auto-orchestrator.md`; `cancel grill` → stop conditions.
6. **Isolation:** retain only what the next dispatch + Final report need (`auto-orchestrator.md` **Isolation**).
7. **Worktree:** Step −1 success → **Worktree anchor** + **Dispatch protocol** in `auto-orchestrator.md`: Steps 1–7 / 7b pin **`working_directory`** to absolute `worktree_path`, prepend **`cd`** + repo-root lines to **INPUTS** (including PM iteration 1). Step 0 lists **`<worktree_path>/project/specs/`**. Wrong tree → **`git -C`** checks + **Wrong-tree detection and recovery** in that file.
8. **No auto-retry** of failed steps.
9. **Platform tool mapping:** `auto-orchestrator.md` → **Platform tool mapping** (Cursor vs Claude Code vs fallback).

---

## Execution outline

1. Preconditions; **Preflight** per `auto-orchestrator.md`; capture epic/task.
2. Parse **`tack.worktree.*`** from **`TACK.md`**; Step −1 or skip if `never`.
3. Steps 0–7 / 7b; **Dispatch protocol** (full prompt + **INPUTS**).
4. Gates per `auto-orchestrator.md`.
5. **Post-completion implementation verification** — when Step 7 / 7b **PASS** and run would be **COMPLETED**, run **`references/post-completion-verification.md`**; set Final report **Implementation verification**; **FAILED** / **GAP** handling per that file and outline below.
6. **Final report** → `references/final-report-template.md`.
7. **`COMPLETED` + worktree** + `gh` → Step 8 PR offer per `auto-orchestrator.md`.
8. **`COMPLETED` + worktree** + `tack.worktree.cleanup` ≠ `never` → Step 9 cleanup offer per `auto-orchestrator.md`.

Stop on `references/stop-conditions.md` / `auto-orchestrator.md` **Stop conditions**. Steps 8–9 failures only update report fields.

**Step 5 detail:** If verification **FAILED**, or **GAP** with no acceptable partial delivery → **Status** `STOPPED at verification — <reason>` (no Steps 8–9). **GAP** + user accepts documented gaps → may **COMPLETED** with **Implementation verification: GAP — …**. Earlier **STOPPED** → optional one-line note under **Implementation verification**.

---

## Additional resources

- `references/post-completion-verification.md` — host verification checklist (also referenced from execution outline).
- `references/troubleshooting.md`, `pipeline-state-machine.md`, `stop-conditions.md`, `final-report-template.md`
- Consumer: `project/prompts/auto-orchestrator.md`, `project/docs/tack-pipeline-models.md`
