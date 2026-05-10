# Tack — project improvements backlog

Prioritized improvement opportunities for this repository (canonical skill at [`skills/tack-bootstrap/`](skills/tack-bootstrap/), mirrors under `.claude/`, `.cursor/`, `.agents/`). Each item can later be promoted to a Tack `S-XXX` spec stub.

**Legend:** **P0** = blocking quality / drift risk; **P1** = high value; **P2** = nice-to-have. **S/M/L** = small / medium / large effort.

## Summary by theme and priority (pending)

| Theme | P0 | P1 | P2 | Total |
|-------|----|----|----|-------|
| 2. Script hardening & tests | 0 | 0 | 0 | 0 |
| 3. Skill correctness & safeguards | 0 | 0 | 0 | 0 |
| 4. Template content & onboarding | 0 | 2 | 4 | 6 |
| 5. Tooling / CLI | 0 | 1 | 1 | 2 |
| 6. Repo hygiene | 1 | 1 | 1 | 3 |
| 7. Worktree polish | 0 | 0 | 2 | 2 |
| **Total** | **1** | **4** | **8** | **13** |

Done so far: **17** (B-01, B-02, B-03, B-04, B-05, B-06, B-07, B-08, B-09, B-10, B-11, B-12, B-13, B-25, B-26, B-27, B-28 — see [Done](#done)).

> **Last refresh:** Theme 3 (**B-10**–**B-13**) moved to **Done**: deterministic `splice-tack-routing.sh` helper (idempotent `## Tack routing` H2 splice, `--check` mode); `tack-doctor.sh` validator (rejects `<UPPERCASE>` in `.cursorrules` + `<fill>` rows in `auto-orchestrator.md`); auto-orchestrator gains a **Platform tool mapping** preamble translating Cursor names (`Task` / `AskQuestion` / `working_directory` / `subagent_type: generalPurpose`) to Claude Code / generic equivalents; root README adds a multi-platform support table.

## Theme 2 — Script hardening & tests

*(No pending items — shipped entries are in [Done](#done).)*

---

## Theme 3 — Skill correctness & safeguards

*(No pending items — shipped entries are in [Done](#done).)*

---

## Theme 4 — Template content & onboarding UX


### B-16 — FAQ + Troubleshooting

- **Priority:** P2 · **Effort:** S
- **Rationale:** Common failures: mirror drift, `git worktree add` sandbox/permissions, Phase 2 skipped, empty specialist routing, model unavailable ([`auto-orchestrator.md`](skills/tack-bootstrap/template/prompts/auto-orchestrator.md) stop conditions).
- **Acceptance:** `docs/FAQ.md` or README subsection with indexed symptoms → fixes.

### B-17 — Portuguese README

- **Priority:** P2 · **Effort:** M
- **Rationale:** SKILL rule 1 ([`SKILL.md:22`](skills/tack-bootstrap/SKILL.md)) supports PT/EN; public docs are English-only.
- **Acceptance:** `README.pt-BR.md` mirroring install and conventions; link from main README. Mention the **DDD profile** opt-in (`tack.ddd.profile`) alongside other Phase 1 detection knobs.

### B-29 — End-to-end OrderFlow demo with DDD profile on

- **Priority:** P2 · **Effort:** M
- **Rationale:** [`skills/tack-bootstrap/template/examples/`](skills/tack-bootstrap/template/examples/) now shows DDD-populated glossary and spec rows, but a coherent multi-context walkthrough (Checkout + Payments + Fulfillment) — including a `@domain-modeler.md` re-run that splits a context — would help users understand when DDD pays off.
- **Acceptance:** Worked example under `examples/orderflow-ddd/` with three contexts, an ADR splitting Sales out of Checkout, and a sample `plan.md` that includes the new `## DDD impact` section from `architect.md` rule 8.

### B-30 — Event-storming companion specialist

- **Priority:** P2 · **Effort:** L
- **Rationale:** `@domain-modeler.md` works from the Phase 2 discovery draft, but greenfield projects (no code) need a structured event-storming pass to produce the first context map. A dedicated specialist running before `@domain-modeler.md` could conduct that interview.
- **Acceptance:** New `event-stormer.md` prompt under `skills/tack-bootstrap/template/prompts/`, registered in `tack-agent`, with a worked example replacing what is currently the Phase 3 Block A — DDD round 2/3 questions when no Phase 2 draft exists.

---

## Theme 5 — Tooling / CLI

### B-18 — `tack` CLI

- **Priority:** P1 · **Effort:** L
- **Rationale:** Bootstrap is skill-driven; a small CLI could `init` copy template, `specialist add`, and `doctor` (placeholders, routing table, parse `tack.*` keys from `.cursorrules`).
- **Acceptance:** Published binary or `npx tack` with documented subcommands; does not replace the interview skill for full bootstrap unless explicitly scoped.

### B-19 — GitHub template repo + README CTA

- **Priority:** P2 · **Effort:** S
- **Rationale:** Lowers friction for `gh repo create --template`; aligns with skills.sh distribution story in [`README.md`](README.md).
- **Acceptance:** Repo setting documented for maintainers; README “Use this template” button instructions.

---

## Theme 6 — Repo hygiene

### B-20 — `.gitignore` and `.editorconfig`

- **Priority:** P0 · **Effort:** S
- **Rationale:** Root lacked standard ignores; risk of committing `.DS_Store`, editor noise, or accidental [`recon.sh`](skills/tack-bootstrap/scripts/recon.sh) output (`recon.json`, per script usage).
- **Acceptance:** `.gitignore` covers OS/IDE artifacts and local bootstrap outputs; `.editorconfig` sets trim/charset/newline for markdown and shell.

### B-21 — Community files and templates

- **Priority:** P1 · **Effort:** S
- **Rationale:** OSS expectations: issue/PR templates, `CODE_OF_CONDUCT.md`, `SECURITY.md`.
- **Acceptance:** `.github/ISSUE_TEMPLATE/`, `PULL_REQUEST_TEMPLATE.md`, CoC and security policy (can be minimal stubs linking to org policy).

### B-22 — CHANGELOG + Conventional Commits

- **Priority:** P2 · **Effort:** S
- **Rationale:** Git history uses long single-line messages; structured commits ease releases and skill version bumps.
- **Acceptance:** `CHANGELOG.md` (Keep a Changelog style); CONTRIBUTING section on commit convention.

---

## Theme 7 — Worktree polish

### B-23 — Parse `.cursorrules` inside `tack-worktree.sh`

- **Priority:** P2 · **Effort:** S
- **Rationale:** [`worktree-coordinator.md`](skills/tack-bootstrap/template/prompts/worktree-coordinator.md) instructs parsing `tack.worktree.*` from `.cursorrules` and passing flags; the shell script could read the same keys for defaults.
- **Acceptance:** `create` without `--wt-dir`/`--base` reads optional lines from repo-root `.cursorrules` when present; documented alongside coordinator.

### B-24 — `tack-worktree.sh create --dry-run`

- **Priority:** P2 · **Effort:** S
- **Rationale:** Safer automation and tests without mutating git state.
- **Acceptance:** `--dry-run` prints or emits JSON with planned `path`, `branch`, `spec_id`, `base`, `slug` without `git worktree add`; documented in script `--help`.

---

## Done

Items below have shipped. Kept here (rather than deleted) so each acceptance criterion has a single, citable evidence link in-tree. Move to a release note / `CHANGELOG.md` (see pending **B-22**) and prune from this file once cumulative.

### B-01 — CI guard: routing snippet matches AGENTS/CLAUDE templates · P0 · S

- **Shipped:** [`scripts/check-routing-snippet.sh`](scripts/check-routing-snippet.sh) extracts the `## Tack routing` H2 from [`skills/tack-bootstrap/template/AGENTS.md.template`](skills/tack-bootstrap/template/AGENTS.md.template), [`skills/tack-bootstrap/template/CLAUDE.md.template`](skills/tack-bootstrap/template/CLAUDE.md.template), and the 1st + 3rd fenced ` ```markdown ` blocks of [`skills/tack-bootstrap/references/file-templates/agents-routing.md`](skills/tack-bootstrap/references/file-templates/agents-routing.md), then `diff`s each against canonical [`skills/tack-bootstrap/template/routing-snippet.md`](skills/tack-bootstrap/template/routing-snippet.md). Wired as `npm run check-routing` (see [`package.json`](package.json)) and enforced in CI at [`.github/workflows/check.yml`](.github/workflows/check.yml) ("Routing snippet matches all canonical copies"). Acceptance fully met.

### B-02 — Pre-push hook: sync + check-sync · P0 · S

- **Shipped:** [`.githooks/pre-push`](.githooks/pre-push) runs `check-sync`, `validate-skill`, and `check-routing` before push; installs via `npm run install-hooks` (which sets `core.hooksPath=.githooks`). The hook no-ops gracefully when `.git` is not writable. Documented in [`CONTRIBUTING.md`](CONTRIBUTING.md) ("Local hooks (optional)") and [`.githooks/README.md`](.githooks/README.md). Acceptance met (note: hook intentionally runs `check-sync`, not `sync`, so committers explicitly resync rather than mutating files at push time).

### B-03 — Single source of version truth · P1 · S

- **Shipped:** [`scripts/validate-skill-frontmatter.sh`](scripts/validate-skill-frontmatter.sh) reads `version` from [`package.json`](package.json) (canonical) and fails when any `skills/*/SKILL.md` frontmatter `version` differs. Run via `npm run validate-skill` and enforced in CI ("Validate SKILL.md frontmatter") and the pre-push hook. Implemented together with **B-27** (multi-skill iteration), which is required for this guard to cover the dispatcher skills.

### B-04 — Markdown linter + link checker in CI · P1 · M

- **Shipped:** CI ([`.github/workflows/check.yml`](.github/workflows/check.yml)) runs `markdownlint-cli2-action` over `skills/tack-bootstrap/**`, `skills/tack-run/**`, `skills/tack-agent/**`, and root `*.md`, then `lychee-action` (offline) over the same scope plus `README.md`, `AGENTS.md`, `CONTRIBUTING.md`, `BACKLOG.md`. Configs at [`.markdownlint-cli2.jsonc`](.markdownlint-cli2.jsonc) and [`lychee.toml`](lychee.toml). Local helpers `npm run lint` and `npm run check-links` ([`scripts/check-links.sh`](scripts/check-links.sh) auto-fetches a pinned `lychee` binary on first run for Apple silicon / Linux). Acceptance met.

### B-05 — Bats tests for `detect-stack.sh` · P0 · M

- **Shipped:** [`test/bats/detect-stack.bats`](test/bats/detect-stack.bats) + [`test/bats/helpers.bash`](test/bats/helpers.bash) cover all nine manifest branches in [`skills/tack-bootstrap/scripts/detect-stack.sh`](skills/tack-bootstrap/scripts/detect-stack.sh) and `project_class` new vs existing. CI: [`.github/workflows/check.yml`](.github/workflows/check.yml) (`bats-core/bats-action` + `npm test`). Acceptance met.

### B-06 — Bats tests for `tack-worktree.sh` · P0 · M

- **Shipped:** [`test/bats/tack-worktree.bats`](test/bats/tack-worktree.bats) exercises `next-spec-id`, linked worktrees, slug sanitization, `list` JSON, `remove` gates (dirty / unmerged / `--force`). CI via `npm test`. Acceptance met.

### B-07 — Bats test for `recon.sh` layer patterns · P1 · S

- **Shipped:** [`test/bats/recon.bats`](test/bats/recon.bats) asserts six-layer bucketing, `node_modules` prune, and cap truncation. [`skills/tack-bootstrap/scripts/recon.sh`](skills/tack-bootstrap/scripts/recon.sh) was fixed so per-layer `truncated` flags are set in the main shell (not lost in a `$(...)` subshell). CI via `npm test`. Acceptance met.

### B-08 — `shellcheck` in CI · P1 · S

- **Shipped:** [`package.json`](package.json) `npm run check-shell` runs `shellcheck` on every tracked `*.sh`; [`.shellcheckrc`](.shellcheckrc) pins `shell=bash`. CI step in [`.github/workflows/check.yml`](.github/workflows/check.yml). Policy: zero ShellCheck warnings (documented in [`CONTRIBUTING.md`](CONTRIBUTING.md) under **Checks**). Acceptance met.

### B-09 — `--wt-dir` vs `ensure_gitignore_worktrees` · P1 · S

- **Shipped:** Regression in [`test/bats/tack-worktree.bats`](test/bats/tack-worktree.bats) (`create --wt-dir custom-wt` → `.gitignore` contains `custom-wt/`). Naming `case` in [`skills/tack-bootstrap/template/scripts/tack-worktree.sh`](skills/tack-bootstrap/template/scripts/tack-worktree.sh) refactored for ShellCheck + clarity. Acceptance met.

### B-10 — Deterministic `splice-routing` helper · P0 · M

- **Shipped:** [`skills/tack-bootstrap/template/scripts/splice-tack-routing.sh`](skills/tack-bootstrap/template/scripts/splice-tack-routing.sh) reads a target (`AGENTS.md` / `CLAUDE.md`) plus a `routing-snippet.md` (default: sibling `../routing-snippet.md` of the script, so it works both as `${SKILL_DIR}/template/scripts/...` during bootstrap and as `project/scripts/...` after Phase 5). Algorithm: awk replaces from `## Tack routing` until the next H1/H2 (regex `^##?` plus a single space) or EOF; appends with a blank-line separator if the heading is missing. Idempotent — `--check` mode prints a diff and exits 1 only when a write would change bytes; otherwise exits 0 with `unchanged`. Wired into [`skills/tack-bootstrap/SKILL.md`](skills/tack-bootstrap/SKILL.md) Phase 5 step 3b (helper named, `--check` first, then apply on user accept) and into the **Additional resources** index. Bats coverage in [`test/bats/splice-tack-routing.bats`](test/bats/splice-tack-routing.bats) (12 cases): byte-equal no-op against both stock templates, append when heading is missing, replace mid-document with byte-for-byte preservation of the trailing section, replace as last section, `--check` exit code on drift, snippet-without-heading rejection, missing-file errors, `--help`, and H1-after-routing termination. Idempotence asserted in two tests by re-running `--check` after the first apply. ShellCheck clean.

### B-11 — Phase-5 placeholder validator for `.cursorrules` · P1 · S

- **Shipped:** Combined with **B-12** into [`skills/tack-bootstrap/template/scripts/tack-doctor.sh`](skills/tack-bootstrap/template/scripts/tack-doctor.sh). Check 1 fails when `.cursorrules` matches `<[A-Z][A-Z0-9_]*>` (i.e. `<UPPERCASE_PLACEHOLDER>` like `<TEST_COMMAND>`, `<PROJECT_NAME>`); deliberately ignores schema annotations like `<yes | no>` and `<agents | claude | both | none>` so the documentation lines in the **Auto-orchestration routing** section don't trip the check. `--rules` overrides the default path. Wired into [`skills/tack-bootstrap/SKILL.md`](skills/tack-bootstrap/SKILL.md) Phase 6 step 1a as the post-bootstrap verification gate (re-route to Phase 5 step 3 on failure). Bats coverage in [`test/bats/tack-doctor.bats`](test/bats/tack-doctor.bats): clean fixtures pass; leftover `<TEST_COMMAND>` and `<PROJECT_NAME>` each fail with cited line numbers; missing file fails with actionable message; sanity check that the stock `.cursorrules.template` still trips the regex (so the validator has bite once shipped to consumers). ShellCheck clean.

### B-12 — Validator for Specialist routing table · P1 · S

- **Shipped:** Same `tack-doctor.sh` as B-11. Check 2 fails on any `<fill>` substring in `project/prompts/auto-orchestrator.md` (covers the literal Specialist-routing table rows at [`auto-orchestrator.md:228–231`](skills/tack-bootstrap/template/prompts/auto-orchestrator.md)). `--orchestrator` overrides the default path. Phase 6 step 1a in [`skills/tack-bootstrap/SKILL.md`](skills/tack-bootstrap/SKILL.md) routes failures back to Phase 5 step 7 (Specialist routing fill-in). Documented in [`CONTRIBUTING.md`](CONTRIBUTING.md) under **Consumer-side scripts**. Bats coverage: leftover `<fill>` row fails with cited line number; sanity check that the stock template still trips the check.

### B-13 — Decouple Cursor-specific tools in auto-orchestrator · P2 · M

- **Shipped:** Added a **Platform tool mapping** preamble to [`skills/tack-bootstrap/template/prompts/auto-orchestrator.md`](skills/tack-bootstrap/template/prompts/auto-orchestrator.md) (after the Role section, before Model routing). The preamble translates Cursor names — `Task`, `subagent_type: generalPurpose`, `working_directory`, `AskQuestion`, `model` — to **Claude Code** (`Agent`, `subagent_type: general-purpose`, `cwd`, `AskUserQuestion`) and to a **generic / Copilot CLI / Codex / Antigravity** column (post the question in chat, prepend `cd <worktree_path>` to the dispatched prompt when no `cwd` parameter exists). Calls out the `AskQuestion` ↔ `AskUserQuestion` swap as the only contract change downstream prompts care about, and points hosts without subagent dispatch at `@orchestrator.md` as a fallback. Brief cross-references added to [`skills/tack-run/SKILL.md`](skills/tack-run/SKILL.md) (rule 8) and [`skills/tack-agent/SKILL.md`](skills/tack-agent/SKILL.md) (rule 9) so dispatcher skills surface the mapping at the entry point. Public-facing summary added to [`README.md`](README.md) under **Multi-platform agent support** as the requested README table.

### B-28 — Contract tests for `tack-run` / `tack-agent` against bundled prompts · P1 · M

- **Shipped:** [`scripts/check-dispatch-contract.sh`](scripts/check-dispatch-contract.sh) (`npm run check-dispatch`) verifies stock prompts in [`skills/tack-agent/references/agent-catalog.md`](skills/tack-agent/references/agent-catalog.md) exist under [`skills/tack-bootstrap/template/prompts/`](skills/tack-bootstrap/template/prompts/), and that model-routing tables + Step→model bullets align across [`skills/tack-run/references/pipeline-state-machine.md`](skills/tack-run/references/pipeline-state-machine.md) and [`skills/tack-bootstrap/template/prompts/auto-orchestrator.md`](skills/tack-bootstrap/template/prompts/auto-orchestrator.md) (including **Step 7b**). [`test/bats/check-dispatch-contract.bats`](test/bats/check-dispatch-contract.bats) smoke + drift fixture (`TACK_DISPATCH_CONTRACT_ROOT`). CI in [`.github/workflows/check.yml`](.github/workflows/check.yml). Acceptance met.

### B-27 — `validate-skill-frontmatter.sh` covers all canonical SKILLs · P1 · S

- **Shipped:** [`scripts/validate-skill-frontmatter.sh`](scripts/validate-skill-frontmatter.sh) globs `skills/*/SKILL.md` (so `tack-bootstrap`, `tack-run`, and `tack-agent` are all checked) and enforces `name`, `description`, the `Use when` substring, and `version` equality with [`package.json`](package.json). Bundled copies under `skills/tack-bootstrap/template/skills/*/SKILL.md` are not iterated directly — they are kept byte-equal to canonical by **B-26**, so frontmatter is implicitly covered.

### B-25 — `sync-skills.sh` / `check-skills-sync.sh` cover all canonical skills · P0 · S

- **Shipped:** [`scripts/sync-skills.sh`](scripts/sync-skills.sh) and [`scripts/check-skills-sync.sh`](scripts/check-skills-sync.sh) now auto-discover every `skills/*/SKILL.md` (so `tack-bootstrap`, `tack-run`, and `tack-agent` are all covered without an explicit list) and (sync) `cp -R` / (check) `diff -rq` against the three editor mirrors `.claude/skills/<name>/`, `.cursor/skills/<name>/`, `.agents/skills/<name>/`. A deliberate edit to any canonical SKILL without `npm run sync` causes `npm run check-sync` (and CI [`.github/workflows/check.yml:19`](.github/workflows/check.yml), via the existing `npm run check-sync` step) to fail with a `diff -ru` excerpt and a `run from repo root: npm run sync` pointer. Verified by drift probe (`printf '\n# DRIFT_PROBE\n' >> skills/tack-run/SKILL.md` → check-sync exits 1; isolated mirror drift on `.claude/skills/tack-run/SKILL.md` → check-sync exits 1 pointing at the mirror; restore + `npm run sync` → byte-equal). Acceptance fully met.

### B-26 — Bundled bootstrap install source kept byte-equal to canonical · P0 · S

- **Shipped:** [`scripts/sync-skills.sh`](scripts/sync-skills.sh) Phase A auto-discovers any `skills/tack-bootstrap/template/skills/*/SKILL.md` (today `tack-run`, `tack-agent`) and `cp -R` from canonical `skills/<name>/` **before** the editor-mirror loop, so a fix to canonical reaches bootstrapped consumers via [`skills/tack-bootstrap/SKILL.md`](skills/tack-bootstrap/SKILL.md) Phase 5 step **1a** (lines 272–281). [`scripts/check-skills-sync.sh`](scripts/check-skills-sync.sh) Phase A runs `diff -rq skills/<name> skills/tack-bootstrap/template/skills/<name>` and fails on any divergence (verified: `printf '\n# DRIFT_PROBE\n' >> skills/tack-run/SKILL.md` → `bundled drift detected for skills/tack-bootstrap/template/skills/tack-run`). Documented in [`CONTRIBUTING.md`](CONTRIBUTING.md) under "After you change the skill". Acceptance fully met.

---

## How to use this backlog

### Workflow

1. Pick a row; open a PR referencing `BACKLOG.md#b-NN` (or a future `S-XXX`).
2. After implementing, move the item to the **Done** subsection (preferred — preserves a citable evidence link) or delete it; keep this file the single source of pending work, or migrate to GitHub Issues with labels `P0` / `P1` / `P2`.

### Conventions (IDs, priority, effort)

- Use **`B-NN`** headings that stay unique across **pending** and **Done**; pick the next free number (e.g. **B-31** after **B-30**).
- **Priority** and **effort** follow the **Legend** at the top of this file: **P0** / **P1** / **P2** and **S** / **M** / **L**.
- Place each item under the correct **theme** section (Themes 2–7). Match the bullet shape used by pending items such as **B-14**–**B-24** and **B-29**–**B-30**:
  - `### B-NN — Short title`
  - `- **Priority:** P? · **Effort:** S|M|L`
  - `- **Rationale:**` … (link to paths in-repo where it helps)
  - `- **Acceptance:**` … (testable outcome)

### Adding items

1. Add the entry under the right theme.
2. **Update the summary table** ([Summary by theme and priority](#summary-by-theme-and-priority-pending)): adjust the **P0** / **P1** / **P2** counts for that theme row and the **Total** row when you add, remove, or change priority.
3. Optionally extend the **Last refresh** blockquote under the table when you batch-change or ship multiple items.

### Changing items

1. Edit **priority** or **effort** as needed; if the **P** tier changes, fix the **summary table** counts.
2. Refine **Rationale** and **Acceptance** when scope becomes clearer.
3. When an item ships, move it to **[Done](#done)** using the same style as **B-01** onward: title line includes priority and effort; **Shipped:** points to files and states how acceptance was met. Increment **Done so far:** and append the **B-NN** id on the “Done so far” line. Items stay in **Done** for citable evidence until **B-22** (CHANGELOG) lands and you prune or migrate.

### Caveats

- Listing work here does **not** create GitHub issues or **S-XXX** specs automatically — promotion is intentional.
- Renumbering items or reshuffling themes breaks **`#b-NN`** anchors in PRs; prefer new **B-NN** ids over renumbering old ones.
