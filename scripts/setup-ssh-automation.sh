#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# SSH Automation Setup Script
# Sets up passwordless SSH access to all infrastructure hosts
# ═══════════════════════════════════════════════════════════════════════════════

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ═══════════════════════════════════════════════════════════════════════════════
# HOST DEFINITIONS
# ═══════════════════════════════════════════════════════════════════════════════
declare -A HOSTS=(
    ["TamMediaBox"]="tammer@192.168.0.13"
    ["AI_Docker"]="tammer@192.168.0.7"
    ["TrueNAS"]="truenas_admin@192.168.0.44"
    ["UGREEN"]="tammer@192.168.0.8"
    ["Proxmox"]="root@192.168.0.40"
)

# Default password for interactive setup
DEFAULT_PASSWORD="!St00pid!"

# ═══════════════════════════════════════════════════════════════════════════════
# FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}\n"
}

print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if SSH key exists, create if not
ensure_ssh_key() {
    print_header "Checking SSH Key"
    
    if [[ -f ~/.ssh/id_ed25519 ]]; then
        print_status "SSH key already exists: ~/.ssh/id_ed25519"
    elif [[ -f ~/.ssh/id_rsa ]]; then
        print_status "SSH key already exists: ~/.ssh/id_rsa"
    else
        print_warning "No SSH key found, generating new ed25519 key..."
        ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -C "$(whoami)@$(hostname)"
        print_status "SSH key generated: ~/.ssh/id_ed25519"
    fi
    
    # Show public key
    echo -e "\n${YELLOW}Your public key:${NC}"
    cat ~/.ssh/id_ed25519.pub 2>/dev/null || cat ~/.ssh/id_rsa.pub
}

# Add host keys to known_hosts
add_host_keys() {
    print_header "Adding Host Keys to known_hosts"
    
    for name in "${!HOSTS[@]}"; do
        host="${HOSTS[$name]#*@}"
        if ssh-keyscan -H "$host" >> ~/.ssh/known_hosts 2>/dev/null; then
            print_status "Added $name ($host)"
        else
            print_error "Failed to scan $name ($host)"
        fi
    done
}

# Test SSH connectivity
test_ssh() {
    local name="$1"
    local target="$2"
    
    if ssh -o BatchMode=yes -o ConnectTimeout=5 "$target" "echo 'OK'" 2>/dev/null | grep -q "OK"; then
        return 0
    else
        return 1
    fi
}

# Copy SSH key to remote host using sshpass
copy_ssh_key() {
    local name="$1"
    local target="$2"
    local password="$3"
    
    if command -v sshpass &> /dev/null; then
        sshpass -p "$password" ssh-copy-id -o StrictHostKeyChecking=no "$target" 2>/dev/null
        return $?
    else
        print_warning "sshpass not installed. Manual key copy required."
        echo "Run: ssh-copy-id $target"
        return 1
    fi
}

# Test all hosts
test_all_hosts() {
    print_header "Testing SSH Connectivity"
    
    local all_ok=true
    
    for name in "${!HOSTS[@]}"; do
        target="${HOSTS[$name]}"
        echo -n "  $name ($target): "
        
        if test_ssh "$name" "$target"; then
            echo -e "${GREEN}✓ Connected${NC}"
        else
            echo -e "${RED}✗ Failed${NC}"
            all_ok=false
        fi
    done
    
    if $all_ok; then
        echo -e "\n${GREEN}All hosts accessible!${NC}"
        return 0
    else
        return 1
    fi
}

# Setup SSH for a single host
setup_host() {
    local name="$1"
    local target="$2"
    
    echo -e "\n${YELLOW}Setting up $name ($target)...${NC}"
    
    if test_ssh "$name" "$target"; then
        print_status "$name already configured"
        return 0
    fi
    
    # Try with default password
    if copy_ssh_key "$name" "$target" "$DEFAULT_PASSWORD"; then
        print_status "$name configured successfully"
        return 0
    fi
    
    # Manual fallback
    print_warning "Automatic setup failed for $name"
    echo "Please run manually:"
    echo "  ssh-copy-id $target"
    return 1
}

# Setup all hosts
setup_all_hosts() {
    print_header "Setting Up SSH Keys on Remote Hosts"
    
    # Check for sshpass
    if ! command -v sshpass &> /dev/null; then
        print_warning "Installing sshpass for automated key copy..."
        apt-get update -qq && apt-get install -y sshpass -qq 2>/dev/null || true
    fi
    
    for name in "${!HOSTS[@]}"; do
        setup_host "$name" "${HOSTS[$name]}"
    done
}

# Create SSH config file
create_ssh_config() {
    print_header "Creating SSH Config"
    
    local config_file=~/.ssh/config
    
    # Backup existing config
    if [[ -f "$config_file" ]]; then
        cp "$config_file" "${config_file}.bak"
        print_status "Backed up existing config to ${config_file}.bak"
    fi
    
    cat > "$config_file" << 'EOF'
# ═══════════════════════════════════════════════════════════════════════════════
# TheHighestCommittee Infrastructure SSH Config
# Generated by setup-ssh-automation.sh
# ═══════════════════════════════════════════════════════════════════════════════

# Global settings
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    StrictHostKeyChecking accept-new
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_ed25519

# ───────────────────────────────────────────────────────────────────────────────
# Infrastructure Hosts
# ───────────────────────────────────────────────────────────────────────────────

# TamMediaBox - Media Server (Plex, Jellyfin)
Host mediabox tammediabox 192.168.0.13
    HostName 192.168.0.13
    User tammer
    
# AI Docker Host - ML/AI Services (Ollama, Paperless)
Host ai ai-docker 192.168.0.7
# AI Docker Host - ML/AI Services (Ollama, Paperless)
    HostName ${AI_HOST_IP:-CHANGEME}
    User ${AI_HOST_USER:-CHANGEME}

# TrueNAS Scale - NAS & Docker (qBit, SABnzbd)
Host truenas nas 192.168.0.44
# TrueNAS Scale - NAS & Docker (qBit, SABnzbd)
    HostName ${TRUENAS_IP:-CHANGEME}
    User ${TRUENAS_USER:-CHANGEME}

# UGREEN NAS - SSD Storage
Host ugreen 192.168.0.8
    HostName ${UGREEN_IP:-CHANGEME}
    User ${UGREEN_USER:-CHANGEME}
    Port 22

# Proxmox - Hypervisor
Host proxmox pve 192.168.0.40
# Proxmox - Hypervisor
    HostName ${PROXMOX_IP:-CHANGEME}
    User ${PROXMOX_USER:-CHANGEME}

# PostgreSQL Server
Host postgres db 192.168.0.12
# PostgreSQL Server
    HostName ${POSTGRES_IP:-CHANGEME}
    User ${POSTGRES_USER:-CHANGEME}

# phpIPAM Server
Host phpipam 192.168.0.116
# phpIPAM Server
    HostName ${PHPIPAM_IP:-CHANGEME}
    User ${PHPIPAM_USER:-CHANGEME}
EOF

    chmod 600 "$config_file"
    print_status "SSH config created at $config_file"
    
    echo -e "\n${YELLOW}You can now use shortcuts:${NC}"
    echo "  ssh mediabox    → 192.168.0.13"
    echo "  ssh ai          → 192.168.0.7"
    echo "  ssh truenas     → 192.168.0.44"
    echo "  ssh ugreen      → 192.168.0.8"
    echo "  ssh proxmox     → 192.168.0.40"
}

# Show usage
usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  test      Test SSH connectivity to all hosts"
    echo "  setup     Setup SSH keys on all hosts (requires sshpass)"
    echo "  config    Create/update SSH config file"
    echo "  keys      Add host keys to known_hosts"
    echo "  all       Run full setup (keys + config + test)"
    echo "  help      Show this help"
    echo ""
    echo "Hosts:"
    for name in "${!HOSTS[@]}"; do
        echo "  $name: ${HOSTS[$name]}"
    done
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    case "${1:-all}" in
        test)
            test_all_hosts
            ;;
        setup)
            ensure_ssh_key
            setup_all_hosts
            test_all_hosts
            ;;
        config)
            create_ssh_config
            ;;
        keys)
            add_host_keys
            ;;
        all)
            ensure_ssh_key
            add_host_keys
            create_ssh_config
            setup_all_hosts
            test_all_hosts
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            echo "Unknown command: $1"
            usage
            exit 1
            ;;
    esac
}

main "$@"
