# 🔐 OIDC Integration Guide
## Pocket ID SSO for TheHighestCommittee Homelab

**Pocket ID OIDC Endpoint:** `https://auth.thehighestcommittee.com`

---

## 📊 Service OIDC Support Matrix

### ✅ Native OIDC Support (10 services)

| Service | Status | Difficulty | Notes |
|---------|--------|------------|-------|
| **Audiobookshelf** | ✅ Mature | Easy | Auto-discovery, PKCE support |
| **Paperless-NGX** | ✅ v2.5.0+ | Easy | Django-allauth, auto-signup |
| **Mealie** | ✅ Stable | Easy | Group support, optional password disable |
| **Tandoor Recipes** | ✅ Stable | Easy | PKCE required |
| **RoMM** | ✅ Excellent | Easy | Great docs, multiple providers |
| **Dockhand** | ✅ Free | Easy | MFA support, multiple providers |
| **Jellyseerr** | ⚠️ Preview | Medium | Requires preview-OIDC tag |
| **Jellyfin** | ⚠️ Plugin | Medium | Requires jellyfin-plugin-sso |
| **Homarr** | ⚠️ Archived | Medium | Project archived Oct 2025 |
| **Dozzle** | ✅ Via Proxy | Medium | Requires oauth2-proxy |

### ❌ No Native Support - Use Authelia (14 services)

**Already protected by Authelia (no additional config needed):**
- Sonarr, Radarr, Lidarr, Readarr, Prowlarr
- Overseerr
- Bazarr, Tautulli
- qBittorrent, SABnzbd
- Kavita, Navidrome
- Homepage
- Maintainerr, Suwayomi

**Public services (bypassed in Authelia):**
- Plex, Jellyfin (proprietary auth systems)

---

## 🔑 Pocket ID API Setup

### API Authentication

Pocket ID doesn't have a traditional REST API for OIDC client creation. Clients must be created via:
1. **Web UI** (recommended)
2. **Direct SQLite database manipulation** (advanced)

### Get API Token (One-Time Access)

```bash
# Generate one-time login token for admin
docker exec security-pocket-id-1 /app/pocket-id one-time-access-token tammer

# Output: https://auth.thehighestcommittee.com/login/one-time-access/<TOKEN>
# Valid for 15 minutes
```

---

## 📝 Step-by-Step Integration

### 1. Audiobookshelf

**OIDC Client Setup:**

```bash
# 1. Create OIDC client in Pocket ID Web UI:
# - Name: Audiobookshelf
# - Redirect URIs: https://audiobookshelf.thehighestcommittee.com/auth/openid/callback
#                  https://audiobookshelf.thehighestcommittee.com/auth/openid/mobile-redirect
# - Scopes: openid, profile, email, groups
# - Grant Types: authorization_code, refresh_token
# - Response Types: code
# - Token Endpoint Auth Method: client_secret_post
# - PKCE: Required (S256)

# 2. Configure Audiobookshelf Environment Variables:
```

**docker-compose.yml:**
```yaml
services:
  audiobookshelf:
    environment:
      - AUDIOBOOKSHELF_OIDC_ISSUER_URL=https://auth.thehighestcommittee.com
      - AUDIOBOOKSHELF_OIDC_CLIENT_ID=<client_id_from_pocketid>
      - AUDIOBOOKSHELF_OIDC_CLIENT_SECRET=<client_secret_from_pocketid>
      - AUDIOBOOKSHELF_OIDC_BUTTON_TEXT=Login with Pocket ID
      - AUDIOBOOKSHELF_OIDC_AUTO_LAUNCH=false
      - AUDIOBOOKSHELF_OIDC_AUTO_REGISTER=true
      # Optional: Group-based access control
      - OIDC_USER_GROUP=users
      - OIDC_ADMIN_GROUP=admins
```

**Or via Web UI:**
1. Settings → Authentication
2. Enable OpenID Connect
3. Issuer URL: `https://auth.thehighestcommittee.com`
4. Client ID & Secret from Pocket ID
5. Save & Test

**Redirect URIs:**
```
https://audiobookshelf.thehighestcommittee.com/auth/openid/callback
https://audiobookshelf.thehighestcommittee.com/auth/openid/mobile-redirect
```

---

### 2. Paperless-NGX

**OIDC Client Setup:**

```bash
# Create OIDC client in Pocket ID:
# - Name: Paperless-NGX
# - Redirect URIs: https://paperless.thehighestcommittee.com/accounts/oidc/pocketid/login/callback/
# - Scopes: openid, profile, email
# - PKCE: Required
```

**docker-compose.yml:**
```yaml
services:
  paperless:
    environment:
      - PAPERLESS_APPS=allauth.socialaccount.providers.openid_connect
      - PAPERLESS_SOCIALACCOUNT_PROVIDERS='{
          "openid_connect": {
            "APPS": [{
              "provider_id": "pocketid",
              "name": "Pocket ID",
              "client_id": "<client_id>",
              "secret": "<client_secret>",
              "settings": {
                "server_url": "https://auth.thehighestcommittee.com/.well-known/openid-configuration"
              }
            }],
            "OAUTH_PKCE_ENABLED": true
          }
        }'
      - PAPERLESS_SOCIAL_AUTO_SIGNUP=true
      - PAPERLESS_DISABLE_REGULAR_LOGIN=true  # Optional
```

**Redirect URI:**
```
https://paperless.thehighestcommittee.com/accounts/oidc/pocketid/login/callback/
```

---

### 3. Mealie

**OIDC Client Setup:**

```bash
# Create OIDC client in Pocket ID:
# - Name: Mealie
# - Redirect URIs: https://mealie.thehighestcommittee.com/login
# - Scopes: openid, profile, email, groups
```

**docker-compose.yml:**
```yaml
services:
  mealie:
    environment:
      - OIDC_AUTH_ENABLED=true
      - OIDC_SIGNUP_ENABLED=true
      - OIDC_CONFIGURATION_URL=https://auth.thehighestcommittee.com/.well-known/openid-configuration
      - OIDC_CLIENT_ID=<client_id>
      - OIDC_CLIENT_SECRET=<client_secret>
      - OIDC_AUTO_REDIRECT=false
      # Optional: Group-based access control
      - OIDC_USER_GROUP=users
      - OIDC_ADMIN_GROUP=admins
      # Optional: Disable password login
      - ALLOW_PASSWORD_LOGIN=false
```

**Redirect URI:**
```
https://mealie.thehighestcommittee.com/login
```

---

### 4. Tandoor Recipes

**OIDC Client Setup:**

```bash
# Create OIDC client in Pocket ID:
# - Name: Tandoor
# - Redirect URIs: https://recipes.thehighestcommittee.com/accounts/openid_connect/pocketid/login/callback/
# - Scopes: openid, profile, email
# - PKCE: Required
```

**docker-compose.yml:**
```yaml
services:
  tandoor:
    environment:
      - SOCIAL_PROVIDERS=allauth.socialaccount.providers.openid_connect
      - SOCIALACCOUNT_PROVIDERS='{
          "openid_connect": {
            "APPS": [{
              "provider_id": "pocketid",
              "name": "Pocket ID",
              "client_id": "<client_id>",
              "secret": "<client_secret>",
              "settings": {
                "server_url": "https://auth.thehighestcommittee.com/.well-known/openid-configuration"
              }
            }],
            "OAUTH_PKCE_ENABLED": true
          }
        }'
```

**Redirect URI:**
```
https://recipes.thehighestcommittee.com/accounts/openid_connect/pocketid/login/callback/
```

---

### 5. RoMM (ROM Manager)

**OIDC Client Setup:**

```bash
# Create OIDC client in Pocket ID:
# - Name: RoMM
# - Redirect URIs: https://romm.thehighestcommittee.com/api/oauth/openid
# - Scopes: openid, profile, email
```

**docker-compose.yml:**
```yaml
services:
  romm:
    environment:
      - OIDC_ENABLED=true
      - OIDC_PROVIDER=PocketID
      - OIDC_CLIENT_ID=<client_id>
      - OIDC_CLIENT_SECRET=<client_secret>
      - OIDC_REDIRECT_URI=https://romm.thehighestcommittee.com/api/oauth/openid
      - OIDC_SERVER_APPLICATION_URL=https://auth.thehighestcommittee.com
      # Optional: Auto-create users
      - OIDC_AUTO_CREATE_USER=true
```

**Redirect URI:**
```
https://romm.thehighestcommittee.com/api/oauth/openid
```

---

### 6. Dockhand

**OIDC Client Setup:**

```bash
# Create OIDC client in Pocket ID:
# - Name: Dockhand
# - Redirect URIs: https://dockhand.thehighestcommittee.com/callback
# - Scopes: openid, profile, email
```

**Configuration:**
1. Go to Dockhand Settings
2. Authentication → Enable OIDC
3. Provider: Custom
4. Issuer URL: `https://auth.thehighestcommittee.com`
5. Client ID & Secret from Pocket ID
6. Redirect URI: `https://dockhand.thehighestcommittee.com/callback`
7. Enable MFA (optional)

**⚠️ Important:** Configure at least one provider before enabling authentication!

---

### 7. Jellyseerr (Preview)

**OIDC Client Setup:**

```bash
# ⚠️ Requires preview-OIDC Docker tag
# docker pull fallenbagel/jellyseerr:preview-OIDC

# Create OIDC client in Pocket ID:
# - Name: Jellyseerr
# - Redirect URIs: https://jellyseerr.thehighestcommittee.com/login?provider=oidc&callback=true
# - Scopes: openid, profile, email
# - PKCE: No client secret needed (SPA)
```

**docker-compose.yml:**
```yaml
services:
  jellyseerr:
    image: fallenbagel/jellyseerr:preview-OIDC
    environment:
      - OIDC_ISSUER=https://auth.thehighestcommittee.com
      - OIDC_CLIENT_ID=<client_id>
      - OIDC_PROVIDER_NAME=Pocket ID
```

**Web UI Configuration:**
1. Settings → Authentication
2. Enable OpenID Connect
3. Configure provider details

**Redirect URI:**
```
https://jellyseerr.thehighestcommittee.com/login?provider=oidc&callback=true
```

---

### 8. Jellyfin (Plugin)

**Prerequisites:**
```bash
# Install jellyfin-plugin-sso
# In Jellyfin Admin → Plugins → Catalog → SSO-Auth
```

**OIDC Client Setup:**

```bash
# Create OIDC client in Pocket ID:
# - Name: Jellyfin
# - Redirect URIs: https://jellyfin.thehighestcommittee.com/sso/OID/redirect/pocketid
# - Scopes: openid, profile, email
```

**Jellyfin Plugin Configuration:**
1. Dashboard → Plugins → SSO-Auth
2. Provider: OpenID
3. Add Provider:
   - Name: PocketID
   - OID Endpoint: `https://auth.thehighestcommittee.com`
   - Client ID & Secret
   - Enable Folder Access
4. Save

**Redirect URI:**
```
https://jellyfin.thehighestcommittee.com/sso/OID/redirect/pocketid
```

---

### 9. Dozzle (via oauth2-proxy)

**OIDC Client Setup:**

```bash
# Create OIDC client in Pocket ID:
# - Name: Dozzle
# - Redirect URIs: https://dozzle.thehighestcommittee.com/oauth2/callback
# - Scopes: openid, email, profile, groups
```

**docker-compose.yml:**
```yaml
services:
  oauth2-proxy:
    image: quay.io/oauth2-proxy/oauth2-proxy:latest
    command:
      - --provider=oidc
      - --oidc-issuer-url=https://auth.thehighestcommittee.com
      - --client-id=<client_id>
      - --client-secret=<client_secret>
      - --redirect-url=https://dozzle.thehighestcommittee.com/oauth2/callback
      - --cookie-secret=<random_32_char_string>
      - --email-domain=*
      - --upstream=http://dozzle:8080
      - --scope=openid email profile groups
    ports:
      - "4180:4180"

  dozzle:
    image: amir20/dozzle:latest
    # No authentication needed - oauth2-proxy handles it
```

**Generate cookie secret:**
```bash
python3 -c 'import secrets; print(secrets.token_urlsafe(32))'
```

---

## 🔧 Pocket ID OIDC Client Creation (Web UI)

### Step-by-Step:

1. **Login to Pocket ID:**
   ```
   https://auth.thehighestcommittee.com
   ```

2. **Navigate to OIDC Clients:**
   - Admin Panel → Applications / OIDC Clients
   - Click "Add Client" or "New Application"

3. **Configure Client:**
   ```
   Name: <Service Name>
   Client ID: Auto-generated (or custom)
   Client Secret: Auto-generated
   Redirect URIs: <service_redirect_uri>
   Scopes: openid, profile, email, groups
   Grant Types: authorization_code, refresh_token
   Response Types: code
   Token Endpoint Auth Method: client_secret_post
   ```

4. **PKCE Settings:**
   - For services requiring PKCE: Enable "Require PKCE"
   - Code Challenge Method: S256

5. **User Access:**
   - Assign user groups (if needed)
   - Default: All authenticated users

6. **Save & Copy Credentials:**
   - Copy Client ID
   - Copy Client Secret
   - Note: Secret shown only once!

---

## 🗄️ Direct Database Method (Advanced)

### Create OIDC Client via SQLite:

```bash
# Generate client credentials
CLIENT_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
CLIENT_SECRET=$(openssl rand -hex 32)

# Insert OIDC client
sqlite3 /opt/stacks/arrstack/appdata/pocket-id/data/pocket-id.db <<EOF
INSERT INTO oidc_clients (
    id, created_at, updated_at,
    name, client_id, client_secret,
    redirect_uris, grant_types, response_types,
    scopes, token_endpoint_auth_method
) VALUES (
    '$(uuidgen | tr '[:upper:]' '[:lower:]')',
    datetime('now'),
    datetime('now'),
    'Audiobookshelf',
    '${CLIENT_ID}',
    '${CLIENT_SECRET}',
    '["https://audiobookshelf.thehighestcommittee.com/auth/openid/callback"]',
    '["authorization_code","refresh_token"]',
    '["code"]',
    '["openid","profile","email","groups"]',
    'client_secret_post'
);
EOF

echo "Client ID: ${CLIENT_ID}"
echo "Client Secret: ${CLIENT_SECRET}"

# Restart Pocket ID to load new client
docker restart security-pocket-id-1
```

---

## 📋 Quick Reference

### Pocket ID OIDC Endpoints:

```
Issuer: https://auth.thehighestcommittee.com
Authorization: https://auth.thehighestcommittee.com/authorize
Token: https://auth.thehighestcommittee.com/api/oidc/token
UserInfo: https://auth.thehighestcommittee.com/api/oidc/userinfo
JWKS: https://auth.thehighestcommittee.com/.well-known/jwks.json
Discovery: https://auth.thehighestcommittee.com/.well-known/openid-configuration
```

### Standard Scopes:
```
openid    - Required for OIDC
profile   - Name, display name, picture
email     - Email address, verification status
groups    - User group membership
```

### Common Redirect URI Patterns:
```
/auth/openid/callback          - Audiobookshelf
/accounts/oidc/<id>/login/callback/  - Django apps (Paperless, Tandoor)
/login                         - Mealie
/api/oauth/openid              - RoMM
/callback                      - Dockhand
/oauth2/callback               - oauth2-proxy
```

---

## 🚀 Deployment Checklist

- [ ] Create OIDC client in Pocket ID
- [ ] Copy Client ID and Secret
- [ ] Configure service environment variables
- [ ] Update docker-compose.yml
- [ ] Restart service: `docker compose up -d`
- [ ] Test login flow
- [ ] Verify user creation/auto-registration
- [ ] Test group-based access (if configured)
- [ ] Document credentials in password manager
- [ ] Disable password auth (optional)

---

## 🔍 Troubleshooting

### Common Issues:

**"Invalid redirect_uri"**
- Check exact match in Pocket ID client config
- Include protocol (https://)
- No trailing slashes (unless required)

**"Invalid client"**
- Verify Client ID matches exactly
- Check Client Secret hasn't expired
- Restart Pocket ID after DB changes

**"PKCE required"**
- Enable PKCE in Pocket ID client settings
- Service must support S256 challenge method

**"User not found / auto-register failed"**
- Enable auto-registration in service config
- Check email claim is present
- Verify scopes include 'email'

**"Groups not working"**
- Ensure 'groups' scope is requested
- Check group names match exactly
- Verify Pocket ID user is in correct group

### Debug Commands:

```bash
# Check OIDC client config
sqlite3 /opt/stacks/arrstack/appdata/pocket-id/data/pocket-id.db \
  "SELECT name, client_id, redirect_uris FROM oidc_clients;"

# View Pocket ID logs
docker logs security-pocket-id-1 --tail 50 -f

# Test OIDC discovery endpoint
curl -s https://auth.thehighestcommittee.com/.well-known/openid-configuration | jq

# Check service logs
docker logs <service_name> --tail 50 -f
```

---

**Last Updated:** 2026-02-04
**Pocket ID Version:** 2.2.0
**Total OIDC-Ready Services:** 10/70+
