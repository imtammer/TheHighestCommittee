#!/bin/bash
# Multi-Host Automation - Deployment Checklist
# Run this to verify automation setup

echo "════════════════════════════════════════════════════════════════"
echo "Multi-Host Automation Setup Checklist"
echo "════════════════════════════════════════════════════════════════"
echo ""

FAILED=0

echo "1. Checking script files..."
for script in orchestrate.sh tammediabox.sh ai_docker_host.sh setup-cron.sh quick-ref.sh; do
    if [[ -x "/opt/stacks/scripts/$script" ]]; then
        echo "   ✅ /opt/stacks/scripts/$script (executable)"
    else
        echo "   ❌ /opt/stacks/scripts/$script (MISSING or NOT EXECUTABLE)"
        FAILED=$((FAILED+1))
    fi
done
echo ""

echo "2. Checking documentation files..."
for doc in AUTOMATION.md COMMANDS.md IMPLEMENTATION.md .stacks-aliases; do
    if [[ -f "/opt/stacks/$doc" ]]; then
        echo "   ✅ /opt/stacks/$doc"
    else
        echo "   ❌ /opt/stacks/$doc (MISSING)"
        FAILED=$((FAILED+1))
    fi
done
echo ""

echo "3. Checking SSH key..."
if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
    echo "   ✅ SSH key exists: $HOME/.ssh/id_ed25519"
else
    echo "   ⚠️  SSH key not found at $HOME/.ssh/id_ed25519"
fi
echo ""

echo "4. Testing SSH connectivity..."
echo "   Testing TamMediaBox (192.168.0.13)..."
if ssh -i "$HOME/.ssh/id_ed25519" -o ConnectTimeout=5 -o StrictHostKeyChecking=no \
    tammer@192.168.0.13 "echo Connected" &>/dev/null; then
    echo "      ✅ SSH connection successful"
else
    echo "      ❌ SSH connection failed"
    FAILED=$((FAILED+1))
fi

echo "   Testing AI_Docker_Host (192.168.0.7)..."
if ssh -i "$HOME/.ssh/id_ed25519" -o ConnectTimeout=5 -o StrictHostKeyChecking=no \
    tammer@192.168.0.7 "echo Connected" &>/dev/null; then
    echo "      ✅ SSH connection successful (passwordless)"
else
    echo "      ⚠️  SSH may prompt for password"
fi
echo ""

echo "5. Checking backup directories..."
for dir in /opt/stacks/TamMediaBox/backups /opt/stacks/AI_Docker_Host/backups; do
    if [[ -d "$dir" ]]; then
        echo "   ✅ $dir exists"
    else
        echo "   ℹ️  Creating: $dir"
        mkdir -p "$dir"
    fi
done
echo ""

echo "6. Checking cron installation status..."
if crontab -l 2>/dev/null | grep -q "orchestrate.sh"; then
    echo "   ✅ Cron jobs already installed"
    echo "      Jobs:"
    crontab -l 2>/dev/null | grep orchestrate.sh | sed 's/^/         /'
else
    echo "   ⚠️  Cron jobs not installed yet"
    echo "      Run: /opt/stacks/scripts/setup-cron.sh"
fi
echo ""

echo "7. Running quick connectivity test..."
echo "   Testing orchestrate.sh..."
if /opt/stacks/scripts/orchestrate.sh check-all &>/dev/null; then
    echo "      ✅ orchestrate.sh works"
else
    echo "      ❌ orchestrate.sh failed"
    FAILED=$((FAILED+1))
fi
echo ""

echo "════════════════════════════════════════════════════════════════"
if [[ $FAILED -eq 0 ]]; then
    echo "✅ All checks passed! Automation is ready."
    echo ""
    echo "Next steps:"
    echo "  1. If AI_Docker_Host prompted for password, run:"
    echo "     ssh-copy-id -i ~/.ssh/id_ed25519 tammer@192.168.0.7"
    echo ""
    echo "  2. If cron jobs not installed, run:"
    echo "     /opt/stacks/scripts/setup-cron.sh"
    echo ""
    echo "  3. Verify everything is working:"
    echo "     orchestrate.sh health-all"
else
    echo "❌ $FAILED check(s) failed. Review errors above."
fi
echo "════════════════════════════════════════════════════════════════"
