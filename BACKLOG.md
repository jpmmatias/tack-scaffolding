# Tack — project improvements backlog

Prioritized improvement opportunities for this repository (canonical skill at [`skills/tack-bootstrap/`](skills/tack-bootstrap/), mirrors under `.claude/`, `.cursor/`, `.agents/`). Each item can later be promoted to a Tack `S-XXX` spec stub.

**Legend:** **P0** = blocking quality / drift risk; **P1** = high value; **P2** = nice-to-have. **S/M/L** = small / medium / large effort.

## Summary by theme and priority

| Theme | P0 | P1 | P2 | Total |
|-------|----|----|----|-------|
| 1. Authoring & DX | 2 | 2 | 0 | 4 |
| 2. Script hardening & tests | 2 | 3 | 0 | 5 |
| 3. Skill correctness & safeguards | 1 | 2 | 1 | 4 |
| 4. Template content & onboarding | 0 | 2 | 2 | 4 |
| 5. Tooling / CLI | 0 | 1 | 1 | 2 |
| 6. Repo hygiene | 1 | 1 | 1 | 3 |
| 7. Worktree polish | 0 | 0 | 2 | 2 |
| **Total** | **6** | **11** | **7** | **24** |

---

## Theme 1 — Authoring & DX

### B-01 — CI guard: routing snippet matches AGENTS/CLAUDE templates

- **Priority:** P0 · **Effort:** S
- **Rationale:** [`skills/tack-bootstrap/SKILL.md`](skills/tack-bootstrap/SKILL.md) rule 12 (line 33) states `template/routing-snippet.md` is the single source for the `## Tack routing` H2, yet the same block is duplicated in [`skills/tack-bootstrap/template/AGENTS.md.template`](skills/tack-bootstrap/template/AGENTS.md.template) (lines 13–21) and [`skills/tack-bootstrap/template/CLAUDE.md.template`](skills/tack-bootstrap/template/CLAUDE.md.template) (lines 13–21). They match today; CI does not enforce equality.
- **Acceptance:** A script or CI step fails when `routing-snippet.md` content (from `## Tack routing` through end of section) differs from the corresponding H2 in both templates after `npm run sync`.

### B-02 — Pre-commit / pre-push: sync + check-sync

- **Priority:** P0 · **Effort:** S
- **Rationale:** [`CONTRIBUTING.md`](CONTRIBUTING.md) requires `npm run sync` after editing canonical; drift is only caught in [`.github/workflows/check.yml`](.github/workflows/check.yml) on push/PR. Local hooks reduce failed CI from forgotten mirrors.
- **Acceptance:** Husky or simple `.git/hooks`-documented script runs `npm run sync` and `npm run check-sync` (or at least `check-sync`) before push; documented in CONTRIBUTING.

### B-03 — Single source of version truth

- **Priority:** P1 · **Effort:** S
- **Rationale:** [`package.json`](package.json) (`version`) and [`skills/tack-bootstrap/SKILL.md`](skills/tack-bootstrap/SKILL.md) YAML frontmatter (`version`, lines 1–6) can diverge.
- **Acceptance:** One field is canonical; the other is generated or validated equal in [`scripts/validate-skill-frontmatter.sh`](scripts/validate-skill-frontmatter.sh) (or `npm run validate-skill`).

### B-04 — Markdown linter + link checker in CI

- **Priority:** P1 · **Effort:** M
- **Rationale:** Many markdown files and relative links across canonical + three mirrors; broken links are easy to miss.
- **Acceptance:** CI job runs markdown lint (e.g. `markdownlint-cli2`) and link check (e.g. `lychee`) on `skills/tack-bootstrap/**` and root docs; failures block merge.

---

## Theme 2 — Script hardening & tests

### B-05 — Bats tests for `detect-stack.sh`

- **Priority:** P0 · **Effort:** M
- **Rationale:** [`skills/tack-bootstrap/scripts/detect-stack.sh`](skills/tack-bootstrap/scripts/detect-stack.sh) encodes nine ecosystem branches (Node/TS, Python pyproject/setup/requirements, Rust, Go, Ruby, Maven, Gradle, PHP) and `project_class` (lines 293–298). No automated regression coverage.
- **Acceptance:** Bats suite with ephemeral fixture repos exercises each branch and at least one `project_class: new` vs `existing` case; runs in CI.

### B-06 — Bats tests for `tack-worktree.sh`

- **Priority:** P0 · **Effort:** M
- **Rationale:** [`skills/tack-bootstrap/template/scripts/tack-worktree.sh`](skills/tack-bootstrap/template/scripts/tack-worktree.sh) implements spec id reservation, create/list/path/remove, JSON output, and merge gates (`cmd_remove`, lines 179–226).
- **Acceptance:** Bats tests in a throwaway git repo cover `sanitize_slug`, `next_spec_id` across linked worktrees, JSON shape, `remove` refusing dirty/unmerged (without `--force`), and `--wt-dir` behavior.

### B-07 — Bats test for `recon.sh` layer patterns

- **Priority:** P1 · **Effort:** S
- **Rationale:** [`skills/tack-bootstrap/scripts/recon.sh`](skills/tack-bootstrap/scripts/recon.sh) buckets files via `LAYER1_PATTERN`–`LAYER6_PATTERN` (lines 102–130) and truncation flags.
- **Acceptance:** One fixture tree with known paths; assert each layer receives expected members and `truncated` reflects cap behavior.

### B-08 — `shellcheck` in CI

- **Priority:** P1 · **Effort:** S
- **Rationale:** Bash scripts under [`scripts/`](scripts/) and [`skills/tack-bootstrap/scripts/`](skills/tack-bootstrap/scripts/) plus [`skills/tack-bootstrap/template/scripts/`](skills/tack-bootstrap/template/scripts/) lack static analysis gate.
- **Acceptance:** CI runs `shellcheck` on all `*.sh`; warnings/errors policy documented (e.g. zero warnings).

### B-09 — Fix `--wt-dir` vs `ensure_gitignore_worktrees`

- **Priority:** P1 · **Effort:** S
- **Rationale:** `ensure_gitignore_worktrees` uses `WT_DIR_DEFAULT` for the ignore line ([`tack-worktree.sh:103–111`](skills/tack-bootstrap/template/scripts/tack-worktree.sh)); `cmd_create` can override `--wt-dir` later (lines 248–250, 288). Risk of appending wrong path to `.gitignore` if ordering/defaults differ.
- **Acceptance:** After `create` with custom `--wt-dir`, `.gitignore` contains that directory (or documented explicit non-append); regression test added.

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

## How to use this backlog

1. Pick a row; open a PR referencing `BACKLOG.md#b-NN` (or a future `S-XXX`).
2. After implementing, move the item to a **Done** subsection or delete it—keep this file the single source of pending work, or migrate to GitHub Issues with labels `P0` / `P1` / `P2`.
