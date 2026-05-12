---
name: tack-run
version: 0.2.0
license: MIT
description: Use when running the full Tack SDD/TDD pipeline in a bootstrapped repo. Triggers on run Tack, auto-orchestrator, epic-to-reviewer flow, or shipping via the spec pipeline.
---

# tack-run

Host-side dispatcher for Tack's active SDD pipeline. Read `project/prompts/auto-orchestrator.md` from the consumer repo and execute it. Do not author specs, plans, tests, or app code in your reply — subagents do, per the orchestrator. Only the Final report comes from you.

## When to use

Full pipeline (epic → reviewer, optional security). One agent only → `tack-agent`.

## Preconditions

- `project/prompts/auto-orchestrator.md` exists.
- Repo-root `TACK.md` defines `<TEST_COMMAND>`, `<LINT_COMMAND>`, and `tack.worktree.*` as needed. Missing → stop; run `tack-bootstrap` or copy `project/TACK.md.template`.
- `project/docs/tack-pipeline-models.md` is an override, not a precondition. `tack.routing.auto = no` does not block explicit `tack-run`.

## Authority

Read `project/prompts/auto-orchestrator.md` at run start. It owns step order, model routing, dispatch wrapper, INPUTS, gates, stop conditions, and Final report. On any conflict the orchestrator wins.

## Output rules

Detect language (PT or EN). Direct tone, no fluff, no emojis except `[ ]` / `[x]` in checklists.

## Dispatch parameters

Model slugs and step→tag mapping: orchestrator's Model routing + Dispatch protocol. Override per step via `project/docs/tack-pipeline-models.md` when present; missing keys fall back to the orchestrator's baseline with a one-time warning. Upward fallback on dispatch failure: Composer → Sonnet → Opus.

## Worktree handling

When Step −1 succeeds:

1. Pin `working_directory` to absolute `worktree_path` for every Step 1–7 / 7b dispatch.
2. Prepend `cd <worktree_path>` plus a repo-root marker to each subagent's `=== INPUTS ===`, including PM iteration 1.
3. Step 0 lists `<worktree_path>/project/specs/`, not the IDE workspace root.
4. Wrong tree: run `git -C <worktree_path> status` and `git -C <repo_root> status`; recover per orchestrator → Wrong-tree detection and recovery.

## Post-completion verification

After Step 7 / 7b PASS, before emitting `COMPLETED`: traceability (epic ↔ AC-*), evidence (run `<TEST_COMMAND>` / `<LINT_COMMAND>` in the active tree), surface check (`git diff --stat` vs expectation). Long form: [references/post-completion-verification.md](references/post-completion-verification.md). Failure → `STOPPED at verification — <reason>`.

## Failure handling & resume

Failed steps do not auto-retry. To resume:

- Re-dispatch one step: invoke `tack-agent` with the failing step's prompt name (`product-manager`, `architect`, …) and the same INPUTS the orchestrator built; the worktree and `S-NNN` stay reusable.
- Resume the full run: re-invoke `tack-run` with input beginning with the resume token `S-NNN` (or `S-NNN-tNN` for a task). Auto-orchestrator's Resume mode skips Step 1 and may skip Step 2 when a valid `plan.md` already covers the spec.

User-facing recovery paths: [references/troubleshooting.md](references/troubleshooting.md).

## Platform tool mapping

This skill describes capabilities, not tool names. Translate to your host:

| Capability             | Cursor             | Claude Code (CLI)   | Claude Code SDK / API |
|------------------------|--------------------|---------------------|-----------------------|
| Dispatch a subagent    | `Task`             | `Agent`             | `Task`                |
| Ask the user a question| `AskQuestion`      | `AskUserQuestion`   | (none — inline)       |
| Pin working directory  | `working_directory`| `isolation: worktree` + `cd` in prompt | host-specific (`cwd` if available, else `cd` in prompt) |
| Subagent type          | `generalPurpose`   | `general-purpose`   | `general-purpose`     |

When a host omits a primitive (e.g. Claude Code Agent has no `working_directory` param), prepend an absolute `cd <path>` line to the dispatched prompt so the subagent runs in the right tree.

## Additional resources

- [references/post-completion-verification.md](references/post-completion-verification.md) — host-side verification long form.
- [references/troubleshooting.md](references/troubleshooting.md) — errors, stops, CLI vs chat, resume paths.
- Consumer: `project/prompts/auto-orchestrator.md`, `project/docs/tack-pipeline-models.md` (override; optional).
