# `ai-project-template-adapter`

## 1. Purpose

`ai-project-template-adapter` is a GitHub template for connecting a software repository to the private:

`szymoniwacz/ai-project-template`

without copying the AI workflow implementation into the target repository.

Its purpose is to allow public and private projects to use the same private AI-assisted development workflow while keeping:

- workflow implementation private,
- prompts private,
- policies private,
- orchestration private,
- reusable AI instructions private,
- project source code independent from the workflow repository.

The adapter is intentionally thin.

It does **not** implement an AI development workflow.

It provides the integration boundary between:

```text
project repository
        ↓
ai-project-template-adapter
        ↓
private ai-project-template
```

---

# 2. Core Principle

```text
ai-project-template defines HOW AI works.

Target repository defines WHAT the project is.

ai-project-template-adapter connects the two.
```

There must be exactly one canonical source of reusable AI workflow logic:

```text
szymoniwacz/ai-project-template
```

The adapter must never become a second copy of that system.

---

# 3. Main Goal

A repository created from `ai-project-template-adapter` should be able to use the private AI workflow without containing its implementation.

For example:

```text
public-project/
├── application code
├── project documentation
├── project-specific AI context
└── thin AI adapters
        │
        ▼
private ai-project-template/
├── workflows
├── policies
├── contracts
├── conventions
├── review rules
├── orchestration
└── automation
```

Changes to the private workflow should therefore become available to connected repositories without copying updated workflow files into every project.

---

# 4. Problems This Repository Solves

## 4.1 Workflow confidentiality

Public repositories must not expose the implementation of `ai-project-template`.

This includes reusable:

- workflows,
- prompts,
- policies,
- contracts,
- orchestration logic,
- review methodology,
- internal AI conventions,
- automation rules.

## 4.2 Workflow duplication

Without the adapter, every repository could eventually contain its own copy of `.ai/`.

That would create:

- duplicated workflow logic,
- different workflow versions,
- manual synchronization,
- configuration drift,
- inconsistent fixes,
- difficult maintenance.

The adapter removes that duplication.

## 4.3 Workflow upgrades

If workflow behavior changes in:

```text
szymoniwacz/ai-project-template
```

connected repositories should not require copying tens of changed files.

Ideally:

```text
update ai-project-template
        ↓
all connected local repositories use new workflow
```

The project-specific configuration remains unchanged.

## 4.4 Public repository safety

It must be possible to publish a connected repository without publishing:

- private workflow files,
- private GitHub credentials,
- private repository URLs containing credentials,
- local filesystem paths,
- tokens,
- generated copies of the workflow.

---

# 5. Responsibilities

There are three separate layers.

## Layer 1 — `ai-project-template`

Private.

Responsible for the reusable AI working system.

Examples:

- workflow lifecycle,
- feature workflow,
- bugfix workflow,
- refactor workflow,
- review process,
- autonomy rules,
- authorization,
- Definition of Ready,
- Definition of Done,
- project intake,
- project definition,
- goal execution,
- task packets,
- planning rules,
- review handoff,
- quality gates,
- automation,
- shared conventions.

This remains the canonical implementation.

## Layer 2 — `ai-project-template-adapter`

Public.

Responsible only for integration.

It knows:

- how to locate the private workflow,
- how to expose it to supported AI tools,
- where project-specific AI information lives,
- how to detect an unavailable workflow,
- how to validate the connection,
- how to fail safely.

It must contain no substantial reusable workflow logic.

## Layer 3 — Target project

Public or private.

Responsible for project-specific facts.

Examples:

- project purpose,
- architecture,
- stack,
- commands,
- tests,
- linting,
- repository structure,
- project conventions,
- domain constraints,
- important documentation,
- project-specific instructions.

These belong to the project because they describe the project, not the generic workflow.

---

# 6. Hard Architectural Boundary

The following rule is fundamental:

> If a rule could be reused unchanged by many unrelated repositories, it probably belongs in `ai-project-template`, not in the adapter or target repository.

Conversely:

> If information describes this particular application's architecture, commands, domain, constraints or structure, it belongs in the target repository.

| Information | Location |
|---|---|
| Feature implementation lifecycle | `ai-project-template` |
| Independent review rules | `ai-project-template` |
| Human authorization rules | `ai-project-template` |
| How to create task packets | `ai-project-template` |
| Rails application structure | target project |
| `bundle exec rspec` | target project |
| Important domain boundaries | target project |
| Repository-specific architectural constraints | target project |
| How to locate the private workflow | adapter |
| Connection validation | adapter |

---

# 7. Repository Structure

Initial recommended structure:

```text
ai-project-template-adapter/
│
├── AGENTS.md
├── CLAUDE.md
│
├── .cursor/
│   └── rules/
│       └── ai-project-template.mdc
│
├── .github/
│   └── copilot-instructions.md
│
├── .ai/
│   ├── README.md
│   ├── project.md
│   └── local.example.yml
│
├── bin/
│   ├── ai-workflow
│   └── ai-workflow-doctor
│
├── docs/
│   └── repository-specification.md
│
├── .gitignore
├── README.md
└── LICENSE
```

This is intentionally small.

The adapter must resist growing into another workflow repository.

---

# 8. `AGENTS.md`

`AGENTS.md` should be a thin entrypoint.

Its job is not to explain the workflow.

It should explain:

1. this repository uses an external AI workflow,
2. where project-specific context lives,
3. how the external workflow is resolved,
4. that external workflow rules are authoritative when available.

Conceptually:

```text
This project uses the private ai-project-template workflow.

Reusable workflow rules are external to this repository.

Project-specific context lives in:
.ai/

Resolve the canonical workflow through the adapter entrypoint.
Do not recreate missing workflow rules locally.
```

Important:

`AGENTS.md` must not contain copied workflow instructions.

---

# 9. `CLAUDE.md`

Same principle.

It exists only because Claude Code uses a repository-specific entrypoint.

It should direct Claude toward:

- the project context,
- the external workflow,
- the adapter command.

It must remain extremely small.

No duplicated:

- planning rules,
- implementation lifecycle,
- review procedure,
- authorization policy.

Those remain private.

---

# 10. Cursor Adapter

`.cursor/rules/ai-project-template.mdc`

should provide Cursor with only enough information to:

- recognize that an external workflow exists,
- locate project-specific context,
- use the canonical external workflow when accessible.

The Cursor adapter must not recreate `.ai/` from `ai-project-template`.

---

# 11. GitHub Copilot Adapter

`.github/copilot-instructions.md`

follows the same design.

It should contain integration instructions only.

The adapter must avoid slowly becoming a manually maintained Copilot-specific version of the workflow.

---

# 12. `.ai/`

This directory has a completely different role than `.ai/` inside the private `ai-project-template`.

In a connected project:

```text
.ai/
```

contains **project context only**.

It must not contain the reusable working system.

Recommended initial files:

```text
.ai/
├── README.md
└── project.md
```

Additional project-specific files can later appear when justified.

For example:

```text
.ai/
├── README.md
├── project.md
├── architecture.md
├── conventions.md
└── decisions/
```

But they must describe the project.

---

# 13. `.ai/project.md`

This should be the canonical compact description of the project for AI tooling.

It should contain information such as:

## Identity

- project name,
- purpose,
- repository type,
- main language,
- framework.

## Commands

For example:

```text
setup
test
lint
format
typecheck
build
run
```

Only real commands should be included.

## Architecture

Short description of:

- important modules,
- boundaries,
- orchestration points,
- infrastructure boundaries.

## Repository structure

Where important things live.

## Project-specific constraints

Rules specific to this repository.

Examples:

- do not put business logic in controllers,
- CLI orchestration belongs in a specific module,
- integrations must use existing adapters,
- no external network access in unit tests.

These are valid because they belong to the project.

---

# 14. `.ai/README.md`

Explains the distinction:

```text
.ai/ in this repository contains project-specific context.

The reusable AI workflow is intentionally not stored here.

Canonical reusable workflow:
szymoniwacz/ai-project-template

Integration:
bin/ai-workflow
```

It should explicitly warn contributors and AI agents:

> Do not copy the canonical workflow into this directory.

---

# 15. Workflow Resolution

The adapter needs one deterministic way to locate `ai-project-template`.

Recommended precedence:

```text
1. AI_PROJECT_TEMPLATE_HOME
2. optional local configuration
3. fail with clear diagnostic
```

Primary mechanism:

```bash
AI_PROJECT_TEMPLATE_HOME=/path/to/ai-project-template
```

Example:

```bash
export AI_PROJECT_TEMPLATE_HOME="$HOME/Projects/ai-project-template"
```

This is configured outside the public repository.

---

# 16. Why an Environment Variable

It avoids hardcoding:

```text
/Users/szymon/...
```

inside repositories.

It also allows different machines to keep the private repository in different locations.

Example:

Machine A:

```text
AI_PROJECT_TEMPLATE_HOME=/Users/.../src/ai-project-template
```

Machine B:

```text
AI_PROJECT_TEMPLATE_HOME=/home/.../code/ai-project-template
```

Target repository remains identical.

---

# 17. Local Configuration

If local configuration is useful, it must never be committed.

Possible pattern:

```text
.ai/local.yml
```

ignored by Git.

Template:

```text
.ai/local.example.yml
```

The real local file could define things like:

```yaml
workflow_path: /local/path/to/ai-project-template
```

However, environment variables should remain the preferred mechanism.

This file is optional.

Do not add configuration complexity unless it solves an actual need.

---

# 18. `bin/ai-workflow`

This is the primary adapter executable.

Responsibilities:

1. determine repository root,
2. determine `AI_PROJECT_TEMPLATE_HOME`,
3. verify the directory exists,
4. verify it is actually an `ai-project-template` checkout,
5. invoke the appropriate external workflow entrypoint,
6. pass the target repository root,
7. forward command-line arguments,
8. preserve exit codes,
9. produce understandable errors.

It must NOT:

- implement workflow decisions,
- contain prompts,
- perform planning itself,
- decide review policy,
- contain project lifecycle logic.

Conceptually:

```text
target repository
      │
      ▼
bin/ai-workflow
      │
      ├── resolve workflow
      ├── validate workflow
      ├── identify project root
      └── delegate
              │
              ▼
      ai-project-template
```

---

# 19. `bin/ai-workflow-doctor`

A small diagnostic tool.

It should answer:

```text
Is the adapter correctly connected?
```

Recommended checks:

```text
✓ project root detected
✓ AI_PROJECT_TEMPLATE_HOME configured
✓ workflow repository exists
✓ workflow repository identity valid
✓ expected workflow entrypoint exists
✓ project .ai/ context exists
✓ no private workflow files copied locally
```

Example output:

```text
AI Project Template Adapter

Project:
  /Users/.../DiffRat

Workflow:
  /Users/.../ai-project-template

Connection:
  OK

Project context:
  .ai/project.md

Status:
  ready
```

Errors should be actionable.

Bad:

```text
workflow unavailable
```

Good:

```text
AI_PROJECT_TEMPLATE_HOME is not configured.

Set it with:

export AI_PROJECT_TEMPLATE_HOME="/path/to/ai-project-template"
```

---

# 20. Fail Closed

This is important.

If the private workflow cannot be resolved, the adapter must **not invent or approximate the missing workflow**.

It should fail.

Example:

```text
Canonical AI workflow is unavailable.

The repository intentionally does not contain a fallback copy.

Configure AI_PROJECT_TEMPLATE_HOME before using the AI workflow.
```

This prevents workflow drift.

---

# 21. No Fallback Workflow

There should be no:

```text
if private workflow unavailable
  use simplified workflow included here
```

That would immediately create two workflow implementations.

Forbidden:

```text
private workflow
+
public fallback workflow
```

Required:

```text
private workflow
OR
clear failure
```

---

# 22. Security Requirements

The repository may itself be public.

Therefore it must never commit:

- GitHub PATs,
- API keys,
- SSH private keys,
- private repository credentials,
- authentication headers,
- credential-bearing URLs,
- secrets,
- machine-specific private paths.

`.gitignore` should include local adapter configuration.

Example:

```gitignore
.ai/local.yml
.env
.env.*
```

subject to the needs of the target project.

---

# 23. Private Repository Access

Local filesystem access is the simplest supported mode.

For local tools:

```text
Cursor
Claude Code
local Copilot/editor
CLI agents
```

the adapter can resolve the existing local checkout directly.

This should be the primary MVP.

---

# 24. Remote / Cloud Agents

Remote agents are a separate problem.

A cloud process cannot automatically read:

```text
$HOME/Projects/ai-project-template
```

from the developer's Mac.

Therefore remote support must not be falsely implied.

For remote environments, the private workflow would need to be made available at runtime through authenticated access.

Possible future mechanisms:

- private GitHub checkout,
- GitHub App,
- appropriately scoped token,
- SSH deploy credentials,
- packaged private artifact.

Credentials must exist outside the public repository.

---

# 25. GitHub Actions

If GitHub Actions integration is later added, the flow should look conceptually like:

```text
public repository
       │
       ▼
GitHub Actions
       │
       ├── checkout public project
       │
       ├── authenticate securely
       │
       ├── checkout private ai-project-template
       │
       └── run adapter
```

Secrets must live in GitHub Secrets or another secure mechanism.

Never inside repository files.

Special care is required for workflows triggered from untrusted forks or pull requests.

Private workflow credentials must not be exposed to them.

This can be postponed beyond MVP.

---

# 26. Versioning

The adapter should support identifying which workflow revision is being used.

At minimum `doctor` should be able to show:

```text
workflow repository
branch
commit SHA
```

Example:

```text
Workflow:
  szymoniwacz/ai-project-template
  branch: main
  commit: abc1234
```

This gives reproducibility without copying the workflow.

---

# 27. Optional Workflow Pinning

Later it may be useful for a project to declare:

```text
minimum compatible adapter/workflow version
```

or a specific workflow revision.

Do not implement a large dependency management system initially.

MVP can simply use the currently checked-out private repository.

---

# 28. Updating the Workflow

Typical local update:

```bash
cd "$AI_PROJECT_TEMPLATE_HOME"
git pull
```

After that, connected repositories automatically use the updated workflow.

This is one of the main benefits of the architecture.

There should be no:

```text
copy workflow into project
commit updates
repeat across repositories
```

---

# 29. Template Usage Flow

Expected workflow:

```text
1. Open ai-project-template-adapter on GitHub

2. Use this template

3. Create:
   my-new-project

4. Clone my-new-project

5. Ensure:
   AI_PROJECT_TEMPLATE_HOME
   points to the private workflow

6. Customize:
   .ai/project.md

7. Run:
   bin/ai-workflow-doctor

8. Start using the normal AI workflow
```

---

# 30. Existing Projects

The adapter must also be easy to add to an existing repository.

It should not require recreating the repository from the GitHub template.

The necessary adapter files should be small enough to introduce manually or through a future install command.

For example, DiffRat could eventually contain the same integration layer.

The result should be:

```text
DiffRat
MdMeet
future Ruby projects
ruby.pl experiments
other public repositories
```

all connecting to the same private workflow.

---

# 31. Relationship With Existing `ai-project-template`

The current private repository already separates:

```text
canonical workflow
```

from tool-specific adapters.

`ai-project-template-adapter` extends that principle one level further.

Current model:

```text
ai-project-template
│
├── .ai/               canonical system
│
├── AGENTS.md           thin adapter
├── CLAUDE.md           thin adapter
├── .cursor/...         thin adapter
└── .github/...         thin adapter
```

New model:

```text
PRIVATE

ai-project-template
└── canonical workflow
       ▲
       │
       │ external integration
       │
PUBLIC │
       │
target repository
├── project code
├── project .ai context
├── AGENTS.md
├── CLAUDE.md
├── Cursor adapter
└── Copilot adapter
```

The canonical workflow still exists only once.

---

# 32. Adapter Must Stay Thin

A useful maintenance rule:

> If `ai-project-template-adapter` starts becoming large, something is probably moving into the wrong repository.

Its code should mostly deal with:

- discovery,
- resolution,
- validation,
- delegation,
- diagnostics.

Not workflow intelligence.

---

# 33. What Must NOT Be Copied

Never copy from `ai-project-template`:

```text
.ai/workflows/
.ai/policies/
.ai/contracts/
.ai/templates/
.ai/instructions/
.ai/quality/
.ai/onboarding/
.ai/automation/
```

or equivalent reusable workflow content.

Also do not copy substantial contents of:

```text
AGENTS.md
CLAUDE.md
.cursor/rules/
.github/copilot-instructions.md
```

if those contents encode the workflow.

The public adapters must only point toward the external canonical system.

---

# 34. Leakage Protection

The repository should provide a simple deterministic safety check.

For example:

```text
bin/check-workflow-leak
```

Its purpose:

detect accidental inclusion of known private workflow directories or markers.

Possible checks:

- forbidden directories,
- known canonical file names,
- accidental symlinks into private repository,
- local configuration committed by mistake.

This should stay deterministic.

It is particularly useful because the main reason for this project is keeping the workflow private.

---

# 35. Symlinks

Do not commit symlinks pointing into the private workflow.

Reasons:

- machine-dependent,
- confusing on GitHub,
- easy to break,
- can accidentally reveal local structure,
- behave inconsistently across environments.

Resolution should happen at runtime.

---

# 36. Git Submodules

Do not use the private workflow as a Git submodule in the default architecture.

A submodule creates unnecessary coupling between the public project repository and the private repository.

It also complicates:

- cloning,
- authentication,
- CI,
- contributor setup,
- public presentation.

Runtime resolution is cleaner for the intended use case.

---

# 37. README Requirements

The root README should clearly explain:

## What the repository is

A thin integration template.

## What it is not

Not the AI workflow implementation.

## Architecture

```text
project → adapter → private workflow
```

## Local setup

How to configure:

```text
AI_PROJECT_TEMPLATE_HOME
```

## Validation

How to run:

```text
bin/ai-workflow-doctor
```

## Security

Why no private workflow code exists here.

## Supported environments

Clearly distinguish:

- local support,
- remote support,
- planned support.

No implied functionality that does not exist.

---

# 38. README Must Avoid

Do not document private workflow internals.

For example, README should not explain detailed internal planning/review algorithms purely to make the public repo look impressive.

The adapter README explains the **interface**, not the implementation.

---

# 39. Project Bootstrap

The original `ai-project-template` currently provides a complete bootstrap system.

The adapter changes how that bootstrap is consumed.

Instead of:

```text
create repository from ai-project-template
        ↓
copy entire AI system into project
```

the desired model becomes:

```text
create repository from ai-project-template-adapter
        ↓
define project-specific context
        ↓
connect private ai-project-template
        ↓
execute private bootstrap workflow
```

The private workflow still controls bootstrap behavior.

---

# 40. Commands

The adapter should expose as few commands as possible.

Initial recommended interface:

```text
bin/ai-workflow
bin/ai-workflow-doctor
```

Possibly:

```text
bin/check-workflow-leak
```

Do not create adapter commands mirroring every private workflow action unless technically required.

Bad:

```text
bin/plan
bin/review
bin/feature
bin/refactor
bin/bugfix
bin/document
...
```

That creates another public API surface to maintain.

Better:

```text
bin/ai-workflow <arguments>
```

and delegate.

---

# 41. Compatibility Contract

The adapter and private workflow need a small explicit contract.

The adapter may assume only a limited number of things about `ai-project-template`.

For example:

```text
1. workflow root can be identified
2. canonical entrypoint has a known location
3. target repository root can be passed
4. arguments can be forwarded
5. exit status can be propagated
```

This contract should be documented.

Internal private folder structure should otherwise remain private implementation detail.

---

# 42. Stable Entrypoint in `ai-project-template`

A prerequisite for the cleanest adapter architecture is a stable public-to-private execution boundary inside `ai-project-template`.

Conceptually:

```text
ai-project-template/bin/ai-workflow
```

or equivalent.

The exact name should follow the actual architecture of `ai-project-template`.

The adapter should depend on **one stable entrypoint**, not dozens of internal files.

This reduces coupling.

---

# 43. Environment Contract

When invoking the private workflow, it should be possible to provide at least:

```text
target repository root
project context location
```

For example conceptually:

```text
AI_TARGET_REPOSITORY=/path/to/project
AI_PROJECT_CONTEXT=/path/to/project/.ai
```

or command arguments.

The exact mechanism should be standardized once.

---

# 44. Principle of Direction

The dependency must be one-way.

Correct:

```text
target project
      ↓
adapter
      ↓
ai-project-template
```

Avoid:

```text
ai-project-template
      ↔
target project implementation details
```

The private workflow may consume project context, but should not require project-specific modifications.

---

# 45. Contributor Experience

Someone cloning a public project without access to the private workflow should still be able to use the project normally.

For example:

```text
bundle install
bundle exec rspec
README
application commands
```

must work independently.

Only the private AI workflow functionality should be unavailable.

The adapter must never make normal project development dependent on private AI infrastructure.

---

# 46. Public Repository UX

A visitor to a public repository should see:

```text
normal software project
+
small AI workflow integration
```

not:

```text
broken repository that depends on inaccessible private files
```

The adapter should therefore be clearly optional for normal project use.

---

# 47. Testing

The adapter itself needs tests because path handling and security failures can otherwise become dangerous.

Minimum test scenarios:

### Resolution

- environment variable present,
- environment variable missing,
- path does not exist,
- path exists but is not `ai-project-template`,
- expected entrypoint missing.

### Repository detection

- run from repository root,
- run from nested directory,
- run outside Git repository.

### Delegation

- arguments forwarded unchanged,
- project path passed correctly,
- external exit code preserved.

### Security

- no workflow copy generated,
- local config ignored,
- forbidden workflow paths detected.

### Diagnostics

- successful doctor output,
- each expected failure produces actionable message.

---

# 48. CI for the Adapter Repository

The adapter's own CI should test:

- shell/script syntax,
- tests,
- leak detection,
- repository cleanliness.

CI must **not require access to the real private `ai-project-template`**.

Instead use a fake fixture representing the minimal compatibility contract.

Example:

```text
test/fixtures/fake-ai-project-template/
```

containing only the fake stable entrypoint needed for adapter tests.

This prevents private implementation leakage into CI.

---

# 49. Fake Workflow Fixture

The fake fixture must not reproduce the private workflow.

It should be minimal.

Example behavior:

```text
receive project path
receive arguments
print them
return configured exit code
```

Enough to prove the adapter works.

Nothing more.

---

# 50. Success Criteria

Version 1 is successful when all of the following are true:

- `ai-project-template-adapter` can be public,
- no private workflow implementation exists in it,
- a project can be created from it,
- local `ai-project-template` can be discovered,
- connection can be validated,
- workflow execution can be delegated,
- project-specific context stays in the project,
- reusable workflow remains private,
- updating the private workflow requires no copying into target repositories,
- missing workflow fails clearly,
- normal project development works without private workflow access,
- no credentials or local paths are committed,
- adapter behavior is tested.

---

# 51. MVP Scope

The first version should contain only what is actually necessary.

## Must have

```text
README.md

AGENTS.md
CLAUDE.md

.github/
  copilot-instructions.md

.cursor/
  rules/
    ai-project-template.mdc

.ai/
  README.md
  project.md

bin/
  ai-workflow
  ai-workflow-doctor
  check-workflow-leak

.gitignore

tests/
```

## Must work

```text
local target repository
        ↓
adapter
        ↓
local private ai-project-template
```

## Does not need in MVP

- GitHub Actions access to private workflow,
- automatic private repo cloning,
- PAT management,
- package publishing,
- workflow version manager,
- auto-updater,
- network service,
- daemon,
- complicated installer.

Build those only when there is a demonstrated need.

---

# 52. Future Extensions

Only after the local architecture is stable:

## Remote workflow resolver

Secure private checkout for remote agents.

## GitHub Actions integration

Private workflow execution in CI.

## Install command

Add adapter to an existing repository.

Conceptually:

```text
ai-project-template-adapter install .
```

## Update command

Update only the adapter integration files.

Not the workflow.

## Compatibility versions

Detect incompatible adapter/workflow versions.

## Workflow revision pinning

Allow selected repositories to remain on a known workflow revision when needed.

---

# 53. Explicit Non-Goals

The project is NOT intended to:

- open-source `ai-project-template`,
- reproduce `ai-project-template`,
- replace `ai-project-template`,
- become another workflow engine,
- contain generic prompts,
- contain planning methodology,
- contain review methodology,
- contain architecture rules shared by all projects,
- manage LLM providers,
- manage API keys,
- become an AI CLI product,
- become a generic agent framework.

It is an adapter.

Nothing more unless a real integration requirement demands it.

---

# 54. Repository Identity

The repository should be described in one sentence as:

> A thin GitHub template that connects software repositories to a private `ai-project-template` workflow without copying the workflow implementation into them.

Short GitHub description:

> Thin adapter for using a private ai-project-template workflow in public or private repositories.

---

# 55. Final Architecture

```text
                    PRIVATE
        ┌───────────────────────────┐
        │      ai-project-template  │
        │                           │
        │ canonical AI workflow     │
        │ workflows                 │
        │ policies                  │
        │ contracts                 │
        │ conventions               │
        │ planning                  │
        │ review                    │
        │ automation                │
        └─────────────▲─────────────┘
                      │
                      │ stable interface
                      │
        ┌─────────────┴─────────────┐
        │ ai-project-template-      │
        │ adapter                   │
        │                           │
        │ resolution                │
        │ validation                │
        │ delegation                │
        │ diagnostics               │
        └─────────────▲─────────────┘
                      │
             PUBLIC OR PRIVATE
                      │
        ┌─────────────┴─────────────┐
        │       target project      │
        │                           │
        │ source code               │
        │ tests                     │
        │ README                    │
        │ architecture              │
        │ project-specific .ai/     │
        └───────────────────────────┘
```

---

# 56. Ultimate Rule

The most important invariant of this repository is:

> `ai-project-template-adapter` may know how to find and invoke the workflow, but it must not know how to perform the workflow itself.

Or more simply:

```text
Private repo owns behavior.
Public repo owns context.
Adapter owns the connection.
```

If that boundary remains intact, the architecture is working.
