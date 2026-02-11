# Authelia Service Protection Guide

Quick reference for protecting services with Authelia authentication.

---

## 🚀 Quick Start

### Protect Single Service

```bash
cd /opt/stacks/security/authelia
./protect-service.sh overseerr
```

### Phased Rollout (Recommended)

```bash
# Phase 1: Test services
./rollout-plan.sh phase1

# Phase 2: Admin services
./rollout-plan.sh phase2

# Phase 3: Media management
./rollout-plan.sh phase3
```

### Check Protection Status

```bash
./rollout-plan.sh status
```

---

## 📋 Protection Scripts

### `protect-service.sh`

Protects individual services with Authelia authentication.

**Usage:**
```bash
./protect-service.sh <service-name> [config-file]
```

**Examples:**
```bash
# Auto-detect config file
./protect-service.sh overseerr

# Specify config file
./protect-service.sh sonarr primary-host.yml

# Protect all eligible services
./protect-service.sh all
```

**What it does:**
1. Connects to Traefik server (192.168.0.2) via SSH
2. Finds the service in Traefik configuration
3. Backs up the config file
4. Adds `middlewares: - authelia@file` to the service router
5. Restarts Traefik
6. Verifies protection is working

**Excluded Services:**
- `authelia` - Would create auth loop
- `auth` - Pocket-ID (separate auth provider)
- `plex` - Uses custom headers
- `jellyfin` - Bypass policy

### `rollout-plan.sh`

Implements phased rollout of Authelia protection.

**Usage:**
```bash
./rollout-plan.sh [command]
```

**Commands:**

| Command | Description | Services |
|---------|-------------|----------|
| `phase1` | Test services | overseerr, jellyseerr |
| `phase2` | Admin services | traefik, dozzle, dockhand, npmplus |
| `phase3` | Media management | sonarr, radarr, lidarr, readarr, prowlarr, qbittorrent, sabnzbd |
| `phase4` | Additional services | audiobookshelf, kapowarr, tunarr, wizarr, etc. |
| `phase5` | Utility services | homepage, homarr, dashy, glances, uptime-kuma |
| `custom` | Interactive custom list | (prompts for services) |
| `status` | Show protection status | (all services) |
| `all` | Protect everything | (all eligible services) |

**Examples:**
```bash
# Start with phase 1 (safe test services)
./rollout-plan.sh phase1

# Check current status
./rollout-plan.sh status

# Protect custom services
./rollout-plan.sh custom
# Then enter: homepage homarr dashy
```

---

## 🎯 Recommended Rollout

### Week 1: Testing Phase

```bash
# Protect low-risk services first
./rollout-plan.sh phase1

# Test services:
# - https://overseerr.thehighestcommittee.com
# - https://jellyseerr.thehighestcommittee.com

# Verify:
# 1. Redirects to Authelia login
# 2. Login works with admin credentials
# 3. 2FA works
# 4. Redirects back to service after login
# 5. Service functions normally
```

**If everything works:**
- Users can login
- 2FA works properly
- Services load correctly after authentication
- No error messages

**Proceed to Phase 2**

### Week 2: Admin Services

```bash
# Protect infrastructure services
./rollout-plan.sh phase2

# Test admin-only access works:
# - https://traefik.thehighestcommittee.com
# - https://dozzle.thehighestcommittee.com

# Verify:
# 1. Admin user can access
# 2. Non-admin users cannot access (if you create test user)
```

### Week 3: Media Management

```bash
# Protect *arr services and downloaders
./rollout-plan.sh phase3

# Test:
# - All *arr services accessible
# - Download clients work
# - API keys still work for automation
```

### Week 4: Full Deployment

```bash
# Protect remaining services
./rollout-plan.sh phase4
./rollout-plan.sh phase5

# Final verification
./rollout-plan.sh status
```

---

## 🔧 Manual Protection

If you need to manually add protection to a service:

### 1. SSH to Traefik Server

```bash
ssh root@192.168.0.2
```

### 2. Edit Config File

```bash
# Find which config file contains the service
grep -l "servicename:" /etc/traefik/conf.d/*.yml

# Edit the file
nano /etc/traefik/conf.d/primary-host.yml
```

### 3. Add Middleware

Find the service router and add the middleware:

**Before:**
```yaml
http:
  routers:
    servicename:
      rule: "Host(`servicename.thehighestcommittee.com`)"
      service: servicename
      entryPoints: [websecure]
      tls: {}
```

**After:**
```yaml
http:
  routers:
    servicename:
      rule: "Host(`servicename.thehighestcommittee.com`)"
      service: servicename
      entryPoints: [websecure]
      middlewares:
        - authelia@file
      tls: {}
```

### 4. Restart Traefik

```bash
systemctl restart traefik
systemctl status traefik
```

### 5. Test

```bash
curl -I https://servicename.thehighestcommittee.com
# Should return HTTP 302 with Location: authelia.thehighestcommittee.com
```

---

## 🔍 Verification

### Check if Service is Protected

```bash
# From osiris
curl -I https://servicename.thehighestcommittee.com

# Expected: HTTP 302 redirect to Authelia
# Location: https://authelia.thehighestcommittee.com/?rd=...
```

### Check Traefik Configuration

```bash
ssh root@192.168.0.2 "grep -A 10 'servicename:' /etc/traefik/conf.d/*.yml"

# Should show:
#   middlewares:
#     - authelia@file
```

### Check Authelia Logs

```bash
docker compose -f /opt/stacks/security/authelia/docker-compose.yml logs -f authelia

# Look for authentication attempts
```

---

## 🐛 Troubleshooting

### Service Returns 401 After Login

**Symptom:** Login works but service shows 401 Unauthorized

**Causes:**
1. Service expecting specific headers
2. Session cookie not being set correctly
3. Service has its own authentication

**Solutions:**
```bash
# Check Authelia logs
docker compose -f /opt/stacks/security/authelia/docker-compose.yml logs authelia | grep -i error

# Verify session is created
docker exec -it authelia-redis redis-cli
> KEYS *
> GET session:sessionid

# Check service logs
docker logs servicename
```

### Infinite Redirect Loop

**Symptom:** Browser keeps redirecting between service and Authelia

**Cause:** Authelia middleware applied to `authelia.thehighestcommittee.com`

**Solution:**
```bash
ssh root@192.168.0.2
grep -A 5 "authelia:" /etc/traefik/conf.d/authelia-router.yml

# Should NOT have:
#   middlewares:
#     - authelia@file
```

### Service Not Redirecting

**Symptom:** Service loads without authentication

**Causes:**
1. Middleware not applied
2. Traefik not restarted
3. Wrong config file edited

**Solutions:**
```bash
# Verify middleware in config
ssh root@192.168.0.2 "grep -B 5 -A 10 'servicename:' /etc/traefik/conf.d/*.yml"

# Restart Traefik
ssh root@192.168.0.2 "systemctl restart traefik"

# Check Traefik logs
ssh root@192.168.0.2 "journalctl -u traefik -n 50"
```

### Script Can't Connect to Traefik

**Symptom:** SSH connection fails

**Solution:**
```bash
# Test SSH connection
ssh root@192.168.0.2 "echo 'Connected'"

# Verify SSH key
ls -la ~/.ssh/id_*

# If no key, setup SSH keys
/opt/stacks/scripts/setup-ssh-automation.sh
```

---

## 📊 Service Protection Status

Check which services are currently protected:

```bash
./rollout-plan.sh status
```

**Output:**
```
phase1:
✓ overseerr - PROTECTED
✓ jellyseerr - PROTECTED

phase2:
○ traefik - not protected
○ dozzle - not protected
...
```

**Legend:**
- ✓ = Protected with Authelia
- ○ = Not protected (but exists in config)
- - = Not found in Traefik config

---

## 🔄 Rollback Protection

If you need to remove Authelia protection from a service:

### Option 1: Restore from Backup

```bash
ssh root@192.168.0.2

# List backups
ls -lt /etc/traefik/conf.d/*.backup.*

# Restore backup
cp /etc/traefik/conf.d/primary-host.yml.backup.20260204_001234 \
   /etc/traefik/conf.d/primary-host.yml

# Restart Traefik
systemctl restart traefik
```

### Option 2: Manual Edit

```bash
ssh root@192.168.0.2
nano /etc/traefik/conf.d/primary-host.yml

# Remove these lines:
#   middlewares:
#     - authelia@file

# Restart Traefik
systemctl restart traefik
```

---

## 📚 Additional Resources

- **Authelia Docs**: /opt/stacks/security/authelia/README.md
- **Deployment Guide**: /opt/stacks/security/authelia/AUTHELIA_SETUP_COMPLETE.md
- **Integration Plan**: /opt/stacks/AUTHELIA_INTEGRATION_PLAN.md
- **Traefik Docs**: https://doc.traefik.io/traefik/middlewares/http/forwardauth/

---

## 🆘 Support

**Common Commands:**

```bash
# View Authelia logs
docker compose -f /opt/stacks/security/authelia/docker-compose.yml logs -f authelia

# View Traefik logs
ssh root@192.168.0.2 "journalctl -u traefik -f"

# Check Authelia status
docker compose -f /opt/stacks/security/authelia/docker-compose.yml ps

# Test service protection
curl -I https://servicename.thehighestcommittee.com

# List all protected services
./rollout-plan.sh status
```

---

**Last Updated:** 2026-02-04
**Status:** Production Ready ✓
