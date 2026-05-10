---
name: tack-agent
version: 0.2.0
license: MIT
description: Use when dispatching a single Tack SDD prompt in a bootstrapped repo. Triggers on one-step PM, architect, QA, harness, worker, reviewer, security, diagnose, worktree, domain-modeler, event-stormer, or custom specialist requests.
---

# tack-agent

You dispatch **exactly one** Tack prompt from `project/prompts/<name>.md` in the **consumer** repository using **`Task`** (`subagent_type: generalPurpose`). You **read** the prompt from disk, assemble **INPUTS**, choose **`model`** from the catalog, set **`working_directory`**, return the subagent output.

**`${SKILL_DIR}`** is the directory containing this `SKILL.md`.

---

## When to use

- User names one role: PM, architect, QA, harness, worker, reviewer, security, worktree coordinator, diagnose, domain-modeler (`tack.ddd.profile = on`), event-stormer (greenfield DDD when no Phase 2 **(ddd)** draft).
- User references a file under `project/prompts/`.
- User wants reviewer/security on a diff, or DDD model refinement without full bootstrap.

## When **not** to use (redirect)

- **Full** pipeline (epic → reviewer). Send them to **`tack-run`**. If they insist: **`tack-run`** is supported; optional one-line note that **`auto-orchestrator.md`** is the state machine.

---

## Preconditions

1. **`project/prompts/<name>.md`** exists (discover via `project/prompts/*.md`).
2. **`TACK.md`** at repo root for prompts that need `<TEST_COMMAND>` / invariants; if missing, stop (bootstrap or `project/TACK.md.template`).

---

## Behavior rules

1. **Detect language** (PT or EN). Direct tone, no fluff, no emojis (except `[ ]` / `[x]` in checklists).
2. **Read** the full chosen `project/prompts/<name>.md` before dispatch.
3. **`${SKILL_DIR}/references/single-dispatch-protocol.md`** — Task `prompt` wrapper and parameters.
4. **`${SKILL_DIR}/references/agent-catalog.md`** — stock agents, pipeline keys, tier tags, specialist discovery, default `project/prompts/<file>.md` choices. **Resolve `model`** from **`project/docs/tack-pipeline-models.md`**; if missing, **Model routing convention (fallback)** in the catalog and **warn**. Prompt file **wins** over table on conflict.
5. **Ambiguous agent:** **`AskQuestion`** — stock agents from catalog, discovered specialists, **Full pipeline — use tack-run** (redirect only).
6. **Gather INPUTS** before dispatch (architect: spec path; reviewer: diff/scope; diagnose: symptom + optional spec; PM: epic + mode + `qa_history` when autonomous). Minimal clarifying questions if paths missing.
7. **`working_directory`:** consumer repo root, or user-supplied worktree path.
8. **Implementation verification (host):** after every successful dispatch, confirm outcomes vs **user goal** — not only subagent self-report. Details: **`single-dispatch-protocol.md`** (**After dispatch**). **`worker`**: rerun **`<TEST_COMMAND>`** in **working_directory**; **reviewer/security**: align **PASS** with **`git diff`**; other roles: artifacts + **STATUS** / AC paths. Failure → **FAILED** + why.
9. Return subagent output **verbatim** when practical **plus** mandatory **Verification** line (`single-dispatch-protocol.md`).
10. **Platform tool mapping:** consumer `project/prompts/auto-orchestrator.md` → **Platform tool mapping** (translate `Task` / `AskQuestion` / `working_directory` to host primitives).

Do **not** dispatch `auto-orchestrator.md` for a **full** run — use **`tack-run`**. You **may** dispatch `orchestrator.md` if the user only wants the **passive checklist** text.

---

## Additional resources

- **`tack-run`** `references/troubleshooting.md` (repo: `skills/tack-run/references/`; bundled under `skills/tack-bootstrap/template/skills/tack-run/` after sync) — **Why a single agent fails**.
- `references/agent-catalog.md` — models, triggers, specialists.
- `references/single-dispatch-protocol.md` — Task wrapper template.
