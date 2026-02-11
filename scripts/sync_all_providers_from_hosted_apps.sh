#!/bin/bash
# sync_all_providers_from_hosted_apps.sh
# Sync all Traefik provider entries on 192.168.0.2 to match HOSTED_APPS.md
# Usage: ./sync_all_providers_from_hosted_apps.sh

set -e
TRAEFIK_HOST="192.168.0.2"
TRAEFIK_USER="root"
SSH_KEY="/root/.ssh/id_ed25519"
PROVIDER_FILE="/etc/traefik/conf.d/primary-host.yml"
HOSTED_APPS_MD="/opt/stacks/HOSTED_APPS.md"

# Backup the provider file first
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$TRAEFIK_USER@$TRAEFIK_HOST" "cp $PROVIDER_FILE $PROVIDER_FILE.bak.$(date +%s)"

# Extract all service, DNS, and port info from HOSTED_APPS.md (skip header, trim spaces)
awk -F'|' 'NR>2 && /\[.*\]\(http/ {gsub(/\[|\]/, "", $3); gsub(/\(|\)/, "", $4); s=$2; gsub(/^ +| +$/, "", s); d=$3; gsub(/^ +| +$/, "", d); p=$4; gsub(/^ +| +$/, "", p); print s "," d "," p}' $HOSTED_APPS_MD > /tmp/traefik_services.csv

# For each service, update or insert the correct router and service entry
while IFS="," read -r service url port; do
  [ -z "$service" ] && continue
  dns=$(echo "$url" | awk -F'/' '{print $3}')
  # Update router (host rule)
  ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$TRAEFIK_USER@$TRAEFIK_HOST" \
    "sed -i '/^ *$service:/,/service:/s/Host(`[^`]*`)/Host(`$dns`)/g' $PROVIDER_FILE"
  # Update backend (service URL)
  ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$TRAEFIK_USER@$TRAEFIK_HOST" \
    "sed -i '/^ *$service:/,/url:/s|url:.*|url: \"http://192.168.0.11:$port\"|g' $PROVIDER_FILE"
done < /tmp/traefik_services.csv

echo "All provider entries updated on $TRAEFIK_HOST in $PROVIDER_FILE to match HOSTED_APPS.md."
echo "A backup was saved as $PROVIDER_FILE.bak.<timestamp> on the remote host."
