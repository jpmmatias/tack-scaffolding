# Tack

> Discipline scaffolding for multi-agent coding.

Portable **spec-driven development** (SDD) and **isolated role prompts** for coding agents: numbered specs (`S-XXX`), acceptance criteria (`AC-N`), plans with traceability, ADRs (`ADR-NNNN`), strict TDD gates, and optional full-auto orchestration via subagents.

The **machine-runnable bootstrap** is the agent skill **`tack-bootstrap`**, which interviews you, mines business rules from existing code when needed, and materializes governance docs under `project/` in your repository.

## Install the skill

### 1. Recommended — `npx skills` (skills.sh)

Works with **Claude Code, Cursor, Google Antigravity, GitHub Copilot, and 50+ other agents** — the CLI installs into each tool’s expected path.

```bash
cd /path/to/your/repo
npx skills add <github-owner>/<github-repo>
# explicit skill name (optional):
npx skills add <github-owner>/<github-repo> --skill tack-bootstrap
```

After install, open your agent and invoke the **tack-bootstrap** skill (or describe bootstrapping SDD / filling `.cursorrules` and `project/docs/`). The skill copies the bundled template into `project/` and walks the six-phase flow described in `skills/tack-bootstrap/SKILL.md`.

Browse more skills at [skills.sh](https://skills.sh/).

### 2. Manual — copy the skill folder

Copy `skills/tack-bootstrap/` into your editor’s skills directory, for example:

| Agent / editor        | Typical path |
|----------------------|--------------|
| Claude Code          | `.claude/skills/tack-bootstrap/` |
| Cursor               | `.cursor/skills/tack-bootstrap/` |
| Antigravity (project)| `.agents/skills/tack-bootstrap/` |

Each folder should contain `SKILL.md`, `references/`, `scripts/`, and `template/`.

### 3. Working on this repository (contributors)

The **canonical** skill lives only at [`skills/tack-bootstrap/`](skills/tack-bootstrap/). Mirrored copies under `.claude/skills/`, `.cursor/skills/`, and `.agents/skills/` are generated — do not edit those by hand.

```bash
npm run sync        # refresh mirrors after editing skills/tack-bootstrap/
npm run check-sync  # verify mirrors match canonical (also run in CI)
```

See [CONTRIBUTING.md](CONTRIBUTING.md).

## What’s in the bundled template

After the skill runs Phase 5, your consumer repo has under `project/`:

| Path | Purpose |
|------|---------|
| `project/.cursorrules.template` | Rename to `.cursorrules` at **repo root** (or generate `.cursorrules` directly during bootstrap). |
| `project/docs/sdd.md` | SDD lifecycle, 7-step pipeline, and **Parallel features** (`git worktree`). |
| `project/scripts/tack-worktree.sh` | Helper to create/list/remove linked worktrees + reserve `S-XXX` across branches (`.cursorrules`: `tack.worktree.*`). |
| `project/scripts/splice-tack-routing.sh` | Deterministic helper used by Phase 5 (and re-runnable by you) to splice `## Tack routing` into `AGENTS.md` / `CLAUDE.md`; idempotent, with `--check` mode for CI. |
| `project/scripts/tack-doctor.sh` | Post-bootstrap validator (Phase 6 step 1a): fails on leftover `<UPPERCASE>` placeholders in `.cursorrules` and `<fill>` rows in `auto-orchestrator.md`. |
| `project/docs/harness-engineering.md` | Guides vs sensors, steering loop. |
| `project/docs/test-harness.md` | Test harness intent and boundary doubles. |
| `project/docs/domain-glossary.md` | Skeleton glossary — **must** be filled for your domain. |
| `project/docs/architecture.md` | Canonical architecture doc placeholder. |
| `project/docs/adr/_template.md` | ADR template. |
| `project/prompts/*.md` | Role prompts: PM, architect, QA, harness engineer, worker, reviewer, security, orchestrators. |
| `project/prompts/_specialist-template.md` | Duplicate for stack-specific roles. |
| `project/specs/_template.md` | Product spec template. |
| `project/examples/` | Fictitious **OrderFlow** examples. |

`AGENTS.md` at this repo’s root is a lightweight router for tools that support it; see [`AGENTS.md`](AGENTS.md).

## Listing on skills.sh

This repo follows the multi-skill layout (`skills/<name>/SKILL.md`) expected by the [Vercel skills CLI](https://vercel.com/docs/agent-resources/skills). To appear in the public directory, submit or update metadata via the process described on [skills.sh](https://skills.sh/) (community registry).

## Multi-platform agent support

Tack ships one canonical `auto-orchestrator.md` written with **Cursor** tool names (`Task`, `AskQuestion`, `working_directory`, `subagent_type: generalPurpose`). It also carries a **Platform tool mapping** preamble translating those names to **Claude Code**, **Copilot CLI**, **Codex**, and **Antigravity**, so the same prompt drives any subagent-capable host.

| Concept | Cursor | Claude Code | Other / generic |
|---------|--------|-------------|-----------------|
| Dispatch a subagent | `Task` | `Agent` (a.k.a. `Task` in older builds) | host-specific subagent primitive |
| Subagent type | `subagent_type: generalPurpose` | `subagent_type: general-purpose` | omit when unsupported |
| Pinned working dir | `working_directory` | `cwd` (or `cd <path> && …` in the prompt) | host-specific; otherwise prepend `cd <worktree_path>` |
| Ask the human | `AskQuestion` | `AskUserQuestion` | post the question in chat verbatim |

The bundled `tack-run` / `tack-agent` skills do this translation when called via the host's skill system (Claude Code, Cursor, Antigravity). For details see [`skills/tack-bootstrap/template/prompts/auto-orchestrator.md`](skills/tack-bootstrap/template/prompts/auto-orchestrator.md) → **Platform tool mapping**.

## Conventions (summary)

- **Specs:** `S-001`, `S-002`, … — files `project/specs/S-XXX-<slug>.md`.
- **ACs:** `AC-1`, `AC-2`, … in Gherkin inside the spec.
- **Plans:** `plan.md` with first line `Spec: S-XXX` and a `## Traceability` table (tasks ↔ ACs).
- **ADRs:** `ADR-0001`, … — files under `project/docs/adr/`.
- **Commits / PRs:** cite `S-XXX` and closed `AC-N` where applicable (e.g. `Closes: S-001#AC-1`).

## References

- [Harness engineering for coding agent users](https://martinfowler.com/articles/harness-engineering.html) (Böckeler, martinfowler.com)

## License

MIT — see [LICENSE](LICENSE).
