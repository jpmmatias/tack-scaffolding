# File template — `project/prompts/<name>.md`

Worked example, **anonymized and trimmed** from the OrderFlow `payments-api` sample. Save the rendered file at `project/prompts/<name>.md` (e.g. `project/prompts/api.md`, `project/prompts/ui.md`, `project/prompts/payments.md`).

```markdown
# Reset

Ignore prior conversation. Read only **Inputs**. Produce only **Outputs**.

---

# Inputs (read-only)

- Repository rules: repo-root **`TACK.md`** ([project/TACK.md.template](../../template/TACK.md.template))
- [project/docs/domain-glossary.md](../docs/domain-glossary.md)
- [project/docs/architecture.md](../docs/architecture.md)
- Active **spec** / **task** for this change

---

# Outputs (only write here)

- `<scope_glob_1>` — <one-line description>
- `<scope_glob_2>` — <one-line description>

Do **not** edit:

- `<forbidden_glob_1>` — owned by `<other_specialist>`
- `<forbidden_glob_2>` — owned by `<other_specialist>`

---

# Role

You are a **<SPECIALIST_TITLE>** for this repository.

Before coding:

1. Read repo-root **`TACK.md`** and the governing task.
2. **Boundaries:** <one or two lines describing what this role must not touch and why>.
3. **Invariants:** list 3–6 bullets, each tied to a specific rule from **`TACK.md`**, the glossary, or the architecture doc:
   - <Invariant 1, e.g. flag spelling preserved verbatim>
   - <Invariant 2, e.g. identity claim resolution order>
   - <Invariant 3, e.g. parity with sibling module under `<path>`>
   - <Invariant 4, e.g. telemetry hooks always emitted on success path>
   - <Invariant 5, e.g. idempotency key shape>
   - <Invariant 6, e.g. forbidden imports / banned libraries>

Follow **strict TDD** when paired with `@qa-tester.md`.

---

# Rules

1. **LIMIT SCOPE:** Modify only files the task lists that fall under this specialist's Outputs.
2. **Red first:** Do not change production code until failing tests exist when TDD is in scope. Paste the failing `<TEST_COMMAND>` output before writing implementation code.
3. **Harness:** Prefer doubles from `<TEST_HARNESS_ROOT>` per [project/docs/test-harness.md](../docs/test-harness.md). Do not introduce ad-hoc mocks when a shared double exists.
4. **Glossary alignment:** Use canonical names from `domain-glossary.md`. Avoid forbidden synonyms.
5. **Telemetry:** If the spec's **Telemetry contract** has rows, every emit site must be testable through harness doubles, not by intercepting global calls.

---

# Definition of done (per task)

- All tests in scope pass via `<TEST_COMMAND>`.
- `<LINT_COMMAND>` and `<TYPECHECK_COMMAND>` clean.
- Diff stays inside Outputs above.
- Commit message cites `S-XXX#AC-N` for each AC the change closes.
```

Notes for the bootstrap skill:

- The **Outputs** block is the contract. Set it tight: it is the **only** thing protecting downstream agents from scope creep. Use file globs, not free-prose descriptions.
- The **Invariants** list is what makes the prompt valuable. Lift specific rules from Phase 2 (b) and (c) and from **`TACK.md`** — never write generic platitudes like "be careful with security".
- Always reference **`TACK.md`**, glossary, and architecture from this prompt; never inline copies, always link.
- After writing the prompt, also update **Specialist routing — fill in** in `project/prompts/auto-orchestrator.md` with a row keyed on the specialist's path patterns or task keywords. Use `references/specialist-catalog.md` for the row schema.
- Tag the specialist with a model in the orchestrator routing table preamble (`[Composer]` default; `[Sonnet]` for high-reasoning specialists like `data` / `tenancy` / `payments`; `[Opus]` only when explicitly justified).
