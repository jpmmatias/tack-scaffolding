# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Repo-root **`TACK.md`** as canonical IDE-agnostic Tack configuration via **`project/TACK.md.template`**; **`project/scripts/tack-resolve-config.sh`** resolves **`TACK.md`** before legacy **`.cursorrules`** for `tack-worktree.sh` and `tack-doctor.sh`.
- [`CHANGELOG.md`](CHANGELOG.md) — release notes (Keep a Changelog).
- Contributor guidance for [Conventional Commits](https://www.conventionalcommits.org/) in [`CONTRIBUTING.md`](CONTRIBUTING.md).
- GitHub **template repository** documentation and README “Use this template” / `gh` examples.
- `tack-worktree.sh`: optional defaults from repo-root **`TACK.md`** or **`.cursorrules`** (`tack.worktree.dir`, `tack.worktree.base`, `tack.worktree.naming`) when flags are omitted; `create --dry-run`.

### Changed

- **`project/.cursorrules.template`** is a Cursor-oriented stub; full Tack keys live in **`TACK.md.template`**. Existing repos with **`.cursorrules`** only remain supported as fallback.

## [0.2.0] — 2026-05-10

### Changed

- Package version `0.2.0` per [`package.json`](package.json); prior releases were not backfilled into this file.
