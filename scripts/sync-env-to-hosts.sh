#!/bin/bash
# Sync environment and documentation to all accessible homelab hosts
# Location: /opt/stacks/scripts/sync-env-to-hosts.sh

set -e

echo "═══════════════════════════════════════════════════"
echo "  Environment & Documentation Sync Script"
echo "═══════════════════════════════════════════════════"
echo ""

# Define hosts
HOSTS=(
    "root@192.168.0.2"      # Traefik
    "tammer@192.168.0.13"   # TamMediaBox
    "tammer@192.168.0.7"    # AI Docker Host
)

# Define files to sync
FILES=(
    "/opt/stacks/.env"
    "/opt/stacks/.gitignore"
    "/opt/stacks/scripts"
    "/opt/stacks/README.md"
    "/opt/stacks/OPERATIONS.md"
    "/opt/stacks/INFRASTRUCTURE.md"
    "/opt/stacks/CLAUDE.md"
    "/opt/stacks/CHANGELOG.md"
    "/opt/stacks/QUICK_REFERENCE.md"
    "/opt/stacks/CREDENTIALS_AND_API_KEYS.md"
    "/opt/stacks/HOSTED_APPS.md"
    "/opt/stacks/README_AI_ASSISTANT.md"
    "/opt/stacks/ENCRYPTION_REMOVAL_SUMMARY.md"
    "/opt/stacks/PERMISSIONS_UPDATE.md"
    "/opt/stacks/HOST_SYNC_STATUS.md"
    "/opt/stacks/AI_AGENT_CONTEXT.md"
)

# Track results
SUCCESS=0
FAILED=0

for host in "${HOSTS[@]}"; do
    echo "──────────────────────────────────────────────────"
    echo "Syncing to: $host"
    echo "──────────────────────────────────────────────────"

    # Test SSH connectivity
    if ! ssh -o ConnectTimeout=5 -o BatchMode=yes "$host" "echo 'SSH OK'" 2>/dev/null; then
        echo "❌ SSH access FAILED to $host"
        echo "   Run: ssh-copy-id $host"
        FAILED=$((FAILED + 1))
        echo ""
        continue
    fi

    # Ensure /opt/stacks exists
    ssh "$host" "mkdir -p /opt/stacks" 2>/dev/null || true

    # Sync files
    echo "📦 Syncing files..."
    if rsync -avz --chown=1000:1000 "${FILES[@]}" "$host:/opt/stacks/" 2>&1 | tail -3; then
        echo "✅ Files synced successfully"
    else
        echo "⚠️  Some files may have failed to sync"
    fi

    # Set permissions
    echo "🔐 Setting permissions..."
    if ssh "$host" "find /opt/stacks -type f \( -name '.env' -o -name '*.md' \) -exec chown 1000:1000 {} \; -exec chmod 640 {} \; && find /opt/stacks/scripts -type f -name '*.sh' -exec chmod +x {} \; 2>/dev/null && echo 'Permissions updated'" 2>&1 | grep -q "Permissions updated"; then
        echo "✅ Permissions set successfully"
    else
        echo "⚠️  Permission update may have issues"
    fi

    # Verify
    echo "🔍 Verifying..."
    ssh "$host" "ls -lh /opt/stacks/.env 2>/dev/null" || echo "⚠️  .env not found on $host"

    SUCCESS=$((SUCCESS + 1))
    echo "✓ $host complete"
    echo ""
done

echo "═══════════════════════════════════════════════════"
echo "  Sync Complete"
echo "═══════════════════════════════════════════════════"
echo "✅ Successful: $SUCCESS hosts"
echo "❌ Failed: $FAILED hosts"
echo ""

if [ $FAILED -gt 0 ]; then
    echo "⚠️  Some hosts failed. Setup SSH keys with:"
    echo "   ssh-copy-id tammer@192.168.0.13"
    echo "   ssh-copy-id tammer@192.168.0.7"
    exit 1
fi

echo "✓ All accessible hosts are now synchronized!"
