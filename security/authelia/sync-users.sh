#!/bin/bash
#
# Pocket ID → Authelia User Sync Script
# Automatically syncs users from Pocket ID to Authelia
#

set -euo pipefail

# Paths
POCKETID_DB="/opt/stacks/arrstack/appdata/pocket-id/data/pocket-id.db"
AUTHELIA_USERS="/opt/stacks/appdata/authelia/config/users_database.yml"
AUTHELIA_USERS_BACKUP="/opt/stacks/appdata/authelia/config/users_database.yml.backup"

# Default password hash for synced users (they should use Pocket ID OIDC, not direct login)
# Password: "UsePocketID123!" - Users should login via OIDC, not this password
DEFAULT_PASSWORD_HASH='$argon2id$v=19$m=65536,t=3,p=4$Zp4dKvYG8R6jNObcW4vxPg$dD0QEwcPEE9PqKxLN8vBNgN0yN1aL8hN2E5kW8vN4Rs'

echo "🔄 Starting Pocket ID → Authelia user sync..."

# Backup current users file
cp "$AUTHELIA_USERS" "$AUTHELIA_USERS_BACKUP"
echo "✅ Backed up users file"

# Get users from Pocket ID
echo "📋 Reading users from Pocket ID..."
USERS=$(sqlite3 "$POCKETID_DB" "SELECT username, email, first_name || ' ' || last_name, id FROM users;")

if [ -z "$USERS" ]; then
    echo "⚠️  No users found in Pocket ID"
    exit 0
fi

# Start building new users_database.yml
cat > "$AUTHELIA_USERS" <<'EOF'
---
###############################################################################
#                        Authelia Users Database                              #
#                   Auto-synced from Pocket ID                                #
###############################################################################

users:
EOF

# Process each user
echo "$USERS" | while IFS='|' read -r username email displayname userid; do
    # Skip if username is empty
    if [ -z "$username" ]; then
        continue
    fi

    # Clean up display name
    displayname=$(echo "$displayname" | xargs)
    if [ -z "$displayname" ]; then
        displayname="$username"
    fi

    echo "  ➕ Adding user: $username ($email)"

    # Determine groups (make first user admin, others regular users)
    if [ "$username" = "tammer" ] || [ "$username" = "admin" ]; then
        groups="admins, users"
    else
        groups="users"
    fi

    # Add user entry
    cat >> "$AUTHELIA_USERS" <<EOF
    $username:
        password: $DEFAULT_PASSWORD_HASH
        displayname: $displayname
        email: $email
        groups:
EOF

    # Add groups
    if [[ "$groups" == *"admins"* ]]; then
        echo "            - admins" >> "$AUTHELIA_USERS"
    fi
    echo "            - users" >> "$AUTHELIA_USERS"

    # Add other attributes
    cat >> "$AUTHELIA_USERS" <<'EOF'
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

echo "✅ Users file updated"

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
echo "✅ Sync complete!"
echo ""
echo "📊 Synced users from Pocket ID:"
sqlite3 "$POCKETID_DB" "SELECT '   • ' || username || ' (' || email || ')' FROM users;"
echo ""
echo "ℹ️  Note: Users should login via Pocket ID (OIDC) when possible."
echo "ℹ️  Direct Authelia login password for synced users: UsePocketID123!"
