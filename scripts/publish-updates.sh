#!/usr/bin/env bash
set -euo pipefail

repo=${GITHUB_REPOSITORY:?}

require_base() {
  if [[ $(gh api "repos/$repo/git/ref/heads/main" --jq .object.sha) != "$1" ]]; then
    echo "main changed during generation; regenerate from current main" >&2
    exit 1
  fi
}

if [[ ${1:-} == prepare ]]; then
  require_base "${2:?source base required}"
  exit 0
fi

pr=${1:?pull request required}
head=${2:?pull request head required}
base=${3:?source base required}
branch=${4:?pull request branch required}
shift 4
(( $# > 0 )) || { echo "owned paths required" >&2; exit 1; }
trap 'echo "Publication incomplete; inspect https://github.com/$repo/pull/$pr" >&2' ERR

# GITHUB_TOKEN PR events await human approval. Dispatch the same CI explicitly,
# and bind its receipt to this head rather than an older run or the PR event.
dispatch_ci() {
  local ref=$1 expected=$2 started run_id attempt
  started=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  gh workflow run ci.yml --repo "$repo" --ref "$ref" >&2 || return
  for ((attempt=0; attempt<30; attempt++)); do
    run_id=$(gh run list --repo "$repo" --workflow ci.yml --event workflow_dispatch \
      --branch "$ref" --commit "$expected" --limit 10 --json databaseId,createdAt \
      --jq "[.[] | select(.createdAt >= \"$started\")][0].databaseId // empty") || return
    if [[ -n $run_id ]]; then
      printf '%s\n' "$run_id"
      return
    fi
    sleep 10
  done
  echo "No exact-head CI dispatch receipt for $ref at $expected" >&2
  return 1
}

require_base "$base"
run_id=$(dispatch_ci "$branch" "$head")
ci_passed=false
for ((attempt=0; attempt<120; attempt++)); do
  receipt=$(gh api "repos/$repo/actions/runs/$run_id" \
    --jq '[.event,.head_sha,.status,.conclusion] | @tsv')
  IFS=$'\t' read -r event actual status conclusion <<< "$receipt"
  [[ $event == workflow_dispatch && $actual == "$head" ]]
  if [[ $status == completed ]]; then
    [[ $conclusion == success ]]
    ci_passed=true
    break
  fi
  sleep 10
done
[[ $ci_passed == true ]]
require_base "$base"

# Normal merge honours repository rules; the expected head closes the review race.
gh pr merge "$pr" --repo "$repo" --squash --match-head-commit "$head"
receipt=$(gh api "repos/$repo/pulls/$pr" --jq '[.merged,.head.sha,.merge_commit_sha] | @tsv')
IFS=$'\t' read -r merged actual merge <<< "$receipt"
[[ $merged == true && $actual == "$head" && -n $merge ]]
git fetch --no-tags origin main:refs/remotes/origin/main "$merge" "$head"
git merge-base --is-ancestor "$merge" origin/main
git diff --exit-code "$head" "$merge" -- "$@"

# A token merge does not trigger push workflows either. Record the merged-head
# dispatch before reporting publication; its downstream checks remain visible.
require_base "$merge"
main_run=$(dispatch_ci main "$merge")
echo "Published https://github.com/$repo/pull/$pr at $merge; CI https://github.com/$repo/actions/runs/$main_run"
