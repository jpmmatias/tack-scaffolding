# Task T1 — Dual-provider Pay dedupe

| Field | Value |
|-------|-------|
| **Task id** | T1 |
| **Spec** | S-001 |
| **ACs covered** | AC-1, AC-3 |

## Objective

Introduce a shared helper so **legacy** and **refactored** checkout paths apply the same deduplication rules when Pay is activated while a Payment Intent is already `processing`.

## Scope

- Extract or add a small module (e.g. `dedupePayActivation`) used by both `legacyCheckoutProvider.tsx` and `src/providers/checkout/` Pay handlers.
- Guard Pay so a second activation within the **2 second** window does not create a new Payment Intent (AC-1).
- Ensure every reference to the feature flag uses the literal **`IDEMPOTENT_RETRY_V2`** — TypeScript, logs, and tests (AC-3).
- Call out **dual-provider parity** in code review: behaviour must match across both providers.

## Invariants

- Align with **`TACK.md`** / **`.cursorrules`** parity / naming rules for checkout modules if present in the consumer repo.

## Done when

- [ ] Second Pay click within the dedupe window does not POST/create a new intent (AC-1).
- [ ] `IDEMPOTENT_RETRY_V2` appears with exact spelling everywhere it is referenced (AC-3).
- [ ] Both providers invoke the same dedupe path or documented shared helper.
