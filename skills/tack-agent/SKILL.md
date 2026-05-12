---
name: tack-agent
version: 0.2.0
license: MIT
description: Use when dispatching a single Tack SDD prompt in a bootstrapped repo. Triggers on one-step PM, architect, QA, harness, worker, reviewer, security, diagnose, worktree, domain-modeler, event-stormer, or custom specialist requests.
---

# tack-agent

Host-side dispatcher for exactly one `project/prompts/<name>.md` in the consumer repo. Read the prompt, assemble INPUTS, choose the model, pin the working directory, return the subagent output.

## When to use

- User names one role: PM, architect, QA, harness, worker, reviewer, security, worktree coordinator, diagnose, domain-modeler (`tack.ddd.profile = on`), event-stormer (greenfield DDD when no Phase 2 (ddd) draft).
- User references a file under `project/prompts/`.
- User wants reviewer/security on a diff, or DDD model refinement without full bootstrap.

## When not to use

Full pipeline (epic → reviewer) → `tack-run`. You may dispatch `orchestrator.md` only if the user explicitly wants the passive checklist text.

## Preconditions

- `project/prompts/<name>.md` exists (discover via `project/prompts/*.md`).
- `TACK.md` at repo root for prompts that need `<TEST_COMMAND>` / invariants. Missing → stop (run `tack-bootstrap` or copy `project/TACK.md.template`).

## Authority

- Protocol: [references/single-dispatch-protocol.md](references/single-dispatch-protocol.md) — Task parameters, prompt body template, After-dispatch verification.
- Agent choice + model slugs + specialist discovery: [references/agent-catalog.md](references/agent-catalog.md).

On any conflict between this SKILL and a referenced file, the referenced file wins.

## Output rules

Detect language (PT or EN). Direct tone, no fluff, no emojis except `[ ]` / `[x]` in checklists.

## Dispatch parameters

Per `references/single-dispatch-protocol.md` (Task parameters + Prompt body template). Resolve `model` from `project/docs/tack-pipeline-models.md` when present, falling back to the baseline table in `references/agent-catalog.md` with a one-time warning. Upward fallback on dispatch failure: Composer → Sonnet → Opus.

## INPUTS gathering

Gather before dispatch — architect: spec path; reviewer / security: diff or scope + governing spec; diagnose: symptom + optional spec; PM: epic + mode + `qa_history` when autonomous; worker: spec + plan/task + red test output. Ask minimal clarifying questions only when paths are missing.

## Ambiguous agent

Ask the user via the host's question tool with one option per stock agent (`references/agent-catalog.md`), plus discovered specialists, plus a final `Full pipeline — use tack-run` redirect.

## Worktree

Working directory: consumer repo root, or a user-supplied worktree path. Ask if unclear.

## Verification

After every successful dispatch, before returning to the user, run the After-dispatch protocol in `references/single-dispatch-protocol.md` (tiered checks per agent type) and emit a single line:

`Verification: PASS | GAP | FAILED — <short evidence>`

Return the subagent output verbatim immediately followed by that line. On `FAILED` (or `GAP` when the user required full satisfaction), say so plainly before any celebratory wording.

## Failure handling

No auto-retry. If the verification line is `FAILED` or `GAP`, the user fixes the cause and re-invokes `tack-agent` with corrected INPUTS, or falls back to `tack-run` with a resume token (`S-NNN`) for a multi-step recovery. See [tack-run/references/troubleshooting.md](../tack-run/references/troubleshooting.md) → Resume after a failure.

## Platform tool mapping

This skill describes capabilities, not tool names. Translate to your host:

| Capability             | Cursor             | Claude Code (CLI)   | Claude Code SDK / API |
|------------------------|--------------------|---------------------|-----------------------|
| Dispatch a subagent    | `Task`             | `Agent`             | `Task`                |
| Ask the user a question| `AskQuestion`      | `AskUserQuestion`   | (none — inline)       |
| Pin working directory  | `working_directory`| `cd <path>` in prompt body          | host-specific (`cwd` if available, else `cd` in prompt) |
| Subagent type          | `generalPurpose`   | `general-purpose`   | `general-purpose`     |

When a host omits a primitive (e.g. Claude Code Agent has no `working_directory` param), prepend an absolute `cd <path>` line to the dispatched prompt so the subagent runs in the right tree.

## Additional resources

- [references/single-dispatch-protocol.md](references/single-dispatch-protocol.md) — Task parameters, prompt wrapper, After-dispatch verification.
- [references/agent-catalog.md](references/agent-catalog.md) — stock agents, pipeline keys, model slugs, specialist discovery.
- `tack-run` references/troubleshooting.md — Why a single agent fails.
