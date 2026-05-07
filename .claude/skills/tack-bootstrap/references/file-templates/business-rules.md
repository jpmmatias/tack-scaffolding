# File template — `project/docs/_discovery/business-rules-draft.md`

Phase 2 scratch artifact. Promote to `project/docs/business-rules.md` only when the user accepts in Phase 5.

The structure mirrors the eleven sections (a–k) of `references/business-rule-discovery-checklist.md`. Every finding **must** carry a `file:line` citation; every gap **must** carry an explicit `??? ASK USER` marker until resolved.

```markdown
# Business rules — discovery draft

> Phase 2 of `tack-bootstrap`. Updated round-by-round. Do not promote to `business-rules.md` until the user replies the literal `complete`.

## (a) Entities & lifecycle

### <Entity 1>

- **Canonical name:** `<Order>` (`src/domain/Order.ts:1`)
- **Aliases found in code:** `purchase` (`src/legacy/Purchase.ts:1`), `transaction` (`src/api/dto/Transaction.ts:1`)
- **Fields:**
  - `id: string` — `src/domain/Order.ts:5` — immutable
  - `status: OrderStatus` — `src/domain/Order.ts:6` — mutable, see transitions below
  - `totalCents: number` — `src/domain/Order.ts:7` — derived from line items at write
  - ... (one row per field)
- **States:** `pending | paid | shipped | cancelled | refunded` (`src/domain/Order.ts:14`)
- **Transitions:**
  - `pending → paid` triggered by `PaymentGateway` webhook (`src/api/webhooks/payment.ts:42`)
  - `paid → shipped` triggered by operator action (`src/api/admin/ship.ts:18`)
  - `paid → refunded` triggered by `RefundService` (`src/services/refund.ts:55`)
  - `??? ASK USER`: is `paid → cancelled` allowed without a refund? Found in tests (`tests/order.spec.ts:22`) but not in production code.
- **Triggers per transition:** see above; user / event / schedule annotated.

### <Entity 2>

... (repeat per core entity)

## (b) Invariants

### <Entity 1>

- **Constructor checks:** `Order.create()` rejects empty `lineItems` (`src/domain/Order.ts:30`).
- **DB constraints:** `orders.status` is `NOT NULL`; no `CHECK` on values, enum is enforced at app layer only (`migrations/2024_01_orders.sql:8`). `??? ASK USER`: should we add a DB-level `CHECK`?
- **Guard clauses:** `OrderService.markPaid()` requires `status = pending`, throws otherwise (`src/services/order.ts:88`).
- **Post-conditions:** after `markPaid()`, `paidAt` is set and `status = paid`.
- **Cross-aggregate consistency:** `Order.markPaid()` reserves stock via `InventoryService`; failure rolls back the status change (`src/services/order.ts:99`).

## (c) Policies & business decisions

- **Pricing:** base price from line items; discounts stack additively (`src/policies/pricing.ts:14`); coupons applied last; rounding `half-up` to two decimals (`src/policies/pricing.ts:55`).
- **Eligibility:** refunds limited to orders <30d old, status `paid` or `shipped` (`src/policies/refund.ts:22`). `??? ASK USER`: window starts from `created_at`, but should it be `paid_at` or `delivered_at`?
- **Limits:** report exports capped at `1000` rows (`src/services/report.ts:42`). `??? ASK USER`: is this negotiable?
- **Authorization:** see (e). Refund requires `role in {admin, support_lead}` (`src/auth/policies/refund.ts:9`).
- **SLA / SLO:** payment provider call timeout `5s` with 3 retries, exponential backoff base `200ms` (`src/lib/payment/client.ts:33`).
- **Idempotency:** `PaymentIntent` keyed by `<orderId>:<attempt>` (`src/lib/payment/client.ts:55`).

## (d) Workflows & processes

### Checkout submit → paid

1. UI calls `POST /api/checkout/submit` with cart payload (`src/app/api/checkout/submit.ts:8`).
2. Server validates cart, creates `Order` in `pending` (`src/services/order.ts:42`).
3. Server creates `PaymentIntent` via `PaymentGateway` (idempotency key per attempt) (`src/lib/payment/client.ts:55`).
4. Async hop: provider webhook → `markPaid` (`src/api/webhooks/payment.ts:42`).
5. Notification: order confirmation email (`src/lib/notify/orderConfirmed.ts:14`).
6. Compensation on webhook failure: order remains `pending`, expires after `24h` and is auto-cancelled by job `expirePendingOrders` (`src/jobs/expire.ts:9`).

## (e) Roles & permissions

- Roles: `customer`, `support`, `support_lead`, `admin`, `system`.
- Capability matrix (excerpt):
  - `customer`: place order, view own orders, request refund
  - `support`: read-only customer / order
  - `support_lead`: trigger refund, view audit log
  - `admin`: everything support_lead has + tenant settings
  - `system`: machine token used by webhooks (`src/auth/system.ts:7`)
- Multi-tenant: **single-tenant for now** — no `tenant_id` in schema (`migrations/`).

## (f) External integrations

### PaymentGateway

- **Purpose:** card / wallet capture, refunds, webhooks.
- **Direction:** outbound + inbound webhook.
- **Failure modes handled:** timeout, `429`, signature verification mismatch (`src/api/webhooks/payment.ts:18`). Ignored: `5xx` after retries → order kept `pending`, `??? ASK USER` whether this should auto-cancel sooner.
- **Idempotency strategy:** deterministic key per intent.
- **Retry / circuit-breaker:** 3 retries, no circuit breaker — `??? ASK USER`.
- **PII boundary:** card tokens only; no PAN ever in logs (`src/lib/payment/client.ts:88`).

### NotificationService

- ... (one entry per integration)

## (g) Money, time, identity, counts

- **Currency:** all amounts stored in minor units (cents); `Decimal.js`-style arithmetic in `src/lib/money.ts`. Single currency `USD`. `??? ASK USER`: any plan to add multi-currency?
- **Time zones:** all timestamps stored in UTC; user-facing display formatted at the BFF layer (`src/lib/format.ts:14`). DST: not relevant — no business rule depends on local time today.
- **IDs:** `Order.id` is ULID (`src/domain/Order.ts:5`). Public-facing receipt id is a slug derived from ULID (`src/lib/receipt.ts:8`).
- **Counters:** stock reservations row-locked at `InventoryService` boundary; no in-app counter race today.

## (h) Telemetry & audit

- **Events emitted:**
  - `OrderFlow Bridge Event: checkout_duplicate_submit` (`src/components/PayButton.tsx:55`) — payload `intentIdHash`, `reason`.
  - `Checkout Observability Action: pay_button_deduped` — same site.
- **Audit log:** writes to `audit_log` table on every refund (`src/services/refund.ts:88`); retention `7y` per `??? ASK USER` (no policy doc found).
- **PII redaction:** `customer.tax_id` is hashed (`src/lib/redact.ts:14`) before logging.
- **Required log fields:** `correlationId`, `orderId`, `tenantId` (currently always null) — enforced by middleware (`src/lib/log.ts:22`).

## (i) Edge cases the code already handles

- **Concurrency:** optimistic version on `Order.version` (`src/domain/Order.ts:12`); FK row locks on `order_items`.
- **Duplicates:** `idempotency_keys` table dedups checkout submits (`migrations/2024_03_idempotency.sql:1`).
- **Partial failures:** Stripe webhook retries managed by provider; internal jobs use BullMQ DLQ at `<topic>.dlq` (`src/jobs/queue.ts:8`).
- **Soft deletes:** `customer.deleted_at`; cascade to `addresses` only (`migrations/2024_02_customer_soft_delete.sql:1`).
- **Backfills:** none in repo today.

## (j) Dead code & contradictions

- `vip_customer` flag referenced in `tests/checkout/vip.spec.ts:22` but never set in production code. `??? ASK USER`: dead, unfinished, or set externally?
- `OrderValidator.ts:88` rejects `quantity = 0` but DB has no `CHECK`. `??? ASK USER`: should we add the DB constraint?
- `TODO`: `src/services/refund.ts:120` — "handle partial refunds for shipping" — not implemented.

## (k) Open questions

1. Refund window start: `created_at` vs `paid_at` vs `delivered_at`? (see (c))
2. Report row cap `1000` — negotiable or hard? (see (c))
3. `paid → cancelled` transition: legal in tests, missing in code. Bug or unimplemented? (see (a))
4. `vip_customer` flag origin? (see (j))
5. Audit log retention policy — confirm `7y`. (see (h))
6. Multi-currency on roadmap? (see (g))
7. Payment provider `5xx`-after-retries: kept `pending` indefinitely or auto-cancel? (see (f))
8. DB-level `CHECK` for status enum and `quantity > 0`? (see (b), (j))

## Follow-ups

Each tag becomes future work. The skill must classify every open question into one of these tags before proposing it as a follow-up.

- `[ADR]` — `[ADR]` Add DB-level constraints (`CHECK`) for status enum and `quantity > 0`. Decision pending discussion.
- `[ADR]` — `[ADR]` Choose refund-window start timestamp.
- `[SPEC]` — `[SPEC]` Operator-driven cancel of stuck `pending` orders after webhook timeout.
- `[SPEC]` — `[SPEC]` Multi-currency support (deferred until merchant requests it).
- `[TEST-GAP]` — `[TEST-GAP]` `paid → cancelled` transition test exists but no production code path.
- `[REFACTOR]` — `[REFACTOR]` Remove or wire up `vip_customer` flag.
- `[DOCS]` — `[DOCS]` Document audit log retention; mirror in glossary.
- `[DOCS]` — `[DOCS]` Glossary entry for `support_lead` role.
```

Notes for the bootstrap skill:

- Use the citation format `(<path>:<line>)` consistently. Do not paraphrase code without a citation.
- Keep `??? ASK USER` markers in the draft until they are answered. Removing one without an answer is a bug.
- The follow-ups list at the bottom is the seed for Phase 5: the user may convert each `[SPEC]` row into a stub spec under `project/specs/`, and each `[ADR]` row into an ADR under `project/docs/adr/`.
