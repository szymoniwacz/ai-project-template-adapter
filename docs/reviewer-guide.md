# Technical walkthrough

**A public adapter for one private AI development workflow.** I use it to share the same instructions across projects and tools without duplicating them or losing project-specific context.

## Design in brief

| Decision | Why it matters | Inspect |
| --- | --- | --- |
| Private submodule | Reusable, versioned source without publishing private code | [Git configuration](../.gitmodules) |
| Local `.ai/` runtime | One entry point for coding tools and automation | [Setup](../scripts/setup-ai-workflow.sh) |
| Tracked project overlay | Requirements and decisions survive workflow updates | [Setup](../scripts/setup-ai-workflow.sh), [Tests](../tests/test-adapter.sh) |
| Fail-closed setup | Missing private access stops the operation | [Setup](../scripts/setup-ai-workflow.sh) |
| Thin automation loaders | Executor behavior stays in one private source | [Goal](ai-workflow/goal-executor-loader.md), [Project](ai-workflow/project-executor-loader.md) |
| Fixture tests | Anyone can test the adapter without secrets | [Tests](../tests/test-adapter.sh), [CI](../.github/workflows/ci.yml) |

## Verify the adapter

```bash
bash tests/test-adapter.sh
bash scripts/check-workflow-leak.sh
```

Both commands are public. The tests simulate the private repository; they do not execute the real AI workflow.

## See the working process

[Installation, health checks, updates, and troubleshooting](setup.md) · [Review, auto-merge, supervised mode, and commands](workflow-modes.md)

## Why the workflow matters

The private workflow goes beyond prompting an AI to write code. It coordinates an authorized issue-to-PR process: dependency preflight, scoped implementation, validation, review, CI stabilization, and human-controlled or explicitly authorized merge. Project execution also handles concurrency, recovery, and evidence-backed audits.

[See the execution modes and project orchestration diagram](workflow-modes.md#project-orchestration-and-recent-workflow-capabilities).

## Important boundaries

The private workflow includes separate implementation, validation, and review stages. Its implementation is **not** included here. The public leak check is path-based and does not scan secrets. Passing adapter tests does **not** establish AI code-review accuracy.

[Architecture](architecture.md) · [Current limitations and improvement ideas](improvements.md) · [Detailed specification](repository-specification.md)
