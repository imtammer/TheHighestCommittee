# 👤 User Registration Guide

**Simple registration for TheHighestCommittee services**

---

## 🚀 For New Users

### Step 1: Register at Pocket ID

Go to: **https://auth.thehighestcommittee.com**

1. Click "Sign Up" or "Register"
2. Enter your details:
   - Username
   - Email address
   - First & Last Name
3. Create a passkey (use Windows Hello, Touch ID, or your phone)
4. Done! (No email verification required)

### Step 2: Wait for Admin to Sync

- Tell the admin you've registered
- Admin will run the sync command
- Wait a few minutes

### Step 3: Login to Services

After sync completes, access any service:
- https://sonarr.thehighestcommittee.com
- https://radarr.thehighestcommittee.com
- https://overseerr.thehighestcommittee.com
- etc.

You'll be prompted to:
1. Login with your username and password: `UsePocketID123!`
2. Set up 2FA (scan QR code with authenticator app)
3. Done! You now have access

**You can change your password** after first login at:
- https://authelia.thehighestcommittee.com

---

## 👨‍💼 For Admins

### When a New User Registers

After they register in Pocket ID, run:

```bash
sudo /opt/stacks/security/authelia/sync-users-safe.sh
```

This will:
- ✅ Add only NEW users from Pocket ID
- ✅ Preserve existing users (admin, etc.)
- ✅ Not overwrite any passwords
- ✅ Restart Authelia automatically

**Safe to run anytime** - won't break existing logins!

---

## 🔑 Default Credentials for Synced Users

- **Username**: Their Pocket ID username
- **Password**: `UsePocketID123!`
- **2FA**: Required on first login

Users should change their password after first login.

---

## 🛡️ User Access Levels

**Standard Users:**
- ✅ All media automation tools (*arr services)
- ✅ Media request tools (Overseerr, Jellyseerr)
- ✅ Most general services
- ❌ Admin tools (requires admin privileges)

**To Grant Admin Access:**

Edit `/opt/stacks/appdata/authelia/config/users_database.yml` and change:

```yaml
    username:
        groups:
            - users
```

To:

```yaml
    username:
        groups:
            - admins
            - users
```

Then restart: `docker restart authelia`

---

## 📊 Admin Commands

### Sync new users from Pocket ID
```bash
sudo /opt/stacks/security/authelia/sync-users-safe.sh
```

### Check who's in Pocket ID
```bash
sqlite3 /opt/stacks/arrstack/appdata/pocket-id/data/pocket-id.db \
  "SELECT username, email FROM users;"
```

### Check who's in Authelia
```bash
grep -E "^\s+[a-zA-Z0-9_-]+:" \
  /opt/stacks/appdata/authelia/config/users_database.yml
```

### Restart Authelia
```bash
docker restart authelia
```

---

**Simple, safe, and secure!** 🎉
