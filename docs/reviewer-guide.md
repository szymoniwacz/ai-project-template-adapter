# Technical overview for reviewers

This repository is a **public integration adapter**, not the AI development workflow itself. It demonstrates how I connect a reusable, privately maintained AI workflow to multiple project repositories and coding tools without copying its implementation into those projects.

## What problem does it solve?

I want the same workflow instructions to work across repositories, local coding agents and cloud automation, while keeping project-specific requirements and decisions under version control. I also want workflow upgrades to preserve those project-specific files.

The adapter separates three concerns:

1. **Private reusable workflow** — prompts, policies, skills, executors and review instructions (not published here).
2. **Public adapter** — setup, updates, diagnostics, integration contracts and protection against accidentally committing private workflow files.
3. **Project context** — tracked requirements, decisions and other project-owned files, overlaid on the locally materialized workflow.

```text
                         public target repository
                                   |
                +------------------+------------------+
                |                                     |
        tracked project context             .ai-template submodule
          (.ai/project/**)                   (private workflow)
                |                                     |
                +------------------+------------------+
                                   |
                       setup-ai-workflow.sh
                                   |
                        materialized .ai/ runtime
                                   |
                    +--------------+--------------+
                    |                             |
            local coding tools              cloud automation
            (Codex / Cursor)              (private executors)
```

## Key engineering decisions

| Decision | Why it matters | Where to inspect |
| --- | --- | --- |
| Private Git submodule | The public repository points to a versioned workflow without publishing its contents | `.gitmodules`, `docs/repository-specification.md` |
| Project-owned overlay | Refreshing reusable instructions must not overwrite tracked project requirements and decisions | `scripts/setup-ai-workflow.sh` |
| One local source of truth | Integrations refer to materialized `.ai/` instead of maintaining separate copies of reusable instructions | `AGENTS.md`, `CLAUDE.md`, `docs/architecture.md` |
| Fail-closed setup | Missing private workflow access stops setup instead of silently replacing it with incomplete logic | `scripts/setup-ai-workflow.sh` |
| Leak check | Rejects tracked reusable workflow paths and certain copies of private content | `scripts/check-workflow-leak.sh` |
| Contract tests | Checks setup, updates, overlay preservation, failure cases and integration materialization against a fake private workflow | `tests/test-adapter.sh` |

## What you can review without private access

- Read the public shell scripts and the integration contract.
- Examine the architecture and public automation loaders under `docs/`.
- Run `bash tests/test-adapter.sh` on macOS or Linux. Tests use a local fake private workflow, not my real private repository.
- Run `bash scripts/check-workflow-leak.sh` to inspect the tracked-file leak guard.
- Inspect `.github/workflows/ci.yml` for the CI test configuration.

The setup command `./scripts/setup-ai-workflow.sh` **requires access to my private workflow** and is **not expected to work for external reviewers**.

## Scope and limitations

- This is an **adapter/infrastructure example**, not an executable public demo of my full agentic development process.
- The actual Project Executor, Goal Executor, code-review instructions and validation policies are private, so this repository alone does not demonstrate their behavior.
- The leak check covers specific tracked paths and cases. It is not a comprehensive secrets scanner or proof that arbitrary project files are safe to publish.
- The repo's test suite verifies the adapter contract using fixtures; it does not validate AI-generated code quality or production correctness.
- The public repository reflects the version committed here; the private workflow may evolve independently.

## Why I built it

I wanted a maintainable way to share one evolving workflow between projects and tools while preserving each project's context. It reflects an engineering approach I also apply when using AI coding agents: explicit boundaries, reproducible setup, deterministic checks where possible, and clear failure behavior.

For implementation details, see [repository specification](repository-specification.md) and [setup guide](setup.md).
