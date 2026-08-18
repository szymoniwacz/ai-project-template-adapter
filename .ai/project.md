# Project Context

Replace placeholder values during project bootstrap. Keep only facts that are true for the target repository.

## Identity

- Name: `<project-name>`
- Purpose: `<short project purpose>`
- Repository type: `<application | library | CLI | service | other>`
- Main language: `<language>`
- Framework: `<framework or none>`

## Commands

Record only commands that actually work in the target repository.

| Action | Command |
|---|---|
| Setup | `<setup command>` |
| Test | `<test command>` |
| Lint | `<lint command>` |
| Format | `<format command or n/a>` |
| Typecheck | `<typecheck command or n/a>` |
| Build | `<build command or n/a>` |
| Run | `<run command>` |

## Architecture

Describe only the important project-specific boundaries:

- main modules/components,
- orchestration points,
- infrastructure boundaries,
- important dependency directions.

## Repository Structure

Document where the important project-specific code and documentation live.

## Project-Specific Constraints

List rules that belong specifically to this project.

Do not copy generic AI workflow rules here. Reusable planning, implementation, review, authorization, and quality rules belong to the private `szymoniwacz/ai-project-template` workflow.
