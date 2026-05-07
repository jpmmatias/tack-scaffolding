# SDD + multi-agent template

Portable **spec-driven development** (SDD) and **isolated role prompts** for coding agents: numbered specs (`S-XXX`), acceptance criteria (`AC-N`), plans with traceability, ADRs (`ADR-NNNN`), strict TDD gates, and optional full-auto orchestration via subagents.

## What’s in this folder

| Path | Purpose |
|------|---------|
| `.cursorrules.template` | Rename to `.cursorrules` in your repo; fill placeholders (`<STACK>`, `<TEST_COMMAND>`, etc.). |
| `docs/sdd.md` | SDD lifecycle and 7-step pipeline. |
| `docs/harness-engineering.md` | Guides vs sensors, steering loop. |
| `docs/test-harness.md` | Test harness intent and boundary doubles. |
| `docs/domain-glossary.md` | Skeleton glossary — **must** be filled for your domain. |
| `docs/architecture.md` | Where to put your canonical architecture doc. |
| `docs/adr/_template.md` | ADR template. |
| `prompts/*.md` | Role prompts: product manager, architect, QA, harness engineer, worker, reviewer, security engineer, orchestrators. |
| `prompts/_specialist-template.md` | Duplicate and rename for stack-specific roles (API, UI, mobile boundary, etc.). |
| `specs/_template.md` | Product spec template. |
| `examples/` | Fictitious **OrderFlow** examples showing how to instantiate each piece. |

## Bootstrap (new repo)

1. Copy this directory into your repo as `project/` (or merge into an existing `project/` layout).
2. Copy `.cursorrules.template` to the **repository root** as `.cursorrules` and fill every `<PLACEHOLDER>`.
3. Replace placeholders in `docs/architecture.md` and `docs/domain-glossary.md`.
4. Duplicate `prompts/_specialist-template.md` for each specialist you need (e.g. `prompts/api.md`, `prompts/ui.md`).
5. Extend **`Specialist routing — fill in`** in `prompts/auto-orchestrator.md` and optionally in `prompts/orchestrator.md` so Step 5 dispatches the right specialist files and path heuristics.
6. Run the pipeline:
   - **Passive:** `@prompts/orchestrator.md` — follow the checklist in isolated chats.
   - **Active:** `@prompts/auto-orchestrator.md` — same steps, executed as subagents where your environment supports it.

## Conventions (summary)

- **Specs:** `S-001`, `S-002`, … — files `specs/S-XXX-<slug>.md`.
- **ACs:** `AC-1`, `AC-2`, … in Gherkin inside the spec.
- **Plans:** `plan.md` with first line `Spec: S-XXX` and a `## Traceability` table (tasks ↔ ACs).
- **ADRs:** `ADR-0001`, … — files under `project/docs/adr/` (adjust path if you relocate).
- **Commits / PRs:** cite `S-XXX` and closed `AC-N` where applicable (e.g. `Closes: S-001#AC-1`).

## References

- [Harness engineering for coding agent users](https://martinfowler.com/articles/harness-engineering.html) (Böckeler, martinfowler.com)
