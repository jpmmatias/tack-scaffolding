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
- Session lookup: <e.g. cookie + DB session>. Cite the resolution order (mirror `.cursorrules`).
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

- The **Layers / boundaries** table seeds the boundary rules in `.cursorrules`. Keep them in sync.
- Persistence and messaging tables are usually populated from Phase 2 sections (g) and (d). External integrations come from Phase 2 (f).
- If the user has a single-paragraph wiki link instead of a diagram, drop the **Canonical architecture diagram** section to a single bullet pointing at the URL — do not invent diagrams that do not exist.
