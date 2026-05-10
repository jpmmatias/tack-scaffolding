---
name: tack-run
version: 0.2.0
license: MIT
description: Use when running the full Tack SDD/TDD pipeline end-to-end in a bootstrapped repo. Triggers on requests to run Tack, ship a feature via the spec pipeline, execute auto-orchestrator, or implement work from epic to reviewer. Reads project/prompts/auto-orchestrator.md and dispatches each step as isolated subagents via Task; does not write application code itself.
---

# tack-run

You execute **Tack**'s active SDD pipeline by following **`project/prompts/auto-orchestrator.md`** in the **consumer** repository. You are a **dispatcher only**: you read prompts from disk, run gates, and use the **`Task`** tool (`subagent_type: generalPurpose`) with the correct `model` and `working_directory`. Do **not** use file or shell tools to create specs, plans, tests, or application code yourself — only subagents do, per that orchestrator’s **Outputs** section. You do **not** write specs, plans, tests, or application source in your own reply except the **Final report**. You **may** use shell and read-only file access for **implementation verification** only: run **`<TEST_COMMAND>`** / **`<LINT_COMMAND>`** from repo-root **`TACK.md`** or **`.cursorrules`**, `git diff`, and read the governing spec — per **Post-completion implementation verification** below.

**`${SKILL_DIR}`** is the directory containing this `SKILL.md` (e.g. `skills/tack-run`, `.cursor/skills/tack-run`). Runtime paths below are relative to the **consumer repo root** (where repo-root **`TACK.md`** (canonical) or legacy **`.cursorrules`** holds quality commands and `tack.worktree.*`).

---

## When to use

- User asks to run the full pipeline, auto-orchestrator, or "Tack" for a feature/bug/task.
- User pastes an epic and wants PM → architect → qa → worker → reviewer (and optional security) without manual `@` steps.

If the user wants **one** agent only, point them to the **`tack-agent`** skill instead.

When the user reports **errors, unexpected stops, or confusion between the `tack` CLI and chat skills**, use **`${SKILL_DIR}/references/troubleshooting.md`** as the user-facing runbook (CLI vs skill, Preflight, gates, recovery checklist).

---

## Preconditions (fail fast)

1. **`project/prompts/auto-orchestrator.md`** must exist.
2. **`project/docs/tack-pipeline-models.md`** must exist with all required pipeline keys when you rely on per-step slugs (same **Preflight** as `auto-orchestrator.md`). If missing, `tack-run` / `auto-orchestrator` stops at Preflight — do not improvise slugs without that file or explicit user override.
3. **`TACK.md`** at repo root (**canonical**) **or** legacy **`.cursorrules`** must exist and define `<TEST_COMMAND>`, `<LINT_COMMAND>` (and `tack.worktree.*` as needed). **`project/scripts/tack-resolve-config.sh`** and **`tack-worktree.sh`** read **`TACK.md` first**, then **`.cursorrules`**. If **both** are missing, stop and tell the user to run **`tack-bootstrap`** or add **`TACK.md`** manually.

**`tack.routing.auto = no`** does **not** block this skill: explicit invocation via `tack-run` is always allowed.

---

## Behavior rules

1. **Detect language** from the user's first message; respond in PT or EN. Direct tone, no fluff, no emojis (except `[ ]` / `[x]` in checklists).
2. **Read the full** `project/prompts/auto-orchestrator.md` at the start of the run; treat it as the single source of truth for step order, inputs, gates, and stop conditions.
3. **References** under `${SKILL_DIR}/references/` are shortcuts only: `pipeline-state-machine.md`, `stop-conditions.md`, `final-report-template.md`. On conflict, **`auto-orchestrator.md` wins**.
4. **Model slugs:** run **`auto-orchestrator.md`** **Preflight** first — load every key from **`project/docs/tack-pipeline-models.md`**. Each **`Task`** uses `models.<key>` from that file; **Upward fallback** per **Model routing** in `auto-orchestrator.md`. Stock tier defaults in `references/pipeline-state-machine.md` apply only when explaining legacy behavior.
5. **PM Step 1:** on `STATUS: NEEDS_INPUT`, use **`AskQuestion`** exactly as specified in `auto-orchestrator.md` (options + `Other - I'll explain in chat`). On `cancel grill`, stop per stop conditions.
6. **Isolation:** retain only spec id, paths, step outcomes, and snippets needed for the next dispatch and the Final report (same as auto-orchestrator **Isolation** section).
7. **Worktree:** When Step −1 succeeds, follow **auto-orchestrator.md** **Worktree anchor** and **Dispatch protocol**: every **Step 1–7** and **7b** `Task` pins **`working_directory` / `cwd` to absolute `worktree_path`** and prepends the **`cd` + repository-root lines** to **INPUTS** (**including PM iteration 1**). **Step 0** spec-id listing uses **`<worktree_path>/project/specs/`**, not the IDE workspace root when that root is the primary clone. If edits may have landed in the wrong checkout, run **`git -C <worktree_path> status`** and **`git -C <repo_root> status`** and reconcile per **Wrong-tree detection and recovery** in that file before continuing.
8. **No auto-retry** of failed steps in this version.
9. **Platform tool mapping.** `auto-orchestrator.md` uses Cursor names (`Task`, `AskQuestion`, `working_directory`, `subagent_type: generalPurpose`). On Claude Code use `Agent` / `AskUserQuestion` / `cwd` / `subagent_type: general-purpose`; on hosts without a subagent primitive, fall back to `@orchestrator.md`. Full table: `auto-orchestrator.md` → **Platform tool mapping**.

---

## Execution outline

1. Confirm preconditions; run **Preflight** (`project/docs/tack-pipeline-models.md`) per `auto-orchestrator.md`; capture the epic / task from the user.
2. Parse **`tack.worktree.*`** from repo-root **`TACK.md`** (canonical), then legacy **`.cursorrules`** if **`TACK.md`** is absent (same resolution order as `project/scripts/tack-worktree.sh`) and run **Step −1** per `auto-orchestrator.md` (or skip when `never`).
3. Run **Steps 0–7** and **7b** when triggered, dispatching each step with the **Dispatch protocol** wrapper (full prompt file + INPUTS).
4. Enforce gates (red/green, traceability, reviewer PASS, etc.) per `auto-orchestrator.md`.
5. **Post-completion implementation verification (host)** — when Step 7 (and Step 7b if it ran) returns **PASS** and the run would otherwise be **COMPLETED**, run the checklist in **Post-completion implementation verification** (same **working_directory** / worktree as downstream steps). Populate the **Implementation verification** line in the Final report. If verification **FAILED**, or **GAP** with no acceptable partial delivery, set **Status** to `STOPPED at verification — <reason>` (do not run Steps 8–9). If the run **STOPPED** earlier, optionally add a one-line partial note under **Implementation verification** when it helps the user. If **GAP** is explicit and the user’s success criteria still allow merging with documented gaps, you may emit **COMPLETED** with **Implementation verification: GAP — …** instead of STOPPED — state that trade-off clearly.
6. Emit the **Final report** using `references/final-report-template.md`.
7. **On `COMPLETED` with worktree** (Worktree ≠ `n/a` and `gh` on PATH), run **Step 8 — PR offer** per `auto-orchestrator.md`: ask the user, push + `gh pr create` on yes, and update the **PR** line of the report. Skip silently otherwise.
8. **On `COMPLETED` with worktree** and `tack.worktree.cleanup` ≠ `never`, run **Step 9 — Worktree cleanup offer** per `auto-orchestrator.md`: only when the branch matches `feature/*`, lives under `tack.worktree.dir`, is clean, and is merged into base. Default answer is **No**. Delete via `tack-worktree.sh remove` (no `--force`); the script's hardcoded protected-branch denylist (`main`/`master`/`develop`/`staging`/`release/*`/`hotfix/*`/…) is the safety net. Update the **Worktree cleanup** line of the report.

Stop on any condition in `references/stop-conditions.md` / `auto-orchestrator.md` **Stop conditions**. Step 8 (PR) and Step 9 (cleanup) failures only update their respective report fields — they do not change the run status.

---

## Post-completion implementation verification (host)

Run **after** reviewer (**Step 7**) and optional security (**Step 7b**) **PASS**, **before** emitting **Final report** **`COMPLETED`** and before Steps 8–9. Use only read-only inspection and repo-config commands (no authoring of specs, tests, or application code).

1. **Request traceability:** From the retained epic / user ask (per **Isolation** in `auto-orchestrator.md`), confirm the governing spec’s **AC-*** acceptance criteria cover that ask. If the original request is wider or different than what the ACs encode, record **GAP** — do not imply the user’s entire request was satisfied unless the mismatch is acknowledged in the report.
2. **Evidence:** In the active **working_directory** (worktree or repo root), run **`<TEST_COMMAND>`** from **`TACK.md`** or **`.cursorrules`** (full suite or scoped per team practice — align with Step 6 intent). Run **`<LINT_COMMAND>`** when it is quick and configured. Capture exit status and scope in the report. Any test failure → **FAILED** (prefer **STOPPED at verification**).
3. **Surface check:** When the user’s ask implies specific files or behaviours, sanity-check **e.g.** `git diff --stat` or `--name-only` against that expectation.

**Outcome:** Set **Implementation verification** in the Final report to **PASS**, **GAP**, or **FAILED** with a short narrative (user ask ↔ spec AC coverage, commands run, notable diff observation). Enumerate missing items under **GAP**/**FAILED**.

---

## Additional resources

- `${SKILL_DIR}/references/troubleshooting.md` — errors, stops, CLI vs skill, recovery checklist.
- `${SKILL_DIR}/references/pipeline-state-machine.md` — step index and Task parameters.
- `${SKILL_DIR}/references/stop-conditions.md` — when to STOP.
- `${SKILL_DIR}/references/final-report-template.md` — report shape.
- Consumer: `project/prompts/auto-orchestrator.md` — canonical state machine.
- Consumer: `project/docs/tack-pipeline-models.md` — per-step `Task` model slugs (**Preflight**).
