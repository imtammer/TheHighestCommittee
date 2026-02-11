#!/bin/bash
################################################################################
# setup_ssh_all_hosts.sh
# Test and configure SSH key authentication to all infrastructure hosts
################################################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SSH_KEY="${HOME}/.ssh/id_ed25519"
SSH_PUB="${SSH_KEY}.pub"
SSH_OPTS="-o ConnectTimeout=5 -o StrictHostKeyChecking=no -o BatchMode=yes"

# Host definitions with labels
declare -A HOSTS=(
    ["192.168.0.2"]="Traefik"
    ["192.168.0.4"]="FoundryVTT"
    ["192.168.0.6"]="Tandoor"
    ["192.168.0.7"]="AI Docker"
    ["192.168.0.8"]="UGREEN"
    ["192.168.0.11"]="Primary (osiris)"
    ["192.168.0.12"]="PostgreSQL"
    ["192.168.0.13"]="TamMediaBox"
    ["192.168.0.14"]="NPM Plus"
    ["192.168.0.40"]="Proxmox"
    ["192.168.0.44"]="TrueNAS"
    ["192.168.0.116"]="phpIPAM"
)

# Common users to try
USERS=("root" "ubuntu" "admin")

echo "======================================"
echo "SSH Key Authentication Setup"
echo "======================================"
echo ""

# Check if SSH key exists
if [[ ! -f "$SSH_KEY" ]]; then
    echo -e "${YELLOW}[SETUP]${NC} Generating SSH key..."
    ssh-keygen -t ed25519 -f "$SSH_KEY" -N "" -C "homelab-automation"
    echo -e "${GREEN}[OK]${NC} SSH key generated"
fi

echo -e "${GREEN}[OK]${NC} Using SSH key: $SSH_KEY"
echo ""

# Test connectivity
echo "======================================"
echo "Testing SSH Connectivity"
echo "======================================"
echo ""

declare -A WORKING_HOSTS
declare -A FAILED_HOSTS

for ip in "${!HOSTS[@]}"; do
    label="${HOSTS[$ip]}"
    connected=false
    working_user=""

    # Try each user
    for user in "${USERS[@]}"; do
        if ssh $SSH_OPTS "${user}@${ip}" "echo test" &>/dev/null; then
            echo -e "${GREEN}✓${NC} ${label} (${ip}) - ${user}@${ip}"
            WORKING_HOSTS["$ip"]="$user"
            connected=true
            working_user="$user"
            break
        fi
    done

    if [[ "$connected" == false ]]; then
        echo -e "${RED}✗${NC} ${label} (${ip}) - No SSH access"
        FAILED_HOSTS["$ip"]="$label"
    fi
done

echo ""
echo "======================================"
echo "Summary"
echo "======================================"
echo -e "Working: ${GREEN}${#WORKING_HOSTS[@]}${NC}/${#HOSTS[@]}"
echo -e "Failed:  ${RED}${#FAILED_HOSTS[@]}${NC}/${#HOSTS[@]}"
echo ""

if [[ ${#FAILED_HOSTS[@]} -gt 0 ]]; then
    echo -e "${YELLOW}[INFO]${NC} Failed hosts require manual SSH key setup:"
    echo ""
    for ip in "${!FAILED_HOSTS[@]}"; do
        label="${FAILED_HOSTS[$ip]}"
        echo "  ${label} (${ip}):"
        echo "    ssh-copy-id -i $SSH_PUB root@${ip}"
        echo "    # or"
        echo "    ssh-copy-id -i $SSH_PUB ubuntu@${ip}"
        echo ""
    done
fi

# Generate detailed report
REPORT_FILE="/opt/stacks/reports/ssh_connectivity_$(date +%Y%m%d_%H%M%S).txt"
{
    echo "SSH Connectivity Report"
    echo "Generated: $(date)"
    echo "========================================"
    echo ""
    echo "WORKING HOSTS (${#WORKING_HOSTS[@]}):"
    echo "========================================"
    for ip in "${!WORKING_HOSTS[@]}"; do
        user="${WORKING_HOSTS[$ip]}"
        label="${HOSTS[$ip]}"
        echo "✓ ${label}: ${user}@${ip}"
    done
    echo ""
    echo "FAILED HOSTS (${#FAILED_HOSTS[@]}):"
    echo "========================================"
    for ip in "${!FAILED_HOSTS[@]}"; do
        label="${FAILED_HOSTS[$ip]}"
        echo "✗ ${label}: ${ip}"
    done
    echo ""
    echo "SETUP COMMANDS FOR FAILED HOSTS:"
    echo "========================================"
    for ip in "${!FAILED_HOSTS[@]}"; do
        label="${FAILED_HOSTS[$ip]}"
        echo "# ${label}"
        echo "ssh-copy-id -i $SSH_PUB root@${ip}"
        echo ""
    done
} > "$REPORT_FILE"

echo -e "${BLUE}[INFO]${NC} Report saved: $REPORT_FILE"
echo ""

# Create SSH config for easy access
SSH_CONFIG="${HOME}/.ssh/config.d/homelab"
mkdir -p "$(dirname $SSH_CONFIG)"

{
    echo "# Homelab SSH Configuration"
    echo "# Generated: $(date)"
    echo ""
    for ip in "${!WORKING_HOSTS[@]}"; do
        user="${WORKING_HOSTS[$ip]}"
        label="${HOSTS[$ip]}"
        hostname=$(echo "$label" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')

        echo "Host ${hostname}"
        echo "    HostName ${ip}"
        echo "    User ${user}"
        echo "    IdentityFile ${SSH_KEY}"
        echo "    StrictHostKeyChecking no"
        echo ""
    done
} > "$SSH_CONFIG"

echo -e "${GREEN}[OK]${NC} SSH config created: $SSH_CONFIG"
echo ""
echo "You can now use shortcuts like:"
for ip in "${!WORKING_HOSTS[@]}"; do
    label="${HOSTS[$ip]}"
    hostname=$(echo "$label" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
    echo "  ssh ${hostname}  # connects to ${ip}"
    break
done
echo ""

# Exit with error if any hosts failed
if [[ ${#FAILED_HOSTS[@]} -gt 0 ]]; then
    exit 1
else
    echo -e "${GREEN}${BOLD}✓ All hosts accessible via SSH!${NC}"
    exit 0
fi
