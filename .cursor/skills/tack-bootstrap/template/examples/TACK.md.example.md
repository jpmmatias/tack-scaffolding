# Example: `TACK.md` (OrderFlow Checkout — fictitious)

Save the active Tack configuration as **`TACK.md`** at the repository root. This example mirrors **`project/TACK.md.template`**. See **`cursorrules.example.md`** only for historical stub shape (deprecated).

---

# Project: OrderFlow Checkout

## Tech stack

- TypeScript
- Next.js (example) + Vitest for unit tests

## Domain and naming

- **Product:** OrderFlow — a hosted checkout experience for ecommerce partners.
- **Entities:** `Cart`, `Order`, `PaymentIntent`, `CustomerSession` — use these spellings in new docs and code.
- **Boundaries:** `PaymentGateway`, `InventoryService`, `NotificationService` — never colloquial “payments API” alone in specs.

## Engineering invariants (CRITICAL)

- **`IDEMPOTENT_RETRY_V2`:** The Unleash (or similar) flag name is intentionally spelled **`IDEMPOTENT_RETRY_V2`**. Do **not** “fix” it to `IDEMPOTENT_RETRY` or `IDEMPOTENT_RETRY_V1`.
- **Dual-provider parity:** Behaviour changes to checkout orchestration must touch **both** `src/providers/legacyCheckoutProvider.tsx` **and** `src/providers/checkout/` until legacy is retired.
- **Customer identity:** Read `customerSessionId` from the `of_session` cookie first; fall back to the `csid` claim in the signed session. Do **not** use `sub` for checkout authorization.

## Architecture rules

- Canonical architecture: `docs/architecture/order-flow.md` (repo root).
- BFF route handlers live under `src/app/api/**`. UI and hooks stay out of that tree unless a task explicitly spans both (then split prompts).

## SDD / TDD / harness

- **Specs:** `S-001`, `S-002`, … under `project/specs/`.
- **ADRs:** `project/docs/adr/` with sequential `NNNN` filenames.
- **Harness root:** `test/harness/`.

## Quality commands

- Lint: `npm run lint`
- Tests: `npm run test:run`
- Typecheck: `npm run typecheck`
