# Canonical Tack skills

Source of truth lives under `skills/<name>/`. After edits, run `npm run sync` from the repository root so mirrors (`.claude/skills/`, `.cursor/skills/`, `.agents/skills/`) and bundled copies under `skills/tack-bootstrap/template/skills/` stay aligned. See [CONTRIBUTING.md](../CONTRIBUTING.md).

## Behavioral evals (skill-creator)

Each skill ships **`evals/evals.json`** in the format defined by Anthropic’s [skill-creator schemas](https://github.com/anthropics/skills/blob/main/skills/skill-creator/references/schemas.md) (`skill_name`, `evals[]` with `id`, `prompt`, `expected_output`, `expectations`).

### Install skill-creator (Claude Code)

1. In Claude Code, run **`/install skill-creator`** (official plugin). Product page: [Skill Creator – Claude Plugin](https://claude.com/plugins/skill-creator).
2. Confirm you can reach **Create**, **Eval**, **Improve**, and **Benchmark** from the plugin UI or skill instructions (modes are described in the [Medium guide](https://medium.com/@karkeralathesh/the-complete-guide-to-testing-claude-code-skills-with-the-skill-creator-1ae3821bd7b8)).

### Run Eval (about 15 minutes per skill)

1. Ensure the canonical tree is synced (`npm run sync`) and committed.
2. In Claude Code with skill-creator installed, evaluate the skill path, for example:  
   `skills/tack-run` (or the absolute path on your machine), **using its `evals/evals.json`**.
3. Read grader output (`eval_feedback`, failed expectations). Add **negative assertions** where the grader flags false positives (see the article’s `post-reviewer` example).
4. Patch `SKILL.md` or `references/*.md`, re-run `npm run sync`, and re-run Eval until expectations pass.

**Grader iteration (run-eval loop):** tighten `expectations` strings so they check both required behavior and **absence** of the wrong workflow (e.g. tack-run must not emit a full multi-role checklist when the user asked for architect-only). Re-run Eval after each edit; keep `npm run validate-skill-evals` green in CI when JSON shape changes.

### Improve and Benchmark

- **Improve**: blind A/B between skill versions; use Comparator/Analyzer output to refine triggers and steps.
- **Benchmark**: multiple runs per configuration (`with_skill` / `without_skill`) when tuning descriptions or measuring variance.

### Cursor-only hosts

Claude Code plugins are not available in every editor. Use the same prompts and expectations manually, or paste eval cases into a PR checklist.

## Progressive disclosure (line budget)

Keep each `SKILL.md` lean; move long playbooks to `references/`. The skill-creator article suggests **progressive disclosure** once a skill approaches **~500 lines**. `npm run validate-skill` warns above **400** lines and fails above **500**. `tack-bootstrap/SKILL.md` is **391 lines** in-tree (under the 450-line “split soon” threshold from the improvement plan)—no extraction pass required until it grows further.

## CI validation

- `npm run validate-skill` — frontmatter, `Use when`, `Triggers`, version, line budget.
- `npm run validate-skill-evals` — JSON shape and consistency with each skill’s `name` in `SKILL.md`.
