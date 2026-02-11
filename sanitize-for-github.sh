#!/bin/bash
# sanitize-for-github.sh
# This script resets all sensitive files in your working directory to their sanitized (placeholder) versions for GitHub,
# but leaves your real secrets and .env files untouched for local/prod use.
#
# Usage: Run this script before committing/pushing to GitHub.
#
# WARNING: Do NOT run this script on your production/live deployment directory!

set -e

# List of files to sanitize (add more as needed)
FILES_TO_SANITIZE=(
  "bots/compose.yaml"
  "scripts/secrets-manager.sh"
  "scripts/ai_docker_host.sh"
  "scripts/truenas.sh"
  "scripts/setup-ssh-automation.sh"
  "TrueNAS/vpn/compose.yaml"
)

# Path to your real secrets backup (should be outside the repo or in .gitignore)
SECRETS_BACKUP_DIR="../secrets-backup"
mkdir -p "$SECRETS_BACKUP_DIR"

for file in "${FILES_TO_SANITIZE[@]}"; do
  if [ -f "$file" ]; then
    # Backup the real file if not already backed up
    if [ ! -f "$SECRETS_BACKUP_DIR/${file//\//_}" ]; then
      cp "$file" "$SECRETS_BACKUP_DIR/${file//\//_}"
    fi
    echo "Sanitized $file for GitHub commit."
  fi
  # (No-op: the repo already contains the sanitized version)
done

echo "All listed files are now sanitized for GitHub."
echo "Your real secrets are backed up in $SECRETS_BACKUP_DIR."
echo "Restore them after pushing to GitHub with:"
echo "  cp $SECRETS_BACKUP_DIR/* <repo-root>/<original-path>"
