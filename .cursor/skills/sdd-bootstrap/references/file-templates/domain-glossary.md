# File template — `project/docs/domain-glossary.md`

Worked example, **anonymized and trimmed** from the OrderFlow sample. Save the rendered file at `project/docs/domain-glossary.md` in the consumer repo.

```markdown
# Domain glossary

**Purpose:** single vocabulary for specs, code, prompts, and tests. When you introduce a new domain noun, add it here in the same change as the spec or ADR that uses it.

## Product

<One paragraph: what the system does and for whom. State explicitly what is **out of scope** so the agents do not drift. Example: "OrderFlow lets merchants embed a hosted checkout. It owns cart presentation, payment orchestration callbacks, and telemetry — not long-term order fulfillment, which belongs to the merchant OMS.">

## Surfaces

| Canonical term | Definition | Avoid |
|----------------|------------|-------|
| **<Surface 1>** | <one-line definition, cite path> | <forbidden synonym> |
| **<Surface 2>** | <…> | <…> |

## Entities

One short paragraph on how entities relate (parent/child, ownership, lifecycle), then:

| Canonical term | Definition | Avoid |
|----------------|------------|-------|
| **<Entity 1>** | <definition, cite where the entity lives in code> | <forbidden synonyms> |
| **<Entity 2>** | <…> | <…> |
| **<Entity 3>** | <…> | <…> |

## Boundaries (external systems)

| Boundary | Responsibility | Canonical name in code/docs |
|----------|----------------|----------------------------|
| **<External system 1>** | <what it does for us> | `<ClientClass>` in `<src/path>` |
| **<External system 2>** | <…> | `<…>` |

## Cross-cutting concerns

List invariants the agents must preserve (spelling, claim order, etc.). Mirror the **Engineering invariants** section of `.cursorrules`.

| Topic | Rule | Notes |
|-------|------|-------|
| Identity | <e.g. session id resolution order> | <cite> |
| Feature flags | <names that must not be auto-corrected> | <cite> |
| Encryption | <fields encrypted at rest, KMS key alias> | <cite> |
| Observability | <required correlation ids, log structure> | <cite> |

## Telemetry vocabulary

Align with the **Telemetry contract** table in each spec.

| Pipeline (rename to match your stack) | When used |
|---------------------------------------|-----------|
| `<PRODUCT_ANALYTICS>` | User-visible product events |
| `<ENGINEERING_OBSERVABILITY>` | Engineering / user-action traces |
| `<LOCAL_DEV_OR_TRACE>` | Optional local-only diagnostics (must never ship PII) |

## Forbidden synonyms

Global list of terms agents must **not** use for new work (legacy code may retain old names until refactored).

| Do not use | Use instead |
|------------|-------------|
| <legacy term> | <canonical term> |
```

Notes for the bootstrap skill:

- Populate `Entities`, `Surfaces`, `Boundaries` directly from Phase 2 sections (a) and (f). Each row should carry a `file:line` citation in a code block or footnote during Phase 5 review; the user may strip citations before final write.
- The `Forbidden synonyms` table is rarely empty for an existing project. If the user claims it is empty, push back with at least one likely candidate from the Phase 2 draft (alias columns of section (a)).
- Replace `<PRODUCT_ANALYTICS>` / `<ENGINEERING_OBSERVABILITY>` / `<LOCAL_DEV_OR_TRACE>` with the actual pipeline names the user gave in Block A — do **not** ship the placeholders.
