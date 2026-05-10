# Tack — FAQ and troubleshooting

Symptom-oriented fixes for **this repository** (`tack-scaffolding`) and for **repos where you already ran `tack-bootstrap`**.

## Contents

- [Skill and template mirror drift](#skill-and-template-mirror-drift)
- [`git worktree` / coordinator errors during `tack-run`](#git-worktree--coordinator-errors-during-tack-run)
- [Bootstrap Phase 2 skipped, stuck, or won't advance](#bootstrap-phase-2-skipped-stuck-or-wont-advance)
- [`tack-doctor` fails or orchestrator can't pick a specialist](#tack-doctor-fails-or-orchestrator-cant-pick-a-specialist)
- [Pipeline stops: "Model unavailable"](#pipeline-stops-model-unavailable)
- [Pipeline stops: "STOPPED at Step N" (general)](#pipeline-stops-stopped-at-step-n-general)

---

## Skill and template mirror drift

**Symptoms**

- Editor skill folders (e.g. `.claude/skills/`, `.cursor/skills/`) don’t match what you see under [`skills/`](../skills/) in this repo.
- CI or `npm run check-sync` reports drift.
- After pulling upstream Tack, your **consumer** repo still has old skill copies.

**Why**

- In **tack-scaffolding**, canonical skills live under [`skills/`](../skills/); mirrors are generated and must stay byte-equal (see [CONTRIBUTING.md](../CONTRIBUTING.md)).
- In a **bootstrapped** repo, skills were copied or installed once; they do not auto-update when the upstream template changes.

**What to do**

- **Maintainers (this repo):** from the repo root run `npm run sync`, then commit. Verify with `npm run check-sync`. Details: [Contributing — After you change the skill](../CONTRIBUTING.md#after-you-change-the-skill).
- **Consumers:** refresh skills with `npx skills add jpmmatias/tack-scaffolding` (or copy [`skills/tack-bootstrap/`](../skills/tack-bootstrap/) manually into the paths your editor uses — see [README — Quick start](../README.md#quick-start)).

---

## `git worktree` / coordinator errors during `tack-run`

**Symptoms**

- `tack-worktree.sh` or the worktree coordinator returns an error; orchestrator reports **STOPPED** after Step −1.
- Sandboxed agent environment blocks `git worktree add`, filesystem permissions, or writing under `.worktrees/`.

**Why**

- Isolated runs depend on **Step −1** (`@worktree-coordinator.md`) succeeding; failure is a stop condition when you cannot fall back. See **Stop conditions** item 13 in [`auto-orchestrator.md`](../skills/tack-bootstrap/template/prompts/auto-orchestrator.md).

**What to do**

- Run worktree creation from a normal terminal with full git access to the repo (not a restricted sandbox), or adjust `.cursorrules` keys `tack.worktree.*` (e.g. `tack.worktree.mode`, `tack.worktree.dir`) as documented in that orchestrator prompt.
- If the orchestrator allows it: authorize **continuing without isolation** so the pipeline runs in the main checkout (no reserved worktree path).
- Ensure downstream tasks use the coordinator’s `worktree_path` as `working_directory` when Step −1 succeeds — mismatch also stops the run.

---

## Bootstrap Phase 2 skipped, stuck, or won't advance

**Symptoms**

- You said “ok”, “ship it”, or “done” but Phase 2 won’t close.
- Phase 2 was skipped on a codebase that already has real application logic.

**Why**

- For **EXISTING** projects, Phase 2 (business-rule discovery) is **mandatory**; only **NEW** (scaffolding-only) repos skip it. See [`skills/tack-bootstrap/SKILL.md`](../skills/tack-bootstrap/SKILL.md) — Phase 2 rules and **never jump phases**.
- The Phase 2 exit gate requires the literal word **`complete`** — synonyms do not count.

**What to do**

- Finish Phase 2 coverage (draft + interview loop), then reply with **`complete`** when ready.
- If you tried to skip Phase 2 on an existing codebase, go back and run discovery — downstream glossary and architecture quality depend on it.

---

## `tack-doctor` fails or orchestrator can't pick a specialist

**Symptoms**

- `bash project/scripts/tack-doctor.sh` reports failures after bootstrap.
- `tack-run` stops because specialists cannot be mapped from `plan.md` / tasks.

**Why**

- [`tack-doctor.sh`](../skills/tack-bootstrap/template/scripts/tack-doctor.sh) fails if `.cursorrules` still contains `<UPPERCASE_PLACEHOLDER>` tokens or if **`Specialist routing`** in `project/prompts/auto-orchestrator.md` still has `<fill>` rows (template ships empty until you customize).
- Empty or generic routing tables mean the auto-orchestrator cannot dispatch stack-specific work to the right prompt.

**What to do**

- Replace every `<fill>` row in **Specialist routing** with conditions and `@prompt.md` paths for your repo (see [`auto-orchestrator.md`](../skills/tack-bootstrap/template/prompts/auto-orchestrator.md) — section **Specialist routing — fill in**).
- Remove placeholder tokens from `.cursorrules` per Phase 5 of [`SKILL.md`](../skills/tack-bootstrap/SKILL.md).
- Re-run `bash project/scripts/tack-doctor.sh` from the consumer repo root until it passes.

---

## Pipeline stops: "Model unavailable"

**Symptoms**

- Final report: **STOPPED** with model / routing failure after upward fallback is exhausted.

**Why**

- [`auto-orchestrator.md`](../skills/tack-bootstrap/template/prompts/auto-orchestrator.md) assigns models per step (**Model routing**) and stops if no model is available (**Stop conditions** item 12). Fallback is **upward** only (e.g. Composer → Sonnet → Opus), never downward.

**What to do**

- Enable or subscribe to at least one model tier your host supports for orchestrator and worker steps.
- If your IDE doesn’t support per-task `model`, follow the orchestrator’s **Platform tool mapping** and document the model in the dispatched prompt per host notes.

---

## Pipeline stops: "STOPPED at Step N" (general)

**Symptoms**

- Report shows `Status: STOPPED at Step N — <reason>` (missing spec, bad plan, red/green gate, reviewer FAIL, worktree error, etc.).

**Why**

- The orchestrator does **not** auto-retry failed steps. Irrecoverable errors are listed under **Stop conditions** (numbered 1–13) in [`auto-orchestrator.md`](../skills/tack-bootstrap/template/prompts/auto-orchestrator.md).

**What to do**

- Read the step number and reason in the report; fix the artifact (spec, `plan.md`, tests, reviewer findings) or environment issue; then re-invoke from the appropriate step or run a fresh `tack-run` after fixing blockers.
- For worktree vs model issues, see the sections above.
