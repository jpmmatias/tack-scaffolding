# Phase 6 — Smoke test

1. Ask the user to run the `<TEST_COMMAND>` and `<LINT_COMMAND>` recorded in **`TACK.md`**. Confirm both succeed (or, for an empty NEW project, report that they succeed against the scaffolding).
1a. Run **`bash project/scripts/tack-doctor.sh`** from the consumer repo root. It fails if repo-root **`TACK.md`** still contains `<UPPERCASE_PLACEHOLDER>` tokens, if `project/prompts/auto-orchestrator.md` still has `<fill>` rows in the **Specialist routing** table, or if **`tack.routing.auto`** is **not** explicitly `no` (see `project/TACK.md.template` — default is **yes** when absent) while **`project/docs/tack-pipeline-models.md`** is missing or its YAML front matter lacks a required pipeline key. If it reports issues, return to Phase 5 step **3** (**`TACK.md`**), step **7** (Specialist routing), or step **1b** (pipeline models) and fix before continuing.
2. Print the SDD 7-step pipeline as a final checklist:

   ```text
   0. [ ] (optional) @project/prompts/worktree-coordinator.md — isolated worktree + branch per `tack.worktree.*` in repo-root **`TACK.md`**
   1. [ ] @project/prompts/product-manager.md — first spec S-001
   2. [ ] @project/prompts/architect.md — plan.md with Traceability
   3. [ ] @project/prompts/qa-tester.md — red
   4. [ ] @project/prompts/harness-engineer.md — only if plan demands it
   5. [ ] @project/prompts/worker.md or specialists — implementation
   6. [ ] @project/prompts/qa-tester.md — green
   7. [ ] @project/prompts/reviewer.md — verdict
   (optional) @project/prompts/security-engineer.md when triggers fire
   ```

- [ ] Confirm repo-root **`TACK.md`** includes **SDD entry points** and **`tack.routing.auto`** (see `project/TACK.md.template`).
- [ ] (Phase 5 step 1a) Confirm `tack-run` and `tack-agent` skills exist under each agent's skill dir for every agent in `tack.agents.active`: `.claude/skills/` (claude-code), `.cursor/skills/` (cursor), `.agents/skills/` (any of cursor / copilot / codex / antigravity). Confirm **no** skill dirs were created for agents not in `tack.agents.active`.

3. Suggest the next step: run **`tack-run`** with the first epic for an end-to-end pipeline, **or** `@project/prompts/product-manager.md` / **`tack-agent`** (product-manager) to draft `S-001`, ideally pulled from the highest-priority `[SPEC]`-tagged follow-up in the Phase 2 business-rules draft. If no follow-ups exist (NEW project), suggest the user paste their first epic.

Stop the skill here. Report the artifacts created and any items the user explicitly skipped.
