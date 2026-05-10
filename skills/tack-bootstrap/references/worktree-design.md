# Git worktrees — design notes (Tack)

This reference complements [`template/docs/sdd.md`](../template/docs/sdd.md) § **Parallel features** and [`template/scripts/tack-worktree.sh`](../template/scripts/tack-worktree.sh).

## Motivation

Multiple agents or humans running the SDD pipeline at the same time on **one working directory** collide on `project/specs/`, `plan.md`, application sources, and test runs. **Git worktrees** give each feature an isolated checkout sharing the same object database, so branches advance independently until merge.

This approach aligns with isolation guidance in [`obra/superpowers` — `using-git-worktrees`](https://github.com/obra/superpowers/blob/main/skills/using-git-worktrees/SKILL.md): detect whether you are already in a linked worktree, prefer platform-native isolation when available, keep project-local worktree directories **gitignored**, and verify a clean test baseline per checkout.

## Branch naming

Default Tack convention: **`feature/S-XXX-<slug>`** (e.g. `feature/S-007-change-background`).

- **`S-XXX`** matches the spec id reserved before `product-manager.md` runs, so branch names stay traceable to specs.
- **`<slug>`** is derived from the epic (kebab-case). The PM may choose a slightly different filename slug; the **spec file name is canonical** for traceability.

Alternative supported by scripts: **`feature/<slug>`** when `tack.worktree.naming` omits the spec id segment.

When **`create`** omits `--wt-dir`, **`list`** / **`path`** / **`remove`** (slug resolution), and **`create`** omit `--base` or `--naming`, `tack-worktree.sh` reads the matching **`tack.worktree.*`** lines from repo-root **`.cursorrules`** when present (same keys as [`worktree-coordinator.md`](../template/prompts/worktree-coordinator.md)), after Markdown noise stripping. CLI flags always win.

## Reserving `S-XXX` under parallelism

`next-spec-id` scans **`project/specs/S-*.md`** in every linked worktree reported by `git worktree list`, plus the primary checkout. That avoids two parallel runs picking the same `S-001`.

If two runs start truly simultaneously before either creates a file, a remaining race is possible; teams needing hard guarantees can serialize reservation (e.g. short lock / bot) outside this script.

## Cleanup gates

`remove` refuses to drop a dirty worktree or delete a branch that is not merged into the detected base branch unless **`--force`**. This mirrors cautious cleanup in multi-agent workflows.

## Credits

- Git worktrees: [`git-worktree` documentation](https://git-scm.com/docs/git-worktree).
- Workflow inspiration: [`obra/superpowers` — `using-git-worktrees`](https://github.com/obra/superpowers/blob/main/skills/using-git-worktrees/SKILL.md).
