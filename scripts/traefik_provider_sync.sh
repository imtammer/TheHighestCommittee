#!/bin/bash
# traefik_provider_sync.sh
# Sync and verify Traefik file provider entries on 192.168.0.2 with HOSTED_APPS.md
# Usage: ./traefik_provider_sync.sh
# Requirements: SSH key-based login to root@192.168.0.2

TRAEFIK_HOST="192.168.0.2"
TRAEFIK_USER="root"
DYNAMIC_CONFIG_DIR="/etc/traefik/dynamic"  # Change if your config is elsewhere
HOSTED_APPS_MD="/opt/stacks/HOSTED_APPS.md"
SSH_KEY="~/.ssh/id_ed25519"

# 1. Extract service, IP, and port from HOSTED_APPS.md
parse_hosted_apps() {
  awk '/^\|/ && $0 ~ /http/ { \
    match($0, /\| ([^|]+) \| ([^|]+) \| ([^|]+) \| ([^|]+) \|/, arr); \
    if (arr[4] != "") print arr[1] "," arr[2] "," arr[3] "," arr[4]; \
  }' "$HOSTED_APPS_MD"
}

# 2. SSH to Traefik host and list all provider files
list_provider_files() {
  ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$TRAEFIK_USER@$TRAEFIK_HOST" "find $DYNAMIC_CONFIG_DIR -type f -name '*.yml' -o -name '*.yaml'"
}

# 3. For each service, check if provider entry matches HOSTED_APPS.md
compare_providers() {
  while IFS="," read -r service host port url; do
    # Extract host and port from URL
    proto_removed=${url#*://}
    url_hostport=${proto_removed%%/*}
    url_host=${url_hostport%%:*}
    url_port=${url_hostport##*:}
    # SSH grep for service in provider files
    provider_entry=$(ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$TRAEFIK_USER@$TRAEFIK_HOST" \
      "grep -H -i $service $DYNAMIC_CONFIG_DIR/*.yml $DYNAMIC_CONFIG_DIR/*.yaml 2>/dev/null | grep url:")
    if [[ "$provider_entry" == *"$url_host"* && "$provider_entry" == *"$url_port"* ]]; then
      echo "[OK] $service: $url matches provider entry."
    else
      echo "[MISMATCH] $service: $url does NOT match provider entry:" >&2
      echo "$provider_entry" >&2
    fi
  done < <(parse_hosted_apps)
}

# Main
parse_hosted_apps > /tmp/traefik_services.csv
compare_providers

# Instructions for SSH key setup
cat <<EOF

If you have not set up SSH key-based login:
  ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
  ssh-copy-id -i ~/.ssh/id_ed25519 root@192.168.0.2
EOF
