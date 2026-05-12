---
# Subagent `model` slugs for each SDD pipeline role (host-agnostic).
# Optional override file — when present, takes precedence over the dispatcher's
# baseline tier slugs. Set during tack-bootstrap (Phase 1b); see
# project/prompts/auto-orchestrator.md → Platform tool mapping for host names.
#
# Curated slugs (commonly available on subagent dispatch):
#   - claude-opus-4-7-thinking-xhigh
#   - claude-4.6-sonnet-medium-thinking
#   - composer-2-fast
#   - gpt-5.3-codex
#   - gpt-5.5-medium
#
# Tier hints (for docs only): [Opus] high-stakes, [Sonnet] contract work, [Composer] mechanical.
worktree_coordinator: composer-2-fast
product_manager: claude-opus-4-7-thinking-xhigh
architect: claude-opus-4-7-thinking-xhigh
qa_tester: claude-4.6-sonnet-medium-thinking
harness_engineer: claude-4.6-sonnet-medium-thinking
worker: composer-2-fast
reviewer: claude-opus-4-7-thinking-xhigh
security_engineer: claude-opus-4-7-thinking-xhigh
---

# Pipeline model slugs

Per-step **`Task` `model`** values for `project/prompts/orchestrator.md` (manual) and `project/prompts/auto-orchestrator.md` (active). **Source of truth:** the YAML block above — edit keys there; the table below mirrors it for humans.

| Key | Pipeline step | Tier hint | Role |
|-----|---------------|-----------|------|
| `worktree_coordinator` | Step −1 | `[Composer]` | `@worktree-coordinator.md` |
| `product_manager` | Step 1 | `[Opus]` | `@product-manager.md` |
| `architect` | Step 2 | `[Opus]` | `@architect.md` |
| `qa_tester` | Steps 3 and 6 | `[Sonnet]` | `@qa-tester.md` (red + green) |
| `harness_engineer` | Step 4 | `[Sonnet]` | `@harness-engineer.md` |
| `worker` | Step 5 | `[Composer]` | `@worker.md` and specialist prompts unless a row overrides |
| `reviewer` | Step 7 | `[Opus]` | `@reviewer.md` |
| `security_engineer` | Step 7b | `[Opus]` | `@security-engineer.md` (optional) |

**Upward fallback** when a slug is unavailable: try stronger tiers in order `composer-2-fast` → `claude-4.6-sonnet-medium-thinking` → `claude-opus-4-7-thinking-xhigh`, substituting your **configured** slug for each tier when it differs from these stock defaults (see `project/prompts/auto-orchestrator.md`).
