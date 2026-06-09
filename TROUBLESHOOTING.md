# PostgreSQL Troubleshooting

## Connection Issues
### Could not connect to server
- Check whether the PostgreSQL container is running:
  - `docker ps`
- Verify the mapped port:
  - `docker compose ps`
- Confirm connection settings in `.env` or application config

### Authentication failed
- Re-check `POSTGRES_USER`, `POSTGRES_PASSWORD`, and `POSTGRES_DB`
- Test login manually:
  - `psql -h localhost -U postgres -d your_database`

## Database Inspection
### List tables
- `\dt`

### Describe a table
- `\d table_name`

### Count rows
- `SELECT COUNT(*) FROM table_name;`

## Backup and Restore
### Create backup
- `pg_dump -U postgres -d your_database > backup.sql`

### Restore backup
- `psql -U postgres -d your_database < backup.sql`

## Common Debugging Queries
### Find duplicate values
```sql
SELECT column_name, COUNT(*)
FROM table_name
GROUP BY column_name
HAVING COUNT(*) > 1;
```

### Check recent records
```sql
SELECT *
FROM table_name
ORDER BY id DESC
LIMIT 10;
```

### Verify null-heavy columns
```sql
SELECT
  COUNT(*) AS total_rows,
  COUNT(column_name) AS non_null_rows
FROM table_name;
```

## Docker Notes
- Restart database container:
  - `docker compose restart db`
- Rebuild from scratch:
  - `docker compose down -v`
  - `docker compose up --build`

## Follow-Up
- Add query performance notes
- Add indexing examples
- Add EXPLAIN / EXPLAIN ANALYZE examples

## Common Auth Errors
- KYC PENDING: customer not yet verified, block transaction access
- KYC FAILED: escalate to compliance team
- Token expired: re-run Link flow, exchange new public_token
