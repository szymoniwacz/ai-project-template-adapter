# Install, verify, and update

This guide is for users with **read access** to the private `szymoniwacz/ai-project-template`. Without it, production setup cannot run. External reviewers can still [test the public adapter](../README.md#run-the-public-tests).

## 1. Install

1. On GitHub, select **Use this template**, create a repository, and clone it.
2. From the repository root, run:

   ```bash
   ./scripts/setup-ai-workflow.sh
   ```

This updates the private Git submodule and materializes workflow instructions to `.ai/`, agent integrations, and GitHub/GitLab issue templates. It preserves existing files in `.ai/project/` (tracked or untracked), seeds missing project defaults from the private workflow, and restores other **tracked** project-specific `.ai/` files after copying the reusable workflow.

**Important before running setup again:** the script uses `rsync --delete` for `.ai/`, `.agents/skills/`, `.cursor/commands/`, `.github/ISSUE_TEMPLATE/`, and `.gitlab/issue_templates/`. Files in these destinations that are not in the current private template may be removed, **except files in `.ai/project/`, which setup leaves intact**. Only tracked files outside `.ai/project/` are restored by the overlay. Review or back up custom files and provider issue templates — **including tracked ones** — before updating. Tracked issue templates are not part of the preserved `.ai/` overlay.

## 2. Check that it works

```bash
./scripts/ai-workflow-doctor.sh
./scripts/check-workflow-leak.sh
```

Expect **`Status: ready`** and **`Workflow leak check: clean`**. The doctor confirms required files and executor entry points exist; it does **not** prove the agents have executed a task successfully.

## 3. Configure your project

Edit the project-owned files in `.ai/project/` (the first three are tracked by default; `alignment.yaml` comes from the private workflow):

| File | What to write |
| --- | --- |
| `product-context.md` | What the project is and who it serves |
| `roadmap.md` | Goals and upcoming work |
| `decisions.md` | Important decisions and constraints |
| `alignment.yaml` (seeded by private setup) | Optional project-specific alignment settings; keep default values or customize as needed |

`alignment.yaml` is ignored by Git by default, like other private-seeded runtime files. After customizing it, keep it local or intentionally run `git add -f .ai/project/alignment.yaml` and commit it if the settings must persist across clones. Avoid staging unreviewed private workflow content. The public adapter does not contain a copy of the private default configuration. Untracked project files are preserved locally but do **not** travel with the repository.

Open your repository in Codex or Cursor, read `.ai/README.md`, and follow the commands available in your tool. For new project context files, check `.gitignore`: not every path under `.ai/project/` is automatically unignored. For goal execution modes and required authorization, see [Workflow commands](workflow-modes.md#available-options).

## 4. Update

```bash
./scripts/update-ai-workflow.sh
./scripts/ai-workflow-doctor.sh
./scripts/check-workflow-leak.sh
git status --short
git diff --submodule
```

Setup intentionally fetches the configured private remote revision, which may differ from the submodule commit recorded in Git. The update helper reports old/new revisions but **does not commit** the new submodule reference.

Review the changed files. You may commit intended project-specific context, provider issue templates, and an explicitly chosen submodule revision. **Never commit copied private workflow files.** Avoid `git add -A` without reviewing every staged path.

## 5. Public contract tests

```bash
bash tests/test-adapter.sh
```

These tests run with a **fake private workflow** and require no credentials. CI runs on **Ubuntu only**.

## Troubleshooting

| Result | What to do |
| --- | --- |
| `private AI workflow is unavailable` | Check Git credentials and read access to `szymoniwacz/ai-project-template` |
| `Status: not ready` | Read the failed doctor check, correct it, and rerun setup |
| `Workflow leak check` fails | Inspect the named tracked paths; do not bypass the check |
| Extra untracked templates or context files | Review individually before staging; some provider templates are expected after setup |

The leak check is path-based, **not** a general secret scanner. See the [security contract](repository-specification.md#7-git-ignore-and-leak-model).
