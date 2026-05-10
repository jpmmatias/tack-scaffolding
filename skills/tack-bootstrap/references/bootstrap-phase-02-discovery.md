# Phase 2 — Deep business-rule discovery (EXISTING projects only)

Skip this entire phase if Phase 1 classified the project as **NEW**. For **EXISTING**, this phase is a closed loop and **must** be completed before Phase 3.

## 2.1 Source code reconnaissance

Run `bash "${SKILL_DIR}/scripts/recon.sh"` from the **consumer repository root** if the script exists. It produces `recon.json` bucketing files into the six layers below. Use it as a starting index, then read the actual files.

Read the repo methodically in this priority order. For every finding, keep a notebook entry with `file:line` citations. Do not summarize from memory — open the files.

**Layer 1 — Domain core**
- `domain/`, `core/`, `entities/`, `models/`, `aggregates/`, `value-objects/` — entity classes, value objects, enums for states.
- `services/`, `usecases/`, `application/`, `commands/`, `handlers/`, `interactors/` — orchestration code.
- `policies/`, `rules/`, `validators/`, `specifications/`, `guards/` — explicit rule code.
- Files named after business concepts (`Order.ts`, `Subscription.py`, `Invoice.cs`, etc.).
- **When `tack.ddd.profile = on` (DDD-conditional reconnaissance):**
  - Cluster Layer-1 directories into **candidate bounded contexts**. Heuristics: top-level folder under the source tree that contains its own domain + application code; CODEOWNERS / git-blame ownership clusters; module names that recur across files; package boundaries (Java packages, Go modules, Python packages).
  - Per cluster, classify as **core / supporting / generic** based on: signal density (how much custom logic vs. CRUD), product-criticality cues from docs / commit messages, and whether the cluster wraps a third-party (generic) or is plain-vanilla persistence (supporting).
  - For each entity in Layer 1, mark it as **aggregate root** (owns transactional consistency, referenced by ID from outside its module) or **internal entity** (only mutated by its aggregate root). Cite the constructor / factory `file:line` and the persistence boundary that proves it.
  - Identify **value objects**: types equal-by-value with no lifecycle (Money, Email, IBAN, DateRange). Look for absence of identity fields and presence of `equals` / `__eq__` / `Equatable` overrides.
  - Identify **domain events**: classes / types ending in `Event` paired with handlers / subscribers; pub-sub `emit` / `publish` / `dispatch` calls inside Layer 1; outbox-table writes. Capture event name, emitting aggregate, payload sketch.
  - Identify **anticorruption layer (ACL) locations**: adapter / mapper / translator code that wraps external SDKs (Layer 2 boundaries) before the result reaches Layer 1. Cite the file paths.
  - Identify **context relationships**: which contexts call which, sync vs. async, who depends on whose vocabulary. This feeds the future Context map.
  - Treat all DDD findings as `??? ASK USER` candidates when ambiguous — do **not** invent classifications. The user resolves them in Phase 2.3.

**Layer 2 — Boundaries**
- `controllers/`, `routes/`, `api/`, `handlers/`, `endpoints/` — HTTP/RPC inputs.
- `schemas/`, `dto/`, `contracts/`, OpenAPI/GraphQL/Protobuf files — request/response shapes.
- `events/`, `subscribers/`, `consumers/`, `jobs/`, `workers/`, `tasks/` — async work and triggers.
- Webhook handlers, CLI commands, cron entries, scheduled functions.

**Layer 3 — Persistence**
- `migrations/`, `prisma/schema.prisma`, `*.sql`, `models/`, ORM definitions — entity shape, FKs, indexes, constraints.
- Seeds, fixtures — what "valid" data looks like.
- DB-level checks (`CHECK`, `UNIQUE`, triggers, partial indexes, generated columns).

**Layer 4 — Tests as specs**
- `tests/`, `spec/`, `e2e/`, `cypress/`, `playwright/` — test names often encode business rules verbatim.
- Snapshot and fixture files — real shapes of accepted/rejected inputs.
- Skipped/`xit`/`pending` tests — surface unfinished or contested rules.

**Layer 5 — Configuration & feature flags**
- `.env.example`, config files, feature flags — toggles, limits, thresholds, kill switches.
- `i18n/`, locale files — user-facing copy reveals concepts and tone.

**Layer 6 — Documentation traces**
- `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `docs/`, existing ADRs.
- Issue templates, PR templates.
- Last ~50 commit messages on `main` and ~20 most recently changed files — current concerns and hotspots.

## 2.2 Extract candidate business rules

Build a structured draft. Every section a–k must be filled with concrete findings or marked `??? ASK USER`. **No silent omissions.** See `references/business-rule-discovery-checklist.md` for the minimum evidence required per section before you may consider it covered.

The required sections are:

- **(a) Entities & lifecycle** — canonical name + aliases, fields, immutability, derived fields, states, allowed transitions, who triggers each.
- **(b) Invariants** — constructor/factory checks, DB constraints, guard clauses, post-conditions, cross-aggregate consistency.
- **(c) Policies & business decisions** — pricing/discounts/fees/taxes/rounding, eligibility/limits/quotas, refund/cancellation, authorization, SLA/SLO commitments in code, idempotency, retry & backoff.
- **(d) Workflows & processes** — trigger, ordered steps including async hops and human-in-the-loop, compensations/rollbacks/sagas, notifications, time-bound steps.
- **(e) Roles & permissions** — full role list, capability matrix, special accounts, multi-tenant boundaries.
- **(f) External integrations** — purpose, direction, failure modes handled vs ignored, idempotency strategy, retry/circuit-breaker, PII boundary.
- **(g) Money, time, identity, counts** — currency precision/rounding/multi-currency/FX, time zones/DST/business calendars/holidays, ID strategy, counters/sequences/inventory races.
- **(h) Telemetry & audit** — events emitted and schemas, audit log destinations and retention, PII redaction, required log fields per event.
- **(i) Edge cases the code already handles** — concurrency, duplicates, partial failures, soft vs hard deletes, backfills.
- **(j) Dead code & contradictions** — unused entities/methods/flags, code paths contradicting tests or DB schema, TODO/FIXME/HACK touching business logic.
- **(k) Open questions / ambiguities** — every place code is ambiguous or contradictory becomes a numbered question for the user.
- **(ddd) DDD strategic & tactical model** — *only when `tack.ddd.profile = on`*. Captures bounded contexts, aggregate classification, value objects, domain events, anticorruption layers, and context relationships found in Layer 1 reconnaissance. Subsections:
  - **(ddd.1) Bounded contexts** — name, role (core / supporting / generic), source folder(s), primary aggregates.
  - **(ddd.2) Aggregates & value objects** — per entity in section (a), the type (entity / aggregate root / value object / domain service) and the owning context.
  - **(ddd.3) Domain events** — event name, emitting aggregate, payload sketch, downstream consumers / subscribers, and any link to a telemetry pipeline named in (h).
  - **(ddd.4) Anticorruption layers** — for each external integration in (f), the path to the wrapping adapter / translator / mapper, plus a one-line note on what it translates.
  - **(ddd.5) Context relationships** — pairwise mapping between contexts: customer-supplier, conformist, ACL, shared kernel, published language, partnership, separate ways.

  Use the `references/business-rule-discovery-checklist.md` (ddd) section for the minimum-evidence rows. When the profile is `off`, omit this section entirely — do not write `??? ASK USER` placeholders just to fill it.

## 2.3 Confirm & deepen — iterative interview loop

Present the draft in **small chunks**: one section at a time, or grouped per entity for sections (a)–(c). Each chunk follows this template:

```text
## Section X — <name>

Here is what I extracted from the code, with citations:

- <finding> (file:line)
- <finding> (file:line)
- ...

Open questions:
1. <focused question>
2. <focused question>
3. <focused question>
```

Use the question patterns documented in `references/discovery-questions.md`:

- **Gap-fill** ("are there transitions I am missing?")
- **Disambiguation** ("DB allows X but validator rejects X — which is the truth?")
- **Origin** ("test references `vip_customer` flag I do not see set anywhere — dead code or external?")
- **Tribal knowledge** ("rules that exist only in someone's head, wiki, or Slack — list them now")
- **Numerical limits** ("hard-coded `1000` in `ReportService.py:42` — what is it, is it negotiable?")
- **Time semantics** ("refund window uses `created_at` — should it be `paid_at` or `delivered_at`?")
- **Failure intent** ("payment timeout marks order `failed` — recoverable or terminal?")
- **Compliance** ("`customer.tax_id` is logged in `app.log` — intentional? masking required?")

After each round:

1. Update the draft on disk (`project/docs/_discovery/business-rules-draft.md`).
2. Show the user **only the diff** since the previous round.
3. Ask them to confirm the diff or push back.

**Done condition.** Use this exact prompt verbatim, every round, after presenting the consolidated draft:

> Here is the consolidated business-rule map. Read it carefully. Is anything missing, wrong, or oversimplified? Reply with the single word `complete` only when you are confident this captures the domain. Anything else will be treated as a follow-up.

If the user replies anything other than the literal `complete` (including "looks good", "ok", "ship it", "done", "finished", "go", "next", or silence) — run **one more round of at least 3 clarifying questions** targeting the **least-covered** sections per `references/business-rule-discovery-checklist.md`, then re-prompt with the exact verbatim done-condition above. Loop until `complete`.

## 2.4 Phase 2 output

A scratch artifact `project/docs/_discovery/business-rules-draft.md` containing every section a–k filled, every finding cited, and a **follow-ups** list at the bottom tagged with one of:

- `[ADR]` — architectural decision worth recording.
- `[SPEC]` — behaviour worth turning into an `S-XXX` spec later.
- `[TEST-GAP]` — behaviour that is not covered by tests.
- `[REFACTOR]` — internal cleanup, no behaviour change.
- `[DOCS]` — pure documentation gap.

This draft feeds `domain-glossary.md` and `architecture.md` in Phase 5. See `references/file-templates/business-rules.md` for the canonical shape.
