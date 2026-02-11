#!/bin/bash
###############################################################################
# TamMediaBox Remote Automation
# Manages Docker containers on TamMediaBox (192.168.0.13) from primary host
###############################################################################

set -euo pipefail

# Source .env if exists
if [[ -f "/opt/stacks/.env" ]]; then
    source "/opt/stacks/.env"
fi

MEDIABOX_IP="${MEDIABOX_IP:-192.168.0.13}"
MEDIABOX_USER="${MEDIABOX_USER:-tammer}"
SSH_KEY="${HOME}/.ssh/id_ed25519"
LOCAL_DIR="/opt/stacks/TamMediaBox"
REMOTE_DIR="/opt/stacks"
BACKUP_DIR="/opt/stacks/backups/TamMediaBox"
LOG_FILE="${LOCAL_DIR}/sync.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

###############################################################################
# Logging Functions
###############################################################################

log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} [${level}] ${message}" | tee -a "${LOG_FILE}"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $@" | tee -a "${LOG_FILE}"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $@" | tee -a "${LOG_FILE}"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $@" | tee -a "${LOG_FILE}" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $@" | tee -a "${LOG_FILE}"
}

###############################################################################
# SSH Command Execution
###############################################################################

ssh_exec() {
    local cmd="$@"
    ssh -i "${SSH_KEY}" -o ConnectTimeout=5 -o StrictHostKeyChecking=no \
        "${MEDIABOX_USER}@${MEDIABOX_IP}" "$cmd" 2>&1
}

###############################################################################
# Health Check
###############################################################################

check_connectivity() {
    log_info "Checking connectivity to TamMediaBox (${MEDIABOX_IP})..."
    
    if ! ping -c 1 -W 2 "${MEDIABOX_IP}" >/dev/null 2>&1; then
        log_error "Cannot reach TamMediaBox at ${MEDIABOX_IP}"
        return 1
    fi
    
    if ! ssh_exec "exit 0" >/dev/null 2>&1; then
        log_error "Cannot SSH to TamMediaBox at ${MEDIABOX_IP}"
        return 1
    fi
    
    log_success "Connected to TamMediaBox"
    return 0
}

###############################################################################
# Sync Operations
###############################################################################

sync_from_tammediabox() {
    log_info "Syncing configuration from TamMediaBox..."
    
    # Create backup directory
    mkdir -p "${BACKUP_DIR}"
    
    # Backup existing files
    if [[ -f "${LOCAL_DIR}/compose.yaml" ]]; then
        cp "${LOCAL_DIR}/compose.yaml" "${BACKUP_DIR}/compose.yaml.$(date +%s).bak"
        log_info "Backed up existing compose.yaml"
    fi
    
    if [[ -f "${LOCAL_DIR}/.env" ]]; then
        cp "${LOCAL_DIR}/.env" "${BACKUP_DIR}/.env.$(date +%s).bak"
        log_info "Backed up existing .env"
    fi
    
    # Sync compose.yaml (it's in /opt/stacks/mediaplayers/ on TamMediaBox)
    log_info "Retrieving compose.yaml from TamMediaBox..."
    if ssh_exec "cat ${REMOTE_DIR}/mediaplayers/compose.yaml" > "${LOCAL_DIR}/compose.yaml"; then
        log_success "Downloaded compose.yaml"
    else
        log_error "Failed to download compose.yaml"
        return 1
    fi
    
    # Sync .env (if exists on TamMediaBox)
    log_info "Retrieving .env from TamMediaBox..."
    if ssh_exec "test -f ${REMOTE_DIR}/.env && cat ${REMOTE_DIR}/.env" > "${LOCAL_DIR}/.env.remote" 2>/dev/null; then
        if [[ -s "${LOCAL_DIR}/.env.remote" ]]; then
            mv "${LOCAL_DIR}/.env.remote" "${LOCAL_DIR}/.env"
            log_success "Downloaded .env"
        else
            rm -f "${LOCAL_DIR}/.env.remote"
            log_warn ".env is empty on TamMediaBox, using local version"
        fi
    else
        rm -f "${LOCAL_DIR}/.env.remote"
        log_warn "No .env file on TamMediaBox, using local version"
    fi
    
    log_success "Sync from TamMediaBox complete"
}

sync_to_tammediabox() {
    log_info "Syncing configuration to TamMediaBox..."
    
    # Sync .env to TamMediaBox (via scp since it contains secrets)
    if [[ -f "${LOCAL_DIR}/.env" ]]; then
        log_info "Uploading .env to TamMediaBox..."
        scp -i "${SSH_KEY}" -q "${LOCAL_DIR}/.env" \
            "${MEDIABOX_USER}@${MEDIABOX_IP}:${REMOTE_DIR}/.env"
        log_success "Uploaded .env"
    fi
    
    # Note: compose.yaml should not be overwritten from primary (it's TamMediaBox-specific)
    # But we can validate it's in sync
    log_info "Validating compose.yaml on TamMediaBox..."
    ssh_exec "cd ${REMOTE_DIR}/mediaplayers && docker compose config >/dev/null 2>&1" || {
        log_error "Compose validation failed on TamMediaBox"
        return 1
    }
    
    log_success "Sync to TamMediaBox complete"
}

###############################################################################
# Container Management
###############################################################################

start_services() {
    log_info "Starting services on TamMediaBox..."
    
    if ssh_exec "cd ${REMOTE_DIR}/mediaplayers && docker compose up -d"; then
        log_success "Services started on TamMediaBox"
        docker_ps
    else
        log_error "Failed to start services on TamMediaBox"
        return 1
    fi
}

stop_services() {
    log_info "Stopping services on TamMediaBox..."
    
    if ssh_exec "cd ${REMOTE_DIR}/mediaplayers && docker compose down"; then
        log_success "Services stopped on TamMediaBox"
    else
        log_error "Failed to stop services on TamMediaBox"
        return 1
    fi
}

restart_services() {
    log_info "Restarting services on TamMediaBox..."
    
    if ssh_exec "cd ${REMOTE_DIR}/mediaplayers && docker compose restart"; then
        log_success "Services restarted on TamMediaBox"
        docker_ps
    else
        log_error "Failed to restart services on TamMediaBox"
        return 1
    fi
}

docker_ps() {
    log_info "Container status on TamMediaBox:"
    ssh_exec "cd ${REMOTE_DIR}/mediaplayers && docker compose ps" | sed 's/^/  /'
}

docker_logs() {
    local service=$1
    log_info "Logs for ${service} on TamMediaBox:"
    ssh_exec "cd ${REMOTE_DIR}/mediaplayers && docker compose logs --tail 50 ${service}" | sed 's/^/  /'
}

###############################################################################
# Health Checks
###############################################################################

health_check() {
    log_info "Running health checks on TamMediaBox..."
    
    local plex_up=$(ssh_exec "curl -s -o /dev/null -w '%{http_code}' http://localhost:32400" || echo "000")
    local jellyfin_up=$(ssh_exec "curl -s -o /dev/null -w '%{http_code}' http://localhost:8096" || echo "000")
    local mstream_up=$(ssh_exec "curl -s -o /dev/null -w '%{http_code}' http://localhost:3000" || echo "000")
    
    log_info "Plex: HTTP ${plex_up}"
    log_info "Jellyfin: HTTP ${jellyfin_up}"
    log_info "mstream: HTTP ${mstream_up}"
    
    if [[ "${plex_up}" == "200" ]] || [[ "${plex_up}" == "401" ]]; then
        log_success "Plex is responding"
    else
        log_warn "Plex may not be responding (HTTP ${plex_up})"
    fi
    
    if [[ "${jellyfin_up}" == "200" ]] || [[ "${jellyfin_up}" == "302" ]]; then
        log_success "Jellyfin is responding"
    else
        log_warn "Jellyfin may not be responding (HTTP ${jellyfin_up})"
    fi
}

###############################################################################
# Main Command Handler
###############################################################################

show_usage() {
    cat << EOF
${BLUE}TamMediaBox Remote Management${NC}

Usage: $0 <command> [options]

Commands:
  check          Check connectivity and health status
  sync           Sync configuration FROM TamMediaBox to primary (backup + download)
  push           Sync configuration TO TamMediaBox from primary
  start          Start all services on TamMediaBox
  stop           Stop all services on TamMediaBox
  restart        Restart all services on TamMediaBox
  logs [service] Show logs for service (default: all)
  ps             Show container status
  health         Run health checks
  
Examples:
  $0 check                 # Check if TamMediaBox is reachable
  $0 sync                  # Backup and download configs from TamMediaBox
  $0 push                  # Upload .env to TamMediaBox
  $0 start                 # Start services on TamMediaBox
  $0 logs plex             # Show Plex logs
  $0 health                # Check service health

EOF
}

main() {
    if [[ $# -lt 1 ]]; then
        show_usage
        exit 1
    fi
    
    local command=$1
    shift || true
    
    case "${command}" in
        check)
            check_connectivity && health_check
            ;;
        sync)
            check_connectivity && sync_from_tammediabox
            ;;
        push)
            check_connectivity && sync_to_tammediabox
            ;;
        start)
            check_connectivity && start_services
            ;;
        stop)
            check_connectivity && stop_services
            ;;
        restart)
            check_connectivity && restart_services
            ;;
        ps)
            check_connectivity && docker_ps
            ;;
        logs)
            check_connectivity && docker_logs "${1:-}"
            ;;
        health)
            check_connectivity && health_check
            ;;
        *)
            log_error "Unknown command: ${command}"
            show_usage
            exit 1
            ;;
    esac
}

# Ensure log directory exists
mkdir -p "$(dirname "${LOG_FILE}")"

# Run main
main "$@"
