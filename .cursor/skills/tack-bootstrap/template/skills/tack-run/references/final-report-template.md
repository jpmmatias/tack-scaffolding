# Final report template

Emit this structure in chat when the run finishes (`COMPLETED` or `STOPPED`):

```markdown
## Auto-orchestrator report

- **Worktree:** `<absolute path>` or `n/a` if Step −1 skipped
- **Branch:** `<branch name>` or `n/a`
- **Spec:** `S-XXX-<slug>` — `<path>`
- **Spec grill (Q&A trail):** (list `question → answer` in order, or "n/a")
- **Plan:** `<path to plan.md>`
- **ADRs created:** (list paths or "none")
- **Test files:** (list)
- **Source files modified:** (from `git diff --name-only` or summary)
- **Reviewer verdict:** PASS | FAIL
- **Reviewer checklist:** (summary or enumerated)
- **Security audit verdict:** PASS | FAIL | n/a (only present when Step 7b ran; `n/a` if no trigger fired)
- **Next steps:** when Worktree is not `n/a` and **Step 8** was skipped or declined: `cd <worktree_path>; git push -u origin <branch>;` open PR (e.g. `gh pr create`) against your base branch.
- **PR:** `<url>` | `declined` | `unavailable (gh missing)` | `failed: <reason>` | `n/a` (only present when Step 8 ran or was eligible)
- **Worktree cleanup:** `removed: <path> (branch <branch>)` | `kept (user declined)` | `skipped (<reason>)` | `failed: <reason>` | `disabled` | `n/a` (only present when Step −1 ran)
- **Implementation verification:** `PASS` | `GAP` | `FAILED` — narrative: original user epic/ask ↔ spec **AC-*** coverage; **`<TEST_COMMAND>`** / **`<LINT_COMMAND>`** (scope + exit status); notable `git diff` observation. Under **GAP**/**FAILED**, list what is missing or failing.
- **Status:** COMPLETED | STOPPED at Step N — <reason> | STOPPED at verification — <reason>
```
