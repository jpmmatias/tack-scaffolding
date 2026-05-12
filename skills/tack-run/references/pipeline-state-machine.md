# Tack pipeline state machine (reference)

**Canonical source:** read `project/prompts/auto-orchestrator.md` from the consumer repository on every run. This file is a short index; if anything disagrees, the prompt file wins.

## Preconditions

- Consumer repo root has **`TACK.md`** with quality commands and `tack.worktree.*` (and optionally `tack.routing.*`). **`project/scripts/tack-resolve-config.sh`** resolves **`TACK.md` only**.
- `project/prompts/auto-orchestrator.md` exists.
- `project/docs/tack-pipeline-models.md` is an **override**: if present, its keys take precedence per step; if absent or a key is missing, fall back to the tier table below.

## Model routing

**Override:** when `project/docs/tack-pipeline-models.md` is present, the dispatched subagent's model = slug from that file for the step's key (`models.<key>`). See **`auto-orchestrator.md` → Preflight** and **Model routing**. **Upward fallback** uses distinct slugs from the same YAML in tier order — never downward.

**Baseline tier table** (default slugs when no override file or a key is missing):

| Orchestrator tag | Model slug |
|------------------|------------|
| `[Opus]` | `claude-opus-4-7-thinking-xhigh` |
| `[Sonnet]` | `claude-4.6-sonnet-medium-thinking` |
| `[Composer]` | `composer-2-fast` |

## Step → model

- Step −1 (worktree): **`[Composer]`** — **`worktree_coordinator`**
- Steps 1, 2, 7: **`[Opus]`** — **`product_manager`**, **`architect`**, **`reviewer`**
- Steps 3, 4, 6: **`[Sonnet]`** — **`qa_tester`**, **`harness_engineer`**, **`qa_tester`**
- Step 5 (implementation / specialists): **`[Composer]`** — **`worker`**
- Step 7b (security, optional): **`[Opus]`** — **`security_engineer`**

Details: **`auto-orchestrator.md`** → **Model routing** and **Preflight**.

## Dispatch wrapper

Build each subagent `prompt` per **Dispatch protocol** in `auto-orchestrator.md`: embed full contents of `project/prompts/<name>.md` under `=== PROMPT FILE ===` and step-specific **INPUTS** below.

Use the host's subagent-dispatch primitive (see **Platform tool mapping** in `tack-run/SKILL.md`) with:

- `subagent_type`: `generalPurpose` (Cursor) / `general-purpose` (Claude Code / SDK)
- `description`: short unique title per step
- `model`: `models.<key>` from `project/docs/tack-pipeline-models.md` when present; otherwise the baseline tier table above
- working directory: absolute `worktree_path` after Step −1 succeeds (required for **Step 1–7 and 7b** subagent dispatches). **Step 0** is lead-side: resolve `project/specs/` under `<worktree_path>/project/specs/` when isolation is active — do not list from the primary clone by mistake. Duplicate pinned cwd inside the prompt `=== INPUTS ===` (`cd` + repository-root line) per **Dispatch protocol** in `auto-orchestrator.md`. Omit working-directory pinning only when Step −1 was skipped.
- `run_in_background`: `false` unless the platform requires otherwise

## Step −1 — Worktree (optional)

Follow **Step −1** in `auto-orchestrator.md`: parse `tack.worktree.*` from repo-root **`TACK.md`** — decide `never` / `always` / `prompt`, dispatch `@worktree-coordinator.md` pinned to primary repo root when the host supports working-directory pinning (else `cd` line in INPUTS).

## Steps 0–7 and 7b

Execute in order: **Step 0** (spec id) → **Step 1** (PM grill loop using the host's question tool on `NEEDS_INPUT`) → **Step 2** (architect) → **Step 3** (qa red) → **Step 4** (harness, conditional) → **Step 5** (worker / specialists per routing table) → **Step 6** (qa green) → **Step 7** (reviewer) → **Step 7b** (security, conditional).

**Step 1:** On `STATUS: NEEDS_INPUT`, use your host's question tool (see **Platform tool mapping** in `tack-run/SKILL.md`) exactly as specified in `auto-orchestrator.md` (options + appended `Other - I'll explain in chat`).

## Outputs

The hosting agent does **not** substitute for subagents: it dispatches only. The **Final report** format is in `final-report-template.md` (same as auto-orchestrator).
