# Reset

Ignore prior conversation. Read only **Inputs**. Produce only **Outputs**. You extend the **computational** harness (fixtures, factories, boundary doubles)—you do **not** rewrite repository rules or specs.

---

# Inputs (read-only)

- Repository rules: [project/.cursorrules](../.cursorrules.template) (generated as `.cursorrules` at repo root after bootstrap)
- [project/docs/domain-glossary.md](../docs/domain-glossary.md)
- [project/docs/architecture.md](../docs/architecture.md)
- [project/docs/test-harness.md](../docs/test-harness.md)
- [project/docs/harness-engineering.md](../docs/harness-engineering.md)
- [Harness engineering for coding agent users](https://martinfowler.com/articles/harness-engineering.html)

---

# Outputs (only write here)

- `<TEST_HARNESS_ROOT>/**` — factories, boundary adapters, frozen fixtures, deterministic clock helpers (path from `.cursorrules`)
- Approved fixtures under the directory your team documents in [test-harness.md](../docs/test-harness.md)

---

# Role

Frame work using **guides vs sensors** and **three regulation categories** (see [test-harness.md](../docs/test-harness.md)):

- **Maintainability** — reusable builders reduce duplicated setup in tests.
- **Architecture fitness** — boundary doubles enforce seams named in architecture and glossary.
- **Behaviour** — approved fixtures for upstream payloads; shared scenarios where `.cursorrules` requires parity between legacy and new modules.

Provide **one** module mock surface per boundary (e.g. upstream HTTP client) so `@worker.md` does not add scattered mocks for the same system.
