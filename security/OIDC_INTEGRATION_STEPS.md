# 🔐 OIDC Integration - Ready to Complete

**Status:** Configurations prepared, awaiting Pocket ID client creation

---

## ✅ What's Been Prepared

### 1. Mealie - `/opt/stacks/cooking/compose.yaml`
- ✅ OIDC environment variables added
- ⏳ Needs Client ID & Secret

### 2. RoMM - `/opt/stacks/emulators/compose.yaml`
- ✅ OIDC environment variables added
- ⏳ Needs Client ID & Secret

### 3. Dockhand - Web UI Configuration
- ⏳ Configure via UI after creating client

---

## 📝 Step 1: Create OIDC Clients in Pocket ID

**Admin Login (valid 1 hour):**
```
https://auth.thehighestcommittee.com/lc/Pre6nJvepEb5kPre
```

### Create 3 Applications:

**Application 1: Mealie**
```
Name: Mealie
Callback URL: https://mealie.thehighestcommittee.com/login
Public Client: No
PKCE Enabled: Yes
```

**Application 2: RoMM**
```
Name: RoMM
Callback URL: https://romm.thehighestcommittee.com/api/oauth/openid
Public Client: No
PKCE Enabled: Yes
```

**Application 3: Dockhand**
```
Name: Dockhand
Callback URL: https://dockhand.thehighestcommittee.com/callback
Public Client: No
PKCE Enabled: Yes
```

**Save each Client ID and Secret!**

---

## 📝 Step 2: Update Configuration Files

### Mealie

Edit: `/opt/stacks/cooking/compose.yaml`

Replace:
```yaml
OIDC_CLIENT_ID: REPLACE_WITH_CLIENT_ID
OIDC_CLIENT_SECRET: REPLACE_WITH_CLIENT_SECRET
```

With your Mealie credentials from Pocket ID.

Then restart:
```bash
cd /opt/stacks/cooking
docker compose up -d
```

### RoMM

Edit: `/opt/stacks/emulators/compose.yaml`

Replace:
```yaml
OIDC_CLIENT_ID: REPLACE_WITH_CLIENT_ID
OIDC_CLIENT_SECRET: REPLACE_WITH_CLIENT_SECRET
```

With your RoMM credentials from Pocket ID.

Then restart:
```bash
cd /opt/stacks/emulators
docker compose up -d
```

### Dockhand (Web UI)

1. Go to: https://dockhand.thehighestcommittee.com
2. Settings → Authentication
3. Add OIDC Provider:
   - **Provider**: Custom
   - **Name**: Pocket ID
   - **Issuer URL**: `https://auth.thehighestcommittee.com`
   - **Client ID**: (from Pocket ID)
   - **Client Secret**: (from Pocket ID)
   - **Redirect URI**: `https://dockhand.thehighestcommittee.com/callback`
4. Save and Enable

---

## 📝 Step 3: Test Each Service

### Test Mealie
1. Go to: https://mealie.thehighestcommittee.com
2. Click "Login with Pocket ID" (or similar button)
3. Should redirect to Pocket ID
4. Login with your credentials
5. Should redirect back to Mealie logged in

### Test RoMM
1. Go to: https://romm.thehighestcommittee.com
2. Should see SSO login option
3. Login via Pocket ID
4. Verify you can access RoMM

### Test Dockhand
1. Go to: https://dockhand.thehighestcommittee.com
2. Should redirect to Pocket ID automatically
3. Login and verify access

---

## 🔍 Troubleshooting

### "Invalid redirect_uri"
- Check exact callback URL in Pocket ID matches config
- No trailing slashes unless specified

### "Invalid client"
- Verify Client ID is correct
- Check Client Secret has no extra spaces

### Service won't start
- Check docker logs: `docker logs <service_name>`
- Verify YAML syntax is correct
- Try: `docker compose config` to validate

### Can't login
- Clear browser cookies/cache
- Check Pocket ID user exists and is active
- Verify service can reach auth.thehighestcommittee.com

---

## 📋 Quick Commands

**Restart all services:**
```bash
cd /opt/stacks/cooking && docker compose up -d
cd /opt/stacks/emulators && docker compose up -d
cd /opt/dockhand && docker compose up -d
```

**View logs:**
```bash
docker logs mealie --tail 50 -f
docker logs romm --tail 50 -f
docker logs dockhand --tail 50 -f
```

**Test OIDC endpoints:**
```bash
curl -s https://auth.thehighestcommittee.com/.well-known/openid-configuration | jq
```

---

## ✅ Completion Checklist

- [ ] Created Mealie client in Pocket ID
- [ ] Updated Mealie compose.yaml with credentials
- [ ] Restarted Mealie
- [ ] Tested Mealie login ✓
- [ ] Created RoMM client in Pocket ID
- [ ] Updated RoMM compose.yaml with credentials
- [ ] Restarted RoMM
- [ ] Tested RoMM login ✓
- [ ] Created Dockhand client in Pocket ID
- [ ] Configured Dockhand via Web UI
- [ ] Tested Dockhand login ✓

---

**Once you've created the Pocket ID clients, paste the credentials here and I'll update the configs!**

Or if you prefer, I can walk you through it step-by-step.
