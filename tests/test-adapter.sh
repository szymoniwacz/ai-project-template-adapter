#!/usr/bin/env bash
set -euo pipefail

adapter_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT

project="$tmp_root/project"
workflow="$tmp_root/ai-project-template"

mkdir -p "$project/bin" "$project/.ai" "$workflow/bin"

git -C "$project" init -q
cp "$adapter_root/bin/ai-workflow" "$project/bin/ai-workflow"
cp "$adapter_root/bin/ai-workflow-doctor" "$project/bin/ai-workflow-doctor"
cp "$adapter_root/bin/check-workflow-leak" "$project/bin/check-workflow-leak"
cp "$adapter_root/tests/fixtures/fake-ai-project-template/bin/ai-workflow" "$workflow/bin/ai-workflow"
chmod +x "$project/bin/ai-workflow" "$project/bin/ai-workflow-doctor" "$project/bin/check-workflow-leak" "$workflow/bin/ai-workflow"
touch "$project/.ai/project.md"
git -C "$workflow" init -q

project_root="$(git -C "$project" rev-parse --show-toplevel)"

assert_contains() {
  local haystack="$1"
  local needle="$2"

  if [[ "$haystack" != *"$needle"* ]]; then
    printf 'Expected output to contain: %s\nActual output:\n%s\n' "$needle" "$haystack" >&2
    exit 1
  fi
}

printf '1. missing configuration fails closed\n'
set +e
missing_output="$(cd "$project" && env -u AI_PROJECT_TEMPLATE_HOME ./bin/ai-workflow 2>&1)"
missing_status=$?
set -e
[[ "$missing_status" -ne 0 ]]
assert_contains "$missing_output" "AI_PROJECT_TEMPLATE_HOME is not configured"

printf '2. delegation forwards project context and arguments\n'
delegation_output="$(cd "$project" && AI_PROJECT_TEMPLATE_HOME="$workflow" ./bin/ai-workflow feature demo)"
assert_contains "$delegation_output" "target=$project_root"
assert_contains "$delegation_output" "context=$project_root/.ai"
assert_contains "$delegation_output" "args=feature demo"

printf '3. delegation preserves workflow exit code\n'
set +e
(cd "$project" && AI_PROJECT_TEMPLATE_HOME="$workflow" FAKE_WORKFLOW_EXIT_CODE=7 ./bin/ai-workflow >/dev/null 2>&1)
workflow_status=$?
set -e
[[ "$workflow_status" -eq 7 ]]

printf '4. doctor reports a valid connection\n'
doctor_output="$(cd "$project" && AI_PROJECT_TEMPLATE_HOME="$workflow" ./bin/ai-workflow-doctor)"
assert_contains "$doctor_output" "Status: ready"
assert_contains "$doctor_output" "canonical workflow entrypoint is executable"

printf '5. doctor reports a missing canonical entrypoint\n'
chmod -x "$workflow/bin/ai-workflow"
set +e
doctor_failure_output="$(cd "$project" && AI_PROJECT_TEMPLATE_HOME="$workflow" ./bin/ai-workflow-doctor 2>&1)"
doctor_failure_status=$?
set -e
[[ "$doctor_failure_status" -ne 0 ]]
assert_contains "$doctor_failure_output" "canonical workflow entrypoint is missing or not executable"
chmod +x "$workflow/bin/ai-workflow"

printf '6. leak check passes for a clean project\n'
(cd "$project" && ./bin/check-workflow-leak >/dev/null)

printf '7. leak check rejects copied workflow directories\n'
mkdir -p "$project/.ai/workflows"
set +e
copied_output="$(cd "$project" && ./bin/check-workflow-leak 2>&1)"
copied_status=$?
set -e
[[ "$copied_status" -ne 0 ]]
assert_contains "$copied_output" "forbidden reusable workflow path exists: .ai/workflows"
rmdir "$project/.ai/workflows"

printf '8. leak check rejects tracked local configuration\n'
printf 'workflow_path: %s\n' "$workflow" > "$project/.ai/local.yml"
git -C "$project" add -f .ai/local.yml
set +e
local_config_output="$(cd "$project" && ./bin/check-workflow-leak 2>&1)"
local_config_status=$?
set -e
[[ "$local_config_status" -ne 0 ]]
assert_contains "$local_config_output" ".ai/local.yml is tracked"
git -C "$project" reset -q .ai/local.yml
rm "$project/.ai/local.yml"

printf 'All adapter contract tests passed.\n'
