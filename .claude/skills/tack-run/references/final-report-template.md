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
- **Next steps:** when Worktree is not `n/a`: `cd <worktree_path>; git push -u origin <branch>;` open PR (e.g. `gh pr create`) against your base branch.
- **Status:** COMPLETED | STOPPED at Step N — <reason>
```
