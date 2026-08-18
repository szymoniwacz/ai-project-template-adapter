# AI Project Template Adapter

Thin adapter for using a private `ai-project-template` workflow in public or private repositories without copying the workflow implementation into them.

## Architecture

```text
project repository
        ↓
ai-project-template-adapter
        ↓
private ai-project-template
```

The responsibilities are deliberately separated:

- `ai-project-template` owns the reusable AI workflow and behavior.
- the target repository owns project-specific context and source code.
- this adapter owns discovery, validation, delegation, diagnostics, and leak protection.

## Core rule

```text
Private repo owns behavior.
Public repo owns context.
Adapter owns the connection.
```

The adapter must stay thin. It must not contain copied workflows, prompts, policies, review rules, or orchestration from the private repository.

## Local setup

Point the adapter at a local checkout of the private workflow:

```bash
export AI_PROJECT_TEMPLATE_HOME="/path/to/ai-project-template"
```

Optional local-only configuration is also supported through `.ai/local.yml`; see `.ai/local.example.yml`.

Project-specific AI context belongs in `.ai/` in the target repository.

## Validate the connection

Run:

```bash
bin/ai-workflow-doctor
```

The doctor verifies:

- the target Git repository,
- workflow path configuration,
- workflow checkout identity,
- the canonical private workflow entrypoint,
- project-specific `.ai/project.md` context.

## Delegate to the private workflow

Use:

```bash
bin/ai-workflow <arguments>
```

The adapter forwards arguments unchanged and exports:

```text
AI_TARGET_REPOSITORY
AI_PROJECT_CONTEXT
```

The private workflow must expose the stable executable:

```text
$AI_PROJECT_TEMPLATE_HOME/bin/ai-workflow
```

See [`docs/compatibility-contract.md`](docs/compatibility-contract.md).

## Prevent private workflow leakage

Run:

```bash
bin/check-workflow-leak
```

The deterministic check rejects known reusable workflow directories, tracked local adapter configuration, and symlinks pointing toward the private workflow.

## Tests

The adapter contract is tested without access to the real private workflow.

A minimal fake workflow fixture verifies:

- fail-closed behavior,
- argument forwarding,
- target/context propagation,
- exit-code propagation,
- doctor diagnostics,
- leak detection.

Run locally with:

```bash
bash tests/test-adapter.sh
```

CI runs the same contract tests on Linux and macOS.

## Current integration status

The public adapter side is implemented and contract-tested.

End-to-end use with the real private `szymoniwacz/ai-project-template` still requires that repository to expose the canonical executable defined by the compatibility contract:

```text
bin/ai-workflow
```

Until that exists, the adapter intentionally fails closed rather than recreating workflow behavior locally.

## Security

Never commit:

- private workflow contents,
- credentials or tokens,
- machine-specific private paths,
- private repository authentication data.

Normal project development must remain usable without access to the private AI workflow.

## Design documentation

- [`docs/repository-specification.md`](docs/repository-specification.md) — source of truth for repository architecture and scope.
- [`docs/compatibility-contract.md`](docs/compatibility-contract.md) — stable adapter/private-workflow boundary.

## License

MIT
