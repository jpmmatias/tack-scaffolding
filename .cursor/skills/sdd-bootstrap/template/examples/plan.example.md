Spec: S-001

Plan path: `examples/plan.example.md` (this file is illustrative — in a real repo, `plan.md` usually lives at the repository root or under `project/specs/`).

## Summary

Implement client-side deduplication of Pay activations against an existing **Payment Intent**, preserve `IDEMPOTENT_RETRY_V2` spelling everywhere, emit telemetry per spec, and maintain **dual-provider parity** between legacy and refactored checkout providers.

## Traceability

| Task id | Description | ACs covered |
|---------|-------------|-------------|
| T1 | Update `legacyCheckoutProvider.tsx` + `src/providers/checkout/` Pay handler with shared dedupe helper | AC-1, AC-3 |
| T2 | Add OrderFlow Bridge Event + Checkout Observability Action hooks in the Pay button module | AC-2 |
| T3 | Extend `test/harness/` with Payment Intent factory + telemetry doubles | AC-1, AC-2 (harness prerequisite) |

## Task files

- `specs/S-001/tasks/T1-dual-provider.md` *(not created in this template package — shown for shape)*
- `specs/S-001/tasks/T2-telemetry.md`
- `specs/S-001/tasks/T3-harness.md`

## ADRs

- None required (behavioural change inside existing boundaries). If Payment Gateway contract changed, architect would add `project/docs/adr/0002-*.md`.
