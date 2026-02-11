# 🔑 User Credentials Reference

**Last Updated:** 2026-02-04

---

## Authelia Login Credentials

### Admin User
```
Username: admin
Email:    imtammer@gmail.com
Password: [Your original admin password]
Groups:   admins, users
```

### Redacted User
```
Username: redacted
Email:    wolfbrother_1@yahoo.com
Password: RedactedPass123!
Groups:   users
```

### Access Services
1. Go to any protected service (e.g., https://sonarr.thehighestcommittee.com)
2. You'll be redirected to Authelia login
3. Enter username and password above
4. Set up 2FA on first login (scan QR code)
5. Done!

---

## Pocket ID Registration

**Registration URL:** https://auth.thehighestcommittee.com

**Current Users:**
- tammer (imtammer@gmail.com) - Verified ✅
- redacted (wolfbrother_1@yahoo.com) - Registered ✅

**Note:** Pocket ID uses passwordless authentication (passkeys only)

---

## Password Reset

### Change Authelia Password

After first login, go to:
```
https://authelia.thehighestcommittee.com
```

Click profile → Change Password

### Reset Password (Admin Only)

```bash
# Generate new password hash
docker run --rm authelia/authelia:latest \
  authelia crypto hash generate argon2 --password 'NewPassword123!'

# Copy the hash and update users_database.yml
sudo nano /opt/stacks/appdata/authelia/config/users_database.yml

# Restart Authelia
docker restart authelia
```

---

## 2FA Setup

**On first Authelia login:**
1. After username/password, you'll see QR code
2. Open authenticator app (Google Authenticator, Authy, etc.)
3. Scan QR code
4. Enter 6-digit code to verify
5. Save backup codes securely!

**Supported Apps:**
- Google Authenticator
- Microsoft Authenticator
- Authy
- 1Password
- Bitwarden

---

## Quick Troubleshooting

**"Invalid username or password"**
- Double-check username (case-sensitive)
- Try password: `RedactedPass123!` for redacted user
- Check Caps Lock is off

**"User not found"**
- User might not be synced yet
- Run: `sudo /opt/stacks/security/authelia/sync-users-safe.sh`

**Can't setup 2FA**
- Make sure authenticator app clock is synced
- Try refreshing the page for new QR code
- Contact admin if persistent

---

**Security Note:** Change default passwords after first login!
