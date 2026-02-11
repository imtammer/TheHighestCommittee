#!/bin/bash
###############################################################################
# Multi-Host Orchestration Master Script
# Manages all remote hosts (TamMediaBox, AI_Docker_Host) from primary host
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TAMMEDIABOX_SCRIPT="${SCRIPT_DIR}/tammediabox.sh"
AI_HOST_SCRIPT="${SCRIPT_DIR}/ai_docker_host.sh"
TRUENAS_SCRIPT="${SCRIPT_DIR}/truenas.sh"
LOG_FILE="${SCRIPT_DIR}/orchestration.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

###############################################################################
# Logging
###############################################################################

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
# Show Usage
###############################################################################

show_usage() {
    cat << EOF
${BLUE}Multi-Host Docker Orchestration${NC}

Usage: $0 <command> [options]

Global Commands:
  check-all          Check all remote hosts
  sync-all           Sync all remote hosts (download configs)
  push-all           Push configs to all remote hosts
  start-all          Start all services on all remote hosts
  stop-all           Stop all services on all remote hosts
  health-all         Check health of all services
  status-all         Show status of all remote hosts

TamMediaBox (192.168.0.13):
  tmb <command>      Run command on TamMediaBox (see: tmb --help)

AI Docker Host (192.168.0.7):
  ai <command>       Run command on AI_Docker_Host (see: ai --help)

TrueNAS Server (192.168.0.44):
  truenas <command>  Run command on TrueNAS (see: truenas --help)

Examples:
  $0 check-all                  # Check all hosts
  $0 sync-all                   # Backup and download configs from all hosts
  $0 start-all                  # Start services on all hosts
  $0 tmb ps                     # Show container status on TamMediaBox
  $0 ai start ollama            # Start Ollama stack on AI_Docker_Host
  $0 ai logs paperless webserver # Show Paperless logs on AI_Docker_Host
  $0 health-all                 # Check health of all services

EOF
}

###############################################################################
# Validation
###############################################################################

check_scripts() {
    if [[ ! -x "${TAMMEDIABOX_SCRIPT}" ]]; then
        log_error "TamMediaBox script not found or not executable: ${TAMMEDIABOX_SCRIPT}"
        return 1
    fi
    
    if [[ ! -x "${AI_HOST_SCRIPT}" ]]; then
        log_error "AI_Docker_Host script not found or not executable: ${AI_HOST_SCRIPT}"
        return 1
    fi
    
    if [[ ! -x "${TRUENAS_SCRIPT}" ]]; then
        log_error "TrueNAS script not found or not executable: ${TRUENAS_SCRIPT}"
        return 1
    fi
    
    return 0
}

###############################################################################
# Global Commands
###############################################################################

check_all() {
    log_info "═══════════════════════════════════════════════════════════"
    log_info "Checking TamMediaBox (192.168.0.13)..."
    log_info "═══════════════════════════════════════════════════════════"
    
    if "${TAMMEDIABOX_SCRIPT}" check; then
        log_success "TamMediaBox check passed"
    else
        log_error "TamMediaBox check failed"
    fi
    
    log_info ""
    log_info "═══════════════════════════════════════════════════════════"
    log_info "Checking AI_Docker_Host (192.168.0.7)..."
    log_info "═══════════════════════════════════════════════════════════"
    
    if "${AI_HOST_SCRIPT}" check; then
        log_success "AI_Docker_Host check passed"
    else
        log_error "AI_Docker_Host check failed"
    fi
    
    log_info ""
    log_info "═══════════════════════════════════════════════════════════"
    log_info "Checking TrueNAS (192.168.0.44)..."
    log_info "═══════════════════════════════════════════════════════════"
    
    if "${TRUENAS_SCRIPT}" check; then
        log_success "TrueNAS check passed"
    else
        log_error "TrueNAS check failed"
    fi
}

sync_all() {
    log_info "═══════════════════════════════════════════════════════════"
    log_info "Syncing TamMediaBox (192.168.0.13)..."
    log_info "═══════════════════════════════════════════════════════════"
    
    if "${TAMMEDIABOX_SCRIPT}" sync; then
        log_success "TamMediaBox sync passed"
    else
        log_warn "TamMediaBox sync had issues"
    fi
    
    log_info ""
    log_info "═══════════════════════════════════════════════════════════"
    log_info "Syncing AI_Docker_Host (192.168.0.7)..."
    log_info "═══════════════════════════════════════════════════════════"
    
    if "${AI_HOST_SCRIPT}" sync; then
        log_success "AI_Docker_Host sync passed"
    else
        log_warn "AI_Docker_Host sync had issues"
    fi
    
    log_info ""
    log_info "═══════════════════════════════════════════════════════════"
    log_info "Syncing TrueNAS (192.168.0.44)..."
    log_info "═══════════════════════════════════════════════════════════"
    
    if "${TRUENAS_SCRIPT}" sync; then
        log_success "TrueNAS sync passed"
    else
        log_warn "TrueNAS sync had issues"
    fi
    
    log_success "All hosts synced"
}

push_all() {
    log_info "═══════════════════════════════════════════════════════════"
    log_info "Pushing configs to TamMediaBox (192.168.0.13)..."
    log_info "═══════════════════════════════════════════════════════════"
    
    if "${TAMMEDIABOX_SCRIPT}" push; then
        log_success "TamMediaBox push passed"
    else
        log_warn "TamMediaBox push had issues"
    fi
    
    log_info ""
    log_info "═══════════════════════════════════════════════════════════"
    log_info "Pushing configs to AI_Docker_Host (192.168.0.7)..."
    log_info "═══════════════════════════════════════════════════════════"
    
    if "${AI_HOST_SCRIPT}" push; then
        log_success "AI_Docker_Host push passed"
    else
        log_warn "AI_Docker_Host push had issues"
    fi
    
    log_info ""
    log_info "═══════════════════════════════════════════════════════════"
    log_info "Pushing configs to TrueNAS (192.168.0.44)..."
    log_info "═══════════════════════════════════════════════════════════"
    
    if "${TRUENAS_SCRIPT}" push; then
        log_success "TrueNAS push passed"
    else
        log_warn "TrueNAS push had issues"
    fi
    
    log_success "All hosts updated"
}

start_all() {
    log_info "═══════════════════════════════════════════════════════════"
    log_info "Starting TamMediaBox services (192.168.0.13)..."
    log_info "═══════════════════════════════════════════════════════════"
    
    if "${TAMMEDIABOX_SCRIPT}" start; then
        log_success "TamMediaBox services started"
    else
        log_error "Failed to start TamMediaBox services"
    fi
    
    log_info ""
    log_info "═══════════════════════════════════════════════════════════"
    log_info "Starting AI_Docker_Host stacks (192.168.0.7)..."
    log_info "═══════════════════════════════════════════════════════════"
    
    if "${AI_HOST_SCRIPT}" start ollama; then
        log_success "Ollama stack started"
    else
        log_error "Failed to start Ollama stack"
    fi
    
    if "${AI_HOST_SCRIPT}" start utilities; then
        log_success "Utilities stack started"
    else
        log_error "Failed to start utilities stack"
    fi
    
    if "${AI_HOST_SCRIPT}" start paperless; then
        log_success "Paperless stack started"
    else
        log_error "Failed to start paperless stack"
    fi
    
    log_success "All services started"
}

stop_all() {
    log_info "═══════════════════════════════════════════════════════════"
    log_info "Stopping TamMediaBox services (192.168.0.13)..."
    log_info "═══════════════════════════════════════════════════════════"
    
    if "${TAMMEDIABOX_SCRIPT}" stop; then
        log_success "TamMediaBox services stopped"
    else
        log_error "Failed to stop TamMediaBox services"
    fi
    
    log_info ""
    log_info "═══════════════════════════════════════════════════════════"
    log_info "Stopping AI_Docker_Host stacks (192.168.0.7)..."
    log_info "═══════════════════════════════════════════════════════════"
    
    for stack in ollama utilities paperless; do
        if "${AI_HOST_SCRIPT}" stop "${stack}"; then
            log_success "${stack} stack stopped"
        else
            log_error "Failed to stop ${stack} stack"
        fi
    done
    
    log_success "All services stopped"
}

health_all() {
    log_info "═══════════════════════════════════════════════════════════"
    log_info "Health check: TamMediaBox (192.168.0.13)"
    log_info "═══════════════════════════════════════════════════════════"
    
    if "${TAMMEDIABOX_SCRIPT}" health; then
        log_success "TamMediaBox health check passed"
    else
        log_warn "TamMediaBox health check had issues"
    fi
    
    log_info ""
    log_info "═══════════════════════════════════════════════════════════"
    log_info "Health check: AI_Docker_Host (192.168.0.7)"
    log_info "═══════════════════════════════════════════════════════════"
    
    if "${AI_HOST_SCRIPT}" health; then
        log_success "AI_Docker_Host health check passed"
    else
        log_warn "AI_Docker_Host health check had issues"
    fi
    
    log_info ""
    log_info "═══════════════════════════════════════════════════════════"
    log_info "Health check: TrueNAS (192.168.0.44)"
    log_info "═══════════════════════════════════════════════════════════"
    
    if "${TRUENAS_SCRIPT}" health; then
        log_success "TrueNAS health check passed"
    else
        log_warn "TrueNAS health check had issues"
    fi
}

status_all() {
    log_info "═══════════════════════════════════════════════════════════"
    log_info "Status: TamMediaBox (192.168.0.13)"
    log_info "═══════════════════════════════════════════════════════════"
    
    "${TAMMEDIABOX_SCRIPT}" ps || true
    
    log_info ""
    log_info "═══════════════════════════════════════════════════════════"
    log_info "Status: AI_Docker_Host - Ollama Stack (192.168.0.7)"
    log_info "═══════════════════════════════════════════════════════════"
    
    "${AI_HOST_SCRIPT}" ps ollama || true
    
    log_info ""
    log_info "Status: AI_Docker_Host - Utilities Stack"
    "${AI_HOST_SCRIPT}" ps utilities || true
    
    log_info ""
    log_info "Status: AI_Docker_Host - Paperless Stack"
    "${AI_HOST_SCRIPT}" ps paperless || true
    
    log_info ""
    log_info "═══════════════════════════════════════════════════════════"
    log_info "Status: TrueNAS (192.168.0.44)"
    log_info "═══════════════════════════════════════════════════════════"
    
    "${TRUENAS_SCRIPT}" ps || true
}

###############################################################################
# Proxy Commands
###############################################################################

tmb_command() {
    "${TAMMEDIABOX_SCRIPT}" "$@"
}

ai_command() {
    "${AI_HOST_SCRIPT}" "$@"
}

truenas_command() {
    "${TRUENAS_SCRIPT}" "$@"
}

###############################################################################
# Main
###############################################################################

main() {
    if [[ $# -lt 1 ]]; then
        show_usage
        exit 1
    fi
    
    check_scripts || exit 1
    
    local command=$1
    shift || true
    
    case "${command}" in
        check-all)
            check_all
            ;;
        sync-all)
            sync_all
            ;;
        push-all)
            push_all
            ;;
        start-all)
            start_all
            ;;
        stop-all)
            stop_all
            ;;
        health-all)
            health_all
            ;;
        status-all)
            status_all
            ;;
        tmb)
            tmb_command "$@"
            ;;
        ai)
            ai_command "$@"
            ;;
        truenas)
            truenas_command "$@"
            ;;
        --help|-h)
            show_usage
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
