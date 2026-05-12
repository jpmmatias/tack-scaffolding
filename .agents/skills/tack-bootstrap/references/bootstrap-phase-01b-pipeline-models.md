# Phase 1b — Pipeline models (override slugs)

Run after Phase 1 if the user wants per-step slugs different from the bundled defaults. Otherwise the dispatcher skills (`tack-run`, `tack-agent`) fall back to defaults automatically; you may skip directly to Phase 2 / 3.

**Curated slugs** (offer these on every question for a pipeline key; hosts may rename them — see consumer `project/prompts/auto-orchestrator.md`):

- `claude-opus-4-7-thinking-xhigh`
- `claude-4.6-sonnet-medium-thinking`
- `composer-2-fast`
- `gpt-5.3-codex`
- `gpt-5.5-medium`
- **`Custom — I'll type the slug in chat`** — if the user picks this, ask them to send the slug in the **next** message; reject empty or whitespace-only input.

1. Ask the user (via the host's question tool — see **Platform tool mapping** in `tack-bootstrap/SKILL.md`): *Use Tack default model slugs for every pipeline step (tier mapping from the bundled template)?*  
   Options: **`Yes — use defaults`** / **`No — pick per step`**.
2. If **`Yes`**: set `tack.pipeline_models.mode = defaults` in working memory. Do not ask per-key questions. The file `template/docs/tack-pipeline-models.md` (skill-local) is copied verbatim in Phase 5.
3. If **`No`**: set `tack.pipeline_models.mode = custom`. For **each** key below, ask the user via the host's question tool with the curated slug list plus **`Custom — I'll type the slug in chat`**. Record `key → slug` (trimmed).

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

4. Persist the map in working memory for Phase 5. If Phase 1b is skipped entirely, dispatchers use the default tier slugs and warn once at runtime.
