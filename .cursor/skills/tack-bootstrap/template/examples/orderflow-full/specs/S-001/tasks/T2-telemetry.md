# Task T2 — Telemetry on duplicate submit

| Field | Value |
|-------|-------|
| **Task id** | T2 |
| **Spec** | S-001 |
| **ACs covered** | AC-2 |

## Objective

When deduplication suppresses a duplicate Pay, emit the **OrderFlow Bridge Event** and **Checkout Observability Action** defined in the spec telemetry table.

## Scope

- On duplicate Pay (same preconditions as AC-1), emit:
  - Bridge: `checkout_duplicate_submit` with `intentIdHash`, `reason=deduplicated`.
  - Observability: `pay_button_deduped` with non-PII `sessionId`.
- Wire hooks in the Pay button module (or the shared dedupe exit path) so telemetry fires **once** per suppressed duplicate.

## Done when

- [ ] Duplicate submit path emits `checkout_duplicate_submit` with hashed intent id and reason `deduplicated` (AC-2).
- [ ] `pay_button_deduped` fires for the same user-visible condition.
- [ ] Assertions exist in tests tagged **S-001 AC-2** (see [samples/qa-ac-tests.example.ts](../../samples/qa-ac-tests.example.ts)).
