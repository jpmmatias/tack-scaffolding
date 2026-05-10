# OrderFlow end-to-end demo (S-001)

This folder is a **traced slice** of the Tack SDD lifecycle for the fictitious **OrderFlow** checkout story: spec → plan → tasks → sample QA test names. Pair it with single-file snippets in the parent [`examples/`](../) directory ([spec](../spec.example.md), [plan](../plan.example.md), [glossary](../domain-glossary.example.md), [ADR](../adr.example.md)).

In a real repository after bootstrap, paths often live under `project/` (see [`docs/sdd.md`](../../docs/sdd.md)); here everything is **relative to this demo folder** so you can read it without installing the template.

## Pipeline walkthrough

### 1. Idea

Informal intent: stop duplicate Pay clicks from creating conflicting Payment Intents.

### 2. Spec (Product Manager output)

**Artifact:** [`specs/S-001-idempotent-checkout-submit.md`](specs/S-001-idempotent-checkout-submit.md)

Numbered **AC-1 … AC-3** with Gherkin, telemetry table, and domain hooks — the PM prompt grills requirements and emits `specs/S-XXX-<slug>.md` from [`specs/_template.md`](../../specs/_template.md).

### 3. Plan + tasks (Architect output)

**Artifacts:**

- [`plan.md`](plan.md) — **Traceability** maps tasks T1–T3 to ACs (every AC appears at least once).
- [`specs/S-001/tasks/T1-dual-provider.md`](specs/S-001/tasks/T1-dual-provider.md)
- [`specs/S-001/tasks/T2-telemetry.md`](specs/S-001/tasks/T2-telemetry.md)
- [`specs/S-001/tasks/T3-harness.md`](specs/S-001/tasks/T3-harness.md)

Prompt: [`prompts/architect.md`](../../prompts/architect.md). ADRs are optional here; see [`../adr.example.md`](../adr.example.md) when a decision is hard to reverse.

### 4. Failing tests (QA Tester output)

**Convention:** `describe('S-001 AC-N: …', …)` — see [`prompts/qa-tester.md`](../../prompts/qa-tester.md).

**Sample:** [`samples/qa-ac-tests.example.ts`](samples/qa-ac-tests.example.ts) (illustrative strings only in this repo).

### 5. Harness (when needed)

Task **T3** calls out factories and doubles; orchestration prompt: [`prompts/harness-engineer.md`](../../prompts/harness-engineer.md).

### 6. Implementation (Worker)

Minimal changes to green tests; commit messages often cite **`Closes: S-001#AC-N`**. Prompt: [`prompts/worker.md`](../../prompts/worker.md).

### 7. Review

Prompt: [`prompts/reviewer.md`](../../prompts/reviewer.md) — verify spec citation and telemetry assertions match [`specs/S-001-idempotent-checkout-submit.md`](specs/S-001-idempotent-checkout-submit.md).

## Flow diagram

```mermaid
flowchart LR
  Idea[Idea]
  PM[Spec_S-001]
  Arch[plan_and_tasks]
  QA[failing_tests_AC]
  Harness[harness_if_needed]
  Worker[implementation]
  Rev[reviewer]

  Idea --> PM
  PM --> Arch
  Arch --> QA
  QA --> Harness
  Harness --> Worker
  Worker --> Rev
```

## Optional: git branch

For isolated work in a bootstrapped repo, reserve the next spec id and create a branch such as `feature/S-001-idempotent-checkout` (see **Parallel features** in [`docs/sdd.md`](../../docs/sdd.md) and `project/scripts/tack-worktree.sh` after install).
