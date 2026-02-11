#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# Multi-Host Configuration Sync Script
# Syncs .env, secrets, documentation, and scripts to all remote Docker hosts
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACKS_DIR="/opt/stacks"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Remote hosts configuration
declare -A HOSTS=(
    ["mediabox"]="tammer@192.168.0.13"
    ["ai"]="tammer@192.168.0.7"
    ["ugreen"]="tammer@192.168.0.8"
    ["truenas"]="truenas_admin@192.168.0.44"
    ["proxmox"]="root@192.168.0.40"
)

# Remote config directory (user-writable)
REMOTE_CONFIG_DIR="~/stacks-config"

print_header() {
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════${NC}\n"
}

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[✓]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[⚠]${NC} $*"; }
log_error() { echo -e "${RED}[✗]${NC} $*" >&2; }

# ═══════════════════════════════════════════════════════════════════════════════
# SYNC FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

sync_env() {
    print_header "Syncing .env Files"
    
    for host in "${!HOSTS[@]}"; do
        log_info "Syncing to $host..."
        
        # Ensure directory exists
        ssh "$host" "mkdir -p ${REMOTE_CONFIG_DIR}/.secrets && chmod 700 ${REMOTE_CONFIG_DIR}/.secrets" 2>/dev/null
        
        # Sync plaintext .env
        if scp -q "${STACKS_DIR}/.env" "${host}:${REMOTE_CONFIG_DIR}/.env" 2>/dev/null; then
            ssh "$host" "chmod 600 ${REMOTE_CONFIG_DIR}/.env" 2>/dev/null
            log_success "$host: .env"
        else
            log_error "$host: .env failed"
        fi
        
        # Sync encrypted .env.enc
        if [[ -f "${STACKS_DIR}/.env.enc" ]]; then
            if scp -q "${STACKS_DIR}/.env.enc" "${host}:${REMOTE_CONFIG_DIR}/.env.enc" 2>/dev/null; then
                log_success "$host: .env.enc"
            else
                log_error "$host: .env.enc failed"
            fi
        fi
    done
}

sync_secrets() {
    print_header "Syncing Secrets Infrastructure"
    
    if [[ ! -f "${STACKS_DIR}/.secrets/age-key.txt" ]]; then
        log_warn "No age key found - skipping secrets sync"
        return 0
    fi
    
    for host in "${!HOSTS[@]}"; do
        log_info "Syncing secrets to $host..."
        
        # Ensure .secrets directory exists
        ssh "$host" "mkdir -p ${REMOTE_CONFIG_DIR}/.secrets && chmod 700 ${REMOTE_CONFIG_DIR}/.secrets" 2>/dev/null
        
        # Sync age key
        if scp -q "${STACKS_DIR}/.secrets/age-key.txt" "${host}:${REMOTE_CONFIG_DIR}/.secrets/age-key.txt" 2>/dev/null; then
            ssh "$host" "chmod 600 ${REMOTE_CONFIG_DIR}/.secrets/age-key.txt" 2>/dev/null
            log_success "$host: age-key.txt"
        else
            log_error "$host: age-key.txt failed"
        fi
    done
}

sync_docs() {
    print_header "Syncing Documentation"
    
    # List of docs to sync
    DOCS=(
        "README.md"
        "INFRASTRUCTURE.md"
        "OPERATIONS.md"
        "CLAUDE.md"
        "AI_AGENT_CONTEXT.md"
    )

    for host in "${!HOSTS[@]}"; do
        log_info "Syncing docs to $host..."
        
        for doc in "${DOCS[@]}"; do
            if [[ -f "${STACKS_DIR}/${doc}" ]]; then
                if scp -q "${STACKS_DIR}/${doc}" "${host}:${REMOTE_CONFIG_DIR}/${doc}" 2>/dev/null; then
                    log_success "$host: $doc"
                else
                    log_error "$host: $doc failed"
                fi
            fi
        done
    done
}

sync_scripts() {
    print_header "Syncing Management Scripts"
    
    local scripts=("secrets-manager.sh" "setup-ssh-automation.sh")
    
    for host in "${!HOSTS[@]}"; do
        log_info "Syncing scripts to $host..."
        
        ssh "$host" "mkdir -p ${REMOTE_CONFIG_DIR}/scripts" 2>/dev/null
        
        for script in "${scripts[@]}"; do
            if [[ -f "${STACKS_DIR}/scripts/${script}" ]]; then
                if scp -q "${STACKS_DIR}/scripts/${script}" "${host}:${REMOTE_CONFIG_DIR}/scripts/${script}" 2>/dev/null; then
                    ssh "$host" "chmod +x ${REMOTE_CONFIG_DIR}/scripts/${script}" 2>/dev/null
                    log_success "$host: $script"
                else
                    log_error "$host: $script failed"
                fi
            fi
        done
    done
}

verify_sync() {
    print_header "Verifying Sync Status"
    
    echo -e "${BLUE}┌────────────────┬────────────┬────────────┬──────────────┬────────────┐${NC}"
    echo -e "${BLUE}│ Host           │ .env       │ .env.enc   │ age-key      │ docs       │${NC}"
    echo -e "${BLUE}├────────────────┼────────────┼────────────┼──────────────┼────────────┤${NC}"
    
    for host in "${!HOSTS[@]}"; do
        local env_status="✗"
        local enc_status="✗"
        local key_status="✗"
        local docs_status="✗"
        
        # Check .env
        ssh "$host" "test -f ${REMOTE_CONFIG_DIR}/.env" 2>/dev/null && env_status="${GREEN}✓${NC}"
        
        # Check .env.enc
        ssh "$host" "test -f ${REMOTE_CONFIG_DIR}/.env.enc" 2>/dev/null && enc_status="${GREEN}✓${NC}"
        
        # Check age key
        ssh "$host" "test -f ${REMOTE_CONFIG_DIR}/.secrets/age-key.txt" 2>/dev/null && key_status="${GREEN}✓${NC}"
        
        # Check docs
        ssh "$host" "test -f ${REMOTE_CONFIG_DIR}/INFRASTRUCTURE.md" 2>/dev/null && docs_status="${GREEN}✓${NC}"
        
        printf "${BLUE}│${NC} %-14s ${BLUE}│${NC}     %b      ${BLUE}│${NC}     %b      ${BLUE}│${NC}      %b       ${BLUE}│${NC}     %b      ${BLUE}│${NC}\n" \
            "$host" "$env_status" "$enc_status" "$key_status" "$docs_status"
    done
    
    echo -e "${BLUE}└────────────────┴────────────┴────────────┴──────────────┴────────────┘${NC}"
}

check_ssh() {
    print_header "Checking SSH Connectivity"
    
    local all_ok=true
    
    for host in "${!HOSTS[@]}"; do
        if ssh -o ConnectTimeout=5 -o BatchMode=yes "$host" "echo 'OK'" &>/dev/null; then
            log_success "$host: connected"
        else
            log_error "$host: connection failed"
            all_ok=false
        fi
    done
    
    if ! $all_ok; then
        log_error "Some hosts unreachable. Run: setup-ssh-automation.sh"
        exit 1
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

usage() {
    cat << EOF
${CYAN}Multi-Host Configuration Sync${NC}

Usage: $0 <command>

Commands:
  all             Sync everything (env, secrets, docs, scripts)
  env             Sync .env and .env.enc files only
  secrets         Sync age key and encrypted files
  docs            Sync documentation (.md files)
  scripts         Sync management scripts
  verify          Verify sync status on all hosts
  check           Check SSH connectivity

Examples:
  $0 all          # Full sync to all hosts
  $0 verify       # Check what's synced
  $0 env          # Quick .env update

EOF
}

main() {
    case "${1:-all}" in
        all)
            check_ssh
            sync_env
            sync_secrets
            sync_docs
            sync_scripts
            verify_sync
            ;;
        env)
            check_ssh
            sync_env
            ;;
        secrets)
            check_ssh
            sync_secrets
            ;;
        docs)
            check_ssh
            sync_docs
            ;;
        scripts)
            check_ssh
            sync_scripts
            ;;
        verify)
            verify_sync
            ;;
        check)
            check_ssh
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            log_error "Unknown command: $1"
            usage
            exit 1
            ;;
    esac
    
    echo ""
    log_success "Done!"
}

main "$@"
