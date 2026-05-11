# Single-agent dispatch protocol

Use this for **one** `project/prompts/<name>.md` execution. The hosting agent does **not** substitute for the subagent: it reads the prompt file, builds INPUTS, and dispatches.

## Task parameters

- `subagent_type`: `generalPurpose`
- `description`: short unique title (e.g. `Tack agent architect S-001`)
- `model`: resolve from **`project/docs/tack-pipeline-models.md`** per **`references/agent-catalog.md`** (**Pipeline model file**). If the file or key is missing, use **Model routing convention (fallback)** in the same file and **warn** once. **Upward fallback** when dispatch fails: Composer → Sonnet → Opus tier slugs from **that YAML** when present, else from the fallback table — never downward.
- `working_directory`: absolute path to consumer repo root, or to an active **worktree** if the user is working in isolation (ask if unclear)
- `run_in_background`: `false` unless the platform requires otherwise

## Prompt body template

```text
You are the agent defined by the PROMPT FILE below. Treat it as your complete instruction set. Execute it on the INPUTS section. Do not merge instructions from this wrapper except where INPUTS extend context.

=== PROMPT FILE: project/prompts/<name>.md ===
<full file contents read from disk>

=== INPUTS ===
<agent-specific: epic, spec path, plan path, mode, qa_history, git diff, phase red|green, etc.>
```

## After dispatch

Return the subagent’s reply to the user **verbatim** (or a faithful summary if the platform truncates). Do not silently rewrite verdicts (PASS/FAIL, STATUS lines).

**Then add implementation verification.** You **may** use read-only shell and file reads in **working_directory** (run **`<TEST_COMMAND>`**, **`<LINT_COMMAND>`** from **`TACK.md`**, **`git diff`**, open paths the subagent named) — not to author new specs, tests, or application code yourself.

Tiered checks:

- **`worker.md` / implementation specialists:** Run **`<TEST_COMMAND>`** (full or scoped per subagent output). Subagent PASS is insufficient if tests fail or contradict the user’s ask.
- **`reviewer.md` / `security-engineer.md`:** Confirm verdict matches a real **`git diff`** (or scoped diff) and the checklist isn’t vacuous versus the stated scope.
- **PM / architect / QA / harness / diagnose / domain-modeler / event-stormer:** Confirm artifacts exist where the subagent claims (`STATUS` fields when present, specs with numbered acceptance criteria, plans with **Spec:** first line + traceability, diagnose repro steps, DDD drafts, etc.) and that they reflect the user's wording.

Emit a single explicit line **after** the subagent payload (same message / next block):

`Verification:` PASS | GAP | FAILED — short evidence (user ask ↔ spec/diff ↔ tests/commands); under **GAP**/**FAILED**, state what’s missing.

If **`Verification: FAILED`** (or **`GAP`** when the user required full satisfaction), say so plainly before any celebratory wording.

## Full pipeline

If the user asks for **all steps**, **end-to-end**, or **the full SDD pipeline**, do **not** simulate multiple steps in one Task — tell them to use the **`tack-run`** skill (or dispatch `project/prompts/auto-orchestrator.md` via that skill’s flow).
