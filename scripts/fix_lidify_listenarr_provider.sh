#!/bin/bash
# fix_lidify_listenarr_provider.sh
# Fix lidify and listenarr Traefik provider entries on 192.168.0.2
# Usage: ./fix_lidify_listenarr_provider.sh

set -e
TRAEFIK_HOST="192.168.0.2"
TRAEFIK_USER="root"
SSH_KEY="/root/.ssh/id_ed25519"
PROVIDER_FILE="/etc/traefik/conf.d/primary-host.yml"

# Backup the provider file first
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$TRAEFIK_USER@$TRAEFIK_HOST" "cp $PROVIDER_FILE $PROVIDER_FILE.bak.$(date +%s)"

# Fix lidify router (set only its own host)
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$TRAEFIK_USER@$TRAEFIK_HOST" \
  "sed -i '/lidify:/,/service:/s/Host(`[^`]*`)/Host(`lidify.thehighestcommittee.com`)/g' $PROVIDER_FILE"

# Fix lidify backend
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$TRAEFIK_USER@$TRAEFIK_HOST" \
  "sed -i '/lidify:/,/url:/s|url:.*|url: \"http://192.168.0.11:3030\"|g' $PROVIDER_FILE"

# Ensure listenarr router exists and is correct
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$TRAEFIK_USER@$TRAEFIK_HOST" bash -c '
PROVIDER_FILE="/etc/traefik/conf.d/primary-host.yml"
if ! grep -q "^\s*listenarr:" "$PROVIDER_FILE"; then
  awk "/lidify:/ && !x {print; print \"    listenarr:\\n      rule: Host(\`listenarr.thehighestcommittee.com\`)\\n      service: listenarr\\n      entryPoints: [websecure]\\n      tls: {}\"; x=1; next} 1" "$PROVIDER_FILE" > /tmp/primary-host.yml && mv /tmp/primary-host.yml "$PROVIDER_FILE"
fi'

# Ensure listenarr service exists and is correct
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$TRAEFIK_USER@$TRAEFIK_HOST" bash -c '
PROVIDER_FILE="/etc/traefik/conf.d/primary-host.yml"
if ! grep -q "^\s*listenarr:" "$PROVIDER_FILE"; then
  awk "/lidify:/ && !x {print; print \"    listenarr:\\n      loadBalancer:\\n        servers:\\n          - url: \\\"http://192.168.0.11:8788\\\"\"; x=1; next} 1" "$PROVIDER_FILE" > /tmp/primary-host.yml && mv /tmp/primary-host.yml "$PROVIDER_FILE"
fi'

echo "Lidify and Listenarr provider entries updated on $TRAEFIK_HOST in $PROVIDER_FILE."
echo "A backup was saved as $PROVIDER_FILE.bak.<timestamp> on the remote host."
