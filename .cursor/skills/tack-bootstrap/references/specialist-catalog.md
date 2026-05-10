# Specialist catalog

Reference catalog for **Phase 4** of `tack-bootstrap`. Every entry below is a *candidate*; the skill must surface them as a checklist (per Phase 4 of `SKILL.md`) and only create the ones the user explicitly checks.

Conventions:

- **Suggested model** uses the orchestrator tag — `[Composer]` (mechanical), `[Sonnet]` (contractual), `[Opus]` (high-stakes reasoning). The concrete Cursor slug comes from **`project/docs/tack-pipeline-models.md`** (see `project/prompts/auto-orchestrator.md`); specialists default to the **`worker`** key unless the routing row implies `[Sonnet]` / `[Opus]`.
- **Scope** is a comma-separated list of file/path globs the specialist owns. Goes into the prompt's *Outputs* block.
- **Detection signals** are what the skill should grep for. Combine path patterns with library imports.
- **Example invariant** is a one-liner the skill can drop into the *Boundaries / Invariants* section of the generated specialist prompt — the user must approve or edit it before write.

`security-engineer.md` already exists in the template; this catalog **never** duplicates it. When PII / PCI / GDPR / HIPAA signals fire, the skill reinforces the existing prompt by adding triggers to the **Specialist routing** table rather than creating a new file.

---

## Web / product

### `ui`

| Field | Value |
|-------|-------|
| Scope | `apps/web/**`, `src/components/**`, `src/hooks/**`, `src/styles/**`, `src/app/(routes)/**` (App Router pages) |
| Detection signals | `package.json` deps include `react`, `next`, `vue`, `svelte`, `solid-js`, `@remix-run/*`; presence of `app/`, `pages/`, `components/`, `tailwind.config.*`, design-system imports |
| Suggested model | `[Composer]` |
| Example invariant | "Do not import from `src/server/**` or `src/lib/db/**`. Domain calls happen via server actions exposed under `src/app/api/**` only." |

### `api`

| Field | Value |
|-------|-------|
| Scope | `src/app/api/**`, `src/server/**`, `routes/**`, `controllers/**`, OpenAPI/GraphQL/Protobuf files |
| Detection signals | `express`, `fastify`, `koa`, `nestjs`, `flask`, `fastapi`, `gin`, `actix-web`; folders `routes/`, `controllers/`, `endpoints/`; `openapi.yaml`, `*.proto`, `schema.graphql` |
| Suggested model | `[Sonnet]` |
| Example invariant | "Every public endpoint validates input against a typed schema before calling domain code. Versioned routes live under `routes/v<N>/` and never re-use a path under a previous version." |

### `mobile`

| Field | Value |
|-------|-------|
| Scope | `ios/**`, `android/**`, `apps/mobile/**`, `src/native/**`, platform-specific shims |
| Detection signals | `ios/Podfile`, `android/build.gradle`, `react-native` in `package.json`, `expo`, Flutter `pubspec.yaml`, Capacitor `capacitor.config.*` |
| Suggested model | `[Sonnet]` |
| Example invariant | "Do not introduce platform-specific business logic outside the boundary modules in `src/native/<platform>/**`. Shared logic lives in pure modules under `src/native/shared/**`." |

---

## Data & persistence

### `data`

| Field | Value |
|-------|-------|
| Scope | `migrations/**`, `prisma/**`, `db/**`, `db/seeds/**`, `scripts/migrate-*`, repository / DAL classes |
| Detection signals | `prisma/schema.prisma`, `migrations/*.sql`, `alembic/`, `flyway/`, `liquibase/`, `sequelize-cli`, `knex`; ORM imports (`@prisma/client`, `sqlalchemy`, `typeorm`, `mikro-orm`, `gorm`) |
| Suggested model | `[Sonnet]` |
| Example invariant | "Every migration is forward-only and idempotent within a single environment; destructive changes go through a deprecation migration first. Schema changes must update the corresponding ORM model in the same PR." |

### `eventing`

| Field | Value |
|-------|-------|
| Scope | `src/events/**`, `src/consumers/**`, `src/workers/**`, `src/jobs/**`, `messaging/**` |
| Detection signals | imports of `kafkajs`, `amqplib`, `bullmq`, `aws-sdk` SQS/SNS, `nats`, `pubsub`; folders `events/`, `consumers/`, `workers/`, `jobs/`, `subscribers/` |
| Suggested model | `[Sonnet]` |
| Example invariant | "Every consumer is idempotent against a deterministic message key. Failed-after-retries messages land in a DLQ named `<topic>.dlq`; they never silently drop." |

---

## Infrastructure

### `infra`

| Field | Value |
|-------|-------|
| Scope | `infra/**`, `terraform/**`, `pulumi/**`, `cdk/**`, `helm/**`, `k8s/**`, `Dockerfile*`, `docker-compose*.yml`, `.github/workflows/**` |
| Detection signals | `*.tf`, `*.tfvars`, `Pulumi.yaml`, `cdk.json`, `helm/`, `kustomization.yaml`, `Dockerfile`, `docker-compose.yml`, `.github/workflows/*.yml` |
| Suggested model | `[Sonnet]` |
| Example invariant | "All cloud resources are defined as code under `infra/`. Manual console changes are reverted by the next apply; any drift is treated as a bug, not a baseline." |

### `tenancy`

| Field | Value |
|-------|-------|
| Scope | `src/tenancy/**`, multi-tenant middleware, row-level security (RLS) policies, tenant-scoped repositories |
| Detection signals | columns / fields named `tenant_id`, `workspace_id`, `org_id`, `account_id`; RLS SQL policies; middleware that pulls tenant from request context |
| Suggested model | `[Sonnet]` |
| Example invariant | "Every database query for tenant-scoped tables filters by tenant id at the repository boundary. RLS policies cover the same tables as a defense-in-depth layer; both must agree." |

---

## Domain-specific

### `payments`

| Field | Value |
|-------|-------|
| Scope | `src/lib/payment/**`, `src/app/api/payments/**`, `webhooks/payment/**`, `src/services/billing/**` |
| Detection signals | imports of `stripe`, `@adyen/api-library`, `braintree`, `paypal-rest-sdk`, `mercadopago`, `pagarme`; webhook handlers under `webhooks/`; env vars `*_API_KEY`, `*_WEBHOOK_SECRET` |
| Suggested model | `[Sonnet]` |
| Example invariant | "Every charge attempt carries a deterministic idempotency key derived from the order id + attempt counter. Webhook handlers verify the provider signature before any state change." |

### `ml`

| Field | Value |
|-------|-------|
| Scope | `notebooks/**`, `models/**`, `pipelines/**`, `src/inference/**`, `src/training/**` |
| Detection signals | `requirements.txt` / `pyproject.toml` with `scikit-learn`, `pandas`, `pytorch`, `tensorflow`, `xgboost`, `transformers`, `mlflow`, `sagemaker`; `*.ipynb`; `models/*.pkl|*.onnx|*.pt` |
| Suggested model | `[Sonnet]` |
| Example invariant | "Inference code never imports from `notebooks/`. Models loaded at runtime are pinned to a specific artifact version recorded in config; ad-hoc model files are not deployed." |

### `search`

| Field | Value |
|-------|-------|
| Scope | `src/search/**`, indexers, query builders, search-result mappers |
| Detection signals | imports of `@elastic/elasticsearch`, `meilisearch`, `algoliasearch`, `typesense`, `opensearch`; folders `search/`, `indexers/` |
| Suggested model | `[Sonnet]` |
| Example invariant | "Search indices are rebuildable from primary data. Re-index jobs are idempotent and run end-to-end without manual cleanup steps." |

---

## Specialist heuristics summary

Use this table during **Phase 4** to map detection signals to suggestions. Show each row only when the signal actually fires in the consumer repo; cite `file:line` for the trigger.

| Detected signal | Suggest |
|---|---|
| React / Vue / Svelte / Solid in `package.json` | `ui` |
| REST / GraphQL endpoints, OpenAPI, contracts | `api` |
| `migrations/`, `prisma/`, `alembic/`, `flyway/`, `liquibase/` | `data` |
| `ios/`, `android/`, React Native, Flutter, Capacitor | `mobile` |
| `terraform/`, `pulumi/`, `cdk/`, `helm/`, k8s manifests | `infra` |
| Stripe, Adyen, Braintree, PayPal, regional payment SDK | `payments` |
| Notebooks, MLflow, SageMaker, training scripts | `ml` |
| Multi-tenant terms (`tenant_id`, `workspace_id`, RLS) | `tenancy` |
| `events/`, `consumers/`, Kafka, RabbitMQ, SQS, BullMQ | `eventing` |
| Elasticsearch, Meilisearch, Algolia, Typesense, OpenSearch | `search` |
| PII / PCI / GDPR / HIPAA mentioned | reinforce existing `security-engineer.md` (do **not** duplicate) |

---

## Routing table row format

When a specialist is approved, append a row to **Specialist routing — fill in** in `project/prompts/auto-orchestrator.md` using this exact schema:

```markdown
| `<task path or keyword>` | `@<name>.md` |
```

Examples (model tag goes into the prompt body or the orchestrator's preamble paragraph above the table — never inside the row):

```markdown
| tasks under `src/app/api/**` or files matching `*.route.ts` | `@api.md` |
| tasks under `src/components/**`, `src/hooks/**`, `apps/web/**` | `@ui.md` |
| tasks editing `prisma/schema.prisma` or files under `migrations/` | `@data.md` |
| tasks touching webhook handlers under `src/app/api/webhooks/payment/**` | `@payments.md` |
| tasks under `infra/`, `.github/workflows/`, `Dockerfile*`, `docker-compose*.yml` | `@infra.md` |
| tasks editing files matching `*tenant*`, `*workspace*` or DB policies under `db/policies/**` | `@tenancy.md` |
| tasks editing files under `src/events/`, `src/consumers/`, `src/workers/` | `@eventing.md` |
```

Always end the **Specialist routing** table with a default fallback row pointing to `@worker.md` for unmatched tasks. Do not remove it.
