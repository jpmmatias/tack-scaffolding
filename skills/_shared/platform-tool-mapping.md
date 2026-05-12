| Capability                 | Cursor                          | Claude Code (CLI)                                              | Claude Code SDK / API / Generic (Copilot CLI / Codex / Antigravity) |
|----------------------------|---------------------------------|----------------------------------------------------------------|---------------------------------------------------------------------|
| Dispatch a subagent        | `Task` tool                     | `Agent` tool                                                   | host-specific subagent / dispatch primitive                          |
| Ask the user a question    | `AskQuestion` tool              | `AskUserQuestion` tool                                         | post the question in chat and wait for the next user message         |
| Pin working directory      | `working_directory` parameter   | `cwd` parameter, or `cd <path> && …` in the dispatched prompt  | host-specific; if no native param, prepend `cd <path>` to the prompt |
| Subagent type              | `subagent_type: generalPurpose` | `subagent_type: general-purpose`                               | omit when the host has no notion of agent types                      |
| Per-step model             | `model` parameter               | `model` parameter                                              | host-specific; if unsupported, document the chosen model in the prompt and rely on upward fallback |
| Shell command availability | `command -v <name>` (bash)      | `command -v <name>` (bash)                                     | shell availability varies; skip dependent steps (e.g. PR creation, post-pipeline cleanup) when unavailable |

When a host omits a native primitive, prepend an absolute `cd <path>` line to the dispatched prompt so the subagent runs in the right tree.
