# Stop conditions (irrecoverable errors)

Stop the pipeline and set **Final report** `Status` to `STOPPED at Step N — <reason>` or **`STOPPED at Preflight — …`** when any of the following holds. **Do not auto-retry** failed steps; document the failure and stop.

**Canonical list:** `project/prompts/auto-orchestrator.md` section **Stop conditions (irrecoverable errors)**. Summary:

**Preflight** — `project/docs/tack-pipeline-models.md` missing or incomplete (`STOPPED at Preflight — …`).

1. Subagent errors or does not create expected artifacts.
2. **Spec id** cannot be determined or collides.
3. **Step 1** — PM returns malformed output (missing/unknown `STATUS`, missing required fields, or missing/empty `options:` when `STATUS: NEEDS_INPUT`).
4. **Step 1** — human replies `cancel grill`.
5. **Step 1** — no valid `project/specs/S-XXX-<slug>.md` with ACs.
6. **Step 2** — no valid `plan.md` with `Spec: S-XXX` and **Traceability** covering all ACs.
7. **Step 3** — missing `describe('S-XXX AC-N:` for any AC, or **red gate**: tests do not fail after qa-tester red phase.
8. **Step 6** — **green gate**: any test still failing.
9. **Invariant / parity** (before Step 7): per repo-root **`TACK.md`** / team fill-in — blocking when defined.
10. **Step 7** — reviewer returns **FAIL** for any checklist item.
11. **Step 7b** — security-engineer returns **FAIL** when the security audit ran.
12. **Model** unavailable after upward fallback.
13. **Step −1** — worktree coordinator error and human did not authorize fallback; or worktree path unusable as `working_directory`.
