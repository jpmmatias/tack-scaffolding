# Spec S-002: payments offer snapshot in checkout banner

| Field | Value |
|-------|-------|
| **Spec id** | `S-002` |
| **Status** | Ready |
| **Author** | Example Team |
| **Date** | 2026-05-10 |
| **Bounded context** | Checkout (reads); Payments (owns **CommercialOffer**) |

## Problem

After **ADR-0002**, the checkout banner must show **total** and **tax summary** from the **CommercialOffer** without importing Payments domain types into Checkout.

## User stories

1. As a shopper, I want the checkout banner to show the priced total from Payments, so that I trust the amount before Pay.
2. As an engineer, I want all Payments DTOs to pass through one ACL module, so that reviewers can grep for leaks.

## Acceptance criteria

### AC-1: banner uses ACL read model

```gherkin
Given a Customer Session with a bound CommercialOffer in Payments
When the checkout summary region renders
Then totals shown in the banner match the ACL view model from src/checkout/acl/payments-offer-reader.ts
And no file under src/checkout/domain imports src/payments/domain
```

### AC-2: stale snapshot handling

```gherkin
Given the offer snapshot version in session does not match Payments head
When the banner hydrates
Then the UI triggers a refetch through the ACL and does not mutate CommercialOffer from Checkout
```

## Telemetry

| Event | When |
|-------|------|
| `offer_banner_hydrated` | Banner successfully mapped ACL DTO |

## Domain hooks

- Glossary: **CommercialOffer**, **Customer Session**, **Cart** ([`../docs/domain-glossary.md`](../docs/domain-glossary.md))
- ADR: [`../docs/adr/0002-split-sales-out-of-checkout.md`](../docs/adr/0002-split-sales-out-of-checkout.md)
