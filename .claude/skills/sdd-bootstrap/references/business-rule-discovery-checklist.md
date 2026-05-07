# Business-rule discovery checklist (Phase 2)

A section is "covered" only when **all** evidence rows below have at least one citation in the Phase 2 draft (`project/docs/_discovery/business-rules-draft.md`) **or** an explicit `??? ASK USER` marker that has already been raised in the interview loop. No silent omissions.

This file is the gate. The skill must use it to decide whether to keep looping in Phase 2.3.

---

## (a) Entities & lifecycle

- [ ] At least one canonical name per core entity, with aliases found in code listed.
- [ ] Field list per entity, with types and immutability marked.
- [ ] Derived fields flagged (computed at read vs persisted).
- [ ] State enum extracted for every entity that has a status. Cite the enum source `file:line`.
- [ ] Allowed state transitions enumerated. Build a state diagram if there are >3 states or >5 transitions.
- [ ] Each transition has a trigger (user action, event, schedule, system) cited at the call site.
- [ ] Transitions present **only** in tests but not in production code are flagged for the user.

Minimum bar: one citation per entity per checked row, or one open question per missing row.

---

## (b) Invariants

- [ ] Constructor / factory checks listed for each aggregate root, with `file:line`.
- [ ] Database constraints surveyed: `NOT NULL`, `CHECK`, `UNIQUE`, FK actions (`CASCADE` / `RESTRICT`), partial indexes, generated columns.
- [ ] Guard clauses in service / use-case layer documented per entity.
- [ ] Post-conditions: anything the code asserts must be true after an operation completes.
- [ ] Cross-aggregate consistency rules listed, or marked `N/A` with one-line justification.

Minimum bar: at least one constructor / factory cited per aggregate; DB schema reviewed; cross-aggregate row addressed.

---

## (c) Policies & business decisions

- [ ] Pricing rules: base price source, discount stacking order, coupon scope, taxes, fees.
- [ ] Rounding rule documented (banker's rounding, half-up, truncation; precision in minor units or decimals).
- [ ] Eligibility checks listed (who/what gates an action).
- [ ] Limits, quotas, rate limiting, throttling — cite each numerical value and its enforcement site.
- [ ] Refund / cancellation / return / dispute rules with timer windows and required state.
- [ ] Authorization matrix: who can do what under which conditions.
- [ ] SLA/SLO commitments expressed in code (timeouts, retries, deadlines, max latency budgets).
- [ ] Idempotency: keys used, scope (per request, per intent, per day), TTL, collision behavior.
- [ ] Retry & backoff policies: max attempts, base delay, jitter, terminal failure handling.

Minimum bar: every monetary, time-bound, or limit value has a citation **and** an answer (negotiable / hard).

---

## (d) Workflows & processes

- [ ] Each end-to-end flow has a named trigger and a list of ordered steps.
- [ ] Async hops marked (event → consumer, job → worker, webhook → handler).
- [ ] Human-in-the-loop steps explicit (admin approval, support intervention, manual review).
- [ ] Compensations / rollbacks / sagas: for each multi-step flow that can fail mid-way, the recovery path is named or marked `??? ASK USER`.
- [ ] Notifications emitted (email, SMS, push, webhook) with destination + payload reference.
- [ ] Time-bound steps documented (e.g. "expires after 24h", "retry after 7d").

Minimum bar: every flow named in `(c)` has a citation in `(d)`; every async hop has a producer **and** consumer cite.

---

## (e) Roles & permissions

- [ ] Full role list with canonical names.
- [ ] Capability matrix per role: what operations are allowed under what conditions.
- [ ] Special accounts named (admin, system, service, impersonation, support).
- [ ] Multi-tenant boundaries identified, or marked `N/A` if single-tenant. If multi-tenant, the tenancy key (`tenant_id`, `workspace_id`, etc.) and where it is enforced are cited.

Minimum bar: every role has at least one source citation (auth middleware, role check, DB role table).

---

## (f) External integrations

For each third party:

- [ ] Purpose (payment, email, identity, analytics, fraud, geolocation, …).
- [ ] Direction: inbound webhook, outbound call, both.
- [ ] Failure modes the code handles vs ignores.
- [ ] Idempotency strategy (key generation, server-side dedup, request hashing).
- [ ] Retry / circuit-breaker behavior.
- [ ] PII boundary: what fields cross the wire; redaction at the boundary if any.
- [ ] Where API keys / secrets are stored and rotated.

Minimum bar: every integration named in code or env vars has all rows answered or `??? ASK USER`.

---

## (g) Money, time, identity, counts

- [ ] Currency handling: precision (minor units?), rounding rule, multi-currency policy, FX source if any.
- [ ] Time zones: storage convention (UTC?), display convention, business calendar source, holiday rules.
- [ ] Daylight saving / DST handling for any time-bound business rule.
- [ ] ID strategy: UUID v4 / v7 / ULID / sequential, public-facing vs internal, slug rules.
- [ ] Counters / sequences / inventory race conditions: optimistic locking, row locks, queue ordering.

Minimum bar: each cross-cutting concern has a single source-of-truth citation, or an explicit "we don't have one yet, mark `[ADR]`" entry.

---

## (h) Telemetry & audit

- [ ] Event catalog: every analytics / observability event emitted, with name and payload schema.
- [ ] Audit log destinations and retention policy.
- [ ] PII redaction rules: which fields are masked / hashed / dropped before logging.
- [ ] Required log fields per event type (correlation id, tenant id, actor id, …).

Minimum bar: at least one event citation per emit site found via grep on `track`, `log`, `emit`, `audit`, `record`.

---

## (i) Edge cases the code already handles

- [ ] Concurrency: locks (row, advisory, distributed), optimistic versioning, queue ordering.
- [ ] Duplicates: dedup keys, natural keys, request-id idempotency.
- [ ] Partial failures: retries, DLQs, manual recovery hooks.
- [ ] Soft deletes vs hard deletes; cascade rules per FK.
- [ ] Backfills, migrations of historical data — any one-shot scripts under `scripts/`, `bin/`, `tools/`.

Minimum bar: each row either cited or marked `N/A` with reasoning.

---

## (j) Dead code & contradictions

- [ ] Unused entities, methods, flags listed (heuristic: zero call-sites, behind a flag that's always false, behind config that's never set).
- [ ] Code paths contradicting tests (e.g. validator rejects what fixture file feeds in).
- [ ] Code paths contradicting DB schema (e.g. validator allows what DB blocks).
- [ ] TODO / FIXME / HACK comments touching business logic, with `file:line`.

Minimum bar: at least one pass over `TODO|FIXME|HACK|XXX` and one over flag references; explicit `none found` is acceptable if true.

---

## (k) Open questions / ambiguities

- [ ] Numbered list. Every question carries the citation that triggered it.
- [ ] Each question is mapped to a follow-up tag (`[ADR]`, `[SPEC]`, `[TEST-GAP]`, `[REFACTOR]`, `[DOCS]`) when answered, or stays open until the user resolves it.

Minimum bar: at least one item from `(j)` should appear here as an open question for the user, unless `(j)` is genuinely empty.

---

## Coverage summary the skill prints before re-prompting

After each interview round, the skill prints:

```text
## Coverage so far

| Section | Cited findings | Open questions | Status |
|---------|----------------|----------------|--------|
| (a)     | N              | M              | covered | partial | ??? |
| ...
```

A section reaches `covered` only when every required row above has at least one citation **and** every `??? ASK USER` marker has been raised in at least one interview round.

Until **all eleven sections** reach `covered`, do not present the verbatim done-prompt. The user replying `complete` while sections are still partial is **ignored**: the skill must run another round of at least 3 questions targeting the lowest-coverage section before re-prompting.
