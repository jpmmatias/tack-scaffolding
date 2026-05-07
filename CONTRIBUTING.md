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
npm run validate-skill  # SKILL.md frontmatter
```
