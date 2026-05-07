# Tack — project improvements backlog

Prioritized improvement opportunities for this repository (canonical skill at [`skills/tack-bootstrap/`](skills/tack-bootstrap/), mirrors under `.claude/`, `.cursor/`, `.agents/`). Each item can later be promoted to a Tack `S-XXX` spec stub.

**Legend:** **P0** = blocking quality / drift risk; **P1** = high value; **P2** = nice-to-have. **S/M/L** = small / medium / large effort.

## Summary by theme and priority (pending)

| Theme | P0 | P1 | P2 | Total |
|-------|----|----|----|-------|
| 2. Script hardening & tests | 0 | 0 | 0 | 0 |
| 3. Skill correctness & safeguards | 1 | 2 | 1 | 4 |
| 4. Template content & onboarding | 0 | 2 | 2 | 4 |
| 5. Tooling / CLI | 0 | 1 | 1 | 2 |
| 6. Repo hygiene | 1 | 1 | 1 | 3 |
| 7. Worktree polish | 0 | 0 | 2 | 2 |
| **Total** | **2** | **6** | **7** | **15** |

Done so far: **13** (B-01, B-02, B-03, B-04, B-05, B-06, B-07, B-08, B-09, B-25, B-26, B-27, B-28 — see [Done](#done)).

> **Last refresh:** Theme 2 (**B-05**–**B-09**, **B-28**) moved to **Done**: Bats coverage for `detect-stack.sh`, `tack-worktree.sh`, and `recon.sh`; `shellcheck` + dispatch contract in CI; `recon.sh` truncation flags fixed (subshell bug); `auto-orchestrator` / `pipeline-state-machine` Step→model parity; `package.json` **0.2.0**.

## Theme 2 — Script hardening & tests

*(No pending items — shipped entries are in [Done](#done).)*

---

## Theme 3 — Skill correctness & safeguards

### B-10 — Deterministic `splice-routing` helper

- **Priority:** P0 · **Effort:** M
- **Rationale:** Phase 5 in [`skills/tack-bootstrap/SKILL.md`](skills/tack-bootstrap/SKILL.md) (step 3b, lines 274–278) requires replacing only `## Tack routing` in `AGENTS.md`/`CLAUDE.md`; today this relies on agent behavior. [`references/file-templates/agents-routing.md`](skills/tack-bootstrap/references/file-templates/agents-routing.md) documents idempotency but provides no executable tool.
- **Acceptance:** Script (e.g. `scripts/splice-tack-routing.sh`) reads consumer file + `routing-snippet.md`, replaces or appends the H2 deterministically, exits 0 on no-op when unchanged; documented for bootstrap or contributors.

### B-11 — Phase-5 placeholder validator for `.cursorrules`

- **Priority:** P1 · **Effort:** S
- **Rationale:** SKILL behavior rule 3 ([`SKILL.md:24`](skills/tack-bootstrap/SKILL.md)) forbids invented placeholders; generated `.cursorrules` from [`.cursorrules.template`](skills/tack-bootstrap/template/.cursorrules.template) can still ship with `<PLACEHOLDER>` if validation is skipped.
- **Acceptance:** Validator script or checklist step fails on `<...>` patterns in `.cursorrules` at consumer root; optional integration into `npm run` scripts.

### B-12 — Validator for Specialist routing table

- **Priority:** P1 · **Effort:** S
- **Rationale:** Template still contains literal `<fill>` rows ([`auto-orchestrator.md:207–210`](skills/tack-bootstrap/template/prompts/auto-orchestrator.md)).
- **Acceptance:** CI or `doctor` command fails if `project/prompts/auto-orchestrator.md` (or template) contains `<fill>` after bootstrap; or document grep in CONTRIBUTING.

### B-13 — Decouple Cursor-specific tools in auto-orchestrator

- **Priority:** P2 · **Effort:** M
- **Rationale:** [`auto-orchestrator.md`](skills/tack-bootstrap/template/prompts/auto-orchestrator.md) names Cursor `Task`, `AskQuestion`, `working_directory`, `subagent_type: generalPurpose` (e.g. lines 30–31, 75–82, 121–124). Other agents use different dispatch APIs.
- **Acceptance:** Additional prompt variant(s) (e.g. Claude-oriented) or a preamble that maps tool names per platform; README table of which file to use where.

---

## Theme 4 — Template content & onboarding UX

### B-14 — End-to-end OrderFlow demo

- **Priority:** P1 · **Effort:** M
- **Rationale:** [`skills/tack-bootstrap/template/examples/`](skills/tack-bootstrap/template/examples/) provides isolated examples (spec, plan, ADR, etc.) but not a full traced run from PM through reviewer.
- **Acceptance:** Branch or `examples/orderflow-full/` with coherent `S-001` spec, `plan.md`, task files, and sample test names matching `S-001 AC-N`; README walkthrough.

### B-15 — Mermaid pipeline in root README

- **Priority:** P1 · **Effort:** S
- **Rationale:** Diagram exists in [`skills/tack-bootstrap/template/docs/sdd.md`](skills/tack-bootstrap/template/docs/sdd.md) (lines 19–33) but [`README.md`](README.md) does not surface it for GitHub visitors.
- **Acceptance:** README section with the same (or simplified) mermaid flowchart linking to SDD doc.

### B-16 — FAQ + Troubleshooting

- **Priority:** P2 · **Effort:** S
- **Rationale:** Common failures: mirror drift, `git worktree add` sandbox/permissions, Phase 2 skipped, empty specialist routing, model unavailable ([`auto-orchestrator.md`](skills/tack-bootstrap/template/prompts/auto-orchestrator.md) stop conditions).
- **Acceptance:** `docs/FAQ.md` or README subsection with indexed symptoms → fixes.

### B-17 — Portuguese README

- **Priority:** P2 · **Effort:** M
- **Rationale:** SKILL rule 1 ([`SKILL.md:22`](skills/tack-bootstrap/SKILL.md)) supports PT/EN; public docs are English-only.
- **Acceptance:** `README.pt-BR.md` mirroring install and conventions; link from main README.

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

1. Pick a row; open a PR referencing `BACKLOG.md#b-NN` (or a future `S-XXX`).
2. After implementing, move the item to the **Done** subsection (preferred — preserves a citable evidence link) or delete it; keep this file the single source of pending work, or migrate to GitHub Issues with labels `P0` / `P1` / `P2`.
