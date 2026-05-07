# Git hooks (optional)

This directory holds repo-provided hooks. Wire them once per clone:

```bash
npm run install-hooks
```

That sets `core.hooksPath` to `.githooks`. The `pre-push` hook runs `check-sync`, `validate-skill`, and `check-routing` so mirror drift is caught before push. It skips automatically if `.git` is not writable.

To run markdown lint or link checks locally (not in the hook): `npm run lint` and `npm run check-links`.
