# Authelia Self-Service Registration System

## Overview
Self-service user registration system with email verification that automatically syncs users to both Authelia and Pocket-ID for immediate login with passkey support.

## Features
- **Self-Service Registration**: Web form for new user sign-ups
- **Email Verification**: Secure token-based email verification (24-hour expiry)
- **Dual Sync**: Automatically adds users to both Authelia and Pocket-ID
- **Immediate Login**: Users can login immediately after verification
- **Passkey Support**: WebAuthn/passkey login via Pocket-ID integration
- **Password Security**: Argon2id hashing with time_cost=3, memory=65536

## Access
- **Registration URL**: https://register.thehighestcommittee.com
- **API Endpoints**:
  - POST `/api/register` - Create new account
  - GET `/api/verify?token=<token>` - Verify email
  - POST `/api/check-username` - Check username availability

## Architecture
```
User Registration Flow:
1. User fills registration form → POST /api/register
2. System generates verification token (24h expiry)
3. Email sent with verification link
4. User clicks link → GET /api/verify?token=xxx
5. System creates user in Authelia (users_database.yml)
6. System syncs user to Pocket-ID via API
7. Authelia container auto-restarts
8. User can immediately login at authelia.thehighestcommittee.com
```

## Configuration
Environment variables in docker-compose.yml:
- `SMTP_HOST`: smtp.gmail.com
- `SMTP_PORT`: 587
- `SMTP_USER`: imtammer@gmail.com
- `SMTP_PASSWORD`: otei ptqs okxn wehq
- `DOMAIN`: thehighestcommittee.com
- `AUTHELIA_CONFIG`: /authelia-config/users_database.yml
- `POCKET_ID_URL`: http://security-pocket-id-1:1411

## Files
- `docker-compose.yml` - Service deployment
- `app/app.py` - Flask API backend
- `app/index.html` - Registration frontend

## Management
```bash
# Start service
docker compose up -d

# View logs
docker logs -f authelia-registration

# Restart service
docker compose restart

# Stop service
docker compose down
```

## Integration Details

### Authelia Integration
- Reads/writes `/authelia-config/users_database.yml`
- Uses Argon2id password hashing matching Authelia config
- Adds new users to 'users' group by default
- Auto-restarts Authelia container after user creation

### Pocket-ID Integration
- Attempts to create user via POST to `http://security-pocket-id-1:1411/api/users`
- Falls back gracefully if Pocket-ID API unavailable
- User will sync on first login if API creation fails
- Enables passkey/WebAuthn support for registered users

## Security Features
- Client-side password validation (minimum 8 characters)
- Password strength indicator
- Username validation (lowercase, numbers, underscores only)
- Email format validation
- Secure token generation (32-byte URL-safe tokens)
- Token expiration (24 hours)
- SMTP TLS encryption
- Argon2id password hashing

## User Groups
By default, new users are added to:
- `users` group in both Authelia and Pocket-ID

To add admin privileges, manually edit `/opt/stacks/appdata/authelia/config/users_database.yml` and add 'admins' group.

## Troubleshooting

### Email not sending
- Check SMTP credentials in docker-compose.yml
- Verify Gmail app password is valid
- Check logs: `docker logs authelia-registration`

### Users can't login after registration
- Verify Authelia restarted: `docker ps | grep authelia`
- Check users_database.yml: `cat /opt/stacks/appdata/authelia/config/users_database.yml`
- Restart Authelia manually: `docker compose -f /opt/stacks/security/authelia/docker-compose.yml restart authelia`

### Pocket-ID sync fails
- This is expected if Pocket-ID doesn't have user creation API
- User will still be created in Authelia
- User will sync to Pocket-ID on first login via LDAP (when configured)

## Production Recommendations
1. Replace in-memory token storage with Redis
2. Use production WSGI server (gunicorn/uwsgi) instead of Flask dev server
3. Add rate limiting for registration endpoint
4. Add CAPTCHA to prevent automated registrations
5. Implement username blacklist
6. Add password complexity requirements
7. Log registration attempts for audit
