# Examples (OrderFlow — fictitious)

These files show **one possible instantiation** of the SDD template. They are **not** prescriptive product requirements; copy patterns, not prose, into your own repo.

For a **traced end-to-end SDD slice** (spec, `plan.md`, task files, and sample `S-001 AC-N` test names), see **[orderflow-full/](./orderflow-full/)** ([README](./orderflow-full/README.md)).

For a **DDD-profile walkthrough** (three bounded contexts, `@event-stormer.md` → `event-storming-draft.md` on greenfield, `@domain-modeler.md` narrative, **ADR-0002** splitting Sales out of Checkout, and sample `plan.md` with `## DDD impact`), see **[orderflow-ddd/](./orderflow-ddd/)** ([README](./orderflow-ddd/README.md)). See also **[event-storming-draft.example.md](./event-storming-draft.example.md)** for a filled storming draft shape.

| File | Shows |
|------|--------|
| [cursorrules.example.md](./cursorrules.example.md) | Filled `.cursorrules` with stack commands and invariants. |
| [domain-glossary.example.md](./domain-glossary.example.md) | Partial glossary with surfaces, entities, telemetry names. |
| [spec.example.md](./spec.example.md) | Full `S-001` spec with Gherkin ACs and telemetry table. |
| [plan.example.md](./plan.example.md) | `plan.md` with traceability rows. |
| [adr.example.md](./adr.example.md) | Sample `ADR-0001` decision record. |
| [event-storming-draft.example.md](./event-storming-draft.example.md) | Greenfield DDD: filled `event-storming-draft.md` shape (OrderFlow) before `domain-modeler`. |

Rename paths (`project/` vs repo root) to match where you install the template.
