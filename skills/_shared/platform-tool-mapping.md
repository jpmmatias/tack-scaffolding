| Capability             | Cursor             | Claude Code (CLI)   | Claude Code SDK / API |
|------------------------|--------------------|---------------------|-----------------------|
| Dispatch a subagent    | `Task`             | `Agent`             | `Task`                |
| Ask the user a question| `AskQuestion`      | `AskUserQuestion`   | (none — inline)       |
| Pin working directory  | `working_directory`| `cd <path>` in prompt body          | host-specific (`cwd` if available, else `cd` in prompt) |
| Subagent type          | `generalPurpose`   | `general-purpose`   | `general-purpose`     |

When a host omits a primitive (e.g. Claude Code Agent has no `working_directory` param), prepend an absolute `cd <path>` line to the dispatched prompt so the subagent runs in the right tree.
