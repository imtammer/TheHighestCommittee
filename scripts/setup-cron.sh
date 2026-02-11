#!/bin/bash
###############################################################################
# Cron Job Setup for Remote Host Automation
# Run this script to set up automated sync and health checks
###############################################################################

set -euo pipefail

SCRIPT_DIR="/opt/stacks/scripts"
ORCHESTRATE_SCRIPT="${SCRIPT_DIR}/orchestrate.sh"
CRON_LOG_DIR="/var/log/stacks"

echo "Setting up cron jobs for multi-host automation..."

# Create log directory
sudo mkdir -p "${CRON_LOG_DIR}"
sudo chmod 755 "${CRON_LOG_DIR}"

# Verify scripts exist
if [[ ! -x "${ORCHESTRATE_SCRIPT}" ]]; then
    echo "Error: orchestrate.sh not found or not executable"
    exit 1
fi

# Install cron jobs
echo ""
echo "Installing cron jobs..."

# Daily health check at 6 AM
(crontab -l 2>/dev/null | grep -v "orchestrate.sh health-all" || true; \
echo "0 6 * * * ${ORCHESTRATE_SCRIPT} health-all >> ${CRON_LOG_DIR}/health-check.log 2>&1") | crontab -

# Weekly config sync at 2 AM on Sundays
(crontab -l 2>/dev/null | grep -v "orchestrate.sh sync-all" || true; \
echo "0 2 * * 0 ${ORCHESTRATE_SCRIPT} sync-all >> ${CRON_LOG_DIR}/sync.log 2>&1") | crontab -

# Every 6 hours: Check service status
(crontab -l 2>/dev/null | grep -v "orchestrate.sh check-all" || true; \
echo "0 */6 * * * ${ORCHESTRATE_SCRIPT} check-all >> ${CRON_LOG_DIR}/check.log 2>&1") | crontab -

echo ""
echo "✓ Cron jobs installed:"
crontab -l | grep "orchestrate.sh" || echo "  (No cron jobs found)"

echo ""
echo "Cron job schedule:"
echo "  • Daily health check: 6:00 AM"
echo "  • Weekly config sync: 2:00 AM Sunday"
echo "  • Status check: Every 6 hours"
echo ""
echo "Log files:"
echo "  • Health checks: ${CRON_LOG_DIR}/health-check.log"
echo "  • Config sync: ${CRON_LOG_DIR}/sync.log"
echo "  • Status checks: ${CRON_LOG_DIR}/check.log"
echo ""
echo "Setup complete!"
