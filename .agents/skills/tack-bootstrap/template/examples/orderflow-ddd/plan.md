Spec: S-002 ([specs/S-002-payments-offer-snapshot.md](specs/S-002-payments-offer-snapshot.md))

Plan path: `plan.md` at the root of this demo folder. In a bootstrapped repository, the same file often lives at the repository root or under `project/specs/`.

## Summary

Wire the checkout summary banner to the **Payments** offer snapshot using the existing ACL at `src/checkout/acl/payments-offer-reader.ts`, add a version mismatch refetch path, and emit `offer_banner_hydrated` per spec. No changes to **CommercialOffer** invariants beyond consuming published read models.

## Traceability

| Task id | Description | ACs covered |
|---------|-------------|-------------|
| T1 | Implement ACL mapper extensions + banner hydration calling only the ACL | AC-1 |
| T2 | Add stale-snapshot detection (session version vs head) and refetch orchestration in checkout UI layer | AC-2 |
| T3 | Emit `offer_banner_hydrated` when hydration succeeds | AC-1, AC-2 |

## DDD impact

**Aggregates (read vs mutate)**

| Aggregate | Context | Read / mutate | Notes |
|-----------|---------|---------------|-------|
| **Customer Session** | Checkout | **Read** for session id + cached snapshot version; **mutate** only for “refetch requested” session flags (no Payments types). | Banner hydration does not change session payment state. |
| **Cart** | Checkout | **Read** | Banner does not mutate line items in this slice. |
| **CommercialOffer** | Payments | **Read** via ACL DTO only from Checkout; **mutate** remains in Payments (out of scope for this plan except published read head). | Checkout never mutates **CommercialOffer**. |
| **Payment Intent** | Payments | **Read** (indirect, if head version is tied to intent lifecycle) | No new terminal transitions. |

**Domain events emitted by this change (canonical names)**

- **None** — this slice only **consumes** published offer data through the ACL and adds **telemetry** `offer_banner_hydrated` per spec (no new `<PastTenseVerb><Aggregate>` names).

**Invariants enforced or changed**

- Preserves **CommercialOffer** immutability after freeze: Checkout code must not call Payments domain mutators (enforced by module boundary + reviewer grep).
- **Customer Session** still enforces at most one in-flight **Payment Intent** per dedupe window (unchanged; do not regress in T2).

**Cross-context calls — ACL pinned in plan**

- All Checkout → Payments offer data: **`src/checkout/acl/payments-offer-reader.ts`** (existing ACL per [ADR-0002](docs/adr/0002-split-sales-out-of-checkout.md)). No new ACL required.

## ADRs

- [ADR-0002](docs/adr/0002-split-sales-out-of-checkout.md) — strategic split (already accepted; this plan implements a consumer of that boundary).

## Task files

_This lean demo omits per-task markdown files; in a real repo the architect would add `specs/S-002/tasks/T*.md` and link them here._
