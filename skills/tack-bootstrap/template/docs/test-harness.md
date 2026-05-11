# Test harness (intent and catalogue)

This document describes the **behaviour** and **architecture fitness** harness for automated tests: factories, boundary doubles, deterministic time, and approved fixtures. It pairs with [harness-engineering.md](./harness-engineering.md) for vocabulary (Fowler/Böckeler).

## References

- [Harness engineering for coding agent users](https://martinfowler.com/articles/harness-engineering.html) — outer harness, guides vs sensors, three regulation categories, steering loop.

## Guides vs sensors (crosswalk)

| Kind | Role in agent harness | Examples in this repo |
|------|------------------------|------------------------|
| **Guides** (feedforward) | Steer before code is written | **`TACK.md`** (repo root), `specs/S-XXX-*.md`, `project/prompts/*.md` |
| **Sensors** (computational feedback) | Deterministic checks after edits | Test runner (`<TEST_COMMAND>`), linter, type checker, reviewer checklist |
| **Sensors** (inferential feedback) | Optional; slower / probabilistic | Optional LLM review — **does not** override failing checklist items |

## Regulation categories vs artifacts

| Category | Purpose | This repo |
|----------|---------|-----------|
| **Maintainability harness** | Style, drift, readability | Tests/linters/TS; `describe('S-XXX AC-N: …')`; avoid vague `should …` for new tests |
| **Architecture fitness harness** | Boundaries, fitness | [architecture.md](./architecture.md), ADRs in `project/docs/adr/`, invariants from **`TACK.md`** |
| **Behaviour harness** | Correctness vs spec | Gherkin ACs, tests per AC, telemetry contract tests, **approved fixtures** for stable payloads |

## Intended `<TEST_HARNESS_ROOT>` contents (incremental)

Replace `<TEST_HARNESS_ROOT>` in **`TACK.md`** (e.g. `test/harness/`). Incrementally add:

- **Factories / builders** — align names with [domain-glossary.md](./domain-glossary.md)
- **Boundary doubles** — one mock surface per external system (HTTP clients, identity, payment, queue, observability SDKs)
- **Deterministic clock** — fake timers or injectable clock for time-dependent logic
- **Approved fixtures** — frozen JSON under e.g. `test/fixtures/` or `test/harness/fixtures/`

Document concrete factory names and boundaries in this file as your project grows.

## Boundary doubles (single place)

Mocks or test adapters should live in harness helpers—not scattered at every feature test—for boundaries you list in **`TACK.md`**, for example:

- Upstream HTTP APIs
- Identity / session
- Payment or billing
- Async messaging
- Product analytics / observability SDKs

Workers should import doubles from `<TEST_HARNESS_ROOT>` when it exists. The reviewer may **FAIL** bespoke mocks at call sites for those boundaries (see `project/prompts/reviewer.md`).

## Deterministic clock

Any logic depending on `Date.now()`, timeouts, or scheduling should use injectable **fake timers** or a clock abstraction so tests do not flake.

## Approved fixtures

For stable upstream shapes, store **frozen fixtures** and assert contract shape + behaviour. Do not rely on ad-hoc generated payload examples for regressions.

## Quality commands

Align local checks with your `package.json`, `Makefile`, or CI config as declared in **`TACK.md`**:

- Fast: `<LINT_COMMAND>`, `<TEST_COMMAND>`
- Broader: integration/e2e as you configure

## Behaviour harness caveat

Green tests are necessary but not sufficient if tests merely mirror implementation. Combine **strict TDD**, **AC-named tests**, **approved fixtures**, and human review on high-risk paths.
