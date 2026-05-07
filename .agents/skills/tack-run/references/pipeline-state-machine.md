# Tack pipeline state machine (reference)

**Canonical source:** read `project/prompts/auto-orchestrator.md` from the consumer repository on every run. This file is a short index; if anything disagrees, the prompt file wins.

## Preconditions

- Consumer repo root has `.cursorrules` with quality commands and `tack.worktree.*` (and optionally `tack.routing.*`).
- `project/prompts/auto-orchestrator.md` exists.

## Model routing (Cursor slugs)

| Orchestrator tag | Cursor model slug |
|------------------|-------------------|
| `[Opus]` | `claude-opus-4-7-thinking-xhigh` |
| `[Sonnet]` | `claude-4.6-sonnet-medium-thinking` |
| `[Composer]` | `composer-2-fast` |

If the model is unavailable, fall back **upward** (Composer → Sonnet → Opus), never downward.

## Step → model

- Step −1 (worktree): `[Composer]`
- Steps 1, 2, 7: `[Opus]`
- Steps 3, 4, 6: `[Sonnet]`
- Step 5 (implementation): `[Composer]`
- Step 7b (security, optional): `[Opus]`

## Dispatch wrapper

Build each subagent `prompt` per **Dispatch protocol** in `auto-orchestrator.md`: embed full contents of `project/prompts/<name>.md` under `=== PROMPT FILE ===` and step-specific **INPUTS** below.

Use **`Task`** with:

- `subagent_type`: `generalPurpose`
- `description`: short unique title per step
- `model`: from table above
- `working_directory`: absolute `worktree_path` after Step −1 succeeds (required for Steps 1–7); omit only when Step −1 skipped
- `run_in_background`: `false` unless the platform requires otherwise

## Step −1 — Worktree (optional)

Follow **Step −1** in `auto-orchestrator.md`: parse `tack.worktree.*` from `.cursorrules`, decide `never` / `always` / `prompt`, dispatch `@worktree-coordinator.md` with `working_directory` at primary repo root when the tool distinguishes it.

## Steps 0–7 and 7b

Execute in order: **Step 0** (spec id) → **Step 1** (PM grill loop with `AskQuestion` for `NEEDS_INPUT`) → **Step 2** (architect) → **Step 3** (qa red) → **Step 4** (harness, conditional) → **Step 5** (worker / specialists per routing table) → **Step 6** (qa green) → **Step 7** (reviewer) → **Step 7b** (security, conditional).

**Step 1:** On `STATUS: NEEDS_INPUT`, use Cursor **`AskQuestion`** exactly as specified in `auto-orchestrator.md` (options + appended `Other - I'll explain in chat`).

## Outputs

The hosting agent does **not** substitute for subagents: it dispatches only. The **Final report** format is in `final-report-template.md` (same as auto-orchestrator).
