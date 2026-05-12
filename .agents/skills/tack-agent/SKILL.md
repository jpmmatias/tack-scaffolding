---
name: tack-agent
version: 0.2.0
license: MIT
description: Use when dispatching a single Tack SDD prompt in a bootstrapped repo. Triggers on one-step PM, architect, QA, harness, worker, reviewer, security, diagnose, worktree, domain-modeler, event-stormer, or custom specialist requests.
---

# tack-agent

You dispatch **exactly one** Tack prompt from `project/prompts/<name>.md` in the **consumer** repository (see **Platform tool mapping** below for the host's dispatch primitive). You **read** the prompt from disk, assemble **INPUTS**, choose the model from the catalog, pin the working directory, return the subagent output.

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
3. **`references/single-dispatch-protocol.md`** — dispatch `prompt` wrapper and parameters.
4. **`references/agent-catalog.md`** — stock agents, pipeline keys, tier tags, specialist discovery, default `project/prompts/<file>.md` choices. **Model slugs:** baseline is the table below. If **`project/docs/tack-pipeline-models.md`** is present, its keys override per step; missing keys fall back + one-time warning. Prompt file **wins** over table on conflict.

   | Tag | Default slug |
   |-----|--------------|
   | `[Opus]` | `claude-opus-4-7-thinking-xhigh` |
   | `[Sonnet]` | `claude-4.6-sonnet-medium-thinking` |
   | `[Composer]` | `composer-2-fast` |

5. **Ambiguous agent:** ask the user via the host's question tool (see **Platform tool mapping**) — stock agents from catalog, discovered specialists, **Full pipeline — use tack-run** (redirect only).
6. **Gather INPUTS** before dispatch (architect: spec path; reviewer: diff/scope; diagnose: symptom + optional spec; PM: epic + mode + `qa_history` when autonomous). Minimal clarifying questions if paths missing.
7. **Working directory:** consumer repo root, or user-supplied worktree path.
8. **Mandatory implementation verification (host).** After every successful dispatch, before returning to the user:
   a. Use read-only shell in the working directory (or the host equivalent) to confirm the outcome — never rely solely on the subagent's PASS.
   b. **worker / implementation specialists:** run `<TEST_COMMAND>` from `TACK.md` (full or scoped).
   c. **reviewer / security-engineer:** confirm the verdict against `git diff` for the stated scope.
   d. **PM / architect / QA / harness / diagnose / domain-modeler / event-stormer:** open the artifact paths the subagent named and confirm they exist and reflect the user's wording.
   e. Emit exactly one line after the subagent payload:
      `Verification: PASS | GAP | FAILED — <short evidence>`
   f. On `FAILED` or `GAP` (when user required full satisfaction), say so plainly **before** any celebratory wording.
   Long-form drill-down: `references/single-dispatch-protocol.md` (After dispatch).
9. Return subagent output **verbatim** when practical, immediately followed by the `Verification:` line from rule 8e.

Do **not** dispatch `auto-orchestrator.md` for a **full** run — use **`tack-run`**. You **may** dispatch `orchestrator.md` if the user only wants the **passive checklist** text.

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

- **`tack-run`** `references/troubleshooting.md` (repo: `skills/tack-run/references/`; bundled under `skills/tack-bootstrap/template/skills/tack-run/` after sync) — **Why a single agent fails**.
- `references/agent-catalog.md` — models, triggers, specialists.
- `references/single-dispatch-protocol.md` — dispatch wrapper template.
