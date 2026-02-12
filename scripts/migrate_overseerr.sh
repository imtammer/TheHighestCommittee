#!/bin/bash
# Migrate Overseerr SQLite to Postgres
# Run this AFTER rebooting the host

SOURCE_DB="/opt/stacks/arrstack/appdata/overseerr/config/db/db.sqlite3.migration_source"
CONFIG_DIR="/opt/stacks/arrstack/appdata/overseerr/config/db"
PGLOADER_SCRIPT="$CONFIG_DIR/pgloader.load"

# Ensure source exists
if [ ! -f "$SOURCE_DB" ]; then
    echo "Source DB not found at $SOURCE_DB"
    exit 1
fi

# Create pgloader script
echo "Creating pgloader script..."
cat > "$PGLOADER_SCRIPT" <<EOF
load database
     from sqlite:///data/db.sqlite3.migration_source
     into postgresql://postgres:postgres@192.168.0.12/seerr-db

 with data only, reset sequences

 set work_mem to '16MB', maintenance_work_mem to '512 MB';
EOF

echo "Ensuring Overseerr is stopped..."
docker compose -f /opt/stacks/arrstack/compose.yaml stop overseerr

echo "Running migration (this may take a minute)..."
# We mount the db directory to /data, so file is at /data/db.sqlite3.migration_source
docker run --rm -v "$CONFIG_DIR":/data --network host dimitri/pgloader pgloader /data/pgloader.load

echo "Starting Overseerr..."
docker compose -f /opt/stacks/arrstack/compose.yaml up -d overseerr

echo "Done! Check logs with 'docker logs overseerr'"
