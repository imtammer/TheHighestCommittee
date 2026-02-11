#!/bin/bash
################################################################################
# cross_reference_automation.sh
# Automated cross-referencing of:
#   - HOSTED_APPS.md service listings
#   - NPM Plus proxy hosts (from MD or API)
#   - Traefik dynamic configurations on 192.168.0.2
#
# Purpose: Ensure DNS names match correct service IPs/ports across all systems
# Usage: ./cross_reference_automation.sh [--npm-api] [--fix]
################################################################################

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STACKS_DIR="/opt/stacks"
HOSTED_APPS_MD="${STACKS_DIR}/HOSTED_APPS.md"
ENV_FILE="${STACKS_DIR}/.env"
OUTPUT_DIR="${STACKS_DIR}/reports"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="${OUTPUT_DIR}/cross_reference_report_${TIMESTAMP}.txt"

# Traefik configuration
TRAEFIK_HOST="192.168.0.2"
TRAEFIK_USER="root"
TRAEFIK_DYNAMIC_DIR="/etc/traefik/dynamic"
SSH_KEY="${HOME}/.ssh/id_ed25519"

# NPM Plus configuration
set +u  # Temporarily allow unset variables for env loading
source "${ENV_FILE}" 2>/dev/null || true
NPM_HOST="${NPMPLUS_IP:-192.168.0.14}"
NPM_PORT="81"
NPM_USER="${NPMPLUS_USERNAME:-}"
NPM_PASS="${NPMPLUS_PASSWORD:-}"
NPM_API="https://${NPM_HOST}:${NPM_PORT}/api"
set -u  # Re-enable strict mode

# Flags
USE_NPM_API=false
AUTO_FIX=false

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

################################################################################
# Helper Functions
################################################################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $*" | tee -a "${REPORT_FILE}"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $*" | tee -a "${REPORT_FILE}"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $*" | tee -a "${REPORT_FILE}"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" | tee -a "${REPORT_FILE}"
}

################################################################################
# Parse HOSTED_APPS.md
################################################################################

parse_hosted_apps_services() {
    log_info "Parsing services from HOSTED_APPS.md..."

    # Extract service entries with ports and external URLs
    # Format: service_name|port|ip|external_domain
    awk '
    /^\| [🏷️🎬📺🎵📚📖🤖🎮🍳📊🎛️🔐🔀🌐]+ \| \*\*[^*]+\*\* \| \[[0-9]+\]/ {
        # Match format: | 🏷️ | **Service** | [port](http://ip:port) | [domain](https://domain) | ...
        match($0, /\*\*([^*]+)\*\*/, service)
        match($0, /\[([0-9]+)\]\(http:\/\/([0-9.]+):([0-9]+)\)/, port_info)
        match($0, /\[([a-z0-9.-]+\.thehighestcommittee\.com)\]/, domain)

        if (service[1] != "" && port_info[2] != "" && port_info[3] != "") {
            service_name = service[1]
            gsub(/^[ \t]+|[ \t]+$/, "", service_name)  # trim
            ip = port_info[2]
            port = port_info[3]
            ext_domain = domain[1] != "" ? domain[1] : "none"

            print service_name "|" port "|" ip "|" ext_domain
        }
    }
    ' "${HOSTED_APPS_MD}" | sort -u
}

parse_npm_proxy_hosts() {
    log_info "Parsing NPM Plus proxy hosts from HOSTED_APPS.md..."

    # Extract from the NPM Plus Proxy Hosts section
    awk '
    /## 🌐 NPM Plus Proxy Hosts/,/^---/ {
        if ($0 ~ /^\| [a-z0-9.-]+\.thehighestcommittee\.com \|/) {
            match($0, /\| ([a-z0-9.-]+\.thehighestcommittee\.com) \| ([0-9.]+:[0-9]+) \| ([^|]+) \|/, arr)
            if (arr[1] != "") {
                domain = arr[1]
                target = arr[2]
                host = arr[3]
                gsub(/^[ \t]+|[ \t]+$/, "", host)  # trim
                print domain "|" target "|" host
            }
        }
    }
    ' "${HOSTED_APPS_MD}" | sort -u
}

################################################################################
# Query NPM Plus API (Optional)
################################################################################

query_npm_api() {
    log_info "Querying NPM Plus API for proxy hosts..."

    # Get auth token
    local token
    token=$(curl -sk -X POST "${NPM_API}/tokens" \
        -H "Content-Type: application/json" \
        -d "{\"identity\": \"${NPM_USER}\", \"secret\": \"${NPM_PASS}\"}" \
        2>/dev/null | jq -r '.token' 2>/dev/null)

    if [[ -z "$token" || "$token" == "null" ]]; then
        log_error "Failed to authenticate with NPM Plus API"
        return 1
    fi

    # Get proxy hosts
    curl -sk -X GET "${NPM_API}/nginx/proxy-hosts" \
        -H "Authorization: Bearer ${token}" \
        2>/dev/null | jq -r '.[] |
        "\(.domain_names[0])|\(.forward_host):\(.forward_port)|\(.meta.nginx_online)"' \
        2>/dev/null | sort -u
}

################################################################################
# Query Traefik Configuration
################################################################################

query_traefik_config() {
    log_info "Querying Traefik dynamic configuration on ${TRAEFIK_HOST}..."

    if ! ssh -i "${SSH_KEY}" -o ConnectTimeout=5 -o StrictHostKeyChecking=no \
        "${TRAEFIK_USER}@${TRAEFIK_HOST}" "test -d ${TRAEFIK_DYNAMIC_DIR}" 2>/dev/null; then
        log_error "Cannot connect to Traefik host or directory doesn't exist"
        return 1
    fi

    # Extract router and service configurations
    ssh -i "${SSH_KEY}" -o StrictHostKeyChecking=no \
        "${TRAEFIK_USER}@${TRAEFIK_HOST}" \
        "find ${TRAEFIK_DYNAMIC_DIR} -type f \( -name '*.yml' -o -name '*.yaml' \) -exec cat {} \;" \
        2>/dev/null | \
    python3 -c '
import sys, yaml, json
try:
    data = yaml.safe_load(sys.stdin)
    for router_name, router_config in data.get("http", {}).get("routers", {}).items():
        rule = router_config.get("rule", "")
        service = router_config.get("service", "")
        # Extract domain from Host() rule
        if "Host(" in rule:
            domain = rule.split("Host(`")[1].split("`")[0] if "Host(`" in rule else ""
            print(f"{router_name}|{domain}|{service}")

    for service_name, service_config in data.get("http", {}).get("services", {}).items():
        if "loadBalancer" in service_config:
            servers = service_config["loadBalancer"].get("servers", [])
            for server in servers:
                url = server.get("url", "")
                print(f"SERVICE|{service_name}|{url}")
except Exception as e:
    pass
' 2>/dev/null || log_warning "Traefik config parsing failed (may not have Python/YAML)"
}

################################################################################
# Cross-Reference and Validate
################################################################################

cross_reference() {
    log_info "Starting cross-reference validation..."
    echo "" >> "${REPORT_FILE}"
    echo "========================================" >> "${REPORT_FILE}"
    echo "CROSS-REFERENCE REPORT" >> "${REPORT_FILE}"
    echo "Generated: $(date)" >> "${REPORT_FILE}"
    echo "========================================" >> "${REPORT_FILE}"
    echo "" >> "${REPORT_FILE}"

    # Parse all sources
    local services_file="/tmp/hosted_services_${TIMESTAMP}.txt"
    local npm_file="/tmp/npm_hosts_${TIMESTAMP}.txt"
    local traefik_file="/tmp/traefik_config_${TIMESTAMP}.txt"

    parse_hosted_apps_services > "${services_file}"
    parse_npm_proxy_hosts > "${npm_file}"

    if [[ "$USE_NPM_API" == true ]]; then
        query_npm_api > "${npm_file}.api" 2>/dev/null || true
    fi

    query_traefik_config > "${traefik_file}" 2>/dev/null || true

    # Report statistics
    local service_count=$(wc -l < "${services_file}")
    local npm_count=$(wc -l < "${npm_file}")
    local traefik_count=$(grep -c "^[^SERVICE]" "${traefik_file}" 2>/dev/null || echo "0")

    log_info "Found ${service_count} services in HOSTED_APPS.md"
    log_info "Found ${npm_count} proxy hosts in NPM Plus section"
    log_info "Found ${traefik_count} routers in Traefik config"
    echo "" >> "${REPORT_FILE}"

    # Cross-reference NPM hosts with services
    log_info "Validating NPM proxy hosts against services..."
    echo "## NPM Proxy Host Validation" >> "${REPORT_FILE}"
    echo "" >> "${REPORT_FILE}"

    local npm_matches=0
    local npm_mismatches=0

    while IFS='|' read -r domain target host; do
        # Extract IP and port from target
        local target_ip="${target%:*}"
        local target_port="${target#*:}"

        # Find matching service
        local service_match=$(grep "|${target_port}|${target_ip}|" "${services_file}" 2>/dev/null || true)

        if [[ -n "$service_match" ]]; then
            local service_name=$(echo "$service_match" | cut -d'|' -f1)
            local service_domain=$(echo "$service_match" | cut -d'|' -f4)

            if [[ "$service_domain" == "$domain" || "$service_domain" == "none" ]]; then
                log_success "NPM: ${domain} → ${target} (${service_name})"
                ((npm_matches++))
            else
                log_warning "NPM: ${domain} → ${target} (${service_name}) - Domain mismatch! Expected: ${service_domain}"
                ((npm_mismatches++))
            fi
        else
            log_error "NPM: ${domain} → ${target} - No matching service found!"
            ((npm_mismatches++))
        fi
    done < "${npm_file}"

    echo "" >> "${REPORT_FILE}"
    log_info "NPM Validation: ${npm_matches} matches, ${npm_mismatches} mismatches"
    echo "" >> "${REPORT_FILE}"

    # Cross-reference Traefik with services
    log_info "Validating Traefik routes against services..."
    echo "## Traefik Route Validation" >> "${REPORT_FILE}"
    echo "" >> "${REPORT_FILE}"

    local traefik_matches=0
    local traefik_mismatches=0

    # Build service lookup map
    declare -A traefik_services
    while IFS='|' read -r type name url; do
        if [[ "$type" == "SERVICE" ]]; then
            traefik_services["$name"]="$url"
        fi
    done < "${traefik_file}"

    # Validate routers
    while IFS='|' read -r router domain service; do
        [[ "$router" == "SERVICE" ]] && continue

        if [[ -n "$domain" ]]; then
            # Look up service URL
            local service_url="${traefik_services[$service]:-}"

            if [[ -n "$service_url" ]]; then
                # Extract IP and port from URL
                local clean_url="${service_url#http://}"
                clean_url="${clean_url#https://}"
                local url_ip="${clean_url%:*}"
                local url_port="${clean_url#*:}"
                url_port="${url_port%/*}"

                # Find matching service in HOSTED_APPS
                local service_match=$(grep "|${url_port}|${url_ip}|" "${services_file}" 2>/dev/null || true)

                if [[ -n "$service_match" ]]; then
                    local service_name=$(echo "$service_match" | cut -d'|' -f1)
                    local service_domain=$(echo "$service_match" | cut -d'|' -f4)

                    if [[ "$service_domain" == "$domain" || "$service_domain" == "none" ]]; then
                        log_success "Traefik: ${domain} → ${service_url} (${service_name})"
                        ((traefik_matches++))
                    else
                        log_warning "Traefik: ${domain} → ${service_url} (${service_name}) - Domain mismatch! Expected: ${service_domain}"
                        ((traefik_mismatches++))
                    fi
                else
                    log_warning "Traefik: ${domain} → ${service_url} - No matching service in HOSTED_APPS.md"
                    ((traefik_mismatches++))
                fi
            else
                log_error "Traefik: ${domain} - Service ${service} not found in config!"
                ((traefik_mismatches++))
            fi
        fi
    done < <(grep -v "^SERVICE" "${traefik_file}" 2>/dev/null || true)

    echo "" >> "${REPORT_FILE}"
    log_info "Traefik Validation: ${traefik_matches} matches, ${traefik_mismatches} mismatches"
    echo "" >> "${REPORT_FILE}"

    # Summary
    echo "========================================" >> "${REPORT_FILE}"
    echo "SUMMARY" >> "${REPORT_FILE}"
    echo "========================================" >> "${REPORT_FILE}"
    echo "NPM Plus: ${npm_matches} OK, ${npm_mismatches} issues" >> "${REPORT_FILE}"
    echo "Traefik: ${traefik_matches} OK, ${traefik_mismatches} issues" >> "${REPORT_FILE}"
    echo "" >> "${REPORT_FILE}"

    local total_issues=$((npm_mismatches + traefik_mismatches))
    if [[ $total_issues -eq 0 ]]; then
        log_success "All validations passed! No mismatches found."
    else
        log_warning "Found ${total_issues} total issues. Review report: ${REPORT_FILE}"
    fi

    # Cleanup temp files
    rm -f "${services_file}" "${npm_file}" "${npm_file}.api" "${traefik_file}"
}

################################################################################
# Main
################################################################################

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --npm-api)
                USE_NPM_API=true
                shift
                ;;
            --fix)
                AUTO_FIX=true
                log_warning "Auto-fix mode not yet implemented"
                shift
                ;;
            -h|--help)
                cat << EOF
Usage: $0 [OPTIONS]

Automated cross-referencing of HOSTED_APPS.md, NPM Plus, and Traefik configs.

OPTIONS:
    --npm-api       Query NPM Plus API instead of parsing MD (requires jq)
    --fix           Auto-fix mismatches (not yet implemented)
    -h, --help      Show this help message

REQUIREMENTS:
    - SSH key access to root@${TRAEFIK_HOST}
    - jq (if using --npm-api)
    - Python 3 with PyYAML (for Traefik config parsing)

EXAMPLE:
    $0                  # Basic validation using HOSTED_APPS.md
    $0 --npm-api        # Include NPM Plus API query

REPORT:
    Generated at: ${OUTPUT_DIR}/cross_reference_report_TIMESTAMP.txt
EOF
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done

    # Setup
    mkdir -p "${OUTPUT_DIR}"

    # Validate dependencies
    if [[ "$USE_NPM_API" == true ]] && ! command -v jq &>/dev/null; then
        log_error "jq is required for --npm-api option. Install with: apt install jq"
        exit 1
    fi

    if ! ssh -i "${SSH_KEY}" -o ConnectTimeout=5 -o StrictHostKeyChecking=no \
        "${TRAEFIK_USER}@${TRAEFIK_HOST}" "echo test" &>/dev/null; then
        log_error "Cannot SSH to ${TRAEFIK_HOST}. Setup keys with:"
        echo "  ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ''"
        echo "  ssh-copy-id -i ~/.ssh/id_ed25519 ${TRAEFIK_USER}@${TRAEFIK_HOST}"
        exit 1
    fi

    # Run cross-reference
    log_info "Starting automated cross-reference validation..."
    cross_reference

    log_info "Report saved to: ${REPORT_FILE}"
}

main "$@"
