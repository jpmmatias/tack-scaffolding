# Tack agent catalog

Paths are relative to the **consumer repo root**. Prompt files live under `project/prompts/`. **Read each prompt’s Inputs section** from disk before dispatch — this table is a guide only.

## Model routing convention

| Tag | Cursor model slug |
|-----|-------------------|
| `[Opus]` | `claude-opus-4-7-thinking-xhigh` |
| `[Sonnet]` | `claude-4.6-sonnet-medium-thinking` |
| `[Composer]` | `composer-2-fast` |

## Stock agents

| Agent | File | Model | Typical triggers / notes |
|-------|------|-------|---------------------------|
| Worktree coordinator | `worktree-coordinator.md` | `[Composer]` | Isolated branch/worktree; needs slug, `tack.worktree.*` from `.cursorrules`; OUTPUTS: JSON only |
| Product manager | `product-manager.md` | `[Opus]` | Spec authoring; **manual**: `mode: manual`, epic; **subagent/orchestrated**: `mode: autonomous`, `qa_history` |
| Architect | `architect.md` | `[Opus]` | Needs approved spec path `project/specs/S-XXX-<slug>.md` |
| QA tester | `qa-tester.md` | `[Sonnet]` | Needs spec + plan/task context; **red** vs **green** is intent in INPUTS (phase) |
| Harness engineer | `harness-engineer.md` | `[Sonnet]` | Harness/factories/doubles; needs spec/plan context when scoped to a feature |
| Worker | `worker.md` | `[Composer]` | Implementation; needs spec, plan/task, red test output when continuing TDD |
| Reviewer | `reviewer.md` | `[Opus]` | Needs diff or review scope + governing spec/task reference |
| Diagnose | `diagnose.md` | `[Opus]` | Hard bugs, regressions, flaky behaviour; needs symptom + rules/harness context; optional `project/specs/S-XXX-*.md` path — **manual** via `tack-agent` (not part of default `auto-orchestrator` pipeline) |
| Security engineer | `security-engineer.md` | `[Opus]` | Needs diff/scope + rules, glossary, architecture; optional spec id |

## Passive vs active orchestration (not single-agent “executors”)

| File | Role |
|------|------|
| `orchestrator.md` | Emits a **checklist** only — human runs each `@` in fresh chats. Dispatch only if the user explicitly wants that checklist text generated. |
| `auto-orchestrator.md` | Full **Task** state machine — use **`tack-run`** instead of reimplementing inside `tack-agent`. |

## Specialists

Any file under `project/prompts/` that is **not** listed above and is **not** `_specialist-template.md` or `auto-orchestrator.md` / `orchestrator.md` is a **candidate specialist** (e.g. team-created `api.md`, `ui.md`). Use `[Composer]` unless the prompt or `auto-orchestrator.md` **Specialist routing** table specifies `[Sonnet]` / `[Opus]`.

**Discovery:** list `project/prompts/*.md` and exclude: `_specialist-template.md`, `auto-orchestrator.md`, `orchestrator.md`, and the stock rows in this table (or include them if the user picks one explicitly).

## Choosing an agent

- If the user names a role or file, map to the table.
- If ambiguous, use **`AskQuestion`** with one option per stock agent plus **Specialist: (list dynamic filenames)** and **Full pipeline (use tack-run)**.
- If the user selects **Full pipeline**, stop and instruct them to invoke **`tack-run`** with their epic (do not chain every step manually unless they insist and accept context-rot risk).
