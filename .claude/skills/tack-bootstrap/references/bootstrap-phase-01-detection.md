# Phase 1 — Detect context

Before asking the user anything, gather facts.

1. List the repo root and look for: `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Gemfile`, `pom.xml`, `build.gradle`, `composer.json`, `Dockerfile`, `docker-compose.yml`, `.github/`, `infra/`, `migrations/`, `prisma/`, `app/`, `src/`, `tests/`, `e2e/`, `project/` (the template).
2. Read the main manifest. Infer language, framework, test runner, linter, build scripts, package manager.
3. Count non-empty source files, excluding `node_modules`, `vendor`, `.venv`, `dist`, `build`, `.git`, `coverage`, `.next`, `.turbo`, `target`.
4. Run `bash "${SKILL_DIR}/scripts/detect-stack.sh"` from the **consumer repository root** if the script exists — it outputs a JSON summary. Treat its output as a hint, not ground truth.
5. **DDD signal scan.** Independently of the stack script, look for code-level signals that suggest the team is already practicing DDD. Use these to **suggest** (not force) the DDD profile default:
   - Directory names anywhere under the source tree: `domain/`, `aggregates/`, `value-objects/`, `events/`, `bounded-contexts/`, `contexts/`, multi-module layouts where each top-level folder looks like a self-contained service (its own `domain/` + `application/` + `infra/`).
   - Class / type name suffixes occurring 3+ times: `*Aggregate`, `*AggregateRoot`, `*ValueObject`, `*DomainEvent`, `*Event` paired with `*Handler`, `Anticorruption*`, `*Acl` / `*ACL` adapter classes.
   - Documentation traces: existing mentions of "bounded context", "ubiquitous language", "aggregate root", "domain event", "anticorruption" in `README.md`, `docs/`, ADRs, or `CONTRIBUTING.md`.
   - Default mapping: **two or more** distinct signals → suggest **`tack.ddd.profile = on`**; one or zero → suggest **`off`**. Always cite the matching `file:line` (or directory path) when suggesting **on**.
6. **Classify the project**:
   - **NEW** — no source code beyond scaffolding (manifests, configs, README, possibly a single `index` or `main` file). Skip Phase 2, jump to Phase 3.
   - **EXISTING** — real source code present. Phase 2 is **mandatory**.

Then present a **detection summary** and ask the user to confirm or correct it. Use this exact structure:

```text
## Detection summary

- Repo root: <abs path>
- Project class: NEW | EXISTING
- Language(s): ...
- Framework(s): ...
- Test runner: ...        ($TEST_COMMAND candidate: ...)
- Linter: ...             ($LINT_COMMAND candidate: ...)
- Typecheck: ...          ($TYPECHECK_COMMAND candidate: ...)
- Build: ...              ($BUILD_COMMAND candidate: ...)
- Package manager: ...
- Non-empty source files: N (capped if > some threshold)
- Notable directories: src/, app/, tests/, infra/, migrations/, ...
- Template location: project/ (assumed; correct me if you copied it elsewhere)
- Agent surfaces detected (for skill install targets only — **not** for separate repo-root Tack files):
    Claude Code   : .claude/                  present | absent
    Cursor        : TACK.md / .cursor/      present | absent
    Copilot CLI   : .github/copilot-cli/ / .copilot/      present | absent
    Codex         : .codex/                               present | absent
    Antigravity   : .antigravity/                         present | absent
    Generic AGENTS.md (multi-agent)                       present | absent
- Suggested `tack.agents.active`: <subset of {claude-code, cursor, copilot, codex, antigravity} matching the rows above; if zero rows match, suggest `claude-code` as the default — never empty>.
  Reasoning (one line): <e.g. ".claude/ and .cursor/ both present" or "no agent markers detected — defaulting claude-code">
- Routing default: `tack.routing.auto = yes` — persist in **`TACK.md`** (see **Auto-orchestration routing**). IDE-agnostic Tack config is **`TACK.md` only** at repo root.
- DDD profile (suggested): tack.ddd.profile = on | off
    Signals matched: <list of file:line / directory citations or "none">
    Reasoning (one line): <e.g. "two DDD folder names + Aggregate suffix in 4 classes" or "no DDD signals detected — defaulting off">

Confirm or correct any field above before I proceed. **In particular, confirm or correct `tack.agents.active`** — list every AI coding agent you actively use in this repo, drawn from {`claude-code`, `cursor`, `copilot`, `codex`, `antigravity`}. If you use only one, say so explicitly. I will only install **`tack-run`** / **`tack-agent`** skills under `.claude/skills/`, `.cursor/skills/`, and `.agents/skills/` for the agents you confirm — a leftover directory does not authorize scaffolding. **Repo-root `TACK.md`** is written for every bootstrap regardless of IDE (routing and SDD entry points live there — not in `AGENTS.md` / `CLAUDE.md` / `.cursorrules`). Reply with corrections, or "correct" to accept.
```

Do not advance until the user confirms or corrects. If they correct any field, restate the summary and ask again. Treat **`tack.ddd.profile`** and **`tack.agents.active`** as first-class outputs of Phase 1: persist them in your working memory and thread them through every subsequent phase. Phase 2 / 3 / 5 conditional steps below reference these flags explicitly. **`tack.agents.active` must be non-empty** — if the user insists on no agents, stop and explain that scaffolding without a target agent is not supported.
