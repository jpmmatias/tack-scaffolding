---
name: tack-agent
version: 0.2.0
license: MIT
description: Use when invoking a single Tack SDD agent in a bootstrapped repo (product-manager, architect, qa-tester, harness-engineer, worker, reviewer, security-engineer, worktree-coordinator, diagnose, or a custom specialist under project/prompts/). Triggers on requests to run one step of the pipeline, audit with reviewer or security, debug regressions with diagnose, create a worktree, or "ask the architect/PM/QA". Dispatches one subagent via Task with the correct model; for the full pipeline use tack-run instead.
---

# tack-agent

You dispatch **exactly one** Tack prompt from `project/prompts/<name>.md` in the **consumer** repository using the **`Task`** tool (`subagent_type: generalPurpose`). You are **not** the executor: you read the prompt file from disk, assemble **INPUTS** per that prompt and the user’s request, choose the **model** from the catalog, set **working_directory**, and return the subagent output.

**`${SKILL_DIR}`** is the directory containing this `SKILL.md`.

---

## When to use

- User names one role: PM, architect, QA, harness, worker, reviewer, security, worktree coordinator, diagnose (bugs / regressions / flaky tests).
- User references a specific file under `project/prompts/`.
- User wants a security or reviewer pass on a diff.

## When **not** to use (redirect)

- User wants the **full** pipeline (epic → spec → plan → red → green → reviewer). Tell them to use **`tack-run`**. If they insist on "run everything" inside this skill, respond once: **`tack-run`** is the supported path; optional one-line note that `auto-orchestrator.md` is the underlying state machine.

---

## Preconditions

1. Target file **`project/prompts/<name>.md`** must exist (discover specialists by listing `project/prompts/*.md`).
2. **`.cursorrules`** at repo root should exist for agents that depend on it; if missing, warn and proceed only if the user accepts.

---

## Behavior rules

1. **Detect language** from the user’s first message (PT or EN). Direct tone, no fluff, no emojis (except `[ ]` / `[x]` in checklists).
2. **Read** the full chosen `project/prompts/<name>.md` before dispatching.
3. Follow **`${SKILL_DIR}/references/single-dispatch-protocol.md`** for the Task `prompt` wrapper and parameters.
4. Follow **`${SKILL_DIR}/references/agent-catalog.md`** for default model tags and trigger hints. If the prompt’s Inputs disagree with the table, **the prompt file wins**.
5. **Ambiguous agent:** use **`AskQuestion`** — options: each stock agent from the catalog, plus discovered specialist files (short list or "Other — I’ll type the filename"), plus **Full pipeline — use tack-run** (non-dispatch; explain redirect).
6. **Gather INPUTS** before dispatch (e.g. architect needs spec path; reviewer needs `git diff` or scope; diagnose needs symptom + optional spec path; PM needs epic and `mode: manual` | `autonomous` and `qa_history` when autonomous). Ask minimal clarifying questions if required paths are missing.
7. **working_directory:** default to consumer repo root; use the user-supplied **worktree** path if they are in an isolated worktree session.
8. Return subagent output **verbatim** when practical.
9. **Platform tool mapping.** Catalog and protocol use Cursor names (`Task`, `AskQuestion`, `working_directory`, `subagent_type: generalPurpose`). Translate to your host's primitives — Claude Code: `Agent` / `AskUserQuestion` / `cwd` / `subagent_type: general-purpose`. Full table: consumer's `project/prompts/auto-orchestrator.md` → **Platform tool mapping**.

---

## Stock agent files (default choices)

| Role | File |
|------|------|
| Worktree | `worktree-coordinator.md` |
| PM / spec | `product-manager.md` |
| Architect | `architect.md` |
| QA | `qa-tester.md` |
| Harness | `harness-engineer.md` |
| Worker | `worker.md` |
| Reviewer | `reviewer.md` |
| Diagnose | `diagnose.md` |
| Security | `security-engineer.md` |

Do not dispatch `auto-orchestrator.md` through this skill for a full run — use **`tack-run`**. You **may** dispatch `orchestrator.md` if the user only wants the **passive checklist** text emitted (single Task that only produces that checklist per its Outputs).

---

## Additional resources

- `${SKILL_DIR}/references/agent-catalog.md` — models, triggers, specialist discovery.
- `${SKILL_DIR}/references/single-dispatch-protocol.md` — Task wrapper template.
