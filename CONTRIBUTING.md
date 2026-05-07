# Contributing

## Canonical skill location

Edit **only** [`skills/sdd-bootstrap/`](skills/sdd-bootstrap/). That directory is the single source of truth for the `sdd-bootstrap` skill (including bundled template under `skills/sdd-bootstrap/template/`).

## After you change the skill

From the repository root:

```bash
npm run sync
```

This copies the canonical skill into:

- `.claude/skills/sdd-bootstrap/` (Claude Code)
- `.cursor/skills/sdd-bootstrap/` (Cursor)
- `.agents/skills/sdd-bootstrap/` (Antigravity workspace skills)

Commit **both** the canonical tree and the three mirrors so CI stays green.

## Checks

```bash
npm run check-sync    # mirrors must match canonical
npm run validate-skill  # SKILL.md frontmatter
```
