#!/bin/bash
###############################################################################
#                  Authelia Service Protection Script                         #
###############################################################################
#
# This script automatically adds Authelia authentication to Traefik services
# Usage: ./protect-service.sh [service-name] [config-file]
# Example: ./protect-service.sh overseerr primary-host
#
###############################################################################

set -euo pipefail

TRAEFIK_HOST="192.168.0.2"
TRAEFIK_USER="root"
TRAEFIK_CONF_DIR="/etc/traefik/conf.d"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_info() { echo -e "${NC}ℹ${NC} $1"; }

# Check arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 <service-name> [config-file]"
    echo ""
    echo "Examples:"
    echo "  $0 overseerr                    # Auto-detect config file"
    echo "  $0 sonarr primary-host          # Specify config file"
    echo "  $0 all                          # Protect all eligible services"
    echo ""
    exit 1
fi

SERVICE_NAME="$1"
CONFIG_FILE="${2:-}"

# Services that should NOT be protected (would break or create loops)
EXCLUDED_SERVICES=(
    "authelia"           # Would create auth loop
    "auth"               # Pocket-ID
    "plex"               # Uses custom headers
    "jellyfin"           # Bypass policy
)

# Function to check if service should be excluded
is_excluded() {
    local service="$1"
    for excluded in "${EXCLUDED_SERVICES[@]}"; do
        if [[ "$service" == "$excluded" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to find which config file contains the service
find_config_file() {
    local service="$1"

    # Try to find the service in Traefik config files
    local found_file=$(ssh "$TRAEFIK_USER@$TRAEFIK_HOST" \
        "grep -l \"${service}:\" $TRAEFIK_CONF_DIR/*.yml 2>/dev/null | head -1")

    if [ -n "$found_file" ]; then
        basename "$found_file"
    else
        echo ""
    fi
}

# Function to backup config file
backup_config() {
    local config_file="$1"
    local backup_name="${config_file}.backup.$(date +%Y%m%d_%H%M%S)"

    print_info "Creating backup: $backup_name"
    ssh "$TRAEFIK_USER@$TRAEFIK_HOST" \
        "cp $TRAEFIK_CONF_DIR/$config_file $TRAEFIK_CONF_DIR/$backup_name"
    print_success "Backup created"
}

# Function to check if service already has authelia middleware
has_authelia() {
    local service="$1"
    local config_file="$2"

    ssh "$TRAEFIK_USER@$TRAEFIK_HOST" \
        "grep -A 10 \"${service}:\" $TRAEFIK_CONF_DIR/$config_file | grep -q 'authelia@file'" && return 0 || return 1
}

# Function to protect a single service
protect_service() {
    local service="$1"
    local config_file="$2"

    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Protecting: $service (in $config_file)"
    echo "═══════════════════════════════════════════════════════════════"

    # Check if service is excluded
    if is_excluded "$service"; then
        print_warning "Service '$service' is in exclusion list - skipping"
        return 1
    fi

    # Check if service already has authelia
    if has_authelia "$service" "$config_file"; then
        print_warning "Service '$service' already has Authelia middleware"
        return 0
    fi

    # Backup config file
    backup_config "$config_file"

    # Create temporary file with the modification
    print_info "Adding Authelia middleware to $service..."

    # Use Python script for safe YAML editing
    ssh "$TRAEFIK_USER@$TRAEFIK_HOST" "python3 - '$service' '$TRAEFIK_CONF_DIR/$config_file'" << 'PYTHON_SCRIPT'
import sys
import re

service_name = sys.argv[1]
config_file = sys.argv[2]

try:
    with open(config_file, 'r') as f:
        content = f.read()

    # Find the service router section
    # Pattern: Match from service_name until the next service at same indentation or end of section
    # Match service_name: followed by indented lines until we hit another service at same level or empty line
    pattern = rf'(^ *{service_name}:\n(?:(?:^      .*\n)+))'

    match = re.search(pattern, content, re.MULTILINE)
    if not match:
        print(f"ERROR: Could not find service '{service_name}' in config", file=sys.stderr)
        sys.exit(1)

    router_section = match.group(0)

    # Check if middlewares already exists
    if 'middlewares:' in router_section:
        # Add authelia to existing middlewares list
        if 'authelia@file' not in router_section:
            # Find the middlewares section and add authelia
            new_section = re.sub(
                r'(middlewares:\n)',
                r'\1        - authelia@file\n',
                router_section
            )
        else:
            print(f"INFO: authelia@file already in middlewares", file=sys.stderr)
            new_section = router_section
    else:
        # Add new middlewares section before tls
        new_section = re.sub(
            r'(\n      entryPoints:.*\n)',
            r'\1      middlewares:\n        - authelia@file\n',
            router_section
        )

    # Replace in content
    new_content = content.replace(router_section, new_section)

    # Write back
    with open(config_file, 'w') as f:
        f.write(new_content)

    print(f"SUCCESS: Added authelia middleware to {service_name}")

except Exception as e:
    print(f"ERROR: {e}", file=sys.stderr)
    sys.exit(1)
PYTHON_SCRIPT

    if [ $? -eq 0 ]; then
        print_success "Authelia middleware added to $service"
        return 0
    else
        print_error "Failed to add middleware to $service"
        return 1
    fi
}

# Function to restart Traefik
restart_traefik() {
    print_info "Restarting Traefik..."
    ssh "$TRAEFIK_USER@$TRAEFIK_HOST" "systemctl restart traefik"
    sleep 2

    # Check if Traefik is running
    if ssh "$TRAEFIK_USER@$TRAEFIK_HOST" "systemctl is-active --quiet traefik"; then
        print_success "Traefik restarted successfully"
        return 0
    else
        print_error "Traefik failed to start!"
        print_error "Check logs: ssh $TRAEFIK_USER@$TRAEFIK_HOST 'journalctl -u traefik -n 50'"
        return 1
    fi
}

# Function to verify service is protected
verify_protection() {
    local service="$1"
    local domain="${service}.thehighestcommittee.com"

    print_info "Verifying protection for $service..."

    # Test if service redirects to Authelia
    local response=$(curl -s -I "https://$domain" | head -1)

    if echo "$response" | grep -q "302"; then
        local location=$(curl -s -I "https://$domain" | grep -i "location:" | grep -i "authelia")
        if [ -n "$location" ]; then
            print_success "$service is now protected (redirects to Authelia)"
            return 0
        fi
    fi

    # Service might still be accessible (check took too long or different response)
    print_warning "Unable to verify protection for $service"
    print_info "Manually test: https://$domain"
    return 1
}

# Main execution
main() {
    echo "═══════════════════════════════════════════════════════════════"
    echo "         Authelia Service Protection Script"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""

    # Check SSH connection
    print_info "Testing SSH connection to Traefik server..."
    if ! ssh -o ConnectTimeout=5 "$TRAEFIK_USER@$TRAEFIK_HOST" "echo 'Connected'" >/dev/null 2>&1; then
        print_error "Cannot connect to $TRAEFIK_HOST"
        print_error "Ensure SSH key authentication is configured"
        exit 1
    fi
    print_success "Connected to $TRAEFIK_HOST"
    echo ""

    if [ "$SERVICE_NAME" == "all" ]; then
        # Protect all eligible services
        print_info "Finding all services in Traefik configs..."

        # Get list of all routers from Traefik configs
        mapfile -t services < <(ssh "$TRAEFIK_USER@$TRAEFIK_HOST" \
            "grep -h '^  [a-z-]*:$' $TRAEFIK_CONF_DIR/*.yml | sed 's/://g' | sed 's/^  //g' | sort -u")

        echo "Found ${#services[@]} services"
        echo ""

        protected_count=0
        skipped_count=0
        failed_count=0

        for service in "${services[@]}"; do
            # Find config file for this service
            config_file=$(find_config_file "$service")

            if [ -z "$config_file" ]; then
                print_warning "Could not find config file for $service"
                ((skipped_count++))
                continue
            fi

            if protect_service "$service" "$config_file"; then
                ((protected_count++))
            else
                if is_excluded "$service"; then
                    ((skipped_count++))
                else
                    ((failed_count++))
                fi
            fi
        done

        echo ""
        echo "═══════════════════════════════════════════════════════════════"
        echo "  Summary"
        echo "═══════════════════════════════════════════════════════════════"
        print_success "Protected: $protected_count services"
        print_warning "Skipped: $skipped_count services"
        if [ $failed_count -gt 0 ]; then
            print_error "Failed: $failed_count services"
        fi

    else
        # Protect single service
        if [ -z "$CONFIG_FILE" ]; then
            print_info "Auto-detecting config file for $SERVICE_NAME..."
            CONFIG_FILE=$(find_config_file "$SERVICE_NAME")

            if [ -z "$CONFIG_FILE" ]; then
                print_error "Could not find service '$SERVICE_NAME' in Traefik configs"
                print_info "Available config files:"
                ssh "$TRAEFIK_USER@$TRAEFIK_HOST" "ls -1 $TRAEFIK_CONF_DIR/*.yml"
                exit 1
            fi

            print_success "Found in: $CONFIG_FILE"
        fi

        if protect_service "$SERVICE_NAME" "$CONFIG_FILE"; then
            echo ""

            # Ask to restart Traefik
            read -p "Restart Traefik to apply changes? (Y/n): " -n 1 -r
            echo ""

            if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                if restart_traefik; then
                    echo ""
                    verify_protection "$SERVICE_NAME"
                fi
            else
                print_warning "Changes will not take effect until Traefik is restarted"
                print_info "Restart manually: ssh $TRAEFIK_USER@$TRAEFIK_HOST 'systemctl restart traefik'"
            fi
        else
            exit 1
        fi
    fi

    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    print_success "Done!"
    echo "═══════════════════════════════════════════════════════════════"
}

# Run main function
main
