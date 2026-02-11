# Pocket-ID Integration with Authelia

Complete guide to integrate Pocket-ID for self-service user registration with Authelia authentication.

---

## 🎯 What This Enables

**After integration, users can:**
- ✅ Register their own accounts via Pocket-ID
- ✅ Reset passwords themselves
- ✅ Manage their profile
- ✅ Login to all Authelia-protected services with one account
- ✅ Use OIDC SSO across applications

---

## 📋 Current Status

**Pocket-ID:**
- ✅ Running at: https://auth.thehighestcommittee.com
- ✅ Container: security-pocket-id-1 (port 1411)
- ✅ Data: /opt/stacks/arrstack/appdata/pocket-id/data

**Authelia:**
- ✅ Running at: https://authelia.thehighestcommittee.com
- ✅ Currently using: File-based authentication
- ⏳ Needs: LDAP or OIDC backend configuration

---

## 🔧 Integration Options

### Option 1: OIDC Integration (Recommended)
Pocket-ID provides user authentication, Authelia handles authorization.

**Pros:**
- Modern standard (OAuth2/OIDC)
- Better security
- Single source of truth for users
- Full profile sync

**Cons:**
- More complex initial setup

### Option 2: LDAP Proxy
Pocket-ID exposes an LDAP interface, Authelia connects via LDAP.

**Pros:**
- Simpler for legacy systems
- Well-tested integration

**Cons:**
- Requires LDAP setup in Pocket-ID

---

## 🚀 Setup Instructions (OIDC - Recommended)

### Step 1: Configure OIDC in Pocket-ID

1. **Login to Pocket-ID**
   ```
   https://auth.thehighestcommittee.com
   ```

2. **Go to Settings → OAuth Applications**

3. **Create New OAuth Application:**
   - **Name:** Authelia
   - **Client ID:** authelia
   - **Redirect URIs:**
     ```
     https://authelia.thehighestcommittee.com/api/oidc/callback
     https://*.thehighestcommittee.com/oauth2/callback
     ```
   - **Grant Types:** Authorization Code, Refresh Token
   - **Scopes:** openid, profile, email, groups

4. **Save and copy the Client Secret** (you'll need this)

### Step 2: Update Authelia Configuration

Run this script after getting the client secret from Pocket-ID:

```bash
/opt/stacks/security/authelia/setup-pocket-id-integration.sh
```

### Step 3: Test Integration

1. Logout from Authelia
2. Visit a protected service (e.g., https://overseerr.thehighestcommittee.com)
3. Should redirect to Pocket-ID login
4. Login or register new account
5. Redirects back to service

---

## 📝 Manual Configuration (If Script Fails)

### Update Authelia Configuration

Edit `/opt/stacks/appdata/authelia/config/configuration.yml`:

```yaml
authentication_backend:
  refresh_interval: 5m

  # Disable file-based auth
  # file:
  #   path: /config/users_database.yml

  # Enable LDAP (Pocket-ID provides LDAP interface)
  ldap:
    implementation: custom
    url: ldap://192.168.0.11:3890
    timeout: 5s
    start_tls: false
    base_dn: dc=stonith404,dc=com
    username_attribute: uid
    additional_users_dn: ou=users
    users_filter: (&({username_attribute}={input})(objectClass=person))
    additional_groups_dn: ou=groups
    groups_filter: (&(member={dn})(objectClass=groupOfNames))
    group_name_attribute: cn
    mail_attribute: mail
    display_name_attribute: displayName
    user: cn=authelia,ou=service-users,dc=stonith404,dc=com
    password: YOUR_LDAP_BIND_PASSWORD
```

**OR use OIDC authentication (preferred):**

Instead of LDAP, use Authelia as OIDC client to Pocket-ID:
- Pocket-ID = OIDC Provider (handles authentication + user management)
- Authelia = OIDC Relying Party (handles authorization + access control)

---

## 🔐 Enable User Registration in Pocket-ID

### Step 1: Access Pocket-ID Admin

1. Login to https://auth.thehighestcommittee.com
2. Go to **Settings → General**

### Step 2: Enable Registration

- ✅ **Allow User Registration:** Enabled
- ✅ **Email Verification:** Enabled (recommended)
- ✅ **Default Group:** users
- ✅ **Require Admin Approval:** (optional - your choice)

### Step 3: Configure Email (Already Done)

Pocket-ID will use its own SMTP or can share Authelia's email settings.

---

## 📊 User Management Flow

### New User Registration
1. User visits https://auth.thehighestcommittee.com/register
2. Fills out registration form
3. Receives verification email
4. Verifies email
5. Account activated
6. Can now login to any Authelia-protected service

### Existing Users
- Current file-based users (admin) will need to be migrated
- OR keep admin in file-based, all new users in Pocket-ID

---

## 🔄 Migration Strategy

### Keep Both Backends (Recommended for Transition)

Authelia supports multiple backends:

```yaml
authentication_backend:
  refresh_interval: 5m

  # Keep file-based for admin
  file:
    path: /config/users_database.yml

  # Add LDAP for new users
  ldap:
    # ... Pocket-ID LDAP config
```

**Note:** Authelia doesn't support multiple backends natively. We need to choose one.

**Recommended:**
1. Use Pocket-ID (LDAP/OIDC) for all users
2. Recreate admin account in Pocket-ID
3. Migrate existing users

---

## 🧪 Testing Checklist

- [ ] Pocket-ID OIDC client created
- [ ] Authelia backend switched to LDAP/OIDC
- [ ] Registration page accessible
- [ ] New user can register
- [ ] Email verification works
- [ ] New user can login to protected service
- [ ] Admin user still works
- [ ] Group-based access control works

---

## 🐛 Troubleshooting

### Issue: Registration page not accessible
**Check:** Pocket-ID settings → Allow registration enabled

### Issue: User can register but can't login
**Check:** Authelia LDAP connection to Pocket-ID

### Issue: Groups not syncing
**Check:** LDAP groups filter in Authelia config

---

## 📚 Additional Resources

- **Pocket-ID Docs:** https://docs.pocket-id.app
- **Authelia LDAP:** https://www.authelia.com/configuration/first-factor/ldap/
- **OIDC Integration:** https://www.authelia.com/integration/openid-connect/introduction/

---

**Next Steps:**
Run the integration script to complete the setup automatically.

```bash
/opt/stacks/security/authelia/setup-pocket-id-integration.sh
```
