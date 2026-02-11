#!/bin/bash
#
# OIDC Integration Completion Script
# Finalize OIDC configuration for Mealie, RoMM, and Dockhand
#

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  OIDC Integration Completion${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Function to update OIDC credentials
update_service() {
    local SERVICE_NAME=$1
    local COMPOSE_FILE=$2
    local CLIENT_ID=$3
    local CLIENT_SECRET=$4

    echo -e "${BLUE}Updating ${SERVICE_NAME}...${NC}"

    # Replace placeholders
    sed -i "s/REPLACE_WITH_CLIENT_ID/${CLIENT_ID}/g" "$COMPOSE_FILE"
    sed -i "s/REPLACE_WITH_CLIENT_SECRET/${CLIENT_SECRET}/g" "$COMPOSE_FILE"

    echo -e "${GREEN}✅ ${SERVICE_NAME} configuration updated${NC}"
}

# Function to restart service
restart_service() {
    local SERVICE_DIR=$1
    local SERVICE_NAME=$2

    echo -e "${BLUE}Restarting ${SERVICE_NAME}...${NC}"
    cd "$SERVICE_DIR"
    docker compose up -d
    echo -e "${GREEN}✅ ${SERVICE_NAME} restarted${NC}"
    echo ""
}

# Check if credentials provided
if [ "$1" == "--help" ] || [ $# -eq 0 ]; then
    echo "Usage: $0 [service]"
    echo ""
    echo "Services:"
    echo "  mealie   - Complete Mealie integration"
    echo "  romm     - Complete RoMM integration"
    echo "  all      - Complete all integrations"
    echo ""
    echo "Interactive mode: $0 mealie"
    echo "Direct mode: $0 mealie <client_id> <client_secret>"
    exit 0
fi

SERVICE=$1

case $SERVICE in
    mealie)
        echo -e "${YELLOW}Integrating Mealie${NC}"
        echo ""

        if [ -z "$2" ]; then
            echo "Enter Mealie Client ID:"
            read -r MEALIE_CLIENT_ID
            echo "Enter Mealie Client Secret:"
            read -r MEALIE_CLIENT_SECRET
        else
            MEALIE_CLIENT_ID=$2
            MEALIE_CLIENT_SECRET=$3
        fi

        update_service "Mealie" "/opt/stacks/cooking/compose.yaml" "$MEALIE_CLIENT_ID" "$MEALIE_CLIENT_SECRET"
        restart_service "/opt/stacks/cooking" "Mealie"

        echo -e "${GREEN}🎉 Mealie OIDC integration complete!${NC}"
        echo ""
        echo "Test at: https://mealie.thehighestcommittee.com"
        echo "Look for 'Login with Pocket ID' button"
        ;;

    romm)
        echo -e "${YELLOW}Integrating RoMM${NC}"
        echo ""

        if [ -z "$2" ]; then
            echo "Enter RoMM Client ID:"
            read -r ROMM_CLIENT_ID
            echo "Enter RoMM Client Secret:"
            read -r ROMM_CLIENT_SECRET
        else
            ROMM_CLIENT_ID=$2
            ROMM_CLIENT_SECRET=$3
        fi

        update_service "RoMM" "/opt/stacks/emulators/compose.yaml" "$ROMM_CLIENT_ID" "$ROMM_CLIENT_SECRET"
        restart_service "/opt/stacks/emulators" "RoMM"

        echo -e "${GREEN}🎉 RoMM OIDC integration complete!${NC}"
        echo ""
        echo "Test at: https://romm.thehighestcommittee.com"
        ;;

    all)
        echo -e "${YELLOW}Complete Integration for All Services${NC}"
        echo ""
        echo "You'll need credentials for:"
        echo "  1. Mealie"
        echo "  2. RoMM"
        echo "  (Dockhand is configured via Web UI)"
        echo ""

        # Mealie
        echo -e "${BLUE}━━━ Mealie ━━━${NC}"
        echo "Enter Mealie Client ID:"
        read -r MEALIE_CLIENT_ID
        echo "Enter Mealie Client Secret:"
        read -r MEALIE_CLIENT_SECRET
        update_service "Mealie" "/opt/stacks/cooking/compose.yaml" "$MEALIE_CLIENT_ID" "$MEALIE_CLIENT_SECRET"
        restart_service "/opt/stacks/cooking" "Mealie"

        # RoMM
        echo -e "${BLUE}━━━ RoMM ━━━${NC}"
        echo "Enter RoMM Client ID:"
        read -r ROMM_CLIENT_ID
        echo "Enter RoMM Client Secret:"
        read -r ROMM_CLIENT_SECRET
        update_service "RoMM" "/opt/stacks/emulators/compose.yaml" "$ROMM_CLIENT_ID" "$ROMM_CLIENT_SECRET"
        restart_service "/opt/stacks/emulators" "RoMM"

        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}🎉 All integrations complete!${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo "Services integrated:"
        echo "  ✅ Mealie: https://mealie.thehighestcommittee.com"
        echo "  ✅ RoMM: https://romm.thehighestcommittee.com"
        echo ""
        echo "Still need to configure:"
        echo "  ⏳ Dockhand: https://dockhand.thehighestcommittee.com"
        echo "     (Configure via Settings → Authentication)"
        ;;

    *)
        echo -e "${YELLOW}Unknown service: $SERVICE${NC}"
        echo "Use: mealie, romm, or all"
        exit 1
        ;;
esac
