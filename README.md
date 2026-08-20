# ai-project-template-adapter

Public GitHub template for using the private `szymoniwacz/ai-project-template` workflow without publishing its reusable workflow files.

## How it works

```text
target repository
      |
      v
.ai-template/                 private git submodule
      |
      v
./scripts/setup-ai-workflow.sh
      |
      +--> .ai/               runtime source of truth
      +--> .agents/skills/    Codex repo skills
      +--> .cursor/commands/  Cursor slash commands
```

Setup updates `.ai-template` to the latest configured remote revision, materializes the private `.ai/` tree and thin tool adapters locally, then restores project-owned tracked `.ai/**` files over the workflow.

Private workflow files may exist in the working tree, but they must never be committed to a public target repository.

## Create a project

After creating a repository from this template and cloning it:

```bash
./scripts/setup-ai-workflow.sh
```

The script initializes or updates `.ai-template` and materializes the current private workflow plus Codex/Cursor adapters. Your GitHub identity or automation environment must have read access to `szymoniwacz/ai-project-template`.

Then customize the tracked project context under:

```text
.ai/project/
```

After setup, agents should read `.ai/README.md` and treat `.ai/` as the workflow source of truth. Tool adapters under `.agents/skills/` and `.cursor/commands/` only delegate into that shared workflow.

## Check the connection

```bash
./scripts/ai-workflow-doctor.sh
```

A ready repository ends with:

```text
Status: ready
```

## Prevent workflow leaks

```bash
./scripts/check-workflow-leak.sh
```

The check allows private workflow files to exist locally after setup, but fails if reusable materialized workflow files are tracked outside the project-owned overlay allowlist.

## Update the private workflow

Running setup again updates and rematerializes the workflow and tool adapters:

```bash
./scripts/setup-ai-workflow.sh
```

For a revision summary around the same operation, use:

```bash
./scripts/update-ai-workflow.sh
```

Neither script commits the changed `.ai-template` gitlink. Review and commit that change explicitly when you want the project to record the new workflow revision.

## Cloud automation

Public loaders live under:

```text
docs/ai-workflow/project-executor-loader.md
docs/ai-workflow/goal-executor-loader.md
```

They contain no private executor logic. They only require the automation environment to obtain the private submodule, materialize `.ai/`, and then delegate to the private runtime.

Automation credentials belong in the provider's runtime/secret configuration, never in this repository.

See `docs/automation-setup.md` for the integration contract.

## Tests

```bash
bash tests/test-adapter.sh
```

Tests use a local fake private workflow fixture. CI never requires access to the real private repository.

## Design

- `docs/repository-specification.md` — source-of-truth architecture and invariants.
- `docs/setup.md` — target repository setup and workflow updates.
- `docs/automation-setup.md` — cloud automation integration.

## Security model

Someone without access to `szymoniwacz/ai-project-template` may see the repository URL and committed submodule revision, but cannot fetch the private workflow contents. Setup fails closed when the private workflow cannot be loaded.

## License

MIT
