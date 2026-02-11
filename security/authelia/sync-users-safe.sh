#!/bin/bash
#
# Safe Pocket ID → Authelia User Sync Script
# Only adds NEW users, preserves existing users and passwords
#

set -euo pipefail

# Paths
POCKETID_DB="/opt/stacks/arrstack/appdata/pocket-id/data/pocket-id.db"
AUTHELIA_USERS="/opt/stacks/appdata/authelia/config/users_database.yml"
AUTHELIA_USERS_BACKUP="/opt/stacks/appdata/authelia/config/users_database.yml.backup.$(date +%Y%m%d_%H%M%S)"

# Default password hash for synced users
DEFAULT_PASSWORD_HASH='$argon2id$v=19$m=65536,t=3,p=4$Zp4dKvYG8R6jNObcW4vxPg$dD0QEwcPEE9PqKxLN8vBNgN0yN1aL8hN2E5kW8vN4Rs'

echo "🔄 Starting safe user sync from Pocket ID..."

# Backup current users file
cp "$AUTHELIA_USERS" "$AUTHELIA_USERS_BACKUP"
echo "✅ Backed up to: $AUTHELIA_USERS_BACKUP"

# Get existing Authelia users (just usernames - they have exactly 4 spaces of indentation)
EXISTING_USERS=$(grep -E "^    [a-zA-Z0-9_-]+:" "$AUTHELIA_USERS" | sed -E 's/^    //g' | sed 's/://g')
echo "📋 Existing Authelia users:"
echo "$EXISTING_USERS" | sed 's/^/   • /'

# Get users from Pocket ID
echo ""
echo "📋 Pocket ID users:"
POCKETID_USERS=$(sqlite3 "$POCKETID_DB" "SELECT username FROM users;")

if [ -z "$POCKETID_USERS" ]; then
    echo "   ⚠️  No users found in Pocket ID"
    exit 0
fi

echo "$POCKETID_USERS" | sed 's/^/   • /'

# Find new users (in Pocket ID but not in Authelia)
echo ""
echo "🔍 Checking for new users..."
NEW_USERS=""
for user in $POCKETID_USERS; do
    if ! echo "$EXISTING_USERS" | grep -q "^${user}$"; then
        NEW_USERS="$NEW_USERS $user"
    fi
done

if [ -z "$NEW_USERS" ]; then
    echo "   ✅ No new users to add - all Pocket ID users already exist in Authelia"
    rm "$AUTHELIA_USERS_BACKUP"
    exit 0
fi

echo ""
echo "➕ New users to add:"
for user in $NEW_USERS; do
    echo "   • $user"
done

# Add new users to the file
for username in $NEW_USERS; do
    username=$(echo "$username" | xargs)

    # Get user details from Pocket ID
    USER_DATA=$(sqlite3 "$POCKETID_DB" "SELECT email, first_name || ' ' || last_name FROM users WHERE username='$username';")
    email=$(echo "$USER_DATA" | cut -d'|' -f1)
    displayname=$(echo "$USER_DATA" | cut -d'|' -f2 | xargs)

    if [ -z "$displayname" ]; then
        displayname="$username"
    fi

    echo "  ➕ Adding: $username ($email)"

    # Append new user to file
    cat >> "$AUTHELIA_USERS" <<EOF
    $username:
        password: $DEFAULT_PASSWORD_HASH
        displayname: $displayname
        email: $email
        groups:
            - users
        given_name: ""
        middle_name: ""
        family_name: ""
        nickname: ""
        gender: ""
        birthdate: ""
        website: ""
        profile: ""
        picture: ""
        zoneinfo: ""
        locale: ""
        phone_number: ""
        phone_extension: ""
        disabled: false
        address: null
        extra: {}
EOF
done

echo "✅ Users added to Authelia config"

# Validate YAML syntax
if ! python3 -c "import yaml; yaml.safe_load(open('$AUTHELIA_USERS'))" 2>/dev/null; then
    echo "❌ Generated YAML is invalid! Restoring backup..."
    cp "$AUTHELIA_USERS_BACKUP" "$AUTHELIA_USERS"
    exit 1
fi

echo "✅ YAML syntax validated"

# Restart Authelia to apply changes
echo "🔄 Restarting Authelia..."
if docker restart authelia > /dev/null 2>&1; then
    echo "✅ Authelia restarted successfully"
else
    echo "⚠️  Failed to restart Authelia (may not be running)"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Sync Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Summary:"
echo "   • New users added: $(echo $NEW_USERS | wc -w)"
for user in $NEW_USERS; do
    email=$(sqlite3 "$POCKETID_DB" "SELECT email FROM users WHERE username='$user';")
    echo "     - $user ($email)"
done
echo ""
echo "🔑 Login credentials for new users:"
echo "   • Password: UsePocketID123!"
echo "   • 2FA: Required on first login"
echo ""
echo "✅ Existing users were preserved (no changes)"
