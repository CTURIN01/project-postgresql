#!/bin/bash
set -e

if [ -z "$1" ]; then
  echo "Usage: bash restore.sh <backup_file>"
  exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
  echo "Error: File $BACKUP_FILE not found"
  exit 1
fi

echo "Restoring from $BACKUP_FILE..."

docker exec -i postgres_db psql \
  -U appuser \
  -d appdb \
  < "$BACKUP_FILE"

echo "Restore complete."
