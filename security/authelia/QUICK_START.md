# Authelia Protection - Quick Start

**Automated service protection via SSH is now configured!**

---

## ✅ What's Ready

1. **Authelia Service**: Running and accessible at https://authelia.thehighestcommittee.com
2. **Protection Scripts**: Automated SSH-based service protection
3. **Rollout Plans**: Phased deployment strategy
4. **Status Monitoring**: Real-time protection status checking

---

## 🚀 Quick Commands

### Check Protection Status

```bash
cd /opt/stacks/security/authelia
./rollout-plan.sh status
```

### Protect Test Services (Recommended First Step)

```bash
./rollout-plan.sh phase1
```

This protects:
- overseerr.thehighestcommittee.com
- jellyseerr.thehighestcommittee.com

### Protect Single Service

```bash
./protect-service.sh overseerr
```

### Protect Admin Services

```bash
./rollout-plan.sh phase2
```

### Protect All Media Management

```bash
./rollout-plan.sh phase3
```

---

## 📊 Current Status

Run `./rollout-plan.sh status` to see:

**Currently Protected:**
- ✓ sonarr

**Ready to Protect:**
- overseerr, jellyseerr (Phase 1 - Test services)
- dozzle, dockhand, npmplus (Phase 2 - Admin)
- radarr, lidarr, readarr, prowlarr, qbittorrent, sabnzbd (Phase 3 - Media)
- And many more...

---

## 🎯 Recommended Next Steps

### 1. Test Authelia Login (5 minutes)

```bash
# Open Authelia portal
xdg-open https://authelia.thehighestcommittee.com

# Login:
# Username: admin
# Password: !St00pid!

# Setup 2FA with your authenticator app
```

### 2. Protect Test Services (5 minutes)

```bash
cd /opt/stacks/security/authelia
./rollout-plan.sh phase1
```

**Then test:**
- Visit https://overseerr.thehighestcommittee.com
- Should redirect to Authelia
- Login with admin credentials + 2FA
- Should redirect back to Overseerr

### 3. Gradual Rollout (Over 2-4 Weeks)

```bash
# Week 1: Test services
./rollout-plan.sh phase1

# Week 2: Admin services
./rollout-plan.sh phase2

# Week 3: Media management
./rollout-plan.sh phase3

# Week 4: Everything else
./rollout-plan.sh phase4
./rollout-plan.sh phase5
```

---

## 🔧 How It Works

### Protection Scripts

**`protect-service.sh`**
1. Connects to Traefik server (192.168.0.2) via SSH
2. Finds service in Traefik config
3. Backs up config file
4. Adds `middlewares: - authelia@file` to router
5. Restarts Traefik
6. Verifies protection

**`rollout-plan.sh`**
- Manages phased rollout
- Protects groups of services
- Shows protection status
- Handles Traefik restarts

### Authentication Flow

```
User → Service (e.g., overseerr.thehighestcommittee.com)
  ↓
Traefik sees authelia middleware
  ↓
Checks with Authelia (192.168.0.11:9091)
  ↓
If not authenticated:
  Redirect to Authelia login
  ↓
  User logs in (username + password + 2FA)
  ↓
  Session stored in Redis
  ↓
  Redirect back to service
  ↓
If authenticated:
  Allow access to service
```

---

## 📁 Files Created

**Scripts:**
- `/opt/stacks/security/authelia/protect-service.sh` - Single service protection
- `/opt/stacks/security/authelia/rollout-plan.sh` - Phased rollout management
- `/opt/stacks/security/authelia/generate-secrets.sh` - Secret generation
- `/opt/stacks/security/authelia/deploy.sh` - Initial deployment

**Configuration:**
- `/opt/stacks/security/authelia/docker-compose.yml` - Authelia stack
- `/opt/stacks/appdata/authelia/config/configuration.yml` - Authelia config
- `/opt/stacks/appdata/authelia/config/users_database.yml` - Users
- `/opt/stacks/appdata/authelia/secrets/*` - Secret files

**Traefik (on 192.168.0.2):**
- `/etc/traefik/conf.d/authelia-router.yml` - Routes to Authelia
- `/etc/traefik/conf.d/authelia-middleware.yml` - ForwardAuth middleware

**Documentation:**
- `/opt/stacks/security/authelia/README.md` - Complete documentation
- `/opt/stacks/security/authelia/AUTHELIA_SETUP_COMPLETE.md` - Deployment guide
- `/opt/stacks/security/authelia/PROTECTION_GUIDE.md` - Protection reference
- `/opt/stacks/security/authelia/QUICK_START.md` - This file

---

## 🔐 Security Notes

### Default Credentials

**⚠️ CHANGE IMMEDIATELY AFTER FIRST LOGIN:**
- Username: admin
- Password: !St00pid!

### 2FA Required

All users must setup 2FA (TOTP) on first login:
1. Login with username/password
2. Scan QR code with authenticator app
3. Enter 6-digit code

### Secrets Location

All secrets are stored securely:
- `/opt/stacks/appdata/authelia/secrets/` (600 permissions)
- Never commit to git
- Backup encrypted

---

## 📊 Monitoring

### View Authelia Logs

```bash
docker compose -f /opt/stacks/security/authelia/docker-compose.yml logs -f authelia
```

### View Traefik Logs

```bash
ssh root@192.168.0.2 "journalctl -u traefik -f"
```

### Check Service Status

```bash
docker compose -f /opt/stacks/security/authelia/docker-compose.yml ps
```

### Test Service Protection

```bash
curl -I https://servicename.thehighestcommittee.com
# Expected: HTTP 302 with Location: authelia.thehighestcommittee.com
```

---

## 🆘 Troubleshooting

### Service Not Protecting

```bash
# Check if middleware was added
ssh root@192.168.0.2 "grep -A 10 'servicename:' /etc/traefik/conf.d/*.yml"

# Restart Traefik
ssh root@192.168.0.2 "systemctl restart traefik"

# Check logs
ssh root@192.168.0.2 "journalctl -u traefik -n 50"
```

### Script Can't Connect

```bash
# Test SSH
ssh root@192.168.0.2 "echo 'Connected'"

# If fails, setup SSH keys
/opt/stacks/scripts/setup-ssh-automation.sh
```

### Infinite Redirect Loop

```bash
# Check authelia router doesn't have authelia middleware
ssh root@192.168.0.2 "grep -A 10 'authelia:' /etc/traefik/conf.d/authelia-router.yml"

# Should NOT show:
#   middlewares:
#     - authelia@file
```

---

## 📚 Full Documentation

- **Complete Guide**: `cat /opt/stacks/security/authelia/README.md`
- **Protection Guide**: `cat /opt/stacks/security/authelia/PROTECTION_GUIDE.md`
- **Deployment Details**: `cat /opt/stacks/security/authelia/AUTHELIA_SETUP_COMPLETE.md`

---

## 🎯 Example Session

```bash
# 1. Check current status
cd /opt/stacks/security/authelia
./rollout-plan.sh status

# 2. Protect test services
./rollout-plan.sh phase1
# Follow prompts, confirm protection, Traefik restarts automatically

# 3. Test in browser
xdg-open https://overseerr.thehighestcommittee.com
# Should redirect to Authelia login
# Login → 2FA → Redirect back to Overseerr

# 4. If successful, proceed with phase 2
./rollout-plan.sh phase2

# 5. Continue with remaining phases over time
./rollout-plan.sh phase3
./rollout-plan.sh phase4
```

---

**Ready to start?**

```bash
cd /opt/stacks/security/authelia
./rollout-plan.sh phase1
```

---

**Status:** ✅ Production Ready
**Last Updated:** 2026-02-04
**Next Step:** Protect Phase 1 test services
