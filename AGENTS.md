# Agent Integration

This repository uses an external private AI workflow.

Canonical reusable workflow:

`szymoniwacz/ai-project-template`

Project-specific context lives in:

`.ai/`

Use `bin/ai-workflow-doctor` to validate the connection and `bin/ai-workflow` as the integration entrypoint.

Do not recreate missing reusable workflow rules in this repository. If the canonical workflow is unavailable, fail clearly instead of inventing a fallback process.
