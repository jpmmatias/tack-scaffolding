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

## Bounded contexts

> **DDD profile only.** Emit this section when `tack.ddd.profile = on`; otherwise omit it.

`Role` classifies each context as `core` (competitive differentiator), `supporting` (needed but not differentiating), or `generic` (off-the-shelf candidate).

| Canonical name | Role | Source folder(s) | Primary aggregates | Owns external integrations |
|----------------|------|------------------|--------------------|----------------------------|
| **<Context A>** | core | `src/checkout/**` | <Cart>, <Order> | <PaymentGateway> |
| **<Context B>** | supporting | `src/inventory/**` | <StockItem> | <InventoryService> |
| **<Context C>** | generic | `src/notifications/**` | — | <NotificationProvider> |

## Entities

One short paragraph on how entities relate (parent/child, ownership, lifecycle), then — **when `tack.ddd.profile = on`** — use the typed table:

| Canonical term | Type | Context | Definition | Invariants enforced | Avoid |
|----------------|------|---------|------------|---------------------|-------|
| **<Aggregate 1>** | aggregate root | <Context A> | <definition, cite path> | <e.g. "total never negative; cite `file:line`"> | <forbidden synonym> |
| **<Entity 2>** | entity | <Context A> | <…> | <…> | <…> |
| **<Value object 3>** | value object | <Context A> | <…> | <equal-by-value, immutable> | <…> |

When the DDD profile is `off`, fall back to the simpler form (drop the `Type`, `Context`, and `Invariants` columns).

## Domain events

> **DDD profile only.** Emit this section when `tack.ddd.profile = on`. Distinct from the **Telemetry vocabulary** table below; an event MAY appear in both but they are different artifacts.

Naming convention: `<PastTenseVerb><Aggregate>` — e.g. `OrderPlaced`, `PaymentCaptured`. Reject deviations in `.cursorrules`.

| Event name | Emitting aggregate | Payload sketch | Consumer(s) | Telemetry link |
|------------|--------------------|----------------|-------------|----------------|
| **<OrderPlaced>** | <Order> | `{ orderId, customerId, totalCents, currency }` | <Inventory>, <Notifications> | `<order_placed_event>` |
| **<PaymentCaptured>** | <PaymentIntent> | `{ intentId, orderId, amountCents }` | <Order>, <Telemetry> | `<payment_captured>` |

## Context relationships

> **DDD profile only.** One row per pair of contexts that talk. Pattern is one of: `customer-supplier`, `conformist`, `ACL`, `shared kernel`, `published language`, `partnership`, `separate ways`.

| Upstream | Downstream | Pattern | Vocabulary alignment | Notes |
|----------|------------|---------|----------------------|-------|
| <Context A> | <Context B> | customer-supplier | published language for `OrderPlaced` | Downstream cannot block upstream releases |
| <Context A> | <Context C> | ACL | translated at `<src/acl/notifications.ts>` | External provider quirks isolated |

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
- When `tack.ddd.profile = on`, populate `Bounded contexts`, the typed `Entities` table, `Domain events`, and `Context relationships` from Phase 2 section (ddd) and Phase 3 Block A — DDD answers. When the profile is `off`, **omit** all four sections — do not ship empty tables for them.
