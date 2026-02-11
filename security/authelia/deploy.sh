#!/bin/bash
###############################################################################
#                      Authelia Deployment Script                             #
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SECRETS_DIR="/opt/stacks/appdata/authelia/secrets"
CONFIG_DIR="/opt/stacks/appdata/authelia/config"
DATA_DIR="/opt/stacks/appdata/authelia/data"

echo "=== Authelia Deployment Script ==="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root"
    exit 1
fi

# Step 1: Create directory structure
echo "Step 1: Creating directory structure..."
mkdir -p "$SECRETS_DIR" "$CONFIG_DIR" "$DATA_DIR"
mkdir -p /opt/stacks/appdata/authelia/redis
echo "✓ Directories created"
echo ""

# Step 2: Generate secrets (if not already generated)
echo "Step 2: Checking secrets..."
if [ ! -f "$SECRETS_DIR/jwt_secret" ]; then
    echo "Secrets not found. Generating..."
    bash "$SCRIPT_DIR/generate-secrets.sh"
else
    echo "✓ Secrets already exist"
fi
echo ""

# Step 3: Generate admin password hash
echo "Step 3: Setting up admin user..."
echo "You need to set an admin password."
echo "Default password is: !St00pid!"
echo ""
read -p "Generate new admin password? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -sp "Enter admin password: " ADMIN_PASS
    echo ""
    read -sp "Confirm admin password: " ADMIN_PASS_CONFIRM
    echo ""

    if [ "$ADMIN_PASS" != "$ADMIN_PASS_CONFIRM" ]; then
        echo "❌ Passwords don't match!"
        exit 1
    fi

    echo "Generating password hash..."
    HASH=$(docker run --rm authelia/authelia:latest authelia crypto hash generate argon2 --password "$ADMIN_PASS" | grep '^\$argon2id')

    # Update users_database.yml
    sed -i "s|password: \"\$argon2id.*\"|password: \"$HASH\"|" "$CONFIG_DIR/users_database.yml"
    echo "✓ Admin password updated"
else
    echo "Using default password (!St00pid!)"
    echo "⚠️  CHANGE THIS AFTER FIRST LOGIN!"

    # Generate hash for default password
    HASH=$(docker run --rm authelia/authelia:latest authelia crypto hash generate argon2 --password '!St00pid!' | grep '^\$argon2id')
    sed -i "s|password: \"\$argon2id.*\"|password: \"$HASH\"|" "$CONFIG_DIR/users_database.yml"
fi
echo ""

# Step 4: Deploy Traefik configuration
echo "Step 4: Deploying Traefik configuration..."
echo "Traefik runs on 192.168.0.2, Authelia runs on this host (192.168.0.11)"
echo "We need to copy both the router and middleware configs to Traefik"
echo ""
read -p "Deploy Traefik configs to 192.168.0.2? (Y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "Copying authelia-traefik-router.yml..."
    scp "$SCRIPT_DIR/authelia-traefik-router.yml" root@192.168.0.2:/etc/traefik/conf.d/authelia-router.yml

    echo "Copying traefik-middleware.yml..."
    scp "$SCRIPT_DIR/traefik-middleware.yml" root@192.168.0.2:/etc/traefik/conf.d/authelia-middleware.yml

    echo "Restarting Traefik..."
    ssh root@192.168.0.2 "systemctl restart traefik"

    echo "✓ Traefik configuration deployed and Traefik restarted"
else
    echo "⚠️  Skipped Traefik configuration deployment"
    echo "Manual steps:"
    echo "  1. Copy authelia-traefik-router.yml to 192.168.0.2:/etc/traefik/conf.d/authelia-router.yml"
    echo "  2. Copy traefik-middleware.yml to 192.168.0.2:/etc/traefik/conf.d/authelia-middleware.yml"
    echo "  3. Restart Traefik: ssh root@192.168.0.2 'systemctl restart traefik'"
fi
echo ""

# Step 5: Start Authelia services
echo "Step 5: Starting Authelia services..."
cd "$SCRIPT_DIR"
docker compose up -d

echo ""
echo "Waiting for services to start..."
sleep 5

# Check if services are running
if docker compose ps | grep -q "running"; then
    echo "✓ Authelia services started"
else
    echo "❌ Failed to start services"
    docker compose logs --tail=50
    exit 1
fi
echo ""

# Step 6: Verify Authelia is accessible
echo "Step 6: Verifying Authelia..."
echo "Testing http://localhost:9091 ..."
sleep 5

if curl -s http://localhost:9091 > /dev/null; then
    echo "✓ Authelia is responding on port 9091"
else
    echo "❌ Authelia is not responding"
    echo "Check logs: docker compose -f $SCRIPT_DIR/docker-compose.yml logs authelia"
    exit 1
fi
echo ""

# Step 7: Display next steps
echo "=== Deployment Complete! ==="
echo ""
echo "✓ Authelia is running at: http://192.168.0.11:9091"
echo "✓ Public URL: https://authelia.thehighestcommittee.com"
echo ""
echo "=== Next Steps ==="
echo ""
echo "1. Test Authelia portal:"
echo "   https://authelia.thehighestcommittee.com"
echo ""
echo "2. Login with:"
echo "   Username: admin"
echo "   Password: (the one you set above)"
echo ""
echo "3. Setup 2FA (TOTP):"
echo "   - Scan QR code with authenticator app"
echo "   - Register device for WebAuthn (optional)"
echo ""
echo "4. Start protecting services:"
echo "   - Edit Traefik router configs on 192.168.0.2"
echo "   - Add 'middlewares: - authelia@file' to routers"
echo "   - Restart Traefik"
echo ""
echo "5. (Optional) Configure Pocket-ID integration:"
echo "   - Register Authelia in Pocket-ID as OIDC provider"
echo "   - Enable SSO across all services"
echo ""
echo "=== Useful Commands ==="
echo ""
echo "View logs:"
echo "  docker compose -f $SCRIPT_DIR/docker-compose.yml logs -f authelia"
echo ""
echo "Restart Authelia:"
echo "  docker compose -f $SCRIPT_DIR/docker-compose.yml restart authelia"
echo ""
echo "Add new user:"
echo "  1. Generate password hash:"
echo "     docker run --rm authelia/authelia:latest authelia crypto hash generate argon2 --password 'UserPassword'"
echo "  2. Edit $CONFIG_DIR/users_database.yml"
echo "  3. Restart: docker compose -f $SCRIPT_DIR/docker-compose.yml restart authelia"
echo ""
echo "Check notifications (email/2FA codes):"
echo "  cat $DATA_DIR/notification.txt"
echo ""
