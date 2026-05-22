#!/bin/bash
set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.sql"

mkdir -p "$BACKUP_DIR"

echo "Starting backup at $TIMESTAMP..."

docker exec postgres_db pg_dump \
  -U appuser \
  -d appdb \
  > "$BACKUP_FILE"

echo "Backup saved to $BACKUP_FILE"
