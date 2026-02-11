#!/bin/bash

# ============================================================================
# Documentation Synchronization Script
# ============================================================================
# Syncs all documentation files across all Docker hosts
# Usage: bash /opt/stacks/scripts/sync-documentation.sh
# ============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SOURCE_DIR="/opt/stacks"
DOCS_PATTERN="*.md"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="/tmp/doc-sync-${TIMESTAMP}.log"

# Host configuration
declare -A HOSTS=(
    ["thoth"]="tammer@192.168.0.7"
    ["tammediabox"]="tammer@192.168.0.13"
    ["traefik"]="root@192.168.0.2"
)

# ============================================================================
# Functions
# ============================================================================

print_header() {
    echo -e "${BLUE}============================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Count markdown files
count_docs() {
    find "$SOURCE_DIR" -maxdepth 1 -name "$DOCS_PATTERN" -type f | wc -l
}

# Sync to a specific host
sync_to_host() {
    local host_name=$1
    local host_addr=$2
    local chown_user=$3

    print_info "Syncing to $host_name ($host_addr)..."

    if rsync -avz --chown="$chown_user" "$SOURCE_DIR"/*.md "$host_addr:/opt/stacks/" >> "$LOG_FILE" 2>&1; then
        local file_count=$(ssh "$host_addr" "ls -1 /opt/stacks/*.md 2>/dev/null | wc -l" 2>/dev/null || echo "?")
        print_success "$host_name: $file_count files synced"
        return 0
    else
        print_error "$host_name: Sync failed"
        return 1
    fi
}

# ============================================================================
# Main Script
# ============================================================================

print_header "Documentation Sync - $(date)"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    print_error "Source directory $SOURCE_DIR does not exist"
    exit 1
fi

# Count local files
DOC_COUNT=$(count_docs)
print_info "Found $DOC_COUNT markdown files in $SOURCE_DIR"

if [ "$DOC_COUNT" -eq 0 ]; then
    print_error "No markdown files found to sync"
    exit 1
fi

# Start sync
echo ""
print_header "Syncing to Remote Hosts"
echo ""

SYNC_SUCCESS=0
SYNC_FAILED=0

# Sync to Thoth (tammer user)
if sync_to_host "Thoth" "${HOSTS[thoth]}" "1000:1000"; then
    ((SYNC_SUCCESS++))
else
    ((SYNC_FAILED++))
fi

# Sync to TamMediaBox (tammer user)
if sync_to_host "TamMediaBox" "${HOSTS[tammediabox]}" "1000:1000"; then
    ((SYNC_SUCCESS++))
else
    ((SYNC_FAILED++))
fi

# Sync to Traefik (root user)
if sync_to_host "Traefik" "${HOSTS[traefik]}" "root:root"; then
    ((SYNC_SUCCESS++))
else
    ((SYNC_FAILED++))
fi

# Summary
echo ""
print_header "Sync Summary"
echo ""
print_info "Documentation files: $DOC_COUNT"
print_success "Successful syncs: $SYNC_SUCCESS"
[ "$SYNC_FAILED" -gt 0 ] && print_error "Failed syncs: $SYNC_FAILED"
echo ""
print_info "Log file: $LOG_FILE"

# Exit with appropriate code
if [ "$SYNC_FAILED" -gt 0 ]; then
    echo ""
    print_error "Some syncs failed. Check log file for details."
    exit 1
else
    echo ""
    print_success "All documentation synced successfully!"
    exit 0
fi
