# Spec S-XXX: &lt;short title&gt;

| Field | Value |
|-------|-------|
| **Spec id** | `S-XXX` |
| **Status** | Draft \| Ready \| Superseded |
| **Author** | |
| **Date** | |
| **Bounded context** | _DDD-only — name a context from `domain-glossary.md` when `tack.ddd.profile = on`; omit row when off_ |

## Problem

&lt;What user or system pain this addresses.&gt;

## User stories

1. As a …, I want …, so that …

## Acceptance criteria

Use Gherkin. Number each criterion **AC-1**, **AC-2**, …

### AC-1: &lt;short name&gt;

```gherkin
Given …
When …
Then …
```

### AC-2: &lt;short name&gt;

```gherkin
Given …
When …
Then …
```

## Non-goals

- &lt;Explicitly out of scope&gt;

## Telemetry contract

List every analytics / observability artifact this change must emit or preserve. Rename columns to match your stack (see `.cursorrules` and `project/docs/domain-glossary.md`).

| Pipeline | Name | When | Payload / attributes |
|----------|------|------|----------------------|
| &lt;PRODUCT_ANALYTICS&gt; | | | |
| &lt;ENGINEERING_OBSERVABILITY&gt; | | | |
| &lt;LOCAL_DEV_OR_TRACE&gt; | | | |

If none: write **None** and justify briefly.

## Domain terms used

Every term below must already exist in [project/docs/domain-glossary.md](../docs/domain-glossary.md) or be added in the same change.

| Term | Definition source |
|------|-------------------|
| | glossary section … |

<!-- ## Aggregates touched
DDD-only — emit when `tack.ddd.profile = on`. List each aggregate this spec reads or mutates; "Mode" is `read` | `mutate`. A `mutate` row implies AC-N or harness coverage of the invariant column.

| Aggregate | Mode | Invariants touched |
|-----------|------|--------------------|
|           |      |                    |
-->

<!-- ## Domain events emitted
DDD-only — emit when `tack.ddd.profile = on`. Distinct from **Telemetry contract** above; an artifact MAY appear in both. Names follow `<PastTenseVerb><Aggregate>` (see `.cursorrules`).

| Event | Trigger (which AC) | Payload | Invariant that produces it |
|-------|--------------------|---------|----------------------------|
|       |                    |         |                            |
-->

<!-- ## Invariants enforced or changed
DDD-only — emit when `tack.ddd.profile = on`. List every invariant this spec adds, removes, or mutates. Each row points at the AC that exercises the invariant and the harness test that asserts it.

| Invariant | AC | Harness test |
|-----------|----|--------------|
|           |    |              |
-->

## References

- Architecture: [project/docs/architecture.md](../docs/architecture.md)
- Related ADRs: [project/docs/adr/](../docs/adr/) (e.g. `ADR-NNNN`)
