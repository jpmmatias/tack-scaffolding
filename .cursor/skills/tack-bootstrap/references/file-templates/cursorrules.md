# File template — `.cursorrules`

Worked example, **anonymized and trimmed** from the OrderFlow sample. Use as a shape guide; replace every `<PLACEHOLDER>` and every concrete OrderFlow value with what you collected during Phases 1–3 of `tack-bootstrap`. Save as `.cursorrules` at the **repository root** (not under `project/`).

```markdown
# Project: <PROJECT_NAME>

## Tech stack

- <PRIMARY_LANGUAGE> (e.g. TypeScript, Python, Go)
- <FRAMEWORKS> (e.g. Next.js + Vitest, FastAPI + pytest, Rails + RSpec)
- <PACKAGE_MANAGER> (e.g. pnpm, poetry, cargo)

## Domain and naming (CRITICAL)

- **Product:** <ONE_LINE_PRODUCT_DESCRIPTION>.
- **Core entities:** list canonical nouns. Forbidden synonyms must be rejected in new docs and code (legacy code may keep old names until refactored).
- **Boundaries:** name external systems with the *single* canonical spelling used in code/docs (e.g. `PaymentGateway`, never "the payments API").

## Engineering invariants (CRITICAL)

- **<INVARIANT_NAME_1>:** describe the rule in one sentence and cite where it lives. Example: "Flag spelling `IDEMPOTENT_RETRY_V2` is intentional. Do not 'fix' it."
- **<INVARIANT_NAME_2>:** parity rule between two modules — e.g. "Behaviour edits to checkout orchestration must touch both `src/providers/legacy/**` and `src/providers/checkout/**` until legacy is retired."
- **<INVARIANT_NAME_3>:** identity / claim resolution order — e.g. "Read `<sessionId>` from `<cookie>` first, fall back to `<claim>` in the signed JWT. Never use `sub`."

## Architecture rules

- Canonical architecture: `project/docs/architecture.md` (link to your source of truth if it lives elsewhere).
- Module / layer boundaries: <BOUNDARY_RULES>. Example: "Domain layer cannot import from infra. UI cannot import from server actions directly — only via typed RPC clients under `src/lib/rpc/`."

## SDD / TDD / harness

- **Specs:** `S-001`, `S-002`, … under `project/specs/<S-XXX-slug>.md`. Reference the active spec id in plans, commits, and PRs when changing behaviour.
- **ADRs:** `ADR-0001`, `ADR-0002`, … under `project/docs/adr/`. Use `project/docs/adr/_template.md`.
- **Traceability:** Tasks cite `AC-N`. Commits use `Closes: S-XXX#AC-N` where applicable.
- **Glossary:** New domain nouns belong in `project/docs/domain-glossary.md`. Do not invent parallel vocabulary.
- **Harness root:** `<TEST_HARNESS_ROOT>` (e.g. `test/harness/` or `tests/_harness/`). Shared factories, doubles, scenario runners.

## Quality commands

- Lint: `<LINT_COMMAND>` (e.g. `pnpm lint`)
- Tests: `<TEST_COMMAND>` (e.g. `pnpm test`)
- Typecheck: `<TYPECHECK_COMMAND>` (e.g. `pnpm typecheck`)
- E2E: `<E2E_COMMAND>` (omit if covered by `<TEST_COMMAND>`)
- Build: `<BUILD_COMMAND>`
- Format: `<FORMAT_COMMAND>` (omit if format runs in lint)

The orchestrator prompts assume a **red** then **green** test gate using `<TEST_COMMAND>`. Override per task only when explicitly justified.
```

Notes for the bootstrap skill:

- Do not write `<TBD>` or `???` into `.cursorrules`. If a value is unknown, **ask** before generating the file.
- The block headings (`Tech stack`, `Domain and naming`, `Engineering invariants`, `Architecture rules`, `SDD / TDD / harness`, `Quality commands`) are part of the contract — keep them verbatim.
- If the consumer repo already has a `.cursorrules`, **diff** before overwriting and offer merge.
