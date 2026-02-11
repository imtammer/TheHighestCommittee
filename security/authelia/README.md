# Authelia Authentication Gateway

Comprehensive authentication and SSO solution for TheHighestCommittee homelab.

---

## 📋 Overview

**What is Authelia?**
Authelia is an authentication and authorization server providing 2FA and SSO for your applications via a web portal.

**Architecture:**
- **Authelia Server**: Runs on 192.168.0.11:9091 (osiris)
- **Traefik Proxy**: Runs on 192.168.0.2
- **Session Storage**: Redis (co-located with Authelia)
- **User Database**: File-based (YAML) - can be migrated to LDAP later
- **Public URL**: https://authelia.thehighestcommittee.com

---

## 🚀 Quick Start Deployment

### Prerequisites
- Docker and Docker Compose installed
- SSH access to Traefik server (192.168.0.2)
- Root access on osiris (192.168.0.11)

### Deployment Steps

```bash
# 1. Navigate to Authelia directory
cd /opt/stacks/security/authelia

# 2. Make scripts executable
chmod +x generate-secrets.sh deploy.sh

# 3. Run deployment script
sudo ./deploy.sh
```

The deployment script will:
1. Create directory structure
2. Generate all required secrets
3. Set up admin user credentials
4. Copy Traefik configuration files to 192.168.0.2
5. Start Authelia and Redis containers
6. Verify deployment

---

## 📁 File Structure

```
/opt/stacks/security/authelia/
├── docker-compose.yml              # Service definitions
├── generate-secrets.sh             # Secret generation script
├── deploy.sh                       # Main deployment script
├── authelia-traefik-router.yml     # Traefik router config (copy to .02)
├── traefik-middleware.yml          # Traefik middleware config (copy to .02)
└── README.md                       # This file

/opt/stacks/appdata/authelia/
├── config/
│   ├── configuration.yml           # Main Authelia config
│   └── users_database.yml          # User credentials
├── secrets/                        # Sensitive keys (600 permissions)
│   ├── jwt_secret
│   ├── session_secret
│   ├── storage_encryption_key
│   ├── oidc_hmac_secret
│   └── oidc_private_key
├── data/
│   ├── db.sqlite3                  # Authelia database
│   └── notification.txt            # 2FA codes (file notifier)
└── redis/                          # Redis session data
```

---

## 🔧 Configuration Details

### Access Control Policies

Defined in `/opt/stacks/appdata/authelia/config/configuration.yml`:

**Bypass (No Auth Required):**
- authelia.thehighestcommittee.com
- auth.thehighestcommittee.com (Pocket-ID)
- plex.thehighestcommittee.com
- jellyfin.thehighestcommittee.com

**One Factor (Login + Password):**
- All media management (*arr services)
- Overseerr, Jellyseerr
- Other standard services

**Admin Only (Login + Password + Admin Group):**
- traefik.thehighestcommittee.com
- dozzle.thehighestcommittee.com
- dockhand.thehighestcommittee.com
- npmplus.thehighestcommittee.com
- qbittorrent.thehighestcommittee.com
- sabnzbd.thehighestcommittee.com

**Default Policy:** Deny (require one_factor for all other services)

### User Groups

**admins:**
- Full access to all services including admin-only services
- Can manage download clients
- Can access infrastructure tools

**users:**
- Access to media management and standard services
- Cannot access admin-only services

---

## 👤 User Management

### Add New User

1. Generate password hash:
```bash
docker run --rm authelia/authelia:latest authelia crypto hash generate argon2 --password 'UserPassword'
```

2. Edit users database:
```bash
nano /opt/stacks/appdata/authelia/config/users_database.yml
```

3. Add user entry:
```yaml
users:
  newusername:
    displayname: "User Full Name"
    password: "$argon2id$v=19$m=65536,t=3,p=4$HASH_FROM_STEP_1"
    email: user@example.com
    groups:
      - users
```

4. Restart Authelia:
```bash
docker compose -f /opt/stacks/security/authelia/docker-compose.yml restart authelia
```

### Change User Password

Same process as adding a user, but replace the existing password hash.

### Delete User

Remove the user entry from `users_database.yml` and restart Authelia.

---

## 🔒 Protecting Services with Authelia

### Step 1: Edit Traefik Router Config

SSH to Traefik server:
```bash
ssh root@192.168.0.2
```

Edit the service's router configuration (e.g., `/etc/traefik/conf.d/primary-host.yml`):

```yaml
http:
  routers:
    sonarr:
      rule: "Host(`sonarr.thehighestcommittee.com`)"
      service: sonarr
      entryPoints: [websecure]
      middlewares:
        - authelia@file  # <-- Add this line
      tls: {}
```

### Step 2: Restart Traefik

```bash
systemctl restart traefik
```

### Step 3: Test

1. Open the service URL in a browser
2. You should be redirected to Authelia login
3. After login, you'll be redirected back to the service

### Services That Should NOT Have Authelia Middleware

- `authelia.thehighestcommittee.com` (would create auth loop)
- `auth.thehighestcommittee.com` (Pocket-ID - separate auth provider)
- Services with bypass policy in configuration.yml

---

## 📊 Rollout Strategy

### Phase 1: Testing (Week 1)
- ✓ Deploy Authelia
- ✓ Configure Traefik integration
- Test with low-risk services:
  - overseerr.thehighestcommittee.com
  - jellyseerr.thehighestcommittee.com

### Phase 2: Admin Services (Week 2)
- Protect admin infrastructure:
  - traefik.thehighestcommittee.com
  - dozzle.thehighestcommittee.com
  - dockhand.thehighestcommittee.com
- Verify admin group enforcement works

### Phase 3: Media Management (Week 3)
- Protect *arr services:
  - sonarr, radarr, lidarr, readarr, prowlarr
- Protect download clients:
  - qbittorrent, sabnzbd

### Phase 4: Full Deployment (Week 4)
- Protect all remaining services
- Remove bypass policies gradually
- Monitor for issues

---

## 🔍 Monitoring and Troubleshooting

### View Authelia Logs

```bash
docker compose -f /opt/stacks/security/authelia/docker-compose.yml logs -f authelia
```

### View Redis Logs

```bash
docker compose -f /opt/stacks/security/authelia/docker-compose.yml logs -f redis
```

### Check Service Status

```bash
docker compose -f /opt/stacks/security/authelia/docker-compose.yml ps
```

### Test Authelia Endpoint

```bash
# Test from local network
curl http://192.168.0.11:9091

# Test from Traefik server
ssh root@192.168.0.2 "curl http://192.168.0.11:9091"

# Test public URL
curl https://authelia.thehighestcommittee.com
```

### View 2FA Codes (File Notifier)

```bash
cat /opt/stacks/appdata/authelia/data/notification.txt
```

### Common Issues

**Issue: Infinite redirect loop**
- **Cause**: Authelia middleware applied to authelia.thehighestcommittee.com
- **Solution**: Remove middleware from Authelia router

**Issue: 401 Unauthorized on protected service**
- **Cause**: User not logged in or session expired
- **Solution**: Clear browser cookies, login again

**Issue: User can't access service after login**
- **Cause**: User not in required group
- **Solution**: Check access control rules, add user to correct group

**Issue: Authelia not accessible via public URL**
- **Cause**: Traefik router not configured
- **Solution**: Verify authelia-router.yml is deployed to 192.168.0.2

---

## 🔗 OIDC Integration (Optional)

Authelia can act as an OpenID Connect (OIDC) provider for SSO integration.

### Prerequisites
- OIDC secrets generated (done by deploy.sh)
- Client application that supports OIDC

### Register New OIDC Client

1. Edit configuration.yml:
```yaml
identity_providers:
  oidc:
    clients:
      - id: client-name
        description: "Client Description"
        secret: '$pbkdf2-sha512$310000$...'  # Generate with command below
        public: false
        authorization_policy: one_factor
        redirect_uris:
          - https://client.example.com/auth/callback
        scopes:
          - openid
          - profile
          - email
          - groups
```

2. Generate client secret:
```bash
docker run --rm authelia/authelia:latest authelia crypto hash generate pbkdf2 --password 'ClientSecretHere'
```

3. Restart Authelia

### Pocket-ID Integration

To use Pocket-ID as the authentication backend:

1. Configure Pocket-ID as LDAP proxy or OIDC provider
2. Update Authelia configuration to use Pocket-ID backend
3. See `/opt/stacks/AUTHELIA_INTEGRATION_PLAN.md` for detailed steps

---

## 🔐 Security Best Practices

1. **Change Default Admin Password Immediately**
   - Default is `!St00pid!` for initial setup only

2. **Enable 2FA for All Users**
   - TOTP (Time-based One-Time Password) via authenticator app
   - WebAuthn for hardware keys (optional)

3. **Rotate Secrets Periodically**
   - Regenerate secrets annually
   - Update configuration and restart services

4. **Use Strong Passwords**
   - Minimum 16 characters
   - Mix of upper/lower case, numbers, symbols

5. **Monitor Access Logs**
   - Review Authelia logs regularly
   - Check for suspicious activity

6. **Backup Configuration**
   - Backup `/opt/stacks/appdata/authelia/` regularly
   - Include secrets in encrypted backup

---

## 📚 Additional Resources

- **Authelia Documentation**: https://www.authelia.com/
- **Traefik ForwardAuth**: https://doc.traefik.io/traefik/middlewares/http/forwardauth/
- **OIDC Configuration**: https://www.authelia.com/configuration/identity-providers/oidc/
- **Access Control**: https://www.authelia.com/configuration/security/access-control/

---

## 🆘 Support

**Authelia Community:**
- GitHub: https://github.com/authelia/authelia
- Discord: https://discord.authelia.com
- Discussions: https://github.com/authelia/authelia/discussions

**Homelab Documentation:**
- HOSTED_APPS.md: `/opt/stacks/HOSTED_APPS.md`
- Integration Plan: `/opt/stacks/AUTHELIA_INTEGRATION_PLAN.md`
- Traefik Setup: `/opt/stacks/TRAEFIK_MIGRATION.md`

---

**Last Updated**: 2026-02-04
**Status**: Ready for deployment
**Maintainer**: TheHighestCommittee Infrastructure Team
