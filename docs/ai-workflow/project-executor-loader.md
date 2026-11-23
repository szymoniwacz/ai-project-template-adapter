# Project Executor — Public Loader

This file is a public loader only. It does not implement Project Executor behavior.

Before any **executor-driven** repository mutation or remote write (setup itself can update the local submodule/worktree):

1. Resolve the target repository default branch and current workspace.
2. Run `./scripts/setup-ai-workflow.sh` in the authorized workspace to initialize/refresh the private submodule and materialize the runtime. The required private-repository access must already be configured.
3. If private workflow access or setup fails, do not proceed to executor-driven repository changes or remote writes; report the blocker. Bootstrap may have made local workspace changes.
4. Verify `.ai/automation/project-executor.md` and `.ai/automation/goal-executor.md` exist after setup.
5. Read both files from the materialized `.ai/` runtime.
6. Follow `project-executor.md` for orchestration and `goal-executor.md` for delegated goals.
7. Do not infer, duplicate, or replace private executor rules from this loader.

The automation environment must have read access to `szymoniwacz/ai-project-template`. Credentials belong in the automation provider's runtime/secret configuration and must never be committed.
