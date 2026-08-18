# Compatibility Contract

This document defines the intentionally small boundary between `ai-project-template-adapter` and the private `szymoniwacz/ai-project-template` workflow.

The adapter must depend on this contract only. Internal workflow directories and documents remain private implementation details.

## Required workflow checkout

The adapter expects `AI_PROJECT_TEMPLATE_HOME` to point to a local Git checkout whose directory name is:

```text
ai-project-template
```

The checkout must expose one stable executable entrypoint:

```text
$AI_PROJECT_TEMPLATE_HOME/bin/ai-workflow
```

## Environment provided by the adapter

Before delegating, the adapter exports:

```text
AI_TARGET_REPOSITORY
AI_PROJECT_CONTEXT
```

`AI_TARGET_REPOSITORY` is the absolute Git root of the target project.

`AI_PROJECT_CONTEXT` is:

```text
$AI_TARGET_REPOSITORY/.ai
```

## Arguments

All arguments passed to:

```text
bin/ai-workflow
```

must be forwarded unchanged to the canonical private workflow entrypoint.

## Exit status

The adapter must return the exact exit status produced by the canonical workflow entrypoint.

## Failure behavior

The adapter fails closed when any required part of the contract is unavailable.

It must not:

- copy workflow files into the target project,
- reconstruct missing workflow behavior,
- use a public fallback workflow,
- infer private workflow internals.

## Compatibility principle

The private workflow may change its internal structure freely as long as this boundary remains stable:

```text
bin/ai-workflow
AI_TARGET_REPOSITORY
AI_PROJECT_CONTEXT
arguments
exit status
```

This keeps connected repositories isolated from private implementation changes.
