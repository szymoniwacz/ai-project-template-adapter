# Setup guide

This guide is for users who **already have read access** to the private `szymoniwacz/ai-project-template` repository. Without it, setup stops. Public reviewers can still [run adapter tests](../README.md#try-the-public-adapter).

## First use

1. Select **Use this template** on GitHub, create a repository, and clone it.
2. Run:

   ```bash
   ./scripts/setup-ai-workflow.sh
   ./scripts/ai-workflow-doctor.sh
   ./scripts/check-workflow-leak.sh
   ```

3. Look for `Status: ready` from the doctor.
4. Write project context in tracked files under `.ai/project/`, starting with:
   - `product-context.md` — what you are building
   - `roadmap.md` — planned work
   - `decisions.md` — important decisions
5. Open the project in Codex or Cursor. Follow `.ai/README.md` and use the appropriate workflow commands for your task.

Setup downloads/updates the private submodule, checks its expected files, copies the shared workflow into `.ai/`, preserves tracked project files, and materializes tool adapters and issue templates.

## Update

```bash
./scripts/update-ai-workflow.sh
./scripts/ai-workflow-doctor.sh
./scripts/check-workflow-leak.sh
git status --short
git diff --submodule
```

The script fetches the configured remote revision. **It does not commit the updated submodule reference.**

Review any new project-context files and GitHub/GitLab issue templates. Commit only the intended project files, provider templates, and (if desired) the submodule reference. **Never commit the copied private workflow.** Avoid `git add -A` without inspecting the file list.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| Private workflow unavailable | Confirm your Git credentials have read access to the private repository |
| Doctor says `not ready` | Run setup again and read the failed check |
| Leak check fails | Inspect the named tracked path; do not bypass the check |

For security boundaries see the [repository specification](repository-specification.md). The leak check is path-based, not a full secrets scanner.
