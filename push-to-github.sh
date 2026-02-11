#!/bin/bash
# push-to-github.sh
# Push sanitized files to GitHub repository after running sanitize-for-github.sh
# Usage: ./push-to-github.sh

set -e

REPO_URL="git@github.com:imtammer/thehighestcommittee.git"
BRANCH="main"

# Ensure we're in a git repo
if [ ! -d .git ]; then
  echo "Not a git repository. Please run this in your repo root." >&2
  exit 1
fi

git add bots/compose.yaml scripts/secrets-manager.sh scripts/ai_docker_host.sh scripts/truenas.sh scripts/setup-ssh-automation.sh TrueNAS/vpn/compose.yaml sanitize-for-github.sh

git commit -m "Sanitize secrets and API keys for GitHub"
git push "$REPO_URL" "$BRANCH"

echo "Sanitized files pushed to $REPO_URL on branch $BRANCH."
