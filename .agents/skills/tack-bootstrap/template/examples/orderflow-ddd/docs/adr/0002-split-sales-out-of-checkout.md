# ADR-0002: Split Sales out of Checkout into Payments

| Field | Value |
|-------|-------|
| **Status** | Accepted |
| **Date** | 2026-05-10 |
| **Spec** | `S-000` (strategic housekeeping — see also `S-002` for first feature on the new boundary) |

## Status

Accepted

## Context

Checkout previously mixed **session/cart** behaviour with **commercial offer** rules (discount stacking, tax lines, internal “Sales” types). That coupling made Payments invariants hard to enforce and duplicated pricing logic under `src/checkout/**`. Parent example [ADR-0001](../../../adr.example.md) (dual providers) still applies to **how** checkout UI is edited; this ADR addresses **who owns** offer vocabulary.

Prior glossary rows (fictitious) placed offer line items on the **Cart** aggregate; pricing corrections required cross-imports from `src/payments/**` into checkout domain types.

## Decision

1. Introduce **CommercialOffer** as an aggregate root in **Payments**; it owns pricing, discounts, and freeze-before-capture.
2. **Checkout** retains **Cart** and **Customer Session** only; it reads a **stable offer snapshot** for display through **`src/checkout/acl/payments-offer-reader.ts`** (new ACL).
3. **Fulfillment** unchanged; still reacts to `PaymentCaptured`.

Bounded contexts remain **three**: Checkout, Payments, Fulfillment.

## Consequences

**Positive:**

- Single owner for money-adjacent invariants (offer totals ↔ intent amount).
- Reviewer can flag any `CommercialOffer` leak into `src/checkout/domain/**`.

**Negative / risks:**

- One extra round-trip or sync step for the checkout banner until read models are cached.

**Mitigations:**

- Document the DTO in the ACL module; version the snapshot field set when Payments evolves.

## Links

- ADR-0001 (dual providers): [`adr.example.md`](../../../adr.example.md) (parent `examples/`; fictitious cross-link)
- Domain glossary: [domain-glossary.md](../domain-glossary.md)
- Architecture: [architecture.md](../architecture.md)
- Follow-up feature spec: [`../../specs/S-002-payments-offer-snapshot.md`](../../specs/S-002-payments-offer-snapshot.md)
- Plan example: [`../../plan.md`](../../plan.md)
