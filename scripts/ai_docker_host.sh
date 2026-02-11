#!/bin/bash
###############################################################################
# AI Docker Host Remote Automation
# Manages Docker containers on AI_Docker_Host (192.168.0.7) from primary host
###############################################################################

set -euo pipefail

# Source .env if exists
if [[ -f "/opt/stacks/.env" ]]; then
    source "/opt/stacks/.env"
fi

AI_HOST_IP="${AI_HOST_IP:-192.168.0.7}"
AI_HOST_USER="${AI_HOST_USER:-tammer}"
SSH_KEY="${HOME}/.ssh/id_ed25519"
LOCAL_DIR="/opt/stacks/AI_Docker_Host"
LOCBACKUP_DIR="/opt/stacks/backups/AI_Docker_Host"
REMOTE_DIR="/opt/stacks"
BACKUP_DIR="${LOCAL_DIR}/backups"
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
        "${AI_HOST_USER}@${AI_HOST_IP}" "$cmd" 2>&1
}

###############################################################################
# Health Check
###############################################################################

check_connectivity() {
    log_info "Checking connectivity to AI_Docker_Host (${AI_HOST_IP})..."
    
    if ! ping -c 1 -W 2 "${AI_HOST_IP}" >/dev/null 2>&1; then
        log_error "Cannot reach AI_Docker_Host at ${AI_HOST_IP}"
        return 1
    fi
    
    if ! ssh_exec "exit 0" >/dev/null 2>&1; then
        log_error "Cannot SSH to AI_Docker_Host at ${AI_HOST_IP}"
        return 1
    fi
    
    log_success "Connected to AI_Docker_Host"
    return 0
}

###############################################################################
# Sync Operations
###############################################################################

sync_from_ai_host() {
    log_info "Syncing configuration from AI_Docker_Host..."
    
    # Create backup directory
    mkdir -p "${BACKUP_DIR}"
    
    local stacks=("ollama" "utilities" "paperless")
    
    for stack in "${stacks[@]}"; do
        log_info "Syncing ${stack} stack..."
        
        # Backup existing files
        if [[ -f "${LOCAL_DIR}/${stack}/compose.yaml" ]]; then
            cp "${LOCAL_DIR}/${stack}/compose.yaml" "${BACKUP_DIR}/${stack}.compose.yaml.$(date +%s).bak"
        fi
        
        if [[ -f "${LOCAL_DIR}/${stack}/.env" ]]; then
            cp "${LOCAL_DIR}/${stack}/.env" "${BACKUP_DIR}/${stack}.env.$(date +%s).bak"
        fi
        
        # Sync compose.yaml
        log_info "Retrieving ${stack}/compose.yaml..."
        if ssh_exec "cat ${REMOTE_DIR}/${stack}/compose.yaml" > "${LOCAL_DIR}/${stack}/compose.yaml"; then
            log_success "Downloaded ${stack}/compose.yaml"
        else
            log_error "Failed to download ${stack}/compose.yaml"
        fi
        
        # Sync .env
        log_info "Retrieving ${stack}/.env..."
        if ssh_exec "test -f ${REMOTE_DIR}/${stack}/.env && cat ${REMOTE_DIR}/${stack}/.env" > "${LOCAL_DIR}/${stack}/.env.remote" 2>/dev/null; then
            if [[ -s "${LOCAL_DIR}/${stack}/.env.remote" ]]; then
                mv "${LOCAL_DIR}/${stack}/.env.remote" "${LOCAL_DIR}/${stack}/.env"
                log_success "Downloaded ${stack}/.env"
            else
                rm -f "${LOCAL_DIR}/${stack}/.env.remote"
                log_warn "${stack}/.env is empty on AI_Docker_Host"
            fi
        else
            rm -f "${LOCAL_DIR}/${stack}/.env.remote"
            log_warn "No ${stack}/.env file on AI_Docker_Host"
        fi
    done
    
    log_success "Sync from AI_Docker_Host complete"
}

sync_to_ai_host() {
    log_info "Syncing configuration to AI_Docker_Host..."
    
    local stacks=("ollama" "utilities" "paperless")
    
    for stack in "${stacks[@]}"; do
        # Sync .env files
        if [[ -f "${LOCAL_DIR}/${stack}/.env" ]]; then
            log_info "Uploading ${stack}/.env to AI_Docker_Host..."
            scp -i "${SSH_KEY}" -q "${LOCAL_DIR}/${stack}/.env" \
                "${AI_HOST_USER}@${AI_HOST_IP}:${REMOTE_DIR}/${stack}/.env"
            log_success "Uploaded ${stack}/.env"
        fi
        
        # Validate compose syntax
        log_info "Validating ${stack}/compose.yaml on AI_Docker_Host..."
        if ssh_exec "cd ${REMOTE_DIR}/${stack} && docker compose config >/dev/null 2>&1"; then
            log_success "${stack}/compose.yaml is valid"
        else
            log_error "${stack}/compose.yaml validation failed on AI_Docker_Host"
        fi
    done
    
    log_success "Sync to AI_Docker_Host complete"
}

###############################################################################
# Container Management
###############################################################################

start_services() {
    local stack=$1
    log_info "Starting ${stack} services on AI_Docker_Host..."
    
    if ssh_exec "cd ${REMOTE_DIR}/${stack} && docker compose up -d"; then
        log_success "${stack} services started on AI_Docker_Host"
        docker_ps "${stack}"
    else
        log_error "Failed to start ${stack} services on AI_Docker_Host"
        return 1
    fi
}

stop_services() {
    local stack=$1
    log_info "Stopping ${stack} services on AI_Docker_Host..."
    
    if ssh_exec "cd ${REMOTE_DIR}/${stack} && docker compose down"; then
        log_success "${stack} services stopped on AI_Docker_Host"
    else
        log_error "Failed to stop ${stack} services on AI_Docker_Host"
        return 1
    fi
}

restart_services() {
    local stack=$1
    log_info "Restarting ${stack} services on AI_Docker_Host..."
    
    if ssh_exec "cd ${REMOTE_DIR}/${stack} && docker compose restart"; then
        log_success "${stack} services restarted on AI_Docker_Host"
        docker_ps "${stack}"
    else
        log_error "Failed to restart ${stack} services on AI_Docker_Host"
        return 1
    fi
}

docker_ps() {
    local stack=$1
    log_info "Container status for ${stack} on AI_Docker_Host:"
    ssh_exec "cd ${REMOTE_DIR}/${stack} && docker compose ps" | sed 's/^/  /'
}

docker_logs() {
    local stack=$1
    local service=$2
    log_info "Logs for ${service} in ${stack} on AI_Docker_Host:"
    ssh_exec "cd ${REMOTE_DIR}/${stack} && docker compose logs --tail 50 ${service}" | sed 's/^/  /'
}

###############################################################################
# Health Checks
###############################################################################

health_check() {
    log_info "Running health checks on AI_Docker_Host..."
    
    local ollama_up=$(ssh_exec "curl -s -o /dev/null -w '%{http_code}' http://localhost:11434" || echo "000")
    local webui_up=$(ssh_exec "curl -s -o /dev/null -w '%{http_code}' http://localhost:8080" || echo "000")
    local paperless_up=$(ssh_exec "curl -s -o /dev/null -w '%{http_code}' http://localhost:8000" || echo "000")
    local whisper_up=$(ssh_exec "curl -s -o /dev/null -w '%{http_code}' http://localhost:9000" || echo "000")
    
    log_info "Ollama API: HTTP ${ollama_up}"
    log_info "Open-WebUI: HTTP ${webui_up}"
    log_info "Paperless: HTTP ${paperless_up}"
    log_info "Whisper-ASR: HTTP ${whisper_up}"
    
    if [[ "${ollama_up}" == "200" ]] || [[ "${ollama_up}" == "404" ]]; then
        log_success "Ollama API is responding"
    else
        log_warn "Ollama API may not be responding (HTTP ${ollama_up})"
    fi
    
    if [[ "${webui_up}" == "200" ]] || [[ "${webui_up}" == "304" ]]; then
        log_success "Open-WebUI is responding"
    else
        log_warn "Open-WebUI may not be responding (HTTP ${webui_up})"
    fi
    
    # Check GPU availability
    log_info "Checking GPU availability..."
    if ssh_exec "nvidia-smi >/dev/null 2>&1"; then
        log_success "GPU is available"
        ssh_exec "nvidia-smi --query-gpu=index,name,memory.total,memory.free --format=csv,nounits" | sed 's/^/  /'
    else
        log_warn "GPU not available or nvidia-smi not installed"
    fi
}

###############################################################################
# Main Command Handler
###############################################################################

show_usage() {
    cat << EOF
${BLUE}AI Docker Host Remote Management${NC}

Usage: $0 <command> [options]

Commands:
  check              Check connectivity and health status
  sync               Sync configuration FROM AI_Docker_Host to primary
  push               Sync configuration TO AI_Docker_Host from primary
  start <stack>      Start services (ollama, utilities, or paperless)
  stop <stack>       Stop services
  restart <stack>    Restart services
  logs <stack> [svc] Show logs for service
  ps <stack>         Show container status
  health             Run health checks (CPU, GPU, services)
  
Stacks:
  - ollama          LLM inference, web UI, speech recognition, subtitle generation
  - utilities       Remote monitoring (dozzle-agent)
  - paperless       Document management with AI enhancement

Examples:
  $0 check                      # Check if AI_Docker_Host is reachable
  $0 sync                       # Backup and download configs from AI_Docker_Host
  $0 push                       # Upload .env to AI_Docker_Host
  $0 start ollama               # Start Ollama stack
  $0 logs paperless webserver   # Show Paperless webserver logs
  $0 ps utilities               # Show utilities stack status
  $0 health                     # Check GPU and service health

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
            check_connectivity && sync_from_ai_host
            ;;
        push)
            check_connectivity && sync_to_ai_host
            ;;
        start)
            check_connectivity && start_services "${1:-ollama}"
            ;;
        stop)
            check_connectivity && stop_services "${1:-ollama}"
            ;;
        restart)
            check_connectivity && restart_services "${1:-ollama}"
            ;;
        ps)
            check_connectivity && docker_ps "${1:-ollama}"
            ;;
        logs)
            check_connectivity && docker_logs "${1:-ollama}" "${2:-}"
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
