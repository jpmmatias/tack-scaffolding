# Contributing

Issue and PR templates live under [`.github/`](.github/). Report security issues privately per [`SECURITY.md`](SECURITY.md). Community expectations are in [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).

## Maintainer notes (GitHub template)

For the lowest-friction **Use this template** experience documented in [`README.md`](README.md):

1. In the GitHub repo → **Settings** → **General**.
2. Under **Template repository**, enable **Template repository** so GitHub shows the green template button and supports `gh repo create … --template <owner>/<repo>`.

That setting is unrelated to listing on [skills.sh](https://skills.sh/); it only affects starting new repos from this scaffold.

## Canonical skill location

Edit **only** the canonical skill trees under [`skills/`](skills/) — today [`skills/tack-bootstrap/`](skills/tack-bootstrap/), [`skills/tack-run/`](skills/tack-run/), and [`skills/tack-agent/`](skills/tack-agent/). Those directories are the single source of truth (the `tack-bootstrap` canonical includes its bundled template under `skills/tack-bootstrap/template/`, except for `skills/tack-bootstrap/template/skills/`, which is regenerated from the dispatcher canonicals — see below).

Behavioral evals for the Anthropic **skill-creator** plugin live beside each skill as [`skills/<name>/evals/evals.json`](skills/tack-run/evals/evals.json). Install workflow, Eval/Improve/Benchmark notes, and line-budget guidance: [`skills/README.md`](skills/README.md).

## After you change the skill

From the repository root:

```bash
npm run sync
```

For each canonical `skills/<name>/`, this:

- copies it into the editor mirrors `.claude/skills/<name>/` (Claude Code), `.cursor/skills/<name>/` (Cursor), and `.agents/skills/<name>/` (Antigravity workspace skills) — auto-discovered from `skills/*/SKILL.md`, so adding a new canonical skill is automatically picked up;
- and, for the dispatcher skills bundled with bootstrap (today `tack-run` and `tack-agent`), also copies it into `skills/tack-bootstrap/template/skills/<name>/` so the bootstrap install source stays byte-equal to canonical.

Commit the canonical tree, the bundled copies, and the editor mirrors so CI stays green (`npm run check-sync` enforces both layers).

## Commit messages

Prefer [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) so history stays grep-friendly and [`CHANGELOG.md`](CHANGELOG.md) stays easy to maintain:

- **`feat:`** — user-visible behavior or new capability.
- **`fix:`** — bug fix or regression repair.
- **`docs:`** — documentation and prompt copy only.
- **`chore:`** — tooling, CI, sync mirrors, formatting without behavior change.

Optional scope in parentheses is welcome (e.g. `feat(tack-worktree): add --dry-run`). Combine with the Spec traceability called out in [`README.md`](README.md) when the change maps to an `S-XXX` / `AC-N` (e.g. trailer `Closes: S-001#AC-1`).

## Checks

```bash
npm run check-sync    # mirrors must match canonical
npm run validate-skill  # SKILL.md frontmatter (all skills/*/SKILL.md; version matches package.json; Use when, Triggers, line budget)
npm run validate-skill-evals  # evals/evals.json shape and skill_name match per skill
npm run check-routing   # routing-snippet.md matches templates + worked examples
npm test                # Bats: detect-stack, tack-worktree, recon, splice-tack-routing, tack-doctor, dispatch contract smoke (install bats-core: brew install bats-core / apt install bats)
npm run check-shell     # shellcheck on every tracked *.sh (install: brew install shellcheck); CI policy is **zero warnings** (see [.shellcheckrc](.shellcheckrc))
npm run check-dispatch  # agent-catalog → template prompts; pipeline vs auto-orchestrator model tables
npm run lint            # optional: markdownlint-cli2 (canonical skills + root *.md)
npm run check-links     # optional: lychee offline link check (downloads a pinned lychee binary on first run on Apple silicon / Linux; Intel macOS: brew install lychee)
```

## Consumer-side scripts (template/scripts/)

Two helpers ship inside `skills/tack-bootstrap/template/scripts/` and are copied to a consumer's `project/scripts/` during Phase 5. They are validated by Bats and `shellcheck` here, but are intended to be run **from a bootstrapped repo's root**, not from this scaffold:

- `splice-tack-routing.sh` — deterministic `## Tack routing` H2 splice into `AGENTS.md` / `CLAUDE.md` from `project/routing-snippet.md`. Idempotent; supports `--check` for CI / preview. Used by `tack-bootstrap` Phase 5 step 3b and re-runnable when `routing-snippet.md` upgrades.
- `tack-doctor.sh` — post-bootstrap validator for **`TACK.md`** (or `--rules`; falls back to legacy **`.cursorrules`**): no `<UPPERCASE>` placeholders, `project/prompts/auto-orchestrator.md` has no `<fill>` Specialist routing rows. Run by `tack-bootstrap` Phase 6 step 1a; consumers can wire into their own CI as `bash project/scripts/tack-doctor.sh`.

## Local hooks (optional)

After clone, run once:

```bash
npm run install-hooks
```

That sets `git config core.hooksPath .githooks`. On `git push`, `pre-push` runs `check-sync`, `validate-skill`, and `check-routing` (not `sync` — if mirrors are stale, run `npm run sync` and commit). The hook skips when `.git` is not writable.
