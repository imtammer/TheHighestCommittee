#!/bin/bash
###############################################################################
#              Pocket-ID Integration Setup for Authelia                       #
###############################################################################

set -euo pipefail

CONFIG_FILE="/opt/stacks/appdata/authelia/config/configuration.yml"
BACKUP_FILE="/opt/stacks/appdata/authelia/config/configuration.yml.backup.$(date +%Y%m%d_%H%M%S)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

echo "═══════════════════════════════════════════════════════════════"
echo "      Pocket-ID Integration with Authelia Setup"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Check if Pocket-ID is running
echo "Checking Pocket-ID status..."
if curl -s -o /dev/null -w "%{http_code}" https://auth.thehighestcommittee.com | grep -q "200"; then
    print_success "Pocket-ID is running at https://auth.thehighestcommittee.com"
else
    print_error "Pocket-ID is not accessible"
    exit 1
fi
echo ""

# Ask user for integration method
echo "Choose integration method:"
echo "1. LDAP Proxy (Simpler, recommended)"
echo "2. OIDC (More features, complex)"
echo ""
read -p "Enter choice [1]: " choice
choice=${choice:-1}

if [ "$choice" == "2" ]; then
    echo ""
    print_warning "OIDC integration requires manual steps in Pocket-ID first"
    echo ""
    echo "Steps needed:"
    echo "1. Login to https://auth.thehighestcommittee.com"
    echo "2. Go to Settings → OAuth Applications"
    echo "3. Create new OAuth app for Authelia"
    echo "4. Copy the Client Secret"
    echo ""
    read -p "Have you completed these steps? (y/N): " completed

    if [[ ! $completed =~ ^[Yy]$ ]]; then
        echo ""
        print_warning "Please complete the Pocket-ID OIDC setup first"
        echo "See: /opt/stacks/security/authelia/POCKET_ID_INTEGRATION.md"
        exit 0
    fi

    echo ""
    read -p "Enter Pocket-ID OIDC Client Secret: " client_secret

    if [ -z "$client_secret" ]; then
        print_error "Client secret cannot be empty"
        exit 1
    fi
fi

# Backup current configuration
echo ""
echo "Backing up current configuration..."
cp "$CONFIG_FILE" "$BACKUP_FILE"
print_success "Backup created: $BACKUP_FILE"
echo ""

# Configure LDAP integration (Option 1)
if [ "$choice" == "1" ]; then
    echo "Configuring LDAP integration..."
    echo ""

    # Check if Pocket-ID LDAP is enabled
    print_warning "Pocket-ID LDAP server must be enabled"
    echo "Check: https://auth.thehighestcommittee.com/settings"
    echo "Enable: LDAP Server"
    echo ""
    read -p "Is LDAP enabled in Pocket-ID? (y/N): " ldap_enabled

    if [[ ! $ldap_enabled =~ ^[Yy]$ ]]; then
        print_error "Please enable LDAP in Pocket-ID first"
        exit 1
    fi

    echo ""
    read -p "Enter LDAP Bind Password (from Pocket-ID settings): " ldap_password

    if [ -z "$ldap_password" ]; then
        print_error "LDAP password cannot be empty"
        exit 1
    fi

    # Update configuration
    echo ""
    echo "Updating Authelia configuration..."

    # Comment out file-based auth and add LDAP
    python3 << 'EOF'
import sys

config_file = sys.argv[1]
ldap_password = sys.argv[2]

with open(config_file, 'r') as f:
    content = f.read()

# Comment out file-based auth
content = content.replace(
    '  file:\n    path: /config/users_database.yml',
    '  # file:\n  #   path: /config/users_database.yml'
)

# Add LDAP configuration after authentication_backend
ldap_config = f'''
  # Pocket-ID LDAP integration
  ldap:
    implementation: custom
    address: ldap://192.168.0.11:3890
    timeout: 5s
    start_tls: false
    tls:
      skip_verify: false
    base_dn: dc=pocket-id,dc=local
    username_attribute: uid
    additional_users_dn: ou=users
    users_filter: (&({{username_attribute}}={{input}})(objectClass=inetOrgPerson))
    additional_groups_dn: ou=groups
    groups_filter: (&(member={{dn}})(objectClass=groupOfNames))
    group_name_attribute: cn
    mail_attribute: mail
    display_name_attribute: displayName
    user: cn=authelia,ou=service-accounts,dc=pocket-id,dc=local
    password: {ldap_password}
'''

# Insert LDAP config
if 'authentication_backend:' in content:
    parts = content.split('authentication_backend:', 1)
    if len(parts) == 2:
        # Find end of authentication_backend section
        lines = parts[1].split('\n')
        insert_index = 0
        for i, line in enumerate(lines):
            if line.strip() and not line.startswith(' ') and not line.startswith('#'):
                insert_index = i
                break

        if insert_index > 0:
            lines.insert(insert_index, ldap_config)
            content = parts[0] + 'authentication_backend:' + '\n'.join(lines)

with open(config_file, 'w') as f:
    f.write(content)

print("Configuration updated")
EOF "$CONFIG_FILE" "$ldap_password"

    print_success "LDAP configuration added"
fi

# Restart Authelia
echo ""
echo "Restarting Authelia..."
docker compose -f /opt/stacks/security/authelia/docker-compose.yml restart authelia
sleep 5

# Check if Authelia started successfully
if docker compose -f /opt/stacks/security/authelia/docker-compose.yml ps authelia | grep -q "healthy\|running"; then
    print_success "Authelia restarted successfully"
else
    print_error "Authelia failed to start"
    echo "Restoring backup..."
    cp "$BACKUP_FILE" "$CONFIG_FILE"
    docker compose -f /opt/stacks/security/authelia/docker-compose.yml restart authelia
    exit 1
fi

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "        Integration Setup Complete!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
print_success "Authelia is now using Pocket-ID for authentication"
echo ""
echo "Next steps:"
echo "1. Enable user registration in Pocket-ID:"
echo "   https://auth.thehighestcommittee.com/settings"
echo "   → Enable 'Allow Registration'"
echo ""
echo "2. Test new user registration:"
echo "   https://auth.thehighestcommittee.com/register"
echo ""
echo "3. Migrate existing admin user:"
echo "   - Create admin account in Pocket-ID"
echo "   - Add to 'admins' group"
echo "   - Test login"
echo ""
echo "Troubleshooting:"
echo "- View logs: docker compose -f /opt/stacks/security/authelia/docker-compose.yml logs authelia"
echo "- Restore backup: cp $BACKUP_FILE $CONFIG_FILE"
echo ""
