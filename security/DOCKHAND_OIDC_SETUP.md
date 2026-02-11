# Dockhand OIDC Setup

## Configuration via Web UI

**Client ID**: `3ac8da8d-7229-4397-9482-3a30fcaa1ebd`

### Steps:

1. Go to: **https://dockhand.thehighestcommittee.com**

2. **Settings** → **Authentication**

3. **Add OIDC Provider:**
   - Provider Type: **Custom**
   - Provider Name: **Pocket ID**
   - Issuer URL: `https://auth.thehighestcommittee.com`
   - Client ID: `3ac8da8d-7229-4397-9482-3a30fcaa1ebd`
   - Client Secret: **Leave blank** (Public client with PKCE)
   - Redirect URI: `https://dockhand.thehighestcommittee.com/callback`
   - Scopes: `openid profile email`

4. **Enable** OIDC Authentication

5. **Save**

### Test:
- Logout from Dockhand
- Should redirect to Pocket ID for login
- Login with your Pocket ID credentials
- Should redirect back to Dockhand

---

**Note:** Dockhand is configured as a public client with PKCE, so no client secret is needed.
