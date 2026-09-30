#!/usr/bin/env bash
set -euo pipefail

if git diff --quiet; then
  echo "No changes"
  exit 0
fi
git config user.name "openclaw-ci"
git config user.email "ci@openclaw.local"
git add -A
git commit -m "$1"
git push

# GITHUB_TOKEN pushes do not trigger push workflows; dispatch CI explicitly.
gh workflow run ci.yml --repo "$GITHUB_REPOSITORY" --ref main
