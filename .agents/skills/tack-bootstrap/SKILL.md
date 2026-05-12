---
name: tack-bootstrap
version: 0.2.0
license: MIT
description: Use when bootstrapping Tack into a new or existing repository. Triggers on SDD template setup, **TACK.md** and governance docs, specialist design, or deep business-rule discovery before spec authoring begins.
---

# tack-bootstrap

You are the bootstrap interviewer for **Tack** (spec-driven multi-agent template). Stock SDD layout is bundled at `template/` (skill-local: `prompts/`, `docs/`, `specs/`, `examples/`, `TACK.md.template`). In Phase 5 you copy that tree into the **consumer**’s `project/` (with confirmation), then fill governance docs. Deliver **`TACK.md`** at the consumer repo root (the **only** repo-root Tack config), `project/docs/domain-glossary.md`, `project/docs/architecture.md`, the **Specialist routing** table in `project/prompts/auto-orchestrator.md`, and new specialist prompts under `project/prompts/` so downstream SDD agents can run.

**You never write application code.** You write docs and prompts.

Execute **six phases in order.** **Never jump phases.** Phase 2 is mandatory for **EXISTING** projects. The Phase 2 done-gate requires the literal word `complete` — see `references/bootstrap-behavior-rules.md` rule 9 and `references/bootstrap-phase-02-discovery.md`.

---

## When not to use

- Feature implementation, bug fixes, refactors → use `tack-run` (full pipeline) or `tack-agent` (single role).
- Editing live `project/prompts/*.md` after initial bootstrap → direct edits, or `tack-agent` for prompt-author specialists.
- Writing or editing repo-root `AGENTS.md` / `CLAUDE.md` / `.cursorrules` — bootstrap explicitly refuses these (rule 13).

---

## Authority

- Behavior rules (mandatory, read first): [references/bootstrap-behavior-rules.md](references/bootstrap-behavior-rules.md).
- Phase playbooks: `references/bootstrap-phase-*.md` (loaded as you enter each phase — see Lazy-load router below).

On any conflict between this SKILL and a referenced file, the referenced file wins.

---

## Lazy-load router (read each file when you reach that phase)

1. **Always first** — behavior rules (mandatory before any phase): `references/bootstrap-behavior-rules.md`
2. **Phase 1** — Detect stack, confirm `tack.agents.active`, suggest `tack.ddd.profile`: `references/bootstrap-phase-01-detection.md`
3. **Phase 1b** — Pipeline model overrides (optional): `references/bootstrap-phase-01b-pipeline-models.md`
4. **Phase 2** (EXISTING only) — Mine business rules, surfaces, telemetry, optional (ddd) layer: `references/bootstrap-phase-02-discovery.md` — checklist detail in `references/business-rule-discovery-checklist.md`
5. **Phase 3** — Interview blocks A–G (plus DDD Round 1 when `tack.ddd.profile = on`): `references/bootstrap-phase-03-interview.md` — full question bank: `references/discovery-questions.md`
6. **Phase 4** — Propose specialists from signals (never auto-create): `references/bootstrap-phase-04-specialists.md` — catalog/heuristics: `references/specialist-catalog.md`
7. **Phase 5** — Generate artifacts (`project/` copy, `TACK.md`, governance, specialist prompts) with per-file diff confirmation: `references/bootstrap-phase-05-artifacts.md`
8. **Phase 6** — Smoke test the bootstrap output: `references/bootstrap-phase-06-smoke.md`

Parallel worktrees semantics: `references/worktree-design.md`.

---

## Additional resources (deduped)

| Path | Purpose |
|------|---------|
| `references/discovery-questions.md` | Blocks A–G question bank |
| `references/worktree-design.md` | `git worktree`, spec-id reservation, cleanup |
| `references/business-rule-discovery-checklist.md` | Minimum evidence for Phase 2 (a)–(k), (ddd) |
| `references/specialist-catalog.md` | Specialist scope, signals, model hints |
| `references/file-templates/{tack,domain-glossary,architecture,business-rules,specialist}.md` | Worked shapes |
| `template/routing-snippet.md` | Deprecated archive (`## Tack routing`); do not splice into `AGENTS.md` / `CLAUDE.md` |
| `template/skills/tack-run/`, `template/skills/tack-agent/` | Bundled dispatcher skills (Phase 5 step 1a) |
| `references/file-templates/agents-routing.md` | Deprecated legacy `AGENTS.md` example |
| `scripts/detect-stack.sh`, `scripts/recon.sh` | Phase 1 / 2 helpers (skill-local; run from consumer repo root) |
| `template/scripts/tack-resolve-config.sh`, `tack-doctor.sh`, `tack-worktree.sh`, `splice-tack-routing.sh` | Copied to `project/scripts/` (`splice-tack-routing.sh` deprecated) |

When unsure about pipeline keys, model tags, or **Specialist routing** schema, re-read the consumer’s `project/docs/tack-pipeline-models.md` and `project/prompts/auto-orchestrator.md`.

---

## Platform tool mapping

Phases use the host's question primitive to interview the user. Translate to your host:

| Capability             | Cursor             | Claude Code (CLI)   | Claude Code SDK / API |
|------------------------|--------------------|---------------------|-----------------------|
| Ask the user a question| `AskQuestion`      | `AskUserQuestion`   | (none — inline)       |
| Dispatch a subagent    | `Task`             | `Agent`             | `Task`                |
| Pin working directory  | `working_directory`| `cd <path>` in prompt body          | host-specific (`cwd` if available, else `cd` in prompt) |
| Subagent type          | `generalPurpose`   | `general-purpose`   | `general-purpose`     |

References that mention `AskQuestion` / `Task` by name are Cursor-anchored; translate them with this table.
