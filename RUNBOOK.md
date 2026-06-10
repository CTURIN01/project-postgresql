# PostgreSQL Fintech Stack — Operational Runbook

This runbook covers how to bring up the PostgreSQL stack from zero, load the schema and seed data, run analytical queries, and perform a backup and restore. It mirrors the kind of documentation a support or DevOps engineer would maintain for a containerized database service.

---

## Prerequisites

- Docker Desktop installed and running
- Git Bash (Windows) or terminal (Linux/macOS)
- Repo cloned locally:

```bash
git clone https://github.com/CTURIN01/project-postgresql.git
cd project-postgresql
```

---

## 1. Start the Stack

```bash
docker-compose up -d
```

Expected output:

```text
✔ Container postgres_db   Started
✔ Container pgadmin       Started
```

Verify containers are running:

```bash
docker ps
```

You should see `postgres_db` and `pgadmin` listed as `Up`.

---

## 2. Load Schema and Seed Data

Copy SQL files into the running container (required on Windows with Git Bash due to path conversion):

```bash
MSYS_NO_PATHCONV=1 docker cp schema.sql postgres_db:/schema.sql
MSYS_NO_PATHCONV=1 docker cp seed.sql postgres_db:/seed.sql
MSYS_NO_PATHCONV=1 docker cp queries/analysis.sql postgres_db:/analysis.sql
```

Apply schema:

```bash
MSYS_NO_PATHCONV=1 docker exec -it postgres_db psql -U appuser -d appdb -f /schema.sql
```

Load seed data:

```bash
MSYS_NO_PATHCONV=1 docker exec -it postgres_db psql -U appuser -d appdb -f /seed.sql
```

---

## 3. Verify Tables and Row Counts

Connect to the database:

```bash
docker exec -it postgres_db psql -U appuser -d appdb
```

Then inside psql run each query one at a time:

```sql
\dt
```

```sql
SELECT COUNT(*) FROM users;
```

```sql
SELECT COUNT(*) FROM accounts;
```

```sql
SELECT COUNT(*) FROM transactions;
```

```sql
SELECT COUNT(*) FROM fraud_flags;
```

Expected results:

| Table | Expected Rows |
|-------|---------------|
| users | 4 |
| accounts | 5 |
| transactions | 5 |
| fraud_flags | 2 |

---

## 4. Run Analytical Queries

```bash
MSYS_NO_PATHCONV=1 docker exec -it postgres_db psql -U appuser -d appdb -f /analysis.sql
```

Queries included:

- KYC status breakdown
- Flagged transactions with user context
- Account balance summary per user
- High-value transaction report (> $1,000)
- Fraud review queue (unreviewed flags older than 24 hours)

---

## 5. Backup the Database

Run a manual pg_dump backup:

```bash
docker exec -it postgres_db bash -c "pg_dump -U appuser appdb > /tmp/backup_$(date +%Y%m%d_%H%M%S).sql"
```

Copy the backup file to your host machine:

```bash
MSYS_NO_PATHCONV=1 docker cp postgres_db:/tmp/backup_$(date +%Y%m%d).sql ./backups/
```

---

## 6. Restore from Backup

```bash
MSYS_NO_PATHCONV=1 docker cp backups/<backup_filename>.sql postgres_db:/restore.sql
MSYS_NO_PATHCONV=1 docker exec -it postgres_db psql -U appuser -d appdb -f /restore.sql
```

---

## 7. Tear Down and Rebuild from Scratch

To stop containers and remove all data (full reset):

```bash
docker-compose down -v
```

Then restart and re-apply schema and seed from Step 1.

---

## 8. Access pgAdmin (Optional)

pgAdmin is available in a browser at:
http://localhost:5050Login with credentials from your `.env` file (default: `admin@example.com` / `changeme`).

Add a new server connection:

- Host: `postgres_db`
- Port: `5432`
- Database: `appdb`
- Username: `appuser`
- Password: `apppassword`

---

## Quick Reference

| Task | Command |
|------|---------|
| Start stack | `docker-compose up -d` |
| Stop stack | `docker-compose down` |
| Full reset | `docker-compose down -v` |
| Connect to psql | `docker exec -it postgres_db psql -U appuser -d appdb` |
| Run schema | `MSYS_NO_PATHCONV=1 docker exec -it postgres_db psql -U appuser -d appdb -f /schema.sql` |
| Run seed | `MSYS_NO_PATHCONV=1 docker exec -it postgres_db psql -U appuser -d appdb -f /seed.sql` |
| Run queries | `MSYS_NO_PATHCONV=1 docker exec -it postgres_db psql -U appuser -d appdb -f /analysis.sql` |
| Backup | `docker exec -it postgres_db bash -c "pg_dump -U appuser appdb > /tmp/backup.sql"` |


---

## 9. Load Bulk Test Data (500+ Transactions)

After running the base seed, optionally load the bulk seed script to generate realistic data volume for testing analytical queries:

```bash
MSYS_NO_PATHCONV=1 docker cp scripts/bulk_seed.sql postgres_db:/bulk_seed.sql
MSYS_NO_PATHCONV=1 docker exec -it postgres_db psql -U appuser -d appdb -f /bulk_seed.sql
```

This inserts:
- 500 mock transactions across all accounts (debit, credit, transfer; completed, pending, failed)
- 50 fraud flags with realistic reasons against random transactions
- A verification query that prints final row counts for all four tables


## Fraud Review SLA
- All OPEN fraud flags must be reviewed within 24 hours
- Query fraud_flags WHERE reviewed = FALSE AND flagged_at < NOW() - INTERVAL '24 hours'
- Escalate any flag open > 48 hours to compliance team
