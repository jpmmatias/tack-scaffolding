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
- For role dispatches that need a spec (architect, QA, worker, reviewer, security): the spec must be resolvable from either an explicit path in INPUTS or a resume token in user input (see **Resume tokens** below). Missing or ambiguous → ask before dispatch.

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

## Resume tokens

When the user's input **begins** with a Tack spec id — `S-NNN`, `S-NNN-tNN`, or `S-NNN-task-NN` (optionally preceded by `resume`, `continue`, or `work on`; case-insensitive on letters, digits preserved as typed) — parse it as a spec id, not as the epic. Anything after the matched token is supplementary context (e.g. a role name), not the epic.

1. Resolve a unique `S-NNN-*.md` under `project/specs/` (or `<worktree_path>/project/specs/` when the user pointed you at a worktree). A task suffix (`S-NNN-tNN` / `S-NNN-task-NN`) forces a task-spec match; bare `S-NNN` excludes `*-task-NN-*.md` from the candidate set.
2. **Zero matches** → stop; tell the user the spec id is not present under `project/specs/` and suggest `tack-run` for a fresh epic.
3. **Multiple matches** → ask the user via the host's question tool which spec to target (one option per matching path) before dispatch.
4. **Exactly one match** → use that path in INPUTS for whichever role the user named, or fall through to **Ambiguous agent** carrying the resolved spec forward when no role was named.

Resume tokens here are **local resolution only** — they let `tack-agent` resolve a spec from a short id without a full path. They do **not** trigger the orchestrator's Resume mode (Step 1 skip, plan reuse) — that's `tack-run`'s job; see **Failure handling** for multi-step recovery.

## Ambiguous agent

Ask the user via the host's question tool with one option per stock agent (`references/agent-catalog.md`), plus discovered specialists, plus a final `Full pipeline — use tack-run` redirect.

## Worktree

`tack-agent` does **not** create or manage worktrees — that is `tack-run` Step −1's responsibility. Dispatch with `working_directory` set to either:

- the consumer repo root, **or**
- an absolute path to an existing worktree the user pointed you at.

Ask if unclear. When the host has no `working_directory` primitive (see **Platform tool mapping**), prepend `cd <absolute path>` to the dispatched prompt.

## Verification

After every successful dispatch, before returning to the user, run the After-dispatch protocol in `references/single-dispatch-protocol.md` (tiered checks per agent type) and emit a single line:

`Verification: PASS | GAP | FAILED — <short evidence>`

Return the subagent output verbatim immediately followed by that line. On `FAILED` (or `GAP` when the user required full satisfaction), say so plainly before any celebratory wording.

> **Scope.** This per-dispatch `Verification:` line is **distinct from `tack-run`'s post-pipeline `Implementation verification:` line** — same outcome vocabulary, narrower scope (one subagent output, not the full epic ↔ AC coverage). Use the bare `Verification:` label here only; never substitute `Implementation verification:`.

## Failure handling

No auto-retry. If the verification line is `FAILED` or `GAP`:

- **Single-step recovery:** the user fixes the cause and re-invokes `tack-agent` with corrected INPUTS. The worktree (if any) and any reserved `S-NNN` stay reusable.
- **Multi-step recovery:** fall back to `tack-run` with input beginning with the resume token `S-NNN` (or `S-NNN-tNN` for a task — examples: `S-002`, `resume S-002`, `continue S-002-t01`). Auto-orchestrator's Resume mode skips Step 1 and may skip Step 2 when a valid `plan.md` already covers the spec.

See also (when `tack-run` is installed alongside): `tack-run/references/troubleshooting.md` → Resume after a failure.

## Platform tool mapping

This skill describes capabilities, not tool names. Translate to your host:

<!-- BEGIN: shared/platform-tool-mapping — auto-generated by `npm run sync`; edit skills/_shared/platform-tool-mapping.md -->
| Capability                 | Cursor                          | Claude Code (CLI)                                              | Claude Code SDK / API / Generic (Copilot CLI / Codex / Antigravity) |
|----------------------------|---------------------------------|----------------------------------------------------------------|---------------------------------------------------------------------|
| Dispatch a subagent        | `Task` tool                     | `Agent` tool                                                   | host-specific subagent / dispatch primitive                          |
| Ask the user a question    | `AskQuestion` tool              | `AskUserQuestion` tool                                         | post the question in chat and wait for the next user message         |
| Pin working directory      | `working_directory` parameter   | `cwd` parameter, or `cd <path> && …` in the dispatched prompt  | host-specific; if no native param, prepend `cd <path>` to the prompt |
| Subagent type              | `subagent_type: generalPurpose` | `subagent_type: general-purpose`                               | omit when the host has no notion of agent types                      |
| Per-step model             | `model` parameter               | `model` parameter                                              | host-specific; if unsupported, document the chosen model in the prompt and rely on upward fallback |
| Shell command availability | `command -v <name>` (bash)      | `command -v <name>` (bash)                                     | shell availability varies; skip dependent steps (e.g. PR creation, post-pipeline cleanup) when unavailable |

When a host omits a native primitive, prepend an absolute `cd <path>` line to the dispatched prompt so the subagent runs in the right tree.
<!-- END: shared/platform-tool-mapping -->

## Additional resources

- [references/single-dispatch-protocol.md](references/single-dispatch-protocol.md) — Task parameters, prompt wrapper, After-dispatch verification.
- [references/agent-catalog.md](references/agent-catalog.md) — stock agents, pipeline keys, model slugs, specialist discovery.
- `tack-run` references/troubleshooting.md — Why a single agent fails.
