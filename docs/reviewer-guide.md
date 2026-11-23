# Technical reviewer guide

**Reading time: about 3 minutes.** This public repository is the integration layer for a private AI-assisted software development workflow.

## The problem

As I started using the same AI-assisted development process in different projects, I wanted to avoid copying and maintaining instructions separately in each repository and coding tool. At the same time, project-specific requirements and decisions needed to remain version-controlled and survive workflow upgrades.

## The design

```text
                  target repository
              +-----------+------------+
              |                        |
         .ai/project/              .ai-template
         project context           private submodule
              |                        |
              +-----------+------------+
                          |
                 setup-ai-workflow.sh
                          |
                  local .ai/ runtime
                          |
               Codex / Cursor / automation
```

There are three clear ownership boundaries:

1. **Private workflow:** reusable instructions, skills, review policies and executors.
2. **Public adapter (this repository):** setup, diagnostics, local tool integrations, public automation loaders, and contract tests.
3. **Project-owned files:** tracked context such as requirements and decisions, preserved when the workflow is refreshed.

## Engineering decisions worth reviewing

| Choice | Motivation | Evidence |
| --- | --- | --- |
| Private Git submodule | Reuse a versioned source without publishing its contents | [`.gitmodules`](../.gitmodules) |
| Materialize into `.ai/` | Give different tools one local entry point | [setup script](../scripts/setup-ai-workflow.sh), [agent entry point](../AGENTS.md) |
| Preserve tracked project context | Avoid overwriting requirements or decisions during updates | [setup script](../scripts/setup-ai-workflow.sh), [contract tests](../tests/test-adapter.sh) |
| Explicit failure when private source is missing | Avoid silently running an incomplete or inconsistent workflow | [setup script](../scripts/setup-ai-workflow.sh) |
| Keep automation loaders thin | Avoid duplicating private executor logic in public files | [Project Executor loader](ai-workflow/project-executor-loader.md), [Goal Executor loader](ai-workflow/goal-executor-loader.md) |
| Test with a fake private workflow | Make the integration independently testable without publishing private source | [tests](../tests/test-adapter.sh), [CI](../.github/workflows/ci.yml) |

## Verify in two commands

No private access is required for the contract tests:

```bash
bash tests/test-adapter.sh
bash scripts/check-workflow-leak.sh
```

The tests cover setup/refresh, idempotency, tracked overlay preservation, stale-file removal, failure scenarios, provider issue-template generation and Codex/Cursor adapter materialization. CI runs the test suite on Ubuntu.

**Do not run the production setup script without private access.** It is designed to fail if the private submodule cannot be loaded.

## How this relates to AI-assisted engineering

This adapter is not the agent that writes or reviews code. It is the infrastructure that makes a shared workflow reusable and keeps the boundary between reusable instructions and project-specific context explicit.

In the private workflow, implementation and review are separate stages, with quality gates and human-decision boundaries. Those internal procedures are intentionally **not published** in this adapter; this repository is evidence of integration design, not proof that AI review reliably catches every defect.

## Trade-offs and limitations

- **Private access requirement:** external reviewers cannot run the actual workflow; they *can* inspect and test this adapter.
- **Freshness vs reproducibility:** setup fetches the configured remote revision. The gitlink can record the selected revision, but updating it is a separate, explicit action.
- **Path-based leak check:** catches selected accidental commits, not arbitrary secrets or sensitive contents. Publication still needs human review and a separate secret scan.
- **Test scope:** public contract tests use a fake workflow. They do not test actual model behavior or production correctness.

For technical details, see the [full repository specification](repository-specification.md) and [cloud automation contract](automation-setup.md).
