# AI Project Template Adapter

**A lightweight, public integration layer for a private AI-assisted development workflow.**

I built this adapter to reuse one development workflow across multiple repositories, coding agents, and cloud automations—without duplicating its instructions or publishing the private implementation.

> **For reviewers:** This repository demonstrates the *integration architecture*, setup, safeguards, and contract tests. It is **not** a public demo of the private AI agents or their code-review behavior. You can inspect the code and run the tests without private access.

## At a glance

| Problem | Approach |
| --- | --- |
| Multiple tools need the same workflow instructions | One shared workflow, materialized into each repository |
| Each project has its own requirements and decisions | Preserve tracked project-specific context on every update |
| The reusable workflow must remain private | Reference it through a private Git submodule; never commit materialized reusable files |
| Missing or invalid workflow should not cause silent degradation | Stop setup with an explicit error |
| Integration should be verifiable without private access | Contract tests use a fake private workflow fixture |

## Architecture

```text
                    Target repository
                    ├── .ai/project/           tracked project context
                    └── .ai-template/          private Git submodule
                              |
                              v
                    setup-ai-workflow.sh
                              |
                    materialized .ai/
                              |
                  +-----------+-----------+
                  |                       |
             Local agents          Cloud automations
             Codex / Cursor        Project / Goal Executor
```

The setup script updates the private submodule, materializes the workflow into `.ai/`, restores tracked project-owned files, and prepares the Codex/Cursor adapters and issue templates for GitHub/GitLab. Agents use `.ai/` as their local source of truth.

The private submodule is a *reference*, not a copy of the private source in this public repository.

## Start here: review without private access

These actions **do not** require access to my private workflow:

```bash
bash tests/test-adapter.sh
bash scripts/check-workflow-leak.sh
```

- [Read the technical reviewer guide](docs/reviewer-guide.md) — decisions, trade-offs, and what to inspect.
- [Inspect setup](scripts/setup-ai-workflow.sh) — updates, materialization, project-context preservation.
- [Inspect contract tests](tests/test-adapter.sh) — behavior and failure cases using a local fixture.
- [Read architecture](docs/architecture.md) — private workflow, public adapter, project overlay.
- [Read full specification](docs/repository-specification.md) — requirements and invariants.

CI runs the contract tests on **Ubuntu**; see [the CI workflow](.github/workflows/ci.yml).

**External reviewers should not run `./scripts/setup-ai-workflow.sh`:** it requires read access to the private `szymoniwacz/ai-project-template` repository and will stop without it.

## Using the adapter in an authorized project

Create a repository from this template and configure read access to the private workflow:

```bash
./scripts/setup-ai-workflow.sh
./scripts/ai-workflow-doctor.sh
./scripts/check-workflow-leak.sh
```

Setup updates the private submodule to its configured remote branch. The script does **not** commit the updated submodule revision; you can choose when to record that Git revision in the target repository.

Then customize tracked project context under `.ai/project/`. Agents start with `.ai/README.md`. Codex skills and Cursor commands are thin adapters that delegate to the same private workflow.

For future updates:

```bash
./scripts/update-ai-workflow.sh
git status --short
git diff --submodule
```

Review newly materialized files before committing: the private `.ai/` runtime must remain untracked; GitHub/GitLab issue templates are intended to be committed when appropriate.

More details: [setup](docs/setup.md) · [cloud automation](docs/automation-setup.md).

## Security boundaries

- The private workflow is referenced by a Git submodule and is not committed here.
- Private runtime files may exist locally after setup; they must not be tracked in public repositories.
- `check-workflow-leak.sh` detects **specific tracked-file paths and obvious private tree copies**. It is **not a secrets scanner**.
- Cloud credentials belong in secret stores or runtime configuration, never in repository files.
- Without access to the private submodule, setup fails rather than guessing a replacement workflow.

## Limitations

The complete agentic workflow, review policies and executor logic are **not available** in this public adapter. Contract tests verify integration behavior—not the correctness of AI-generated code. The submodule records a revision of the private workflow; setup can fetch newer revisions.

## License

MIT.
