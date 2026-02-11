#!/bin/bash
###############################################################################
#                      Authelia Secrets Generation Script                     #
###############################################################################

set -euo pipefail

SECRETS_DIR="/opt/stacks/appdata/authelia/secrets"

echo "=== Authelia Secrets Generation ==="
echo ""

# Create secrets directory if it doesn't exist
mkdir -p "$SECRETS_DIR"

# Function to generate a random secret
generate_secret() {
    openssl rand -base64 32 | tr -d '\n'
}

# Generate JWT Secret
echo "Generating JWT secret..."
generate_secret > "$SECRETS_DIR/jwt_secret"
chmod 600 "$SECRETS_DIR/jwt_secret"

# Generate Session Secret
echo "Generating session secret..."
generate_secret > "$SECRETS_DIR/session_secret"
chmod 600 "$SECRETS_DIR/session_secret"

# Generate Storage Encryption Key
echo "Generating storage encryption key..."
generate_secret > "$SECRETS_DIR/storage_encryption_key"
chmod 600 "$SECRETS_DIR/storage_encryption_key"

# Generate OIDC HMAC Secret
echo "Generating OIDC HMAC secret..."
generate_secret > "$SECRETS_DIR/oidc_hmac_secret"
chmod 600 "$SECRETS_DIR/oidc_hmac_secret"

# Generate OIDC Private Key (RSA 4096)
echo "Generating OIDC private key (RSA 4096)..."
openssl genpkey -algorithm RSA -out "$SECRETS_DIR/oidc_private_key" -pkeyopt rsa_keygen_bits:4096
chmod 600 "$SECRETS_DIR/oidc_private_key"

# Set ownership
chown -R root:root "$SECRETS_DIR"

echo ""
echo "✓ All secrets generated successfully!"
echo ""
echo "Secrets stored in: $SECRETS_DIR"
echo ""
echo "Files created:"
echo "  - jwt_secret"
echo "  - session_secret"
echo "  - storage_encryption_key"
echo "  - oidc_hmac_secret"
echo "  - oidc_private_key"
echo ""
echo "⚠️  IMPORTANT: These secrets are sensitive. Keep them secure!"
echo ""
