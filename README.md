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
- this adapter owns discovery, validation, delegation, and diagnostics.

## Core rule

```text
Private repo owns behavior.
Public repo owns context.
Adapter owns the connection.
```

The adapter must stay thin. It must not contain copied workflows, prompts, policies, review rules, or orchestration from the private repository.

## Local setup

The intended local integration uses:

```bash
export AI_PROJECT_TEMPLATE_HOME="/path/to/ai-project-template"
```

Project-specific AI context belongs in `.ai/` in the target repository.

## Status

The repository is being built incrementally from the architecture defined in [`docs/repository-specification.md`](docs/repository-specification.md).

The private workflow currently needs a stable execution entrypoint before end-to-end delegation can be considered complete.

## Security

Never commit:

- private workflow contents,
- credentials or tokens,
- machine-specific private paths,
- private repository authentication data.

Normal project development must remain usable without access to the private AI workflow.
