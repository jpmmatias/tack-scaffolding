# Contributing

## Canonical skill location

Edit **only** [`skills/tack-bootstrap/`](skills/tack-bootstrap/). That directory is the single source of truth for the `tack-bootstrap` skill (including bundled template under `skills/tack-bootstrap/template/`).

## After you change the skill

From the repository root:

```bash
npm run sync
```

This copies the canonical skill into:

- `.claude/skills/tack-bootstrap/` (Claude Code)
- `.cursor/skills/tack-bootstrap/` (Cursor)
- `.agents/skills/tack-bootstrap/` (Antigravity workspace skills)

Commit **both** the canonical tree and the three mirrors so CI stays green.

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
