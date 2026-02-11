#!/bin/bash
# fix_readarr_provider.sh
# Fix the Readarr Traefik provider entry on 192.168.0.2 to point to the correct service/port
# Usage: ./fix_readarr_provider.sh [provider_file_path]
# Default provider file path: /etc/traefik/dynamic/services.yaml

TRAEFIK_HOST="192.168.0.2"
TRAEFIK_USER="root"
SSH_KEY="/root/.ssh/id_ed25519"
PROVIDER_FILE="${1:-/etc/traefik/conf.d/additional-services.yml}"

# Backup the provider file first
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$TRAEFIK_USER@$TRAEFIK_HOST" "cp $PROVIDER_FILE $PROVIDER_FILE.bak.$(date +%s)"

# Fix the Readarr entry (replace lidify with readarr:8787)
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$TRAEFIK_USER@$TRAEFIK_HOST" \
  "sed -i '/readarr:/,/url:/s|url:.*|url: \"http://readarr:8787\"|' $PROVIDER_FILE"

echo "Readarr provider entry updated on $TRAEFIK_HOST in $PROVIDER_FILE."
echo "A backup was saved as $PROVIDER_FILE.bak.<timestamp> on the remote host."
