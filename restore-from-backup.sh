#!/bin/bash
# restore-from-backup.sh
# Restore real secrets and configs from backup after pushing sanitized files to GitHub
# Usage: ./restore-from-backup.sh

set -e

BACKUP_DIR="../secrets-backup"
FILES_TO_RESTORE=(
  "bots/compose.yaml"
  "scripts/secrets-manager.sh"
  "scripts/ai_docker_host.sh"
  "scripts/truenas.sh"
  "scripts/setup-ssh-automation.sh"
  "TrueNAS/vpn/compose.yaml"
)

for file in "${FILES_TO_RESTORE[@]}"; do
  backup_file="$BACKUP_DIR/${file//\//_}"
  if [ -f "$backup_file" ]; then
    cp "$backup_file" "$file"
    echo "Restored $file from backup."
  else
    echo "Backup for $file not found!" >&2
  fi

done

echo "All files restored from backup."
