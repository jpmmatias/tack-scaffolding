# Domain glossary (OrderFlow — DDD demo)

Fictitious **post–ADR-0002** model: Sales pricing lives under **Payments**; **Checkout** consumes a read-only offer snapshot via an ACL.

## Product

OrderFlow embeds accelerated checkout. **Checkout** presents the flow; **Payments** owns money, intents, and commercial offers; **Fulfillment** creates **Order** after capture.

## Surfaces

| Canonical term | Definition | Avoid |
|----------------|------------|-------|
| **Checkout** | Payment flow page (`/checkout`). | “purchase funnel” |
| **Pay** | Primary payment activation control. | “submit” without context |

## Bounded contexts

| Canonical name | Role | Source folder(s) | Primary aggregates | Owns external integrations |
|----------------|------|------------------|--------------------|----------------------------|
| **Checkout** | core | `src/checkout/**` | Cart, Customer Session | — |
| **Payments** | core | `src/payments/**` | Payment Intent, CommercialOffer | Payment Gateway |
| **Fulfillment** | supporting | `src/orders/**` | Order | — |

_Citations:_ folder layout assumed from `business-rules-draft.md` §checkout (fictitious); ADR-0002.

## Entities

| Canonical term | Type | Context | Definition | Invariants enforced | Avoid |
|----------------|------|---------|------------|---------------------|-------|
| **Cart** | aggregate root | Checkout | Mutable pre-payment basket for a **Customer Session**. | `total ≥ 0`; `lineItems.count ≤ 100` | “basket” in new prose |
| **Customer Session** | aggregate root | Checkout | Browser-bound session; at most one in-flight **Payment Intent** per dedupe window. | single in-flight intent within dedupe window | “user session” |
| **CommercialOffer** | aggregate root | Payments | Priced commercial snapshot (lines, discounts, tax) bound to a session before capture. | totals reconcile to line sums; immutable after `CommercialOfferFrozenForCapture` | “quote” without glossary |
| **Payment Intent** | aggregate root | Payments | Idempotent payment lifecycle from **Payment Gateway**. | terminal states `captured`, `failed`, `cancelled` only | “charge object” |
| **Order** | aggregate root | Fulfillment | Record created after successful capture. | created once per `PaymentCaptured` | “purchase” as synonym |
| **Money** | value object | Payments | Amount + currency, immutable. | ISO 4217 precision | “price” without unit |

## Domain events

| Event name | Emitting aggregate | Payload sketch | Consumer(s) | Telemetry link |
|------------|--------------------|----------------|-------------|----------------|
| `CommercialOfferPriced` | CommercialOffer | `{ offerId, sessionId, totalCents }` | Checkout (read model) | `offer_priced` |
| `CommercialOfferFrozenForCapture` | CommercialOffer | `{ offerId, intentId }` | Payments domain | `offer_frozen` |
| `CheckoutSubmitDeduplicated` | Customer Session | `{ intentIdHash, sessionId }` | Telemetry | `checkout_duplicate_submit` |
| `PaymentCaptured` | Payment Intent | `{ intentId, amountCents }` | Fulfillment | `payment_captured` |
| `OrderPlaced` | Order | `{ orderId, sessionId }` | Inventory | `order_placed` |

## Context relationships

| Upstream | Downstream | Pattern | Vocabulary alignment | Notes |
|----------|------------|---------|----------------------|-------|
| Payments | Checkout | customer-supplier | published read model: offer snapshot DTO | Checkout **must** use ACL — see `src/checkout/acl/payments-offer-reader.ts` |
| Checkout | Payments | customer-supplier | `CustomerSessionId`, intent dedupe contract | Checkout drives submit dedupe |
| Payments | Fulfillment | published language | `PaymentCaptured` | Fulfillment does not block Payments |
| Payments | (Payment Gateway) | ACL | `src/lib/payment/acl.ts` | Vendor SDK never reaches `src/payments/domain/` |

## Boundaries (external systems)

| Boundary | Responsibility | Canonical name |
|----------|----------------|----------------|
| **Payment Gateway** | Card capture + webhooks | `PaymentGateway` client in `src/lib/payment/` |

## Forbidden synonyms (new work)

| Do not use | Use instead |
|------------|-------------|
| “Sales module in checkout” | **CommercialOffer** in **Payments** + ACL read in Checkout |
