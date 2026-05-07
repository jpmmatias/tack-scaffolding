# Discovery questions

Question bank for the `tack-bootstrap` skill. Use this in **Phase 3** (blocks A–E) and during the **Phase 2.3** interview loop.

Hard rules:

- Maximum **3 questions per turn**. Wait for the user to answer before sending more.
- Skip any question whose answer is already in the Phase 2 draft. Do not re-ask.
- For every "I don't know" answer: present 2–3 options with one-line trade-offs and ask the user to pick.
- Always cite `file:line` when a question grounds in existing code.

---

## Phase 3 question blocks

### Block A — Product & domain

Run in full for **NEW** projects. For **EXISTING** projects, only ask gaps left by Phase 2.

1. In one paragraph, what business problem does this product solve, and for whom?
2. List the personas/roles that interact with the system (end user, admin, internal operator, machine, partner).
3. Name 3–7 core domain entities. For each, give the canonical spelling and any **forbidden synonyms** (terms used historically that must not appear in new code/docs).
4. List the surfaces (UI areas, public APIs, internal APIs, async jobs, channels, CLI). One line each.
5. What telemetry pipelines exist or are planned? (e.g. product analytics, engineering observability, internal devtrace.) Name them with the conventions you want enforced.

Conditional follow-ups:

- If the user names only 1–2 entities → ask "What other nouns appear repeatedly in your roadmap, dashboards, or onboarding docs?"
- If the user lists no forbidden synonyms → ask "Are there legacy terms you actively want banned from new work? E.g. an old product name, or a misleading data shape." Suggest at least one likely candidate based on Phase 2 findings if available.
- If telemetry is "we don't have any yet" → propose a single pipeline placeholder, mark it explicitly TODO in the glossary, and add a `[SPEC]` follow-up "Define telemetry baseline".

### Block B — Stack & quality

1. Confirm or correct the language(s), framework(s), and package manager I detected. Anything I missed?
2. Give me the exact commands for: `lint`, `test`, `typecheck`, `build`, `e2e`, `format`. Use the same form you put in CI — `npm run lint`, `pnpm test`, `pytest -q`, `cargo test`, `make test`, etc.
3. Is the integration / E2E suite a separate runner from unit tests? If yes, what is its command and where do its tests live?

Conditional follow-ups:

- If no `e2e` or integration command → ask "Are there any tests you want gated separately from the unit suite (slow, network, or DB-heavy)? If yes, what command runs only those?"
- If the user gives no `format` command → ask "Should the agents auto-format on save, or is formatting a CI gate only? If a gate, which command?"
- If the user names a coverage threshold → record it in `.cursorrules` quality section. If they don't → ask "Is there a minimum coverage threshold the orchestrator should enforce, or do you trust QA judgement?"

### Block C — Engineering invariants

1. List the boundary rules in your codebase. Examples: "domain layer cannot import from infra", "UI cannot import from server actions directly", "no `fetch` in `src/lib/`".
2. Are there any hard limits the agents must respect? Examples: max function length, max module size, no `any` in TypeScript, banned globals, banned libraries.
3. Is there a mandatory architectural pattern (hexagonal, clean architecture, feature folders, vertical slice, layered MVC, …)? If yes, where is it described?

Conditional follow-ups:

- If the user says "we don't enforce that" → ask "Should we enforce one starting now? Pick from: (a) hexagonal/ports-and-adapters, (b) feature folders, (c) layered MVC, (d) keep current ad-hoc but document boundaries case by case." Record the choice.
- For each invariant, ask "Is there a known invariant that has been broken in the past and you want loud about? E.g. a flag spelling, a claim order, a parity rule between two modules."
- If the project uses TypeScript and the user has not mentioned `strict` → ask "Is `strict: true` on, or do you want it on?"

### Block D — Architecture

Run in full for **NEW**; for **EXISTING**, only fill gaps after Phase 2.

1. Pick the topology that matches reality: monolith, modular monolith, microservices, serverless, hybrid. One line on why.
2. What persists state and how? (Postgres, MySQL, DynamoDB, Mongo, Redis, S3, message log, file system.) For each, who owns the schema and where does it live?
3. List the critical external integrations (payment provider, email/SMS, identity, analytics, fraud, OS notifications). For each, name the canonical client/module path in code.

Conditional follow-ups:

- If the user names a job system but no broker → ask "Are jobs run via cron, queue (SQS/RabbitMQ/Kafka/Redis), or in-process? Where do failed jobs go?"
- If multiple databases → ask "Which one is the system of record for each entity? Cross-DB reads/writes happen through what?"
- If "we'll figure it out later" → push back: "Pick one for the baseline ADR; you can change later via a new ADR. Choose: (a) Postgres + simple jobs, (b) Postgres + queue, (c) something else (describe)."

### Block E — Team & risk

1. Team size today and 6 months out. Are there async contributors / outside contractors who need stricter governance?
2. What compliance/security regimes apply? PII, PCI-DSS, GDPR, HIPAA, SOC 2, ISO 27001, FedRAMP, none. Be specific.
3. Do you have existing ADRs to import, or are we starting fresh? If existing, where do they live?

Conditional follow-ups:

- If "no compliance" but Phase 2 detected PII handling → push back: "I see customer email and tax_id in `<file:line>`. Even without a formal regime, want me to enable security-engineer triggers on those paths?"
- If team > 5 → recommend explicit `[Opus]` review on Step 7 even for low-risk changes.
- If existing ADRs in another folder → ask "Move them under `project/docs/adr/`, or keep them where they are and just point `.cursorrules` at the canonical location?"

---

## Phase 2 question patterns

Use during the iterative business-rule discovery interview (Phase 2.3). Each pattern targets a specific kind of gap. Always lead with the citation, then the question.

### Pattern: Gap-fill

Use when you've extracted a list and want to know what's missing.

> "I see `Order.status` can be `pending | paid | shipped | cancelled | refunded` based on `src/domain/Order.ts:14`. Are there transitions I'm missing — e.g. `paid → cancelled` directly without a refund?"

Conditional follow-up — if the user names a missing state:

> "Where is that state set, and what triggers it? Is it persisted, or only used in-memory?"

If the user says "no, that's all":

> "Confirm: the only legal terminal states are `cancelled` and `refunded`. Anything else and we treat it as a bug."

### Pattern: Disambiguation

Use when two sources contradict each other.

> "The DB allows `quantity = 0` (no `CHECK` constraint in `migrations/2024_01_orders.sql:12`) but `OrderValidator.ts:88` rejects it with 'quantity must be > 0'. Which is the truth — should the DB also reject, or should the validator accept zero for some path I'm missing?"

Conditional follow-up — if the user picks the validator:

> "Should I record a `[ADR]` follow-up to add a `CHECK (quantity > 0)` constraint? Or is there a deliberate reason the DB stays permissive?"

If the user says "the DB is right":

> "Then what is the validator protecting? Maybe a UI flow where zero is sentinel for 'remove line item'? Cite where."

### Pattern: Origin

Use when you find a flag, field, or value with no obvious source.

> "Tests in `tests/checkout/vip.spec.ts:22` reference a `vip_customer` flag, but I cannot find it set anywhere in the application code. Is it (a) dead code, (b) unfinished work, (c) set externally by a service or admin tool, (d) something else?"

Conditional follow-up — if "set externally":

> "Which service sets it, and how does this codebase read it? Header? Cookie? Database join? Cite the read site if it exists."

If "dead code":

> "Should I tag this `[REFACTOR]` for removal, or is there a planned feature it ties to?"

### Pattern: Tribal knowledge

Use late in Phase 2 to flush out unwritten rules. Run at least once per session.

> "Are there business rules that exist only in someone's head, on a wiki, or in Slack — not in the code? Examples: 'we always credit a free month after 3 failed charges', 'EU customers get a separate invoice format', 'admin overrides bypass the eligibility check'. List them now even informally; I'll capture them as `[SPEC]` follow-ups."

Conditional follow-up for each item the user names:

> "Where would the new test for that rule live, and which entity is the source of truth? If you don't know, mark it `[ADR]` for me to push to the architect."

### Pattern: Numerical limits

Use whenever you find a magic number.

> "I see a hard-coded `1000` in `src/services/ReportService.py:42` (looks like a row cap). What does it mean? Is it negotiable — could a customer hit it and how do we recover?"

Conditional follow-up — if the user says "no, it's fine":

> "Then I'll record it in **(c) Policies** as a hard limit. Should it move to config / env so it can change without a deploy?"

If "we'll raise it for big customers":

> "How? Per-tenant config, feature flag, env override? Cite the lookup site so it's documented."

### Pattern: Time semantics

Use when timestamps drive business outcomes.

> "Refunds use `created_at` for the 30-day window in `src/policies/RefundPolicy.ts:55`. Should the clock start at `paid_at`, `delivered_at`, or `created_at`? Confirm the canonical timestamp; I will flag any code that uses a different one."

Conditional follow-up — if the user picks `delivered_at`:

> "Is `delivered_at` always set, or can it be null? What happens for never-delivered orders — refundable forever, or fall back to `paid_at + 30d`?"

### Pattern: Failure intent

Use whenever you find error handling.

> "When the payment provider times out, `PaymentService.ts:120` retries 3× with exponential backoff and then marks the order `failed`. Is `failed` recoverable (operator can retry manually), or terminal (customer must place a new order)?"

Conditional follow-up — if "recoverable":

> "Where is the recovery path? Admin UI, cron, support tool? Cite it. If it doesn't exist, should I record `[SPEC]` for it?"

If "terminal":

> "Then how does the customer find out? Email, in-app banner, support ticket? Should `failed` cascade to refund any partial captures?"

### Pattern: Compliance

Use whenever you suspect PII / financial / health data leakage.

> "Field `customer.tax_id` is logged in `app.log` via `logger.info({ customer })` at `src/api/customer.ts:33`. Is that intentional? Any masking required by your compliance regime?"

Conditional follow-up — if "not intentional":

> "Should I tag this `[REFACTOR]` for redaction and add a glossary rule 'never log full `tax_id`, only last 4'?"

If "intentional":

> "Where is the access control on the log destination documented? Add it to `(h) Telemetry & audit` and consider a security-engineer trigger on this path."

---

## "I don't know" defaults

When the user defers, present these triplets and ask them to pick. Never silently choose.

### Stack baseline

(a) Conservative: pick the most popular framework in the chosen language with built-in test runner.
(b) Modern: pick the current "boring + well-supported" choice (e.g. Next.js + Vitest, FastAPI + pytest, Rails + RSpec).
(c) Custom: defer the choice to an ADR.

### Coverage threshold

(a) None — trust QA.
(b) 60% lines globally, 100% on changed lines per PR.
(c) 80% lines globally, mutation testing on critical modules.

### Architectural pattern

(a) Feature folders — colocate UI, server, tests by feature.
(b) Hexagonal / ports-and-adapters — strict domain isolation.
(c) Layered MVC — controllers, services, repositories.

### Specialist baseline

(a) Just `worker.md` (default) — no specialists, simplest setup.
(b) `worker.md` + `api` + `ui` — standard web app split.
(c) Full menu — let me propose specialists per Phase 4 heuristics.

---

## Round-end summary template

After every block, end the turn with:

```text
## Captured so far — Block <X>

- <field>: <value>
- ...

Confirm or correct, then I'll move to Block <X+1>.
```

Do not advance until the user confirms.
