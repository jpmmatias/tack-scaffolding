# ADR-0001: Dual checkout providers until legacy retirement

| Field | Value |
|-------|-------|
| **Status** | Accepted |
| **Date** | 2026-01-10 |
| **Spec** | `S-000` (historical housekeeping — no single product spec) |

## Status

Accepted

## Context

OrderFlow ships two checkout provider implementations while migrating from a legacy monolith component to a modular provider. Behavioural drift between the two would create cohort-specific bugs and inconsistent telemetry.

## Decision

All checkout behaviour changes must modify **both** `src/providers/legacyCheckoutProvider.tsx` and `src/providers/checkout/` until the legacy provider is removed. Remove this ADR when legacy is deleted.

## Consequences

**Positive:**

- Feature parity across user cohorts.
- Easier reviewer automation (diff must touch both files).

**Negative / risks:**

- Higher change cost for every behaviour edit.

**Mitigations:**

- Extract shared helpers under `src/providers/checkout/lib/` where possible.

## Links

- Architecture: `docs/architecture/order-flow.md`
- Harness: `test/harness/` for shared scenario runners (future work)
