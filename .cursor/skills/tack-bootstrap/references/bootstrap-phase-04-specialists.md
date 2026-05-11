# Phase 4 — Suggest specialists (NEVER auto-create)

Based on Phases 1–3, propose candidate specialists derived from `${SKILL_DIR}/template/prompts/_specialist-template.md` if `project/prompts/_specialist-template.md` is not present yet, otherwise from `project/prompts/_specialist-template.md`. **Present as a checklist** with short justification grounded in actual findings — cite `file:line` or detection signals where possible.

**Heuristics** (signal → specialist id): use **`references/specialist-catalog.md`** for the full catalog, scope, detection signals, suggested model tags, example invariants, and naming conventions — do not duplicate that table here.

Present as:

```text
Based on what I gathered, these specialists would make sense. Check the ones you want me to create:

- [ ] `api` — REST + contract versioning seen in `routes/v1/` (file:line)
- [ ] `ui` — React + design system in `apps/web/` (file:line)
- [ ] `data` — migrations + critical queries in `prisma/` (file:line)
- [ ] `payments` — Stripe webhook handler at `webhooks/stripe.ts:42`
- [ ] `infra` — Terraform under `infra/` (file:line)

Anything missing? Want to remove any? Reply with the list of names you want, or "none".
```

(Replace example rows with candidates grounded in *this* repo using **`references/specialist-catalog.md`**.)

Only create the marked ones. Each created specialist gets:

1. A new file `project/prompts/<name>.md` filled from `_specialist-template.md` (use `references/file-templates/specialist.md` as a worked example).
2. A row in the **Specialist routing — fill in** table of `project/prompts/auto-orchestrator.md`. Schema: `| Condition (task paths / keywords) | Prompt |` plus a leading line indicating the suggested model tag (`[Composer]` default; `[Sonnet]` for high-reasoning specialists; `[Opus]` only when explicitly justified).

Never create a specialist that the user did not check. Never invent specialists outside the catalog without asking first.
