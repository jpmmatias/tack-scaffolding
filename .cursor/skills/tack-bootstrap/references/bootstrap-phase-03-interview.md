# Phase 3 — Guided interview

Conducted in **short rounds, max 3 questions per turn**. After each block, summarize what you captured and ask for confirmation before proceeding to the next block.

For **EXISTING** projects: skip every question Phase 2 already answered. Ask only the remaining gaps.

For **NEW** projects: run every block in full.

The full question bank lives in `references/discovery-questions.md`. Blocks, in order:

- **Block A — Product & domain.** Business problem, personas/roles, 3–7 core entities (canonical + forbidden synonyms), surfaces (UI / API / jobs / channels), telemetry pipelines. **When `tack.ddd.profile = on`,** follow the **Block A — DDD subsection** in `references/discovery-questions.md`: **Round 1** (strategic shape) always; if Phase 2 draft is missing or has no populated **(ddd)** section (**greenfield path**), **stop after Round 1** for tactical DDD and direct the human to run **`@event-stormer.md`** via **`tack-agent`** before Block B. If Phase 2 **(ddd)** exists (**existing path**), continue with Rounds 2–3 inline per that file.
- **Block B — Stack & quality.** Confirm/collect stack. Exact commands: `lint`, `test`, `typecheck`, `build`, `e2e`, `format`. Separate runners for integration / E2E? Required minimum coverage?
- **Block C — Engineering invariants.** Boundary rules (e.g. "domain does not import from infra"), function/module size limits, mandatory architectural pattern (hexagonal, clean, feature folders, …), mock conventions and libraries.
- **Block D — Architecture.** Topology (monolith, modular, microservices, serverless), persistence, messaging, jobs, auth/identity, critical external integrations.
- **Block E — Team & risk.** Team size, security/compliance areas (PII, PCI, GDPR, HIPAA, SOC2, etc.), existing ADRs or starting fresh.
- **Block F — Parallel execution (git worktrees).** Three questions (max 3 per turn; if combined with other gaps, split across rounds):
  1. Should `@auto-orchestrator.md` ask before creating an isolated worktree per feature? Recommend **`prompt`** (confirm each run), alternatives **`always`** / **`never`** (legacy single-checkout flow).
  2. Branch naming: recommend **`feature/S-XXX-<slug>`** (ties branch to spec id); alternative **`feature/<slug>`** only if the team insists.
  3. Base branch for `git worktree add`: **`detect`** (script tries `main` → `master` → current) vs pinning **`main`** / **`master`** / another stable branch.
- **Block G — Agent routing (auto-orchestration).** One question.
  1. Should this repo auto-route every feature/bug/task request to `@project/prompts/auto-orchestrator.md`? Recommend **`yes`**: the SDD pipeline becomes the default; agents should load repo-root **`TACK.md`** for entry points, commands, and worktree policy. **`no`** keeps the passive flow (the human `@`-mentions prompts manually). Persist as `tack.routing.auto` in **`TACK.md`**.

  If the user wants to change which agents receive skill installs, return to Phase 1 and re-ask **`tack.agents.active`** there — do not introduce a parallel control surface in Block G.

When the user says "I don't know", offer 2–3 options with trade-offs (see Block-by-Block defaults in `references/discovery-questions.md`).
