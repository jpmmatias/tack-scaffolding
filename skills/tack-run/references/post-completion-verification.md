# Post-completion implementation verification (host)

Referenced from `tack-run` **SKILL.md**. Run **after** reviewer (**Step 7**) and optional security (**Step 7b**) **PASS**, **before** emitting **Final report** **`COMPLETED`** and before Steps 8–9. Use only read-only inspection and repo-config commands (no authoring of specs, tests, or application code).

1. **Request traceability:** From the retained epic / user ask (per **Isolation** in `auto-orchestrator.md`), confirm the governing spec’s **AC-*** acceptance criteria cover that ask. If the original request is wider or different than what the ACs encode, record **GAP** — do not imply the user’s entire request was satisfied unless the mismatch is acknowledged in the report.
2. **Evidence:** In the active **working_directory** (worktree or repo root), run **`<TEST_COMMAND>`** from **`TACK.md`** (full suite or scoped per team practice — align with Step 6 intent). Run **`<LINT_COMMAND>`** when it is quick and configured. Capture exit status and scope in the report. Any test failure → **FAILED** (prefer **STOPPED at verification**).
3. **Surface check:** When the user’s ask implies specific files or behaviours, sanity-check **e.g.** `git diff --stat` or `--name-only` against that expectation.

**Outcome:** Set **Implementation verification** in the Final report to **PASS**, **GAP**, or **FAILED** with a short narrative (user ask ↔ spec AC coverage, commands run, notable diff observation). Enumerate missing items under **GAP**/**FAILED**.
