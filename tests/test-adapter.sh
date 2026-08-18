#!/usr/bin/env bash
set -euo pipefail

adapter_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT

project="$tmp_root/project"
workflow="$tmp_root/ai-project-template"
wrong_workflow="$tmp_root/not-the-template"
outside="$tmp_root/outside"

mkdir -p "$project/bin" "$project/.ai" "$project/nested/deeper" "$workflow/bin" "$wrong_workflow/bin" "$outside"

git -C "$project" init -q
git -C "$workflow" init -q
git -C "$wrong_workflow" init -q

cp "$adapter_root/bin/ai-workflow" "$project/bin/ai-workflow"
cp "$adapter_root/bin/ai-workflow-doctor" "$project/bin/ai-workflow-doctor"
cp "$adapter_root/bin/check-workflow-leak" "$project/bin/check-workflow-leak"
cp "$adapter_root/.gitignore" "$project/.gitignore"
cp "$adapter_root/tests/fixtures/fake-ai-project-template/bin/ai-workflow" "$workflow/bin/ai-workflow"
cp "$adapter_root/tests/fixtures/fake-ai-project-template/bin/ai-workflow" "$wrong_workflow/bin/ai-workflow"
chmod +x "$project/bin/ai-workflow" "$project/bin/ai-workflow-doctor" "$project/bin/check-workflow-leak" "$workflow/bin/ai-workflow" "$wrong_workflow/bin/ai-workflow"
touch "$project/.ai/project.md"

project_root="$(git -C "$project" rev-parse --show-toplevel)"

assert_contains() {
  local haystack="$1"
  local needle="$2"

  if [[ "$haystack" != *"$needle"* ]]; then
    printf 'Expected output to contain: %s\nActual output:\n%s\n' "$needle" "$haystack" >&2
    exit 1
  fi
}

assert_failure() {
  local status="$1"
  if [[ "$status" -eq 0 ]]; then
    printf 'Expected command to fail, but it succeeded.\n' >&2
    exit 1
  fi
}

printf '1. missing configuration fails closed\n'
set +e
missing_output="$(cd "$project" && env -u AI_PROJECT_TEMPLATE_HOME ./bin/ai-workflow 2>&1)"
missing_status=$?
set -e
assert_failure "$missing_status"
assert_contains "$missing_output" "AI_PROJECT_TEMPLATE_HOME is not configured"

printf '2. nonexistent workflow path fails clearly\n'
set +e
nonexistent_output="$(cd "$project" && AI_PROJECT_TEMPLATE_HOME="$tmp_root/missing" ./bin/ai-workflow 2>&1)"
nonexistent_status=$?
set -e
assert_failure "$nonexistent_status"
assert_contains "$nonexistent_output" "AI_PROJECT_TEMPLATE_HOME does not exist"

printf '3. wrong workflow checkout identity fails clearly\n'
set +e
wrong_identity_output="$(cd "$project" && AI_PROJECT_TEMPLATE_HOME="$wrong_workflow" ./bin/ai-workflow 2>&1)"
wrong_identity_status=$?
set -e
assert_failure "$wrong_identity_status"
assert_contains "$wrong_identity_output" "configured workflow directory must be named ai-project-template"

printf '4. delegation forwards project context and arguments\n'
delegation_output="$(cd "$project" && AI_PROJECT_TEMPLATE_HOME="$workflow" ./bin/ai-workflow feature demo)"
assert_contains "$delegation_output" "target=$project_root"
assert_contains "$delegation_output" "context=$project_root/.ai"
assert_contains "$delegation_output" "args=feature demo"

printf '5. delegation works from a nested project directory\n'
nested_output="$(cd "$project/nested/deeper" && AI_PROJECT_TEMPLATE_HOME="$workflow" "$project/bin/ai-workflow" nested)"
assert_contains "$nested_output" "target=$project_root"
assert_contains "$nested_output" "context=$project_root/.ai"
assert_contains "$nested_output" "args=nested"

printf '6. running outside a Git repository fails clearly\n'
set +e
outside_output="$(cd "$outside" && AI_PROJECT_TEMPLATE_HOME="$workflow" "$project/bin/ai-workflow" 2>&1)"
outside_status=$?
set -e
assert_failure "$outside_status"
assert_contains "$outside_output" "run this command from inside a Git repository"

printf '7. local configuration fallback resolves the workflow\n'
printf 'workflow_path: %s\n' "$workflow" > "$project/.ai/local.yml"
local_fallback_output="$(cd "$project" && env -u AI_PROJECT_TEMPLATE_HOME ./bin/ai-workflow local-config)"
assert_contains "$local_fallback_output" "args=local-config"
rm "$project/.ai/local.yml"

printf '8. delegation preserves workflow exit code\n'
set +e
(cd "$project" && AI_PROJECT_TEMPLATE_HOME="$workflow" FAKE_WORKFLOW_EXIT_CODE=7 ./bin/ai-workflow >/dev/null 2>&1)
workflow_status=$?
set -e
[[ "$workflow_status" -eq 7 ]]

printf '9. delegation does not materialize private workflow directories\n'
(cd "$project" && AI_PROJECT_TEMPLATE_HOME="$workflow" ./bin/ai-workflow no-copy >/dev/null)
[[ ! -e "$project/.ai/workflows" ]]
[[ ! -e "$project/.ai/policies" ]]
[[ ! -e "$project/.ai/contracts" ]]

printf '10. doctor reports a valid connection\n'
doctor_output="$(cd "$project" && AI_PROJECT_TEMPLATE_HOME="$workflow" ./bin/ai-workflow-doctor)"
assert_contains "$doctor_output" "Status: ready"
assert_contains "$doctor_output" "canonical workflow entrypoint is executable"

printf '11. doctor reports a missing canonical entrypoint\n'
chmod -x "$workflow/bin/ai-workflow"
set +e
doctor_failure_output="$(cd "$project" && AI_PROJECT_TEMPLATE_HOME="$workflow" ./bin/ai-workflow-doctor 2>&1)"
doctor_failure_status=$?
set -e
assert_failure "$doctor_failure_status"
assert_contains "$doctor_failure_output" "canonical workflow entrypoint is missing or not executable"
chmod +x "$workflow/bin/ai-workflow"

printf '12. leak check passes for a clean project\n'
(cd "$project" && ./bin/check-workflow-leak >/dev/null)

printf '13. leak check rejects copied workflow directories\n'
mkdir -p "$project/.ai/workflows"
set +e
copied_output="$(cd "$project" && ./bin/check-workflow-leak 2>&1)"
copied_status=$?
set -e
assert_failure "$copied_status"
assert_contains "$copied_output" "forbidden reusable workflow path exists: .ai/workflows"
rmdir "$project/.ai/workflows"

printf '14. local configuration stays ignored by default\n'
printf 'workflow_path: %s\n' "$workflow" > "$project/.ai/local.yml"
ignored_files="$(git -C "$project" status --short --untracked-files=all)"
if [[ "$ignored_files" == *".ai/local.yml"* ]]; then
  printf '.ai/local.yml should be ignored by default.\n' >&2
  exit 1
fi
rm "$project/.ai/local.yml"

printf '15. leak check rejects tracked local configuration\n'
printf 'workflow_path: %s\n' "$workflow" > "$project/.ai/local.yml"
git -C "$project" add -f .ai/local.yml
set +e
local_config_output="$(cd "$project" && ./bin/check-workflow-leak 2>&1)"
local_config_status=$?
set -e
assert_failure "$local_config_status"
assert_contains "$local_config_output" ".ai/local.yml is tracked"
git -C "$project" reset -q .ai/local.yml
rm "$project/.ai/local.yml"

printf '16. leak check rejects symlinks toward the private workflow\n'
ln -s "$workflow" "$project/private-workflow-link"
set +e
symlink_output="$(cd "$project" && ./bin/check-workflow-leak 2>&1)"
symlink_status=$?
set -e
assert_failure "$symlink_status"
assert_contains "$symlink_output" "symlink points toward private workflow"
rm "$project/private-workflow-link"

printf 'All adapter contract tests passed.\n'
