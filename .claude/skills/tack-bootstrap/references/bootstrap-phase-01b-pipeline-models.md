# Phase 1b — Pipeline models (Task slugs)

Run **once** immediately after Phase 1 is accepted — **before** Phase 2 (EXISTING) or Phase 3 (NEW).

**Curated slugs** (offer these on every `AskQuestion` for a pipeline key; hosts may rename them — see consumer `project/prompts/auto-orchestrator.md`):

- `claude-opus-4-7-thinking-xhigh`
- `claude-4.6-sonnet-medium-thinking`
- `composer-2-fast`
- `gpt-5.3-codex`
- `gpt-5.5-medium`
- **`Custom — I'll type the slug in chat`** — if the user picks this, ask them to send the slug in the **next** message; reject empty or whitespace-only input.

1. **AskQuestion:** *Use Tack default model slugs for every pipeline step (tier mapping from the bundled template)?*  
   Options: **`Yes — use defaults`** / **`No — pick per step`**.
2. If **`Yes`**: set `tack.pipeline_models.mode = defaults` in working memory. Do not ask per-key questions. The file **`${SKILL_DIR}/template/docs/tack-pipeline-models.md`** is copied verbatim in Phase 5.
3. If **`No`**: set `tack.pipeline_models.mode = custom`. For **each** key below, run **`AskQuestion`** with the curated slug list plus **`Custom — I'll type the slug in chat`**. Record `key → slug` (trimmed).

   | Key | Step | Tier hint (guidance only) |
   |-----|------|---------------------------|
   | `worktree_coordinator` | −1 | `[Composer]` |
   | `product_manager` | 1 | `[Opus]` |
   | `architect` | 2 | `[Opus]` |
   | `qa_tester` | 3 and 6 | `[Sonnet]` |
   | `harness_engineer` | 4 | `[Sonnet]` |
   | `worker` | 5 | `[Composer]` |
   | `reviewer` | 7 | `[Opus]` |
   | `security_engineer` | 7b | `[Opus]` |

4. Persist the map in working memory for Phase 5. Do not advance to Phase 2 / 3 until Phase 1b is complete.
