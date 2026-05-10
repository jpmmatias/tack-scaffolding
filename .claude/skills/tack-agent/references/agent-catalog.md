# Tack agent catalog

Paths are relative to the **consumer repo root**. Prompt files live under `project/prompts/`. **Read each prompt’s Inputs section** from disk before dispatch — this table is a guide only.

## Model routing convention (fallback)

When **`project/docs/tack-pipeline-models.md`** is missing or a key is absent, use this tier → slug map and **warn** the user to run bootstrap Phase 1b or add the file.

| Tag | Cursor model slug |
|-----|-------------------|
| `[Opus]` | `claude-opus-4-7-thinking-xhigh` |
| `[Sonnet]` | `claude-4.6-sonnet-medium-thinking` |
| `[Composer]` | `composer-2-fast` |

## Pipeline model file

**Primary:** read **`project/docs/tack-pipeline-models.md`** (YAML front matter). Each **`Task`** uses the slug for the row’s **pipeline key** below.

| Agent | File | Pipeline key | Tier tag (hint) |
|-------|------|--------------|-----------------|
| Worktree coordinator | `worktree-coordinator.md` | `worktree_coordinator` | `[Composer]` |
| Product manager | `product-manager.md` | `product_manager` | `[Opus]` |
| Architect | `architect.md` | `architect` | `[Opus]` |
| QA tester | `qa-tester.md` | `qa_tester` | `[Sonnet]` |
| Harness engineer | `harness-engineer.md` | `harness_engineer` | `[Sonnet]` |
| Worker | `worker.md` | `worker` | `[Composer]` |
| Reviewer | `reviewer.md` | `reviewer` | `[Opus]` |
| Diagnose | `diagnose.md` | *(no stock key)* | `[Opus]` — use **Model routing convention (fallback)** unless you add `diagnose:` to `tack-pipeline-models.md` |
| Security engineer | `security-engineer.md` | `security_engineer` | `[Opus]` |
| Domain modeler | `domain-modeler.md` | reuse **`architect`** | `[Opus]` — use slug for **`architect`** in YAML (stock file always has it) |
| Event stormer | `event-stormer.md` | reuse **`qa_tester`** | `[Sonnet]` — use slug for **`qa_tester`** in YAML (stock file always has it) |

**Out-of-band agents** (`diagnose`, `domain-modeler`, `event-stormer`): not all have dedicated YAML keys in the stock template. **Diagnose:** add `diagnose:` to `tack-pipeline-models.md` or use **fallback** `[Opus]` slug. **Domain modeler / event stormer:** use the **`architect`** / **`qa_tester`** slug from the same file unless you add dedicated keys.

## Stock agents

| Agent | File | Model | Pipeline key | Typical triggers / notes |
|-------|------|-------|--------------|----------------------------|
| Worktree coordinator | `worktree-coordinator.md` | `[Composer]` | `worktree_coordinator` | Isolated branch/worktree; needs slug, `tack.worktree.*` from repo-root **TACK.md**; OUTPUTS: JSON only |
| Product manager | `product-manager.md` | `[Opus]` | `product_manager` | Spec authoring; **manual**: `mode: manual`, epic; **subagent/orchestrated**: `mode: autonomous`, `qa_history` |
| Architect | `architect.md` | `[Opus]` | `architect` | Needs approved spec path `project/specs/S-XXX-<slug>.md` |
| QA tester | `qa-tester.md` | `[Sonnet]` | `qa_tester` | Needs spec + plan/task context; **red** vs **green** is intent in INPUTS (phase) |
| Harness engineer | `harness-engineer.md` | `[Sonnet]` | `harness_engineer` | Harness/factories/doubles; needs spec/plan context when scoped to a feature |
| Worker | `worker.md` | `[Composer]` | `worker` | Implementation; needs spec, plan/task, red test output when continuing TDD |
| Reviewer | `reviewer.md` | `[Opus]` | `reviewer` | Needs diff or review scope + governing spec/task reference |
| Diagnose | `diagnose.md` | `[Opus]` | see **Pipeline model file** | Hard bugs, regressions, flaky behaviour; needs symptom + rules/harness context; optional `project/specs/S-XXX-*.md` path — **manual** via `tack-agent` (not part of default `auto-orchestrator` pipeline) |
| Security engineer | `security-engineer.md` | `[Opus]` | `security_engineer` | Needs diff/scope + rules, glossary, architecture; optional spec id |
| Domain modeler | `domain-modeler.md` | `[Opus]` | see **Pipeline model file** | Refines strategic DDD model — bounded contexts, context map, ACLs. Requires `tack.ddd.profile = on`. **Manual** via `tack-agent` (bootstrap-time + on-demand re-runs); **not** part of the default `auto-orchestrator` per-feature pipeline. Inputs: glossary + architecture + Phase 2 discovery draft **and/or** *event-storming draft* under `project/docs/_discovery/` + trigger text |
| Event stormer | `event-stormer.md` | `[Sonnet]` | see **Pipeline model file** | Greenfield DDD — structured event-storming interview; writes an *event-storming draft* under `project/docs/_discovery/`. Requires `tack.ddd.profile = on` and Phase 3 Block A + DDD Round 1 answers. **Manual** via `tack-agent` at bootstrap when no Phase 2 **(ddd)** draft; **not** part of the default per-feature pipeline. Inputs: repo-root **TACK.md** + Block A answers + Round 1 bounded contexts + narrative goal |

## Passive vs active orchestration (not single-agent “executors”)

| File | Role |
|------|------|
| `orchestrator.md` | Emits a **checklist** only — human runs each `@` in fresh chats. Dispatch only if the user explicitly wants that checklist text generated. |
| `auto-orchestrator.md` | Full **Task** state machine — use **`tack-run`** instead of reimplementing inside `tack-agent`. |

## Specialists

Any file under `project/prompts/` that is **not** listed above and is **not** `_specialist-template.md` or `auto-orchestrator.md` / `orchestrator.md` is a **candidate specialist** (e.g. team-created `api.md`, `ui.md`). Use the **`worker`** slug from **`project/docs/tack-pipeline-models.md`** unless the prompt or `auto-orchestrator.md` **Specialist routing** table specifies `[Sonnet]` / `[Opus]` — then use the slug for **`qa_tester`** or **`product_manager`** respectively, or the tier **fallback** in **Model routing convention (fallback)** if that key is missing.

**Discovery:** list `project/prompts/*.md` and exclude: `_specialist-template.md`, `auto-orchestrator.md`, `orchestrator.md`, and the stock rows in this table (or include them if the user picks one explicitly).

## Choosing an agent

- If the user names a role or file, map to the table.
- If ambiguous, use **`AskQuestion`** with one option per stock agent plus **Specialist: (list dynamic filenames)** and **Full pipeline (use tack-run)**.
- If the user selects **Full pipeline**, stop and instruct them to invoke **`tack-run`** with their epic (do not chain every step manually unless they insist and accept context-rot risk).
