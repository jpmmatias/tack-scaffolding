# Event storming draft (example)

Worked shape for `project/docs/_discovery/event-storming-draft.md` after **`@event-stormer.md`**. Fictitious **OrderFlow** slice (Checkout / Payments / Fulfillment), **before** ADR-0002 formalized Sales under Payments — narrative aligns with [`orderflow-ddd/README.md`](./orderflow-ddd/README.md).

---

## 1. Session metadata

- **Intent:** First-pass context map + event catalog for greenfield bootstrap.
- **Bounded contexts (Round 1):** Checkout, Payments, Fulfillment (names frozen in Phase 3 Block A DDD Round 1).
- **Path:** Greenfield — no Phase 2 `business-rules-draft.md` **(ddd)** section.

---

## 2. Domain events (orange)

| Event name | Emitting context | Payload sketch | Consumers | Tags |
|------------|------------------|----------------|-----------|------|
| `CartLineItemAdded` | Checkout | `{ sessionId, sku, qty }` | Read models | — |
| `CheckoutSubmitted` | Checkout | `{ sessionId, intentId }` | Payments | `[OPEN-QUESTION]` idempotency key shape |
| `CommercialOfferPriced` | Payments | `{ offerId, sessionId, totalCents }` | Checkout read model | — |
| `CommercialOfferFrozenForCapture` | Payments | `{ offerId, intentId }` | Payments domain | — |
| `PaymentCaptured` | Payments | `{ intentId, amountCents }` | Fulfillment | — |
| `OrderPlaced` | Fulfillment | `{ orderId, sessionId }` | Inventory (future) | `[SPEC]` |

---

## 3. Commands (blue)

| Command | Actor / system | Target | Notes |
|---------|----------------|--------|-------|
| AddLineToCart | Shopper | Cart (Checkout) | — |
| SubmitCheckout | Shopper | Customer Session → Payments | must be idempotent |
| PriceOfferForSession | Checkout UI | Payments / CommercialOffer | cross-context — `[OPEN-QUESTION]` sync vs async |
| CapturePayment | Payments worker | Payment Intent | webhook-driven |

---

## 4. Aggregates & policies (yellow)

| Context | Aggregate roots | Key invariants / policies |
|---------|-----------------|---------------------------|
| Checkout | Cart, Customer Session | at most one in-flight Payment Intent per dedupe window |
| Payments | Payment Intent, CommercialOffer | offer immutable after freeze; totals reconcile |
| Fulfillment | Order | one Order per `PaymentCaptured` |

**Hotspot (policy):** Checkout historically owned discount rules — vocabulary collision with Payments **CommercialOffer**; resolve via ADR or fold vocabulary under Payments (`[SPEC]`).

---

## 5. Read models / queries (green)

| Read model | Fed by | Owner context |
|------------|--------|----------------|
| Checkout banner “priced offer” | `CommercialOfferPriced`, snapshot DTO | Checkout (not source of truth) |

---

## 6. External systems & ACL

| System | Purpose | Owning context | ACL |
|--------|---------|-----------------|-----|
| Payment Gateway | capture + webhooks | Payments | `[OPEN-QUESTION]` path e.g. `src/lib/payment/acl.ts` |

---

## 7. Context relationships

| Upstream | Downstream | Pattern | Rationale |
|----------|------------|---------|-----------|
| Payments | Checkout | customer-supplier | Checkout consumes priced offer via read model / ACL |
| Checkout | Payments | customer-supplier | submit drives intent lifecycle |
| Payments | Fulfillment | published language | `PaymentCaptured` |

---

## 8. Hotspots

1. **Sales vocabulary** in Checkout vs Payments — split or ACL? (`[ADR]` candidate).
2. Idempotency contract for `CheckoutSubmitted` — key ownership: Checkout vs Payments (`[OPEN-QUESTION]`).
3. Inventory context not modeled — out of scope for this pass (`[SPEC]`).
