# Target Repository Setup

## First setup

Create a repository from this GitHub template, clone it, then run:

```bash
./scripts/setup-ai-workflow.sh
```

The setup command:

1. verifies `.gitmodules`,
2. initializes `.ai-template` when needed and updates it from the configured remote,
3. validates the expected private workflow structure,
4. saves tracked project-specific `.ai/**` files,
5. materializes `.ai-template/.ai/` into `.ai/`,
6. restores the project overlay,
7. reports the private workflow revision.

No `AI_PROJECT_TEMPLATE_HOME` environment variable is required.

## Access requirement

The local Git identity must be able to read:

```text
https://github.com/szymoniwacz/ai-project-template.git
```

If access is unavailable, setup stops. There is no public fallback workflow.

## Project context

The template seeds:

```text
.ai/project/product-context.md
.ai/project/roadmap.md
.ai/project/decisions.md
```

These files are target-owned and remain tracked. Other project-specific `.ai/**` files may be tracked according to the ownership contract in `docs/repository-specification.md`.

## Verify

Run:

```bash
./scripts/ai-workflow-doctor.sh
./scripts/check-workflow-leak.sh
```

## Update the workflow

Run setup again whenever you want to refresh the private workflow and rematerialize `.ai/`:

```bash
./scripts/setup-ai-workflow.sh
```

`./scripts/update-ai-workflow.sh` performs the same refresh and additionally reports the old and new revisions.

Then review:

```bash
git status
git diff --submodule
```

Commit the `.ai-template` gitlink only when you want the target repository to record the refreshed workflow revision. Materialized private `.ai/` files remain local and ignored.

## Clone with submodules

`git clone --recurse-submodules ...` is supported, but not required. The setup script initializes `.ai-template` when it is absent.
