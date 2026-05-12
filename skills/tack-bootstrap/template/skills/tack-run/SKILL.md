---
name: tack-run
version: 0.2.0
license: MIT
description: Use when running the full Tack SDD/TDD pipeline in a bootstrapped repo. Triggers on run Tack, auto-orchestrator, epic-to-reviewer flow, or shipping via the spec pipeline.
---

# tack-run

You execute **Tack**'s active SDD pipeline by following **`project/prompts/auto-orchestrator.md`** in the **consumer** repository. You are a **dispatcher only**: read prompts from disk, run gates, dispatch a subagent (see **Platform tool mapping** below) with the right model and working directory. Do **not** create specs, plans, tests, or application code yourself — subagents do, per that file’s **Outputs**. Do **not** write specs, plans, tests, or app source in your reply except the **Final report**. You **may** use shell and read-only access for **implementation verification**: **`<TEST_COMMAND>`** / **`<LINT_COMMAND>`** from repo-root **`TACK.md`**, `git diff`, governing spec.

Paths below are relative to the **consumer repo root** (**`TACK.md`**, `tack.worktree.*`) unless they start with `references/` (skill-local).

---

## When to use

- Full pipeline, auto-orchestrator, or "Tack" for a feature/bug/task; epic → PM → … → reviewer (optional security).
- For **one** agent only → **`tack-agent`**.

**Errors, stops, CLI vs chat:** **`references/troubleshooting.md`**.

---

## Preconditions (fail fast)

1. **`project/prompts/auto-orchestrator.md`** exists.
2. Repo-root **`TACK.md`** defines `<TEST_COMMAND>`, `<LINT_COMMAND>` (and `tack.worktree.*` as needed). **`project/scripts/tack-resolve-config.sh`** / **`tack-worktree.sh`** read **`TACK.md` only**. If missing → stop; **`tack-bootstrap`** or `project/TACK.md.template`.

**`project/docs/tack-pipeline-models.md`** is an **override**, not a precondition. If present, its keys take precedence per step; if absent or a key is missing, fall back to the table in rule 4 and warn once.

**`tack.routing.auto = no`** does **not** block explicit **`tack-run`**.

---

## Behavior rules

1. **Detect language** (PT or EN). Direct tone, no fluff, no emojis (except `[ ]` / `[x]` in checklists).
2. **Read the full** `project/prompts/auto-orchestrator.md` at run start — source of truth for order, inputs, gates, stops.
3. **`references/`** shortcuts: `pipeline-state-machine.md`, `stop-conditions.md`, `final-report-template.md`, **`post-completion-verification.md`**. On conflict → **`auto-orchestrator.md` wins**.
4. **Model slugs.** Baseline is the fallback table below. If **`project/docs/tack-pipeline-models.md`** is present, its keys override per step; missing keys fall back + one-time warning. Upward fallback on dispatch failure: Composer → Sonnet → Opus.

   | Tag | Default slug |
   |-----|--------------|
   | `[Opus]` | `claude-opus-4-7-thinking-xhigh` |
   | `[Sonnet]` | `claude-4.6-sonnet-medium-thinking` |
   | `[Composer]` | `composer-2-fast` |

5. **PM Step 1:** `STATUS: NEEDS_INPUT` → ask the user via the host's question tool (see **Platform tool mapping**) per `auto-orchestrator.md`; `cancel grill` → stop conditions.
6. **Isolation:** retain only what the next dispatch + Final report need (`auto-orchestrator.md` **Isolation**).
7. **Worktree:** Step −1 success → **Worktree anchor** + **Dispatch protocol** in `auto-orchestrator.md`: Steps 1–7 / 7b pin the working directory to absolute `worktree_path`, prepend **`cd`** + repo-root lines to **INPUTS** (including PM iteration 1). Step 0 lists **`<worktree_path>/project/specs/`**. Wrong tree → **`git -C`** checks + **Wrong-tree detection and recovery** in that file.
8. **No auto-retry** of failed steps.

---

## Execution outline

1. Preconditions; **Preflight** per `auto-orchestrator.md`; capture epic/task.
2. Parse **`tack.worktree.*`** from **`TACK.md`**; Step −1 or skip if `never`.
3. Steps 0–7 / 7b; **Dispatch protocol** (full prompt + **INPUTS**).
4. Gates per `auto-orchestrator.md`.
5. **Post-completion implementation verification (mandatory).** When Steps 7 / 7b are PASS and the run would be COMPLETED, before emitting the Final report:
   a. **Traceability:** confirm the governing spec's AC-* covers the original epic / user ask. Mismatch → record **GAP**.
   b. **Evidence:** in the active working directory, run `<TEST_COMMAND>` (and `<LINT_COMMAND>` if quick). Any failure → **FAILED** (prefer **STOPPED at verification**).
   c. **Surface check:** when the ask implies specific files / behaviours, sanity-check `git diff --stat` against that expectation.
   Set Final report **Implementation verification** to PASS / GAP / FAILED with a short narrative. Long-form: `references/post-completion-verification.md`.
6. **Final report** → `references/final-report-template.md`.
7. **`COMPLETED` + worktree** + `gh` → Step 8 PR offer per `auto-orchestrator.md`.
8. **`COMPLETED` + worktree** + `tack.worktree.cleanup` ≠ `never` → Step 9 cleanup offer per `auto-orchestrator.md`.

Stop on `references/stop-conditions.md` / `auto-orchestrator.md` **Stop conditions**. Steps 8–9 failures only update report fields.

**Step 5 detail:** If verification **FAILED**, or **GAP** with no acceptable partial delivery → **Status** `STOPPED at verification — <reason>` (no Steps 8–9). **GAP** + user accepts documented gaps → may **COMPLETED** with **Implementation verification: GAP — …**. Earlier **STOPPED** → optional one-line note under **Implementation verification**.

---

## Platform tool mapping

This skill describes capabilities, not tool names. Translate to your host:

| Capability             | Cursor             | Claude Code (CLI)   | Claude Code SDK / API |
|------------------------|--------------------|---------------------|-----------------------|
| Dispatch a subagent    | `Task`             | `Agent`             | `Task`                |
| Ask the user a question| `AskQuestion`      | `AskUserQuestion`   | (none — inline)       |
| Pin working directory  | `working_directory`| `isolation: worktree` + `cd` in prompt | host-specific (`cwd` if available, else `cd` in prompt) |
| Subagent type          | `generalPurpose`   | `general-purpose`   | `general-purpose`     |

When a host omits a primitive (e.g. Claude Code Agent has no `working_directory` param), prepend an absolute `cd <path>` line to the dispatched prompt so the subagent runs in the right tree.

---

## Additional resources

- `references/post-completion-verification.md` — long-form drill-down for outline step 5.
- `references/troubleshooting.md`, `pipeline-state-machine.md`, `stop-conditions.md`, `final-report-template.md`
- Consumer: `project/prompts/auto-orchestrator.md`, `project/docs/tack-pipeline-models.md` (override; optional)
