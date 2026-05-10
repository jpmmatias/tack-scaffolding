Spec: S-001 ([specs/S-001-idempotent-checkout-submit.md](specs/S-001-idempotent-checkout-submit.md))

Plan path: `plan.md` at the root of this demo folder. In a bootstrapped repository, the same file often lives at the repository root or under `project/specs/`.

## Summary

Implement client-side deduplication of Pay activations against an existing **Payment Intent**, preserve `IDEMPOTENT_RETRY_V2` spelling everywhere, emit telemetry per spec, and maintain **dual-provider parity** between legacy and refactored checkout providers.

## Traceability

| Task id | Description | ACs covered |
|---------|-------------|-------------|
| T1 | Update `legacyCheckoutProvider.tsx` + `src/providers/checkout/` Pay handler with shared dedupe helper | AC-1, AC-3 |
| T2 | Add OrderFlow Bridge Event + Checkout Observability Action hooks in the Pay button module | AC-2 |
| T3 | Extend `test/harness/` with Payment Intent factory + telemetry doubles | AC-1, AC-2 (harness prerequisite) |

## Task files

- [specs/S-001/tasks/T1-dual-provider.md](specs/S-001/tasks/T1-dual-provider.md)
- [specs/S-001/tasks/T2-telemetry.md](specs/S-001/tasks/T2-telemetry.md)
- [specs/S-001/tasks/T3-harness.md](specs/S-001/tasks/T3-harness.md)

## ADRs

- None required for this behavioural change inside existing boundaries. For the shape of an ADR when the architect needs one, see [../adr.example.md](../adr.example.md). If the Payment Gateway contract changed, the architect would add something like `project/docs/adr/0002-*.md`.
