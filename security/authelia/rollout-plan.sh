#!/bin/bash
###############################################################################
#                  Authelia Rollout Plan Automation                           #
###############################################################################
#
# This script implements the phased rollout of Authelia protection
# Usage: ./rollout-plan.sh [phase]
# Example: ./rollout-plan.sh phase1
#
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROTECT_SCRIPT="$SCRIPT_DIR/protect-service.sh"
TRAEFIK_HOST="192.168.0.2"
TRAEFIK_USER="root"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_info() { echo -e "${YELLOW}ℹ${NC} $1"; }

# Rollout phases
declare -A PHASES

# Phase 1: Low-risk test services
PHASES[phase1]="overseerr jellyseerr"

# Phase 2: Admin services
PHASES[phase2]="traefik dozzle dockhand npmplus"

# Phase 3: Media management
PHASES[phase3]="sonarr radarr lidarr readarr prowlarr qbittorrent sabnzbd"

# Phase 4: Additional services
PHASES[phase4]="audiobookshelf kapowarr tunarr wizarr listenarr komga kavita calibre calibre-web bazarr whisparr mylar3 lazylibrarian"

# Phase 5: Utility services
PHASES[phase5]="homepage homarr dashy glances dozzle uptime-kuma changedetection healthchecks"

# Function to protect services in a phase
protect_phase() {
    local phase="$1"
    local services="${PHASES[$phase]}"

    if [ -z "$services" ]; then
        echo "Unknown phase: $phase"
        echo "Available phases: ${!PHASES[@]}"
        exit 1
    fi

    print_header "Rollout $phase"
    echo "Services to protect:"
    for service in $services; do
        echo "  - $service"
    done
    echo ""

    read -p "Proceed with $phase? (y/N): " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Cancelled"
        exit 0
    fi

    echo ""
    protected=0
    failed=0

    for service in $services; do
        echo ""
        print_info "Protecting $service..."

        if bash "$PROTECT_SCRIPT" "$service" >/dev/null 2>&1; then
            print_success "$service protected"
            ((protected++))
        else
            # Check if service exists
            if ssh "$TRAEFIK_USER@$TRAEFIK_HOST" "grep -q '${service}:' /etc/traefik/conf.d/*.yml"; then
                echo "  Service found but protection failed (may already be protected)"
            else
                echo "  Service not found in Traefik config - skipping"
            fi
            ((failed++))
        fi
    done

    echo ""
    print_header "Phase $phase Summary"
    print_success "Protected: $protected services"
    if [ $failed -gt 0 ]; then
        echo "  Failed/Skipped: $failed services"
    fi
    echo ""

    # Restart Traefik
    print_info "Restarting Traefik..."
    ssh "$TRAEFIK_USER@$TRAEFIK_HOST" "systemctl restart traefik"
    sleep 2

    if ssh "$TRAEFIK_USER@$TRAEFIK_HOST" "systemctl is-active --quiet traefik"; then
        print_success "Traefik restarted successfully"
    else
        echo "ERROR: Traefik failed to start!"
        echo "Check logs: ssh $TRAEFIK_USER@$TRAEFIK_HOST 'journalctl -u traefik -n 50'"
        exit 1
    fi

    echo ""
    print_header "Testing Phase $phase"
    echo "Test these services to ensure authentication works:"
    echo ""
    for service in $services; do
        echo "  https://${service}.thehighestcommittee.com"
    done
    echo ""
    print_info "You should be redirected to Authelia login page"
    print_info "After login, you should be redirected back to the service"
    echo ""
}

# Function to show rollout status
show_status() {
    print_header "Authelia Rollout Status"

    for phase in "${!PHASES[@]}"; do
        echo ""
        echo "$phase:"
        services="${PHASES[$phase]}"

        for service in $services; do
            # Check if service has authelia middleware
            if ssh "$TRAEFIK_USER@$TRAEFIK_HOST" \
                "grep -A 10 '${service}:' /etc/traefik/conf.d/*.yml 2>/dev/null | grep -q 'authelia@file'"; then
                print_success "$service - PROTECTED"
            else
                # Check if service exists
                if ssh "$TRAEFIK_USER@$TRAEFIK_HOST" \
                    "grep -q '${service}:' /etc/traefik/conf.d/*.yml 2>/dev/null"; then
                    echo "  ○ $service - not protected"
                else
                    echo "  - $service - not found in config"
                fi
            fi
        done
    done

    echo ""
}

# Function to protect custom list of services
protect_custom() {
    print_header "Custom Service Protection"

    echo "Enter services to protect (space-separated):"
    read -r services

    if [ -z "$services" ]; then
        print_info "No services specified"
        exit 0
    fi

    echo ""
    echo "Services to protect:"
    for service in $services; do
        echo "  - $service"
    done
    echo ""

    read -p "Proceed? (y/N): " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Cancelled"
        exit 0
    fi

    protected=0
    for service in $services; do
        if bash "$PROTECT_SCRIPT" "$service"; then
            ((protected++))
        fi
    done

    echo ""
    print_success "Protected $protected services"

    # Restart Traefik
    read -p "Restart Traefik? (Y/n): " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        ssh "$TRAEFIK_USER@$TRAEFIK_HOST" "systemctl restart traefik"
        print_success "Traefik restarted"
    fi
}

# Main menu
main() {
    if [ $# -eq 0 ]; then
        print_header "Authelia Rollout Plan"
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  phase1        - Protect test services (overseerr, jellyseerr)"
        echo "  phase2        - Protect admin services (traefik, dozzle, etc.)"
        echo "  phase3        - Protect media management (*arr, downloaders)"
        echo "  phase4        - Protect additional services"
        echo "  phase5        - Protect utility services"
        echo "  custom        - Protect custom list of services"
        echo "  status        - Show protection status of all services"
        echo "  all           - Protect all eligible services (use with caution!)"
        echo ""
        echo "Examples:"
        echo "  $0 phase1"
        echo "  $0 status"
        echo "  $0 custom"
        echo ""
        exit 0
    fi

    case "$1" in
        phase1|phase2|phase3|phase4|phase5)
            protect_phase "$1"
            ;;
        status)
            show_status
            ;;
        custom)
            protect_custom
            ;;
        all)
            print_header "WARNING: Protect ALL Services"
            echo "This will add Authelia protection to ALL eligible services"
            echo ""
            read -p "Are you sure? Type 'YES' to continue: " confirm

            if [ "$confirm" == "YES" ]; then
                bash "$PROTECT_SCRIPT" all
            else
                print_info "Cancelled"
            fi
            ;;
        *)
            echo "Unknown command: $1"
            echo "Run without arguments to see usage"
            exit 1
            ;;
    esac
}

main "$@"
