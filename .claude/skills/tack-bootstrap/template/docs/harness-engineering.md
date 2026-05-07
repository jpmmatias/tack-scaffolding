# Harness engineering (outer harness)

This repo uses **harness engineering** in the sense of [Harness engineering for coding agent users](https://martinfowler.com/articles/harness-engineering.html) (Böckeler, martinfowler.com, April 2026): **Agent = Model + Harness**. The **outer harness** is what you define—rules, specs, prompts, tests, review gates—not the IDE’s built-in model or retrieval.

## Core ideas

- **Guides (feedforward)** steer before implementation: `project/.cursorrules`, `specs/S-XXX-*.md`, `project/prompts/*.md`.
- **Sensors (feedback)** check after: your test runner, linter, type checker, the reviewer checklist.
- **Computational** sensors are deterministic (CPU, fast). **Inferential** sensors (e.g. optional LLM review) are slower and probabilistic—they **never** replace hard failures on invariants defined in `.cursorrules` or the spec.
- **Steering loop:** when the same mistake repeats, improve **both** guides and sensors so the next agent self-corrects earlier (fewer tokens, higher quality).

## Three regulation categories

See the table in [test-harness.md](./test-harness.md). In short:

1. **Maintainability** — linting, typing, test naming tied to `S-XXX AC-N`.
2. **Architecture fitness** — ADRs, module boundaries, stack-specific invariants from `.cursorrules`.
3. **Behaviour** — Gherkin ACs, telemetry contracts, approved fixtures for upstream payloads.

## Harnessability (ambient affordances)

Environments that are **legible** and **tractable** for agents improve outcomes. This template favours:

- Explicit types and domain terms ([domain-glossary.md](./domain-glossary.md))
- Clear boundaries in [architecture.md](./architecture.md)
- Consistent prompt **Inputs / Outputs** sections in `project/prompts/`

## Detail catalogue

For factories, boundary doubles, clocks, and fixtures, see [test-harness.md](./test-harness.md).
