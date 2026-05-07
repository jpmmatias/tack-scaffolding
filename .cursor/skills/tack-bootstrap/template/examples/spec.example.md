# Spec S-001: idempotent checkout submit

| Field | Value |
|-------|-------|
| **Spec id** | `S-001` |
| **Status** | Ready |
| **Author** | Example Team |
| **Date** | 2026-05-07 |

## Problem

Customers occasionally double-click **Pay**, creating duplicate **Payment Intents** and conflicting webhook states.

## User stories

1. As a shopper, I want the checkout to ignore duplicate submit attempts, so that I am charged at most once per intent.
2. As a merchant, I want OrderFlow to emit an analytics event when a duplicate attempt is ignored, so that we can measure UX friction.

## Acceptance criteria

### AC-1: same intent, second click ignored

```gherkin
Given a Customer Session with an existing Payment Intent in state "processing"
When the customer activates Pay a second time within 2 seconds
Then the client does not create a new Payment Intent
And the UI remains in "processing"
```

### AC-2: analytics on duplicate attempt

```gherkin
Given AC-1's preconditions
When the duplicate Pay activation happens
Then an OrderFlow Bridge Event "checkout_duplicate_submit" is emitted with intent id (hashed) and reason "deduplicated"
```

### AC-3: feature flag spelling preserved

```gherkin
Given the IDEMPOTENT_RETRY_V2 flag evaluation is logged for debugging
When code references the flag name in TypeScript, logs, or tests
Then the string matches "IDEMPOTENT_RETRY_V2" exactly
```

## Non-goals

- Changing Payment Gateway settlement timing.
- Mobile native SDK integration (web checkout only).

## Telemetry contract

| Pipeline | Name | When | Payload / attributes |
|----------|------|------|----------------------|
| OrderFlow Bridge Event | `checkout_duplicate_submit` | Duplicate Pay within dedupe window | `intentIdHash`, `reason=deduplicated` |
| Checkout Observability Action | `pay_button_deduped` | Same | `sessionId` (non-PII correlation id) |
| DevTrace Event | None | — | None |

## Domain terms used

| Term | Definition source |
|------|-------------------|
| Payment Intent | glossary → Entities |
| Customer Session | glossary → Entities |
| IDEMPOTENT_RETRY_V2 | `.cursorrules` invariants |

## References

- Architecture: `docs/architecture/order-flow.md`
