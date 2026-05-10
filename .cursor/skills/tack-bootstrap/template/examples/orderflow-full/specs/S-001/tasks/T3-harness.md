# Task T3 — Harness: factories and telemetry doubles

| Field | Value |
|-------|-------|
| **Task id** | T3 |
| **Spec** | S-001 |
| **ACs covered** | AC-1, AC-2 (prerequisite) |

## Objective

Extend the test harness so QA and worker tests can drive **Payment Intent** states and assert **telemetry** without bespoke mocks at each boundary.

## Scope

- Add or extend factories under `<TEST_HARNESS_ROOT>` for Customer Session + Payment Intent in `processing`.
- Provide doubles (or spies) for OrderFlow Bridge and Checkout Observability pipelines per [test-harness.md](../../../../../docs/test-harness.md) in a bootstrapped repo.
- Coordinate with [@harness-engineer](../../../../../prompts/harness-engineer.md) if the repo’s harness policy requires approval for new fixtures.

## Done when

- [ ] Tests can set “intent already processing” without reaching for raw network mocks (supports AC-1).
- [ ] Tests can assert telemetry payloads for duplicate submit (supports AC-2).
- [ ] T1/T2 implementation tasks can run against the harness without one-off fakes.
