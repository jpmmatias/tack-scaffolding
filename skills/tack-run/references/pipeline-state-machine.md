# Tack pipeline state machine (reference)

**Canonical source:** read `project/prompts/auto-orchestrator.md` from the consumer repository on every run. This file is a short index; if anything disagrees, the prompt file wins.

## Preconditions

- Consumer repo root has **`TACK.md`** (canonical) or legacy **`.cursorrules`** with quality commands and `tack.worktree.*` (and optionally `tack.routing.*`). **`project/scripts/tack-resolve-config.sh`** reads **`TACK.md` first**, then **`.cursorrules`**.
- `project/prompts/auto-orchestrator.md` exists.
- `project/docs/tack-pipeline-models.md` exists with required YAML keys when running the pipeline (see **Preflight** in `auto-orchestrator.md`).

## Model routing (Cursor slugs)

**Canonical:** `Task` **`model`** = slug from **`project/docs/tack-pipeline-models.md`** for the step’s key (`models.<key>`). See **`auto-orchestrator.md` → Preflight** and **Model routing**. **Upward fallback** uses distinct slugs from the same YAML in tier order — never downward.

Stock **tier reference** (when bootstrap used defaults):

| Orchestrator tag | Cursor model slug |
|------------------|-------------------|
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

Use **`Task`** with:

- `subagent_type`: `generalPurpose`
- `description`: short unique title per step
- `model`: **`models.<key>`** from **`project/docs/tack-pipeline-models.md`** (see **Preflight**)
- `working_directory`: absolute `worktree_path` after Step −1 succeeds (required for **Step 1–7 and 7b** subagent dispatches). **Step 0** is lead-side: resolve `project/specs/` under **`<worktree_path>/project/specs/`** when isolation is active — do not list from the primary clone by mistake. Duplicate pinned cwd inside the prompt `=== INPUTS ===` (`cd` + repository-root line) per **Dispatch protocol** in `auto-orchestrator.md`. Omit `working_directory` only when Step −1 was skipped.
- `run_in_background`: `false` unless the platform requires otherwise

## Step −1 — Worktree (optional)

Follow **Step −1** in `auto-orchestrator.md`: parse `tack.worktree.*` from repo-root **`TACK.md`** (canonical), then **`.cursorrules`** if **`TACK.md`** is missing — decide `never` / `always` / `prompt`, dispatch `@worktree-coordinator.md` with `working_directory` at primary repo root when the tool distinguishes it.

## Steps 0–7 and 7b

Execute in order: **Step 0** (spec id) → **Step 1** (PM grill loop with `AskQuestion` for `NEEDS_INPUT`) → **Step 2** (architect) → **Step 3** (qa red) → **Step 4** (harness, conditional) → **Step 5** (worker / specialists per routing table) → **Step 6** (qa green) → **Step 7** (reviewer) → **Step 7b** (security, conditional).

**Step 1:** On `STATUS: NEEDS_INPUT`, use Cursor **`AskQuestion`** exactly as specified in `auto-orchestrator.md` (options + appended `Other - I'll explain in chat`).

## Outputs

The hosting agent does **not** substitute for subagents: it dispatches only. The **Final report** format is in `final-report-template.md` (same as auto-orchestrator).
