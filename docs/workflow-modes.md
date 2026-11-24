# Workflow modes and review paths

This page describes the **high-level behavior of my private AI workflow**. It is a design overview, **not executable code** or evidence that an AI reviewer will catch every defect. The public adapter only loads the private workflow into authorized project repositories.

## Goal lifecycle

```mermaid
flowchart TD
    A["Authorized goal"] --> B["Analyze scope and dependencies"]
    B --> C["Plan and implement"]
    C --> D["Run quality checks and tests"]
    D --> E["Review the change"]
    E --> F{"Material decisions or blockers?"}
    F -->|"Yes"| G["Human decision or approval"]
    G --> H["Apply decision; revalidate"]
    H --> I["Open or update PR / MR"]
    F -->|"No"| I
    I --> J["Stabilize CI and assess diff risk"]
    J --> K{"Authorized review mode"}
    K -->|"Default"| L["Human code review"]
    L --> M["Human merge"]
    K -->|"Self-correcting"| N["Review / fix / revalidate loop"]
    N --> O{"Clean and eligible?"}
    O -->|"No"| L
    O -->|"Yes"| P{"Auto-merge also authorized?"}
    P -->|"No"| M
    P -->|"Yes"| Q["Verify all merge preconditions"]
    Q -->|"Satisfied"| R["Goal Executor squash merge"]
    Q -->|"Not satisfied"| S["Stop or escalate; no agent merge"]
```

The diagrams simplify internal stages; actual execution follows the private authorization and quality policies. Work also stops for unresolved required approvals or external blockers. A failure to finish the loop does **not** authorize skipping human review.

## Available options

| Option | How to request it | Review and merge outcome |
| --- | --- | --- |
| **Default** | `/execute-goal` | Autonomous work through review-ready PR; human code review and human merge |
| **Supervised** | Explicitly request a checkpoint or earlier stop | Work stops at the requested boundary, including before commit/push when requested |
| **Self-correcting review** | `/execute-goal self-correcting-review` | Review/fix loop; eligible clean changes may skip human code review; human merge remains required |
| **Self-correcting review + auto-merge** | `/execute-goal self-correcting-review auto-merge` | Eligible, clean changes may be squash-merged by Goal Executor after required checks |
| **Auto-execute goal** | `/auto-execute-goal` | Exact alias for `/execute-goal self-correcting-review auto-merge` |
| **Auto-execute project** | `/auto-execute-project` | Exact alias for `/execute-project self-correcting-review auto-merge` |
| **Whole-project execution** | `/execute-project` with the same optional review suffixes | Project Executor delegates one goal at a time to Goal Executor; it never merges itself |

The forms above describe authorized issue comments or supported local commands; local issue references may also be required. These modes are **opt-in where stated**. Merely including a label in a project file does not grant authorization.

## Command reference

These commands belong to the **private workflow** after authorized setup, not to the public adapter scripts. Tool support and issue references depend on the execution environment. Setup refreshes the private submodule from its configured remote, so the commands available after setup may differ from those in the submodule commit recorded in this public repository.

| Command | Purpose |
| --- | --- |
| `/project-intake` or `/define-project` | Gather or organize project requirements |
| `/execute-goal` | Run one authorized goal through a review-ready PR |
| `/execute-project` | Orchestrate a project by delegating goals one at a time |
| `/auto-execute-goal` | Opt into the existing self-correcting review and eligible auto-merge mode for one goal |
| `/auto-execute-project` | Opt into the same mode for sequential project goals |
| `/continue-project` | Resume an already authorized project when needed (local form: `/continue-project #12`) |
| `/audit-project` | Check implemented work against accepted requirements |
| `/plan-next-goals` | Plan missing goals while avoiding duplicate backlog work |
| `/validate-change` | Run applicable validation gates |
| `/review-integrated` | Review the integrated change |
| `/run-self-correcting-review` | Run an authorized, bounded review/fix loop |

Typical **local** issue-backed forms include `/execute-goal #42` and `/execute-goal #42 self-correcting-review auto-merge`. Local project execution requires the Project Execution issue number, for example `/execute-project #12` or `/execute-project #12 self-correcting-review auto-merge`. The equivalent short local forms are `/auto-execute-goal #42` and `/auto-execute-project #12`. Authorized cloud execution uses matching commands as issue comments, without the local issue-number argument. A slash command is not a substitute for the authorization rules defined in the private workflow.

### Review behavior

```mermaid
flowchart TD
    A["Change ready for review"] --> B{"Independent reviewer available?"}
    B -->|"Yes"| C["Separate review agent"]
    B -->|"No"| D["Self-review fallback"]
    C --> E["Findings and diff-risk assessment"]
    D --> E
    E --> F{"Self-correcting mode authorized and eligible?"}
    F -->|"No"| G["Human code review"]
    F -->|"Yes"| H["Review → fix → revalidate"]
    H --> I{"Clean within 3 passes?"}
    I -->|"No / risk escalated"| G
    I -->|"Yes"| J["Self-verified handoff"]
```

Independent review is **preferred, not guaranteed**. The self-correcting loop has a **maximum of three passes**. High diff-risk, security-sensitive changes, unresolved issues, or required human approvals lead to escalation rather than agent merge.

### Merge safeguards

Agent squash merge is possible **only** with the explicit `self-correcting-review auto-merge` option (or its exact `auto-execute` command alias), a clean eligible review loop, applicable CI green (or no applicable CI), and no outstanding material or safety blockers. It is **not** GitHub's auto-merge queue. Default and escalated paths require human merge.

## Project orchestration and recent workflow capabilities

These features live in the **private workflow**, not in the public adapter:

```mermaid
flowchart TB
    A["Authorized Project Execution issue"] --> B["Resolve current state and acquire coordination lock"]
    B --> C["Audit alignment and choose an eligible goal"]
    C --> D{"Dependencies verified on target branch?"}
    D -->|"No / uncertain"| E["Block or select another ready goal"]
    D -->|"Yes"| F["Delegate exactly one goal to Goal Executor"]
    F --> G["Implement, validate, review and hand off PR"]
    G --> H{"Merge completed?"}
    H -->|"No"| I["Wait, resume or request human input"]
    H -->|"Yes"| J["Verify default-branch CI"]
    J -->|"Red"| K["Plan repair goal"]
    J -->|"Green"| L["Reconcile requirements and backlog"]
    K --> C
    L --> M{"Another ready goal or unresolved validation?"}
    M -->|"Ready goal"| C
    M -->|"Owner validation due"| N["Request batched owner checks"]
    M -->|"Completed and verified"| O["Finalize project"]
    M -->|"Blocked"| P["Wait for decision / evidence"]
    N --> P
```

| Mechanism | What it adds |
| --- | --- |
| **Executor coordination** | Git-ref-based ownership and pending-event reconciliation reduce duplicate concurrent runs; this is cooperative locking, not an atomic transaction across all GitHub operations |
| **Dependency preflight** | A goal cannot start implementation just because prerequisite issues are closed; the current target-branch evidence must satisfy them |
| **Owner amendments** | Only a verified owner's issue comment beginning exactly with `Changes:` is considered for in-scope re-evaluation; it is not new execution authorization |
| **Project alignment** | Audits compare approved requirements with repository evidence; backlog deduplication and dependency checks limit unnecessary goals |
| **Deferred owner validation** | Under eligible project-level self-correcting auto-merge, certain owner-only checks can be collected for a later batch; automated checks and safety gates cannot be deferred |

Project Executor delegates **one goal at a time**, waits for its result and post-merge CI, and never merges PRs itself. Optional `/continue-project` resumes an already authorized project; it does not authorize a new one.

The concurrent-run guard uses Python 3.9+, authenticated `gh`, and repository write permissions in the **authorized automation environment**. Public contract tests do not exercise these private runtime mechanisms.

## Related references

- [Public adapter architecture](architecture.md)
- [Technical reviewer guide](reviewer-guide.md)
- [Setup instructions](setup.md)
- [Limitations and possible improvements](improvements.md)

**Visibility boundary:** this page intentionally describes mode names and observable control flow only. The private prompts, policies, internal executor state machines, and implementation remain in the private repository.
