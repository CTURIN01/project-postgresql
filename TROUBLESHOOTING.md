# PostgreSQL Docker Troubleshooting Guide

This project is designed to run PostgreSQL in Docker for local development. On Windows (especially Git Bash), there are a few common pitfalls that can block you from running schema and seed scripts. This guide documents fixes for those issues.

---

## 1. Git Bash path conversion (MSYS_NO_PATHCONV)

**Symptom**

Running a command like:

```bash
docker exec -it postgres_db psql -U appuser -d appdb -f /schema.sql
```

fails with an error similar to:

```text
psql: error: C:/Program Files/Git/schema.sql: No such file or directory
```

**Cause**

Git Bash automatically rewrites Unix-style paths (like `/schema.sql`) into Windows-style paths (like `C:/Program Files/Git/schema.sql`) before they reach Docker, so `psql` inside the container cannot see the file.

**Fix**

Disable path conversion for the command by prefixing it with `MSYS_NO_PATHCONV=1`, then copy the files into the container and execute them there:

```bash
# Copy SQL files into the running container
MSYS_NO_PATHCONV=1 docker cp schema.sql postgres_db:/schema.sql
MSYS_NO_PATHCONV=1 docker cp seed.sql postgres_db:/seed.sql
MSYS_NO_PATHCONV=1 docker cp queries/analysis.sql postgres_db:/analysis.sql

# Run schema, seed, and analysis scripts from inside the container
MSYS_NO_PATHCONV=1 docker exec -it postgres_db psql -U appuser -d appdb -f /schema.sql
MSYS_NO_PATHCONV=1 docker exec -it postgres_db psql -U appuser -d appdb -f /seed.sql
MSYS_NO_PATHCONV=1 docker exec -it postgres_db psql -U appuser -d appdb -f /analysis.sql
```

If you prefer running scripts interactively, you can also:

```bash
docker exec -it postgres_db psql -U appuser -d appdb
```

Then inside `psql`:

```sql
\i /schema.sql
\i /seed.sql
\i /analysis.sql
```

---

## 2. Role or database does not exist

**Symptom**

Errors like:

```text
FATAL:  role "admin" does not exist
FATAL:  database "appuser" does not exist
```

**Cause**

PostgreSQL defaults to using the current OS user and a database with the same name as the user if `-U` or `-d` are omitted. In this project, the credentials are controlled via `docker-compose.yml` environment variables:

```yaml
environment:
  POSTGRES_DB: appdb
  POSTGRES_USER: appuser
  POSTGRES_PASSWORD: apppassword
```

**Fix**

Always connect using the configured user and database:

```bash
docker exec -it postgres_db psql -U appuser -d appdb
```

If you change `POSTGRES_USER` or `POSTGRES_DB` in `docker-compose.yml`, update your commands to match.

---

## 3. "relation already exists" when re-running schema

**Symptom**

Re-running `schema.sql` produces:

```text
ERROR:  relation "users" already exists
```

**Cause**

The tables were already created in a previous run. The `CREATE TABLE` commands in `schema.sql` are not `CREATE TABLE IF NOT EXISTS`.

**Options**

- **Option A – Safe to ignore:** if the tables already exist and you just want to re-run seed or queries, you can ignore this error and proceed with:

  ```bash
  MSYS_NO_PATHCONV=1 docker exec -it postgres_db psql -U appuser -d appdb -f /seed.sql
  MSYS_NO_PATHCONV=1 docker exec -it postgres_db psql -U appuser -d appdb -f /analysis.sql
  ```

- **Option B – Recreate database from scratch:** if you want a clean database (this deletes all data):

  ```bash
  docker-compose down -v   # stops containers and removes the postgres volume
  docker-compose up -d     # recreates containers and data directory

  # Then reapply schema and seed:
  MSYS_NO_PATHCONV=1 docker cp schema.sql postgres_db:/schema.sql
  MSYS_NO_PATHCONV=1 docker cp seed.sql postgres_db:/seed.sql
  MSYS_NO_PATHCONV=1 docker exec -it postgres_db psql -U appuser -d appdb -f /schema.sql
  MSYS_NO_PATHCONV=1 docker exec -it postgres_db psql -U appuser -d appdb -f /seed.sql
  ```

---

## 4. Quick verification queries

Once schema and seed have run successfully, connect:

```bash
docker exec -it postgres_db psql -U appuser -d appdb
```

Then in `psql`, verify tables and row counts:

```sql
\dt

SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM accounts;
SELECT COUNT(*) FROM transactions;
SELECT COUNT(*) FROM fraud_flags;
```

You should see the four tables and non-zero row counts for each.

---

Keeping this file up to date turns this repo into a mini runbook for Dockerized PostgreSQL on Windows and makes it easier for others (and future you) to get the stack running quickly.
