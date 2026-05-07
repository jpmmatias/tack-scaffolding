# Contributing

## Canonical skill location

Edit **only** the canonical skill trees under [`skills/`](skills/) — today [`skills/tack-bootstrap/`](skills/tack-bootstrap/), [`skills/tack-run/`](skills/tack-run/), and [`skills/tack-agent/`](skills/tack-agent/). Those directories are the single source of truth (the `tack-bootstrap` canonical includes its bundled template under `skills/tack-bootstrap/template/`, except for `skills/tack-bootstrap/template/skills/`, which is regenerated from the dispatcher canonicals — see below).

## After you change the skill

From the repository root:

```bash
npm run sync
```

For each canonical `skills/<name>/`, this:

- copies it into the editor mirrors `.claude/skills/<name>/` (Claude Code), `.cursor/skills/<name>/` (Cursor), and `.agents/skills/<name>/` (Antigravity workspace skills) — auto-discovered from `skills/*/SKILL.md`, so adding a new canonical skill is automatically picked up;
- and, for the dispatcher skills bundled with bootstrap (today `tack-run` and `tack-agent`), also copies it into `skills/tack-bootstrap/template/skills/<name>/` so the bootstrap install source stays byte-equal to canonical.

Commit the canonical tree, the bundled copies, and the editor mirrors so CI stays green (`npm run check-sync` enforces both layers).

## Checks

```bash
npm run check-sync    # mirrors must match canonical
npm run validate-skill  # SKILL.md frontmatter (all skills/*/SKILL.md; version matches package.json)
npm run check-routing   # routing-snippet.md matches templates + worked examples
npm run lint            # optional: markdownlint-cli2 (canonical skills + root *.md)
npm run check-links     # optional: lychee offline link check (downloads a pinned lychee binary on first run on Apple silicon / Linux; Intel macOS: brew install lychee)
```

## Local hooks (optional)

After clone, run once:

```bash
npm run install-hooks
```

That sets `git config core.hooksPath .githooks`. On `git push`, `pre-push` runs `check-sync`, `validate-skill`, and `check-routing` (not `sync` — if mirrors are stale, run `npm run sync` and commit). The hook skips when `.git` is not writable.
