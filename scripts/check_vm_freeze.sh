#!/bin/bash
# Proxmox VM Freeze Diagnostic Script
# Usage: sudo ./check_vm_freeze.sh [since] [until]
# Example: sudo ./check_vm_freeze.sh "2026-02-03 00:00:00" "2026-02-03 23:59:59"

VMID=105
SINCE="${1:-2026-02-03 00:00:00}"
UNTIL="${2:-2026-02-03 23:59:59}"

LOGDIR="freeze_diagnostics_$VMID"
mkdir -p "$LOGDIR"

# 1. Proxmox task log for the VM
cat /var/log/pve/tasks/index | grep "$VMID" > "$LOGDIR/pve_tasks_$VMID.log"

# 2. System journal for the time window (kernel, qemu, kvm, oom, disk errors)
journalctl -xe --since "$SINCE" --until "$UNTIL" | grep -Ei "kvm|qemu|oom|error|fail|disk|zfs|nvme|reset|panic" > "$LOGDIR/journal_$VMID.log"

# 3. Syslog for the time window (if available)
grep -Ei "kvm|qemu|oom|error|fail|disk|zfs|nvme|reset|panic" /var/log/syslog > "$LOGDIR/syslog_$VMID.log" 2>/dev/null || true

# 4. ZFS health (if using ZFS)
zpool status > "$LOGDIR/zpool_status.log" 2>/dev/null || echo "No ZFS pool found" > "$LOGDIR/zpool_status.log"

# 5. Hardware errors from dmesg
dmesg -T | grep -Ei "error|fail|nvme|reset|panic" > "$LOGDIR/dmesg_$VMID.log"

echo "Diagnostics complete. See the $LOGDIR directory for results."
