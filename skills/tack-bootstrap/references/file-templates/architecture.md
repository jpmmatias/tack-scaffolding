# File template — `project/docs/architecture.md`

Worked example, **anonymized and trimmed** from the OrderFlow sample. Save the rendered file at `project/docs/architecture.md`.

```markdown
# Architecture

## One-paragraph summary

<Topology + persistence + key external boundaries in three sentences. Example: "OrderFlow Checkout is a Next.js modular monolith deployed to a single region. It uses Postgres as the system of record, BullMQ for async jobs, and integrates with PaymentGateway, InventoryService, and NotificationService as the only external boundaries.">

## Canonical architecture diagram

- Primary: <PATH_OR_URL_TO_DIAGRAM> (e.g. `docs/architecture/order-flow.md`, internal wiki page, Excalidraw export)
- Optional supporting diagrams: <list>

## Topology

- Pattern: <monolith | modular monolith | microservices | serverless | hybrid>
- Deploy unit(s): <e.g. one Next.js app, three serverless functions, two long-lived services>
- Region(s): <single | multi> — name them.

## Layers / boundaries

| Layer | Responsibility | Path glob | Forbidden imports |
|-------|----------------|-----------|-------------------|
| Domain | Pure business rules, no I/O | `src/domain/**` | `src/lib/db/**`, `src/app/api/**`, third-party SDKs |
| Application | Use-cases, orchestration | `src/application/**` | `src/app/api/**`, framework-specific request types |
| Infra | Database, queue, external SDKs | `src/lib/**` | `src/domain/**` (only domain interfaces, never concretes) |
| Boundary | HTTP / RPC / Webhooks / UI | `src/app/**` | `src/lib/db/**` directly — go through application layer |
| Tests / harness | Doubles, factories, scenario runners | `<TEST_HARNESS_ROOT>/**` | none |

When `tack.ddd.profile = on`, the rows above apply **per bounded context** — i.e. each context has its own `domain/`, `application/`, `infra/`, `boundary/` quadrants under its source folder. **Cross-context imports are forbidden** except through the anticorruption layers listed below.

## Context map

> **DDD profile only.** Emit this section when `tack.ddd.profile = on`; otherwise omit it. Mirrors **Bounded contexts** in `domain-glossary.md`.

Pattern values: `customer-supplier` (one team's deadlines drive the other's), `conformist` (downstream accepts upstream's vocabulary as-is), `ACL` (downstream wraps upstream behind an anticorruption layer), `shared kernel` (both sides own a common module — heavy coupling), `published language` (versioned contract, e.g. event schema), `partnership` (mutual roadmap commitment), `separate ways` (no integration; coincidental shared vocabulary).

| Upstream | Downstream | Pattern | How they communicate |
|----------|------------|---------|----------------------|
| <Context A> | <Context B> | customer-supplier | published language: `<OrderPlaced>` event |
| <Context A> | <Context C> | ACL | translated at `<src/acl/notifications.ts>` |
| <Context B> | <External: PaymentGateway> | ACL | webhook + outbound at `<src/lib/payment/>` |

A mermaid `flowchart LR` is also acceptable in place of the table when the team prefers a visual; pick one, not both.

## Anticorruption layers

> **DDD profile only.** One row per external integration that needs translation between contexts or vendor vocabulary. Re-uses the **External integrations** table below — the ACL row should be the same client cited there.

| External system | ACL location | Translates | Forbidden leaks (do not let these reach domain) |
|-----------------|--------------|------------|--------------------------------------------------|
| <PaymentGateway> | `<src/lib/payment/acl.ts>` | vendor `charge_id` → domain `PaymentIntent.id`; vendor error codes → domain `PaymentFailureReason` | raw vendor SDK types; PAN; 3DS challenge HTML |
| <NotificationProvider> | `<src/acl/notifications.ts>` | vendor template id → domain `NotificationKind`; vendor delivery status → domain enum | provider-specific retry headers; per-recipient cost data |

## Persistence

| Store | Purpose | Schema source | Migration tool |
|-------|---------|---------------|----------------|
| <Postgres> | System of record for <entities> | `<prisma/schema.prisma>` or `<migrations/>` | <prisma migrate \| alembic \| flyway> |
| <Redis> | Caching, rate limiting, session lookup | n/a | n/a |
| <S3 / object storage> | <files / exports / receipts> | n/a | n/a |

## Messaging / async

| Mechanism | Purpose | Producer path | Consumer path |
|-----------|---------|---------------|---------------|
| <BullMQ \| SQS \| Kafka> | <job name> | `<src/jobs/...>` | `<src/workers/...>` |
| <Webhooks inbound> | <provider> | `<webhooks/...>` | n/a |

## External integrations

| Boundary | Direction | Canonical client | Idempotency strategy | PII boundary |
|----------|-----------|------------------|---------------------|--------------|
| <PaymentGateway> | Both (outbound + webhook) | `<src/lib/payment/...>` | Deterministic key per intent | Card data tokenized; never logged |
| <InventoryService> | Outbound | `<src/lib/inventory/...>` | Request id from caller | n/a |
| <NotificationService> | Outbound | `<src/lib/notify/...>` | Dedup by message hash | Email + name leave the system |

## Identity & authorization

- Authentication: <mechanism, e.g. NextAuth, OIDC, custom JWT> at `<src/auth/...>`.
- Session lookup: <e.g. cookie + DB session>. Cite the resolution order in repo-root **`TACK.md`**.
- Authorization: <e.g. role-based middleware> at `<src/auth/middleware.ts>`. Capability matrix lives in `domain-glossary.md`.

## ADRs

- All architectural decisions live under `project/docs/adr/` numbered `ADR-NNNN`. Use `project/docs/adr/_template.md`.
- Reference ADRs in prose as `ADR-NNNN`.

## How SDD uses this file

- `prompts/architect.md` reads this file when producing `plan.md` and ADRs.
- `prompts/security-engineer.md` uses it for trust-boundary review.
- `prompts/reviewer.md` cites layer boundaries when checking PRs.

## Open architectural questions

List anything Phase 2 / Phase 3 surfaced as `[ADR]` follow-ups but did not yet decide. Each one should become an ADR before its first dependent spec lands.

- <open question 1>
- <open question 2>
```

Notes for the bootstrap skill:

- The **Layers / boundaries** table seeds the boundary rules in **`TACK.md`**. Keep them aligned with `project/docs/architecture.md`.
- Persistence and messaging tables are usually populated from Phase 2 sections (g) and (d). External integrations come from Phase 2 (f).
- If the user has a single-paragraph wiki link instead of a diagram, drop the **Canonical architecture diagram** section to a single bullet pointing at the URL — do not invent diagrams that do not exist.
- When `tack.ddd.profile = on`, populate **Context map** and **Anticorruption layers** from Phase 2 sections (ddd.5) and (ddd.4). When the profile is `off`, **omit** both sections entirely — do not ship empty tables for them.
