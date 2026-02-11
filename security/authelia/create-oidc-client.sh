#!/bin/bash
#
# Pocket ID OIDC Client Creation Script
# Creates OIDC clients directly in Pocket ID database
#

set -euo pipefail

# Configuration
POCKETID_DB="/opt/stacks/arrstack/appdata/pocket-id/data/pocket-id.db"
CONTAINER="security-pocket-id-1"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Pocket ID OIDC Client Creator${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if service name provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <service-name> [redirect-uri]"
    echo ""
    echo "Examples:"
    echo "  $0 audiobookshelf https://audiobookshelf.thehighestcommittee.com/auth/openid/callback"
    echo "  $0 mealie https://mealie.thehighestcommittee.com/login"
    echo "  $0 paperless-ngx https://paperless.thehighestcommittee.com/accounts/oidc/pocketid/login/callback/"
    echo ""
    exit 1
fi

SERVICE_NAME="$1"
REDIRECT_URI="${2:-}"

# If no redirect URI provided, ask
if [ -z "$REDIRECT_URI" ]; then
    echo -e "${YELLOW}Enter redirect URI:${NC}"
    read -r REDIRECT_URI
fi

# Generate credentials
CLIENT_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
CLIENT_SECRET=$(openssl rand -hex 32)
CLIENT_DB_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')

echo ""
echo -e "${GREEN}Generated Credentials:${NC}"
echo "Service: $SERVICE_NAME"
echo "Client ID: $CLIENT_ID"
echo "Client Secret: $CLIENT_SECRET"
echo "Redirect URI: $REDIRECT_URI"
echo ""

# Confirm
echo -e "${YELLOW}Create this OIDC client? (y/n)${NC}"
read -r confirm
if [ "$confirm" != "y" ]; then
    echo "Cancelled."
    exit 0
fi

# Insert into database
sqlite3 "$POCKETID_DB" <<EOF
INSERT INTO oidc_clients (
    id,
    created_at,
    updated_at,
    name,
    client_id,
    client_secret,
    redirect_uris,
    grant_types,
    response_types,
    scopes,
    token_endpoint_auth_method,
    allowed_cors_origins
) VALUES (
    '${CLIENT_DB_ID}',
    datetime('now'),
    datetime('now'),
    '${SERVICE_NAME}',
    '${CLIENT_ID}',
    '${CLIENT_SECRET}',
    '["${REDIRECT_URI}"]',
    '["authorization_code","refresh_token"]',
    '["code"]',
    '["openid","profile","email","groups"]',
    'client_secret_post',
    '[]'
);
EOF

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ OIDC client created successfully!${NC}"
    echo ""

    # Restart Pocket ID
    echo -e "${BLUE}Restarting Pocket ID...${NC}"
    docker restart "$CONTAINER" > /dev/null 2>&1
    echo -e "${GREEN}✅ Pocket ID restarted${NC}"
    echo ""

    # Show configuration
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}Configuration for ${SERVICE_NAME}:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "OIDC_ENABLED=true"
    echo "OIDC_ISSUER_URL=https://auth.thehighestcommittee.com"
    echo "OIDC_CLIENT_ID=${CLIENT_ID}"
    echo "OIDC_CLIENT_SECRET=${CLIENT_SECRET}"
    echo "OIDC_REDIRECT_URI=${REDIRECT_URI}"
    echo ""
    echo -e "${YELLOW}⚠️  Save these credentials securely - secret won't be shown again!${NC}"
    echo ""

    # Save to file
    CREDS_FILE="/opt/stacks/security/oidc-clients/${SERVICE_NAME}.txt"
    mkdir -p /opt/stacks/security/oidc-clients
    cat > "$CREDS_FILE" <<CREDS
Service: ${SERVICE_NAME}
Created: $(date)

Client ID: ${CLIENT_ID}
Client Secret: ${CLIENT_SECRET}
Redirect URI: ${REDIRECT_URI}

Configuration:
OIDC_ENABLED=true
OIDC_ISSUER_URL=https://auth.thehighestcommittee.com
OIDC_CLIENT_ID=${CLIENT_ID}
OIDC_CLIENT_SECRET=${CLIENT_SECRET}
OIDC_REDIRECT_URI=${REDIRECT_URI}
CREDS

    chmod 600 "$CREDS_FILE"
    echo -e "${GREEN}✅ Credentials saved to: ${CREDS_FILE}${NC}"

else
    echo ""
    echo -e "${YELLOW}❌ Failed to create OIDC client${NC}"
    exit 1
fi
