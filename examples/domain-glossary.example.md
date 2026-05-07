# Example: domain glossary (OrderFlow — partial)

This illustrates density and tables; your real glossary should cover every surface your team ships.

## Product

OrderFlow lets merchants embed a accelerated checkout. It owns cart presentation, payment orchestration callbacks, and telemetry — **not** long-term order fulfillment (that belongs to the merchant OMS).

## Surfaces

| Canonical term | Definition | Avoid |
|----------------|------------|-------|
| **Checkout** | The payment flow page (`/checkout`). | “purchase funnel”, “buy flow” |
| **Receipt** | Post-payment confirmation view. | “success page” |

## Entities

| Canonical term | Definition | Avoid |
|----------------|------------|-------|
| **Cart** | Mutable pre-payment basket owned by a **Customer Session**. | “basket” in new prose |
| **Order** | Immutable record created after a successful **Payment Intent**. | “purchase” as synonym |
| **Payment Intent** | Idempotent payment lifecycle object returned by **Payment Gateway**. | “charge object” |

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
