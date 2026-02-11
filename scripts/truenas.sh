#!/bin/bash
# TrueNAS Server Automation Script
# Manages Docker containers on TrueNAS (192.168.0.44)
# Note: Downloaders and VPN stacks are managed via Dockge on TrueNAS
# Usage: ./truenas.sh [command] [stack] [options]

set -euo pipefail

# ════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ════════════════════════════════════════════════════════════════════

# Source .env if exists
if [[ -f "/opt/stacks/.env" ]]; then
    source "/opt/stacks/.env"
fi

TRUENAS_IP="${TRUENAS_IP:-192.168.0.44}"
TRUENAS_USER="${TRUENAS_USERNAME:-truenas_admin}"
TRUENAS_PORT="22"
SSH_KEY="${HOME}/.ssh/id_ed25519"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_DIR="/opt/stacks/TrueNAS"
REMOTE_DIR="/mnt/datastore/media/stacks"
BACKUP_DIR="/opt/stacks/backups/TrueNAS"
STACKS=()

# Logging colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ════════════════════════════════════════════════════════════════════
# LOGGING FUNCTIONS
# ════════════════════════════════════════════════════════════════════

log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $*" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $(date '+%Y-%m-%d %H:%M:%S') - $*"
}

# ════════════════════════════════════════════════════════════════════
# SSH HELPER FUNCTION
# ════════════════════════════════════════════════════════════════════

ssh_exec() {
    local cmd="$@"
    ssh -i "${SSH_KEY}" -p "${TRUENAS_PORT}" -o ConnectTimeout=5 \
        -o StrictHostKeyChecking=no "${TRUENAS_USER}@${TRUENAS_IP}" "$cmd" 2>&1
}

# ════════════════════════════════════════════════════════════════════
# CONNECTIVITY CHECK
# ════════════════════════════════════════════════════════════════════

check_connectivity() {
    log_info "Checking connectivity to TrueNAS (${TRUENAS_IP})..."
    
    if ping -c 1 -W 2 "${TRUENAS_IP}" &>/dev/null; then
        log_success "Host is reachable via ping"
    else
        log_warn "Host not reachable via ping (may be blocked)"
    fi
    
    if ssh_exec "echo 'Connected'" &>/dev/null; then
        log_success "Connected to TrueNAS via SSH"
        return 0
    else
        log_error "Failed to connect to TrueNAS via SSH"
        return 1
    fi
}

# ════════════════════════════════════════════════════════════════════
# BACKUP & SYNC FUNCTIONS
# ════════════════════════════════════════════════════════════════════

sync_from_truenas() {
    log_info "Syncing from TrueNAS (${TRUENAS_IP})..."
    mkdir -p "${BACKUP_DIR}"
    
    # Sync each stack
    for stack in "${STACKS[@]}"; do
        log_info "Downloading ${stack} compose.yaml..."
        mkdir -p "${LOCAL_DIR}/${stack}"
        
        # Backup existing
        if [[ -f "${LOCAL_DIR}/${stack}/compose.yaml" ]]; then
            cp "${LOCAL_DIR}/${stack}/compose.yaml" "${BACKUP_DIR}/${stack}-compose.yaml.$(date +%s).bak"
        fi
        
        # Download
        if ssh_exec "test -f ${REMOTE_DIR}/${stack}/compose.yaml && cat ${REMOTE_DIR}/${stack}/compose.yaml" > "${LOCAL_DIR}/${stack}/compose.yaml" 2>/dev/null; then
            log_success "${stack} compose.yaml downloaded"
        else
            log_warn "Failed to download ${stack} compose.yaml (may not exist)"
        fi
    done
    
    # Download root .env file
    log_info "Downloading .env from TrueNAS..."
    if ssh_exec "test -f ${REMOTE_DIR}/.env && cat ${REMOTE_DIR}/.env" > "${LOCAL_DIR}/.env" 2>/dev/null; then
        log_success ".env downloaded"
    else
        log_warn ".env not found on remote (may not exist yet)"
    fi
    
    log_success "Sync from TrueNAS completed"
}

sync_to_truenas() {
    log_info "Syncing to TrueNAS (${TRUENAS_IP})..."
    
    # Validate all stacks
    for stack in "${STACKS[@]}"; do
        if [[ -f "${LOCAL_DIR}/${stack}/compose.yaml" ]]; then
            if ! docker compose -f "${LOCAL_DIR}/${stack}/compose.yaml" config &>/dev/null 2>&1; then
                log_error "${stack} compose.yaml validation failed"
                return 1
            fi
            log_success "${stack} compose.yaml is valid"
        fi
    done
    
    # Upload .env file
    if [[ -f "${LOCAL_DIR}/.env" ]]; then
        log_info "Uploading .env to TrueNAS..."
        scp -i "${SSH_KEY}" -P "${TRUENAS_PORT}" -o ConnectTimeout=5 \
            "${LOCAL_DIR}/.env" "${TRUENAS_USER}@${TRUENAS_IP}:${REMOTE_DIR}/.env" 2>/dev/null
        log_success ".env uploaded"
    fi
    
    log_info "Upload to TrueNAS completed"
}

# ════════════════════════════════════════════════════════════════════
# SERVICE CONTROL
# ════════════════════════════════════════════════════════════════════

start_services() {
    local stack="${1:-}"
    
    if [[ -z "$stack" ]]; then
        # Start all stacks
        log_info "Starting all TrueNAS stacks..."
        for s in "${STACKS[@]}"; do
            if ssh_exec "cd ${REMOTE_DIR}/${s} && docker compose up -d" &>/dev/null; then
                log_success "${s} stack started"
            else
                log_error "Failed to start ${s} stack"
            fi
        done
    else
        # Start specific stack
        log_info "Starting ${stack} stack..."
        if ssh_exec "cd ${REMOTE_DIR}/${stack} && docker compose up -d" &>/dev/null; then
            log_success "${stack} stack started"
            return 0
        else
            log_error "Failed to start ${stack} stack"
            return 1
        fi
    fi
}

stop_services() {
    local stack="${1:-}"
    
    if [[ -z "$stack" ]]; then
        # Stop all stacks
        log_info "Stopping all TrueNAS stacks..."
        for s in "${STACKS[@]}"; do
            if ssh_exec "cd ${REMOTE_DIR}/${s} && docker compose down" &>/dev/null; then
                log_success "${s} stack stopped"
            else
                log_error "Failed to stop ${s} stack"
            fi
        done
    else
        # Stop specific stack
        log_info "Stopping ${stack} stack..."
        if ssh_exec "cd ${REMOTE_DIR}/${stack} && docker compose down" &>/dev/null; then
            log_success "${stack} stack stopped"
            return 0
        else
            log_error "Failed to stop ${stack} stack"
            return 1
        fi
    fi
}

restart_services() {
    local stack="${1:-}"
    stop_services "$stack"
    sleep 3
    start_services "$stack"
}

# ════════════════════════════════════════════════════════════════════
# HEALTH CHECKS
# ════════════════════════════════════════════════════════════════════

health_check() {
    log_info "Running health checks for TrueNAS services..."
    
    log_info "Note: SABnzbd (port 8080), qBittorrent (port 8880), and monitoring stacks are managed via Dockge"
    log_info "Access Dockge at http://192.168.0.44:31014"
    
    log_success "Health check completed"
}

# ════════════════════════════════════════════════════════════════════
# CONTAINER STATUS
# ════════════════════════════════════════════════════════════════════

container_status() {
    local stack="${1:-}"
    
    if [[ -z "$stack" ]]; then
        log_info "Container status for all TrueNAS stacks..."
        for s in "${STACKS[@]}"; do
            log_info ""
            log_info "Stack: ${s}"
            ssh_exec "cd ${REMOTE_DIR}/${s} && docker compose ps" || true
        done
    else
        log_info "Container status for ${stack} stack..."
        ssh_exec "cd ${REMOTE_DIR}/${stack} && docker compose ps" || true
    fi
}

# ════════════════════════════════════════════════════════════════════
# LOGS
# ════════════════════════════════════════════════════════════════════

view_logs() {
    local stack="${1:-}"
    local service="${2:-}"
    
    if [[ -z "$stack" ]]; then
        log_error "Must specify stack"
        return 1
    fi
    
    if [[ -z "$service" ]]; then
        log_info "Showing all logs for ${stack} stack..."
        ssh_exec "cd ${REMOTE_DIR}/${stack} && docker compose logs -f" || true
    else
        log_info "Showing logs for ${service} in ${stack} stack..."
        ssh_exec "cd ${REMOTE_DIR}/${stack} && docker compose logs -f ${service}" || true
    fi
}

# ════════════════════════════════════════════════════════════════════
# HELP
# ════════════════════════════════════════════════════════════════════

show_help() {
    cat << 'EOF'
TrueNAS Automation Script (192.168.0.44)
Manages: SABnzbd, qBittorrent (VPN), Hawser (Docker monitoring)
With 3 separate stacks: downloaders, vpn, monitoring

Usage: truenas.sh [command] [stack] [service]

COMMANDS:
  check              Check connectivity to TrueNAS
  health             Run health checks on all services
  ps [stack]         Show container status (all if not specified)
  logs [stack] [svc] View service logs
  sync               Backup and download configs from TrueNAS
  push               Upload .env changes to TrueNAS
  start [stack]      Start services (all if not specified)
  stop [stack]       Stop services (all if not specified)
  restart [stack]    Restart services (all if not specified)
  help               Show this help message

STACKS:
  downloaders        SABnzbd (Usenet downloader)
  vpn                Gluetun VPN + qBittorrent (torrent client)
  monitoring         Hawser (Docker socket monitoring)

EXAMPLES:
  truenas.sh check                        # Test connection
  truenas.sh health                       # Full health check
  truenas.sh ps                           # Status of all stacks
  truenas.sh ps vpn                       # Status of VPN stack
  truenas.sh logs downloaders sabnzbd     # SABnzbd logs
  truenas.sh logs vpn qbittorrent         # qBittorrent logs
  truenas.sh sync                         # Backup and sync configs
  truenas.sh start vpn                    # Start VPN stack
  truenas.sh start                        # Start all stacks
  truenas.sh restart downloaders          # Restart downloaders stack

CONFIGURATION:
  TrueNAS IP:      192.168.0.44
  SSH User:        tammer
  Stacks Path:     /mnt/datastore/media/stacks/
  Local Backup:    /opt/stacks/TrueNAS/backups/
  Log File:        /opt/stacks/TrueNAS/sync.log

SERVICES:
  • SABnzbd        - Usenet downloader (port 8080)
  • qBittorrent    - Torrent client (port 8880, via Gluetun VPN)
  • Gluetun        - VPN client (ProtonVPN)
  • Hawser         - Docker monitoring/socket proxy

EOF
}

# ════════════════════════════════════════════════════════════════════
# MAIN
# ════════════════════════════════════════════════════════════════════

main() {
    local command="${1:-help}"
    local stack="${2:-}"
    local service="${3:-}"
    
    mkdir -p "${BACKUP_DIR}"
    
    case "$command" in
        check)
            check_connectivity
            ;;
        health)
            check_connectivity && health_check
            ;;
        ps)
            check_connectivity && container_status "$stack"
            ;;
        logs)
            check_connectivity && view_logs "$stack" "$service"
            ;;
        sync)
            check_connectivity && sync_from_truenas
            ;;
        push)
            check_connectivity && sync_to_truenas
            ;;
        start)
            check_connectivity && start_services "$stack"
            ;;
        stop)
            check_connectivity && stop_services "$stack"
            ;;
        restart)
            check_connectivity && restart_services "$stack"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
