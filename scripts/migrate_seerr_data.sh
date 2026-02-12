#!/bin/bash
# Migrate data from Overseerr SQLite to Postgres (seerr-db)
# Properly handles camelCase columns and NaN timestamps

set -e

SQLITE_DB="/opt/stacks/arrstack/appdata/overseerr/config/db/db.sqlite3.migration_source"
PG_HOST="192.168.0.12"
PG_USER="postgres"
PG_PASS="postgres"
PG_DB="seerr-db"
TMPDIR="/tmp/seerr-migration"

export PGPASSWORD="$PG_PASS"

mkdir -p "$TMPDIR"

# Get tables from Postgres (excluding migrations)
PG_TABLES=$(psql -h "$PG_HOST" -U "$PG_USER" -d "$PG_DB" -t -c \
  "SELECT tablename FROM pg_tables WHERE schemaname='public' AND tablename != 'migrations' ORDER BY tablename;" \
  | tr -d ' ' | grep -v '^$')

echo "Tables to migrate: $PG_TABLES"
echo ""

# Disable FK constraints
echo "Disabling triggers..."
for table in $PG_TABLES; do
    psql -h "$PG_HOST" -U "$PG_USER" -d "$PG_DB" -c "ALTER TABLE \"$table\" DISABLE TRIGGER ALL;" 2>/dev/null || true
done

for table in $PG_TABLES; do
    echo "--- Processing table: $table ---"
    
    # Get Postgres column info (name and type)
    PG_COL_INFO=$(psql -h "$PG_HOST" -U "$PG_USER" -d "$PG_DB" -t -c \
      "SELECT column_name || '|' || data_type FROM information_schema.columns 
       WHERE table_schema='public' AND table_name='$table' ORDER BY ordinal_position;" \
      | tr -d ' ' | grep -v '^$')
    
    if [ -z "$PG_COL_INFO" ]; then
        echo "  No columns found, skipping"
        continue
    fi
    
    # Check if SQLite table exists
    SQLITE_HAS=$(sqlite3 "$SQLITE_DB" "SELECT count(*) FROM sqlite_master WHERE type='table' AND name='$table';")
    if [ "$SQLITE_HAS" = "0" ]; then
        echo "  Table not in SQLite, skipping"
        continue
    fi
    
    # Get SQLite column names
    SQLITE_COLS=$(sqlite3 "$SQLITE_DB" "PRAGMA table_info('$table');" | cut -d'|' -f2)
    
    # Build column list and SELECT expression (handling NaN timestamps)
    COMMON_COLS=""
    SELECT_EXPR=""
    for col_info in $PG_COL_INFO; do
        pg_col=$(echo "$col_info" | cut -d'|' -f1)
        pg_type=$(echo "$col_info" | cut -d'|' -f2)
        
        # Check if column exists in SQLite
        found=0
        for sq_col in $SQLITE_COLS; do
            if [ "$pg_col" = "$sq_col" ]; then
                found=1
                break
            fi
        done
        
        if [ "$found" = "1" ]; then
            if [ -z "$COMMON_COLS" ]; then
                COMMON_COLS="\"$pg_col\""
            else
                COMMON_COLS="$COMMON_COLS, \"$pg_col\""
            fi
            
            # For timestamp/date columns, replace NaN values with NULL
            if echo "$pg_type" | grep -qiE "timestamp|date"; then
                if [ -z "$SELECT_EXPR" ]; then
                    SELECT_EXPR="CASE WHEN \"$pg_col\" LIKE '%NaN%' OR \"$pg_col\" = '' THEN NULL ELSE \"$pg_col\" END"
                else
                    SELECT_EXPR="$SELECT_EXPR, CASE WHEN \"$pg_col\" LIKE '%NaN%' OR \"$pg_col\" = '' THEN NULL ELSE \"$pg_col\" END"
                fi
            else
                if [ -z "$SELECT_EXPR" ]; then
                    SELECT_EXPR="\"$pg_col\""
                else
                    SELECT_EXPR="$SELECT_EXPR, \"$pg_col\""
                fi
            fi
        fi
    done
    
    if [ -z "$COMMON_COLS" ]; then
        echo "  No common columns found, skipping"
        continue
    fi
    
    # Count rows
    ROW_COUNT=$(sqlite3 "$SQLITE_DB" "SELECT count(*) FROM \"$table\";")
    echo "  Rows to migrate: $ROW_COUNT"
    
    if [ "$ROW_COUNT" = "0" ]; then
        echo "  No data, skipping"
        continue
    fi
    
    # Export from SQLite to CSV with NaN handling  
    CSV_FILE="$TMPDIR/${table}.csv"
    sqlite3 "$SQLITE_DB" <<SQLEOF
.headers off
.mode csv
.nullvalue \\N
.output $CSV_FILE
SELECT $SELECT_EXPR FROM "$table";
SQLEOF
    
    # Post-process: replace literal NaN strings in CSV
    sed -i 's/0NaN-aN-aN aN:aN:aN\.NaN/\\N/g' "$CSV_FILE"
    sed -i 's/"0NaN-aN-aN aN:aN:aN\.NaN"/\\N/g' "$CSV_FILE"
    
    # Truncate and import
    psql -h "$PG_HOST" -U "$PG_USER" -d "$PG_DB" -c "TRUNCATE TABLE \"$table\" CASCADE;" 2>/dev/null || true
    psql -h "$PG_HOST" -U "$PG_USER" -d "$PG_DB" -c "\copy \"$table\"($COMMON_COLS) FROM '$CSV_FILE' WITH (FORMAT csv, NULL '\\N');"
    
    echo "  Done: $ROW_COUNT rows imported"
done

# Re-enable triggers
echo ""
echo "Re-enabling triggers..."
for table in $PG_TABLES; do
    psql -h "$PG_HOST" -U "$PG_USER" -d "$PG_DB" -c "ALTER TABLE \"$table\" ENABLE TRIGGER ALL;" 2>/dev/null || true
done

# Reset sequences
echo "Resetting sequences..."
psql -h "$PG_HOST" -U "$PG_USER" -d "$PG_DB" <<'SEQEOF'
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT c.relname as seq_name, t.relname as table_name, a.attname as col_name
              FROM pg_class c
              JOIN pg_depend d ON d.objid = c.oid
              JOIN pg_class t ON t.oid = d.refobjid
              JOIN pg_attribute a ON a.attrelid = t.oid AND a.attnum = d.refobjsubid
              WHERE c.relkind = 'S')
    LOOP
        EXECUTE format('SELECT setval(''%I'', COALESCE((SELECT MAX("%s") FROM "%s"), 1))', r.seq_name, r.col_name, r.table_name);
    END LOOP;
END;
$$;
SEQEOF

echo ""
echo "Migration complete!"
rm -rf "$TMPDIR"
