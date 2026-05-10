# File template — optional `.cursorrules` (Cursor)

**Canonical Tack keys** belong in **`TACK.md`** at the repo root — see [`tack.md`](./tack.md) for the full worked shape and [`project/TACK.md.template`](../../template/TACK.md.template) after bootstrap.

Use **`.cursorrules`** only when **`cursor` ∈ `tack.agents.active`**: a **short stub** Cursor can load for editor-specific hints. Start from **`project/.cursorrules.template`** — do **not** duplicate `<TEST_COMMAND>`, `tack.worktree.*`, or `tack.routing.*` here unless you are migrating from a legacy repo; tooling reads **`TACK.md` first**.

Notes:

- If both **`TACK.md`** and **`.cursorrules`** exist, **`TACK.md` is authoritative** for scripts and orchestration; align duplicate keys or remove them from `.cursorrules`.
- See **`template/examples/cursorrules.example.md`** for a minimal stub example.
