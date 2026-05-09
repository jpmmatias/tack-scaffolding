## Tack routing

Follow the SDD pipeline end-to-end for every feature, bug, or task in this repo unless explicitly told otherwise.

- **Explicit skill entry points:** use the **`tack-run`** skill for the full pipeline (same dispatch contract as `@project/prompts/auto-orchestrator.md`). Use the **`tack-agent`** skill to run **one** prompt under `project/prompts/` (e.g. architect, qa-tester, reviewer). `@`-mentions remain valid.
- **Default entry point:** dispatch the request through `@project/prompts/auto-orchestrator.md`. It runs the 7-step pipeline (product-manager → architect → qa-tester red → optional harness → worker/specialists → qa-tester green → reviewer, plus optional security audit) as isolated subagents.
- **Passive fallback:** if subagent dispatch is unavailable, follow `@project/prompts/orchestrator.md` instead — same pipeline, but the human runs each step in a fresh chat window.
- **Configuration:** read `<TEST_COMMAND>`, `<LINT_COMMAND>`, parity invariants, and `tack.worktree.*` from `.cursorrules` at the repo root. Never invent values not in that file.
- **Worktrees:** honor `tack.worktree.mode`/`naming`/`base`/`dir`/`cleanup` from `.cursorrules`. The orchestrator decides whether to isolate and whether to offer end-of-run cleanup; do not bypass it. `tack-worktree.sh remove` refuses protected branches (`main`, `master`, `develop`, `staging`, `release/*`, `hotfix/*`, …) unconditionally.
- **Escape hatch:** trivial chores (typo fixes, doc-only edits, comment tweaks) may bypass the orchestrator. Anything that changes behaviour, public contracts, schemas, infra, or business rules must go through `@project/prompts/auto-orchestrator.md`.
