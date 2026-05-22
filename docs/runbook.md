# PostgreSQL Operational Runbook

## Start the stack
docker-compose up -d

## Stop the stack
docker-compose down

## Connect to the database
docker exec -it postgres_db psql -U appuser -d appdb

## Run a backup
bash scripts/backup.sh

## Restore from backup
bash scripts/restore.sh backups/backup_YYYYMMDD_HHMMSS.sql

## View logs
docker-compose logs -f postgres

## Common issues

### Connection refused
- Check container is running: docker ps
- Verify port 5432 is not already in use

### Password authentication failed
- Check POSTGRES_USER and POSTGRES_PASSWORD in docker-compose.yml
- Match values in your .env or connection string

### Init SQL not running
- Only runs on first startup when volume is empty
- To re-run: docker-compose down -v then docker-compose up -d
