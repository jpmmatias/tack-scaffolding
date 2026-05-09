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

<!-- ## Bounded contexts
DDD-only — emit this section when `tack.ddd.profile = on`. Each row is one bounded context.
`Role` is `core` (competitive differentiator), `supporting` (needed but not differentiating), or `generic` (off-the-shelf candidate).

| Canonical name | Role | Source folder(s) | Primary aggregates | Owns external integrations |
|----------------|------|------------------|--------------------|----------------------------|
|                |      |                  |                    |                            |
-->

## Entities

Core domain objects and how they relate in prose (one short paragraph), then a table.

When `tack.ddd.profile = on`, use the typed table — `Type` is `aggregate root` / `entity` / `value object` / `domain service`; `Context` references a row in **Bounded contexts**; `Invariants enforced` cites the constructor / DB constraint that proves it.

| Canonical term | Type | Context | Definition | Invariants enforced | Avoid |
|----------------|------|---------|------------|---------------------|-------|
|                |      |         |            |                     |       |

When the DDD profile is `off`, use the simpler form (drop the `Type`, `Context`, and `Invariants` columns):

| Canonical term | Definition | Avoid |
|----------------|------------|------|
|                |            |      |

<!-- ## Domain events
DDD-only — emit when `tack.ddd.profile = on`. Distinct from the **Telemetry vocabulary** below; an event MAY appear in both, but they are different artifacts (one carries domain meaning, the other carries product / engineering measurement).

Naming convention: `<PastTenseVerb><Aggregate>` — e.g. `OrderPlaced`, `PaymentCaptured`.

| Event name | Emitting aggregate | Payload sketch | Consumer(s) | Telemetry link |
|------------|--------------------|----------------|-------------|----------------|
|            |                    |                |             |                |
-->

<!-- ## Context relationships
DDD-only — emit when `tack.ddd.profile = on`. One row per pair of contexts that talk. Pattern is one of: `customer-supplier`, `conformist`, `ACL`, `shared kernel`, `published language`, `partnership`, `separate ways`.

| Upstream | Downstream | Pattern | Vocabulary alignment | Notes |
|----------|------------|---------|----------------------|-------|
|          |            |         |                      |       |
-->

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
