# Cross-Reference Automation - Quick Start

## 🚀 Quick Commands

```bash
# Quick validation (Python - no dependencies)
./scripts/npm_traefik_sync.py --no-traefik

# Full validation with Traefik
./scripts/npm_traefik_sync.py

# Detailed report (Bash)
./scripts/cross_reference_automation.sh

# With NPM API query
./scripts/cross_reference_automation.sh --npm-api
```

## 📊 What It Does

Validates that:
- ✅ NPM Plus proxy hosts match services in HOSTED_APPS.md
- ✅ Traefik routes match services in HOSTED_APPS.md
- ✅ DNS names point to correct IPs and ports
- ✅ No orphaned or misconfigured proxy entries

## 🔧 One-Time Setup

```bash
# 1. Setup SSH keys for Traefik access
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
ssh-copy-id -i ~/.ssh/id_ed25519 root@192.168.0.2

# 2. Create reports directory
mkdir -p /opt/stacks/reports

# 3. Test scripts
./scripts/npm_traefik_sync.py --no-traefik
```

## 📝 Example Output

```
[INFO] Parsing HOSTED_APPS.md...
[OK] Found 59 services
[INFO] Parsing NPM proxy hosts...
[OK] Found 49 NPM proxy hosts

=== NPM Proxy Host Validation ===

✓ sonarr.thehighestcommittee.com -> 192.168.0.11:8989 (Sonarr)
✓ radarr.thehighestcommittee.com -> 192.168.0.11:7878 (Radarr)
✓ jellyfin.thehighestcommittee.com -> 192.168.0.13:8096 (Jellyfin)
...
✗ bazarr.thehighestcommittee.com -> 192.168.0.11:6767
  No matching service found in HOSTED_APPS.md!

[INFO] NPM Validation: 42 matches, 7 issues

==================================================
SUMMARY
==================================================
NPM Validation: 42 OK, 7 issues
Traefik Validation: 0 OK, 0 issues
```

## 🔍 Understanding Results

### ✓ Green Checkmark
Service is correctly configured in both NPM/Traefik and HOSTED_APPS.md

### ✗ Red X
Service not found in HOSTED_APPS.md - needs to be added or removed from proxy

### ⚠ Yellow Warning
Service found but domain mismatch - review and fix

## 📂 Files

| File | Purpose |
|------|---------|
| `npm_traefik_sync.py` | Simple Python validator (recommended) |
| `cross_reference_automation.sh` | Full Bash validator with reports |
| `CROSS_REFERENCE_GUIDE.md` | Complete documentation |

## 🤖 Automation

Add to crontab for daily checks:
```bash
# Run daily at 3 AM
0 3 * * * /opt/stacks/scripts/npm_traefik_sync.py >> /opt/stacks/reports/daily.log 2>&1
```

## 🆘 Troubleshooting

### Can't connect to Traefik
```bash
# Check SSH connection
ssh root@192.168.0.2 "echo test"

# Copy SSH key again
ssh-copy-id -i ~/.ssh/id_ed25519 root@192.168.0.2
```

### Services not found
Some infrastructure services (Proxmox, NPM Plus itself, etc.) use different table formats and won't be parsed. This is normal.

## 📚 Full Documentation

See `CROSS_REFERENCE_GUIDE.md` for:
- Detailed usage instructions
- API integration
- Auto-fix features (coming soon)
- CI/CD integration
- Webhook notifications

---

**Last Updated**: 2026-02-03
