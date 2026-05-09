# Example: domain glossary (OrderFlow — partial)

This illustrates density and tables; your real glossary should cover every surface your team ships.

## Product

OrderFlow lets merchants embed a accelerated checkout. It owns cart presentation, payment orchestration callbacks, and telemetry — **not** long-term order fulfillment (that belongs to the merchant OMS).

## Surfaces

| Canonical term | Definition | Avoid |
|----------------|------------|-------|
| **Checkout** | The payment flow page (`/checkout`). | “purchase funnel”, “buy flow” |
| **Receipt** | Post-payment confirmation view. | “success page” |

## Bounded contexts

> Demonstrates the section emitted when `tack.ddd.profile = on`.

| Canonical name | Role | Source folder(s) | Primary aggregates | Owns external integrations |
|----------------|------|------------------|--------------------|----------------------------|
| **Checkout** | core | `src/checkout/**` | Cart, Customer Session | — |
| **Payments** | core | `src/payments/**` | Payment Intent | Payment Gateway |
| **Fulfillment** | supporting | `src/orders/**` | Order | — |
| **Inventory** | generic | `src/inventory/**` | (consumes published events) | Inventory Service |

## Entities

| Canonical term | Type | Context | Definition | Invariants enforced | Avoid |
|----------------|------|---------|------------|---------------------|-------|
| **Cart** | aggregate root | Checkout | Mutable pre-payment basket owned by a **Customer Session**. | `total ≥ 0`; `lineItems.count ≤ 100` | “basket” in new prose |
| **Customer Session** | aggregate root | Checkout | Browser-bound session that owns at most one in-flight **Payment Intent**. | "single in-flight intent within dedupe window" | “user session” |
| **Payment Intent** | aggregate root | Payments | Idempotent payment lifecycle object returned by **Payment Gateway**. | terminal states are `captured`, `failed`, `cancelled` only | “charge object” |
| **Order** | aggregate root | Fulfillment | Immutable record created after a successful **Payment Intent**. | created exactly once per `PaymentCaptured` event | “purchase” as synonym |
| **Money** | value object | Payments | Amount + currency, equal-by-value, immutable. | currency precision per ISO 4217 | "price" without unit |

## Domain events

| Event name | Emitting aggregate | Payload sketch | Consumer(s) | Telemetry link |
|------------|--------------------|----------------|-------------|----------------|
| `CheckoutSubmitDeduplicated` | Customer Session | `{ intentIdHash, sessionId, reason }` | Telemetry | `checkout_duplicate_submit` (Bridge Event) |
| `PaymentCaptured` | Payment Intent | `{ intentId, amountCents, currency }` | Fulfillment | `payment_captured` (Observability Action) |
| `OrderPlaced` | Order | `{ orderId, customerSessionId, totalCents }` | Inventory, Notifications | `order_placed` (Bridge Event) |

## Context relationships

| Upstream | Downstream | Pattern | Vocabulary alignment | Notes |
|----------|------------|---------|----------------------|-------|
| Checkout | Payments | customer-supplier | published language: `CheckoutSubmitDeduplicated` | Checkout drives the dedupe contract |
| Payments | Fulfillment | published language | `PaymentCaptured` event | Fulfillment cannot block Payments |
| Fulfillment | Inventory | conformist | accepts Inventory Service vocabulary as-is | Generic context; ACL would be over-engineered |
| Payments | (Payment Gateway) | ACL | `src/lib/payment/acl.ts` | Vendor SDK never reaches `src/payments/domain/` |

## Boundaries (external systems)

| Boundary | Responsibility | Canonical name |
|----------|----------------|----------------|
| **Payment Gateway** | Card/wallet capture + webhooks | `PaymentGateway` client in `src/lib/payment/` |
| **Inventory Service** | Stock reservations | `InventoryService` |

## Telemetry vocabulary

| Pipeline | When used |
|----------|-----------|
| **OrderFlow Bridge Event** | Merchant-visible analytics (product team dashboards) |
| **Checkout Observability Action** | Engineering traces tied to user actions in the UI |
| **DevTrace Event** | Optional local-only diagnostics (must never ship PII) |

## Forbidden synonyms (new work)

| Do not use | Use instead |
|------------|-------------|
| “wrapper app” | “host application” (if discussing embedding) |
