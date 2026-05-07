# Domain glossary

**Purpose:** single vocabulary for specs, code, prompts, and tests. When you introduce a **new domain noun**, add it here in the same change as the spec or ADR that uses it.

Replace section placeholders with your product language. Delete unused sections or add more as needed.

## Product

One paragraph: what the system does and for whom.

## Surfaces

Name each primary UI/API surface and **avoid** ambiguous alternatives.

| Canonical term | Definition | Avoid |
|----------------|------------|------|
| | | |

## Entities

Core domain objects and how they relate in prose (one short paragraph), then a table:

| Canonical term | Definition | Avoid |
|----------------|------------|------|
| | | |

## Boundaries (external systems)

Name integrations and the **single** way to refer to them in docs and code.

| Boundary | Responsibility | Canonical name in code/docs |
|----------|----------------|----------------------------|
| | | |

## Cross-cutting concerns

Examples: identity, authorization, feature flags, encryption, observability. List invariants that must not drift (spellings, claim order, etc.).

| Topic | Rule | Notes |
|-------|------|------|
| | | |

## Telemetry vocabulary

Align with the **Telemetry contract** table in each spec:

| Pipeline (rename to match your stack) | When used |
|---------------------------------------|-----------|
| `<PRODUCT_ANALYTICS>` | User-visible product events |
| `<ENGINEERING_OBSERVABILITY>` | Engineering/user-action traces |
| `<LOCAL_DEV_OR_TRACE>` | Optional local-only diagnostics |

## Forbidden synonyms

Global list of terms agents must **not** use for new work (legacy code may retain old names until refactored).

| Do not use | Use instead |
|------------|-------------|
| | |
