# AI Project Template Adapter — Repository Specification

## Status

This document is the source of truth for `szymoniwacz/ai-project-template-adapter`.

The adapter is a public GitHub template repository that connects generated target repositories to the private `szymoniwacz/ai-project-template` workflow without publishing that workflow.

This specification replaces the earlier runtime-delegation design based on `AI_PROJECT_TEMPLATE_HOME` and a private `bin/ai-workflow` entrypoint.

## 1. Goals

The adapter must let a repository created from this template use the same AI workflow architecture already proven in DiffRat:

```text
target repository
      |
      v
.ai-template/              private git submodule
      |
      v
scripts/setup-ai-workflow.sh
      |
      v
.ai/                       materialized runtime source of truth
      |
      +-- reusable private workflow
      +-- project-specific tracked overlay
```

The design must satisfy all of the following:

1. The reusable AI workflow remains private.
2. Public target repositories may reference the private repository but must not commit its contents.
3. `.ai/` is the runtime source of truth seen by agents and automations.
4. Project-specific AI context survives workflow setup and upgrades.
5. The workflow revision used locally is visible and the target repository may record it through the submodule gitlink.
6. Local agents and cloud automations use the same workflow layout.
7. Missing access to the private workflow fails closed.
8. The adapter remains thin and does not duplicate Project Executor, Goal Executor, policies, prompts, or other reusable workflow logic.

## 2. Repository roles

### Private `szymoniwacz/ai-project-template`

Owns reusable workflow behavior, including `.ai/automation`, `.ai/policies`, `.ai/skills`, `.ai/workflows`, `.ai/review`, `.ai/git`, `.ai/instructions`, conventions, prompts, quality rules, onboarding material, and reusable tool entrypoint adapters under `.agents/skills/` and `.cursor/commands/`.

### Public `szymoniwacz/ai-project-template-adapter`

Owns only the integration contract:

- `.gitmodules` and the `.ai-template` gitlink,
- workflow setup/materialization,
- project-overlay preservation,
- leak protection,
- thin agent adapters,
- thin automation loaders,
- diagnostics,
- tests and documentation.

### Generated target repository

Owns the product and project-specific AI context: product context, roadmap, decisions, project requirements, ADRs, stack profile, ideas, and other target-specific documents.

## 3. Private submodule contract

Every target repository contains a git submodule at exactly:

```text
.ai-template
```

`.gitmodules` points to:

```text
https://github.com/szymoniwacz/ai-project-template.git
```

Setup updates the submodule checkout from its configured remote before materialization. The target repository may commit the resulting `.ai-template` gitlink when it wants to record that workflow revision explicitly.

A user without read access may see the private repository name and committed submodule identifier, but cannot retrieve the private repository contents through the submodule.

## 4. Runtime source of truth

`.ai-template/` is the private upstream source. It is not the path agents should normally follow.

After setup, `.ai/` is the runtime source of truth. Agent adapters must direct tools to `.ai/README.md` and the workflow paths materialized beneath `.ai/`.

This preserves the existing workflow assumptions used by Project Executor and Goal Executor, including paths such as:

```text
.ai/automation/project-executor.md
.ai/automation/goal-executor.md
.ai/skills/execute-goal.md
.ai/instructions/workflow.md
```

## 5. Materialization

`scripts/setup-ai-workflow.sh` is the canonical setup and refresh command.

It must:

1. resolve the target repository root,
2. initialize `.ai-template` when needed and update it from the configured remote,
3. verify the private workflow has the required structure,
4. save the target repository's tracked `.ai/**` files as project overlay,
5. materialize `.ai-template/.ai/` into `.ai/` with deletion of stale template-owned files,
6. materialize `.ai-template/.agents/skills/` into `.agents/skills/` and `.ai-template/.cursor/commands/` into `.cursor/commands/`,
7. restore the saved project overlay over the materialized workflow,
8. leave the target working tree with the private workflow available locally but not tracked,
9. fail closed when the private workflow cannot be initialized, updated, or validated.

The setup command must be safe to run repeatedly.

## 6. Generic project overlay

The adapter must not contain DiffRat-specific filenames or paths.

The generic ownership rule is:

> Files already tracked by the target repository under `.ai/**` are project-owned overlay. Untracked files materialized from `.ai-template/.ai/` are template-owned runtime files.

Setup preserves the current working-tree contents of tracked `.ai/**` files, not only `HEAD`, so local edits are not silently discarded.

Recommended project-owned locations include:

```text
.ai/project/**
.ai/docs/project-requirements.md
.ai/docs/architecture-direction.md
.ai/architecture/adr-*.md
.ai/stack-profiles/**
.ai/ideas/**
```

The initial adapter seeds `.ai/project/` with minimal project context files. Additional project-specific files can be tracked when needed.

## 7. Git ignore and leak model

Materialized private workflow files may exist locally. Their existence is expected.

The security boundary is tracking, not filesystem presence:

```text
private workflow may exist locally
private workflow must not be committed to the target repository
```

The repository therefore ignores known reusable materialized paths, including `.agents/skills/` and `.cursor/commands/`, while explicitly allowing project-owned overlay paths.

`scripts/check-workflow-leak.sh` must fail when:

- reusable `.ai/**` materialized files are tracked outside the project-owned allowlist,
- `.ai-template` is not represented as the expected gitlink when present in the repository,
- a copied private workflow tree appears outside the submodule,
- a tracked file exposes private workflow credentials or local authentication material.

The check must not fail merely because setup has materialized private workflow files in the working tree.

## 8. Thin agent adapters

`AGENTS.md`, `CLAUDE.md`, Cursor rules, and GitHub Copilot instructions are public thin adapters.

Repo-scoped Codex skills and Cursor commands are materialized from `szymoniwacz/ai-project-template` so they stay synchronized with the canonical workflow.

They must not reproduce reusable workflow rules. Their role is to tell the agent:

1. run setup when `.ai/README.md` is not materialized,
2. treat `.ai/` as source of truth,
3. read `.ai/README.md` first,
4. follow the private workflow documents from `.ai/`.

## 9. Automation loaders

Cloud automations cannot assume private `.ai/automation/*.md` is committed on `origin/main` of a public target repository.

The adapter therefore contains public thin loaders under `docs/ai-workflow/`.

A loader may:

1. verify the private submodule/workflow is available in the automation workspace,
2. run or require workflow setup,
3. verify the materialized executor files exist,
4. load the private Project Executor or Goal Executor document,
5. delegate completely to that document.

A loader must not duplicate executor state machines, authorization rules, review rules, or merge rules.

If private workflow access is unavailable, the loader must stop without repository mutation or remote write.

## 10. Authentication

The submodule solves workflow location and versioning, not authorization.

Any local or cloud environment that needs the workflow must have read access to `szymoniwacz/ai-project-template`.

Credentials must never be committed to the adapter or target repository. Cloud automation credentials belong in the automation provider's secret/runtime configuration.

A user without access should receive a clear setup failure and no fallback implementation.

## 11. Workflow upgrades

Setup refreshes the configured private workflow remote and rematerializes `.ai/`:

```text
./scripts/setup-ai-workflow.sh
```

The adapter may provide a helper script that reports the old and new revisions, but neither setup nor the helper may commit automatically.

After refresh, the target repository may commit the changed `.ai-template` gitlink when it wants to record that workflow revision explicitly.

## 12. Diagnostics

The workflow doctor checks at least:

- repository root,
- `.gitmodules`,
- `.ai-template` gitlink/configuration,
- initialized private submodule,
- expected private `.ai/` structure,
- Project Executor and Goal Executor presence,
- materialized `.ai/README.md`,
- project overlay presence,
- leak-check result,
- private workflow revision when available.

Its final state is `ready` or `not ready`.

## 13. Tests

Tests must use a local fake private workflow fixture, never the real private repository.

Contract coverage includes:

1. valid materialization,
2. setup initialization behavior,
3. setup refreshes a newer configured remote revision,
4. fail-closed behavior when workflow is unavailable,
5. invalid workflow structure,
6. tracked overlay preservation,
7. preservation of uncommitted overlay edits,
8. stale template file deletion,
9. idempotent repeated setup,
10. reusable private workflow remaining untracked,
11. leak detection for accidentally tracked private files,
12. nested-directory invocation,
13. workflow revision reporting,
14. Linux and macOS CI execution,
15. Codex and Cursor adapter materialization.

## 14. Invariants

The following are architectural invariants:

A. Private workflow contents are never tracked in a public target repository.

B. `.ai-template` is the single upstream reusable workflow source.

C. `.ai/` is the runtime source of truth.

D. Tracked project overlay survives every setup and workflow update.

E. Updating the private workflow does not overwrite project-owned context.

F. Private workflow unavailable means fail closed.

G. Public loaders never implement Project Executor or Goal Executor logic.

H. Local and cloud execution use the same materialized workflow layout.

I. Setup refreshes `.ai-template` from its configured remote before materialization; the gitlink may record the selected revision when committed.

J. The adapter does not maintain a second runtime-delegation architecture.

## 15. Out of scope

The adapter does not:

- publish or vendor private workflow files,
- provide a public fallback workflow,
- implement Project Executor or Goal Executor itself,
- automatically commit workflow upgrades,
- solve provider-specific secret provisioning in code,
- copy DiffRat-specific project context into generated repositories.

## 16. Target bootstrap

The desired target-repository bootstrap is intentionally small:

```bash
./scripts/setup-ai-workflow.sh
```

The script initializes or updates the private submodule and materializes the workflow. The user then customizes tracked project context and can use the normal AI workflow, including `/execute-goal` and `/execute-project` when the corresponding automation environment has private-repository access.
