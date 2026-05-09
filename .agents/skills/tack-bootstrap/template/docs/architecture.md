# Architecture

**Fill this file** with a pointer to your canonical architecture description, or paste a short summary here and link to detailed docs.

## Canonical document

- Primary: `<PATH_TO_CANONICAL_ARCH_DOC>` (e.g. `docs/architecture.md` at repo root, or an internal wiki URL)
- Optional diagrams: `<LINK_OR_PATH>`

## How SDD uses this file

- [architect.md](../prompts/architect.md) reads this file when producing `plan.md` and ADRs.
- [security-engineer.md](../prompts/security-engineer.md) uses it for trust-boundary review.
- [domain-modeler.md](../prompts/domain-modeler.md) (when `tack.ddd.profile = on`) edits the **Context map** and **Anticorruption layers** sections below, and writes an ADR when a context boundary moves.

If your team keeps ADRs only under `project/docs/adr/`, say so here and list numbering rules (`ADR-NNNN`).

<!-- ## Context map
DDD-only — emit this section when `tack.ddd.profile = on`. Mirrors **Bounded contexts** in `domain-glossary.md`. Pattern values: `customer-supplier`, `conformist`, `ACL`, `shared kernel`, `published language`, `partnership`, `separate ways`. Use a mermaid diagram or a table — pick one.

| Upstream | Downstream | Pattern | How they communicate |
|----------|------------|---------|----------------------|
|          |            |         |                      |

When `tack.ddd.profile = on`, the `## Layers / boundaries` rules apply **per bounded context** — cross-context imports are forbidden except through anticorruption layers listed below.
-->

<!-- ## Anticorruption layers
DDD-only — emit when `tack.ddd.profile = on`. One row per external integration that needs translation between contexts or vendor vocabulary.

| External system | ACL location | Translates | Forbidden leaks (do not let these reach domain) |
|-----------------|--------------|------------|--------------------------------------------------|
|                 |              |            |                                                  |
-->
