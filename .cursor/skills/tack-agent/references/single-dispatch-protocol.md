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

## Full pipeline

If the user asks for **all steps**, **end-to-end**, or **the full SDD pipeline**, do **not** simulate multiple steps in one Task — tell them to use the **`tack-run`** skill (or dispatch `project/prompts/auto-orchestrator.md` via that skill’s flow).
