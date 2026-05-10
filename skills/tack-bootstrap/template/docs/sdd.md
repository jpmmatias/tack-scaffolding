# Spec-driven development (SDD)

This workspace ties product intent to code through **numbered specs** (`S-XXX`), **acceptance criteria** (`AC-N`), **plans** (`plan.md` + tasks under `specs/`), and **tests** named after criteria.

## Lifecycle

> Two execution modes: run the steps below manually via [orchestrator.md](../prompts/orchestrator.md), or end-to-end automated via [auto-orchestrator.md](../prompts/auto-orchestrator.md). The seven steps are identical. **Optionally** run [worktree-coordinator.md](../prompts/worktree-coordinator.md) first to create a **dedicated git worktree** + branch (see **Parallel features** below).

1. **Idea** — captured informally (ticket, conversation).
2. **Spec** — [product-manager prompt](../prompts/product-manager.md) **asks only when material gaps remain** (with recommended answers), then **confirm-before-write** (`[CONFIRM_SPEC]` in `mode: autonomous`) before producing `specs/S-XXX-<slug>.md` from [specs/_template.md](../specs/_template.md). Same *document-the-domain-as-you-go* style as common “grill-with-docs” guidance: vocabulary lives in [domain-glossary.md](./domain-glossary.md); ADRs stay under [project/docs/adr/](./adr/) via the architect when decisions are hard to reverse.
3. **Plan** — [architect prompt](../prompts/architect.md) produces `plan.md` with a **traceability** table: each task maps to the ACs it closes. Structural decisions require a new ADR under [project/docs/adr/](./adr/) using [project/docs/adr/_template.md](./adr/_template.md).
4. **Failing tests** — [qa-tester prompt](../prompts/qa-tester.md) writes automated tests first; blocks named `S-XXX AC-N: …`; red output before implementation. Prefer **vertical slices** (tracer bullets): one AC’s failing test → minimal implementation → next AC—avoid bulk-writing every test before any production code.
5. **Harness** — if factories or approved fixtures are missing, [harness-engineer prompt](../prompts/harness-engineer.md) extends `<TEST_HARNESS_ROOT>` and boundary doubles (see [test-harness.md](./test-harness.md)).
6. **Implementation** — [worker prompt](../prompts/worker.md) minimal change to green for the **current** failing test / AC, then optional refactor; footer `Closes: S-XXX#AC-N`.
7. **Review** — [reviewer prompt](../prompts/reviewer.md) PASS/FAIL gates including spec citation and telemetry tests when the spec defines them.

## Multi-platform agent support

### Skills do not guarantee subagent tool calls

Installing **`tack-run`** (or pasting `@project/prompts/auto-orchestrator.md`) does **not** force the hosting model to invoke your platform’s subagent primitive. On some hosts (notably **Claude Code**), the **lead** chat may **inline** product-manager / architect / QA / worker work in one thread instead of dispatching **`Task`** / **`Agent`** once per step — that **breaks role isolation** even though the skill text is correct.

When your host **does** support isolated subagents but the model “runs the whole pipeline” in the lead agent, add an **orchestrator-only** steering block in the **same user message as the epic** (before or after the epic text):

```text
Orchestrator-only: Read project/prompts/auto-orchestrator.md and run it as written. Do not simulate PM, architect, QA, harness-engineer, worker, or reviewer yourself. For each step, dispatch one isolated subagent using your platform’s mapping (e.g. Cursor: Task + subagent_type generalPurpose; Claude Code: Agent + subagent_type general-purpose). Build each dispatch prompt per Dispatch protocol in that file: embed the full contents of project/prompts/<name>.md under === PROMPT FILE === plus step INPUTS. You only emit the Final report from auto-orchestrator; file writes happen inside subagents.
```

### `project/prompts/*.md` vs UI “agent libraries”

Tack roles live as **files under `project/prompts/`**. They are **not** the same as product UIs that offer an empty **agent library** (e.g. **Claude Code `/agents`** — “Create new agent”). You do **not** need to pre-create library agents. Each step should pass the **full markdown** of the right **`project/prompts/<name>.md`** inside the wrapper described in [auto-orchestrator.md](../prompts/auto-orchestrator.md) → **Dispatch protocol**.

### When subagent dispatch is missing or unsupported

1. **Passive pipeline** — follow [orchestrator.md](../prompts/orchestrator.md) in order; the human (or the lead agent, with weaker isolation) runs one step at a time.
2. **Single role** — use the **`tack-agent`** skill (or `@`-mention one prompt) for **one** step only.
3. **No subagent primitive on the host** — use the **Platform tool mapping** in [auto-orchestrator.md](../prompts/auto-orchestrator.md): fall back to **`@orchestrator.md`** instead of the active state machine.

## Pipeline diagram

```mermaid
flowchart LR
    Idea --> PM[ProductManager writes S-XXX spec]
    PM --> Arch[Architect plan plus traceability]
    Arch --> ADR{Architectural decision?}
    ADR -->|yes| ADRDoc[ADR-NNNN]
    ADR -->|no| QA
    ADRDoc --> QA[QA-Tester failing tests by AC]
    QA --> Harness[Harness-Engineer fixtures or mocks gap?]
    Harness --> Worker[Worker green plus refactor]
    Worker --> QA2[QA-Tester confirm green]
    QA2 --> Reviewer[Reviewer checks]
    Reviewer -->|fail| Worker
    Reviewer -->|pass| Done[Merge]
```

## Parallel features (git worktrees)

Run **multiple specs at once** without agents overwriting each other’s files: create one **linked worktree + branch per feature** from your trunk (`main` / `master`), run `product-manager` → … → `reviewer` **inside that directory**. Configuration lives under **Parallel execution (worktrees)** in **`TACK.md`**.

Implementation helper (bash, repo root):

- [`../scripts/tack-worktree.sh`](../scripts/tack-worktree.sh) — `create`, `next-spec-id`, `list`, `path`, `remove`.

Suggested flow (also orchestrated by [auto-orchestrator.md](../prompts/auto-orchestrator.md) Step −1):

1. Reserve the next spec id across **all** worktrees: `bash project/scripts/tack-worktree.sh next-spec-id`.
2. Create a branch `feature/S-XXX-<slug>` and checkout under `.worktrees/…`: `bash project/scripts/tack-worktree.sh create "<slug>" [--spec S-XXX]`.
3. Open a dedicated agent **with cwd = that worktree path** and run the usual SDD prompts.

```mermaid
flowchart TB
    Main["main at repo root"]
    WT1[".worktrees/feature-S-005-login"]
    WT2[".worktrees/feature-S-006-change-background"]

    Main --> WT1
    Main --> WT2
```

Cleanup when merged: `bash project/scripts/tack-worktree.sh remove <slug-or-path>` (see script `--help`). Additional design notes ship with the **tack-bootstrap** skill source at `references/worktree-design.md` (developer reference; not required at runtime).

## References

- [Harness engineering for coding agent users](https://martinfowler.com/articles/harness-engineering.html)
- [Architecture](./architecture.md)
- [Domain glossary](./domain-glossary.md)
- ADRs: [project/docs/adr/](./adr/) — template [project/docs/adr/_template.md](./adr/_template.md)
