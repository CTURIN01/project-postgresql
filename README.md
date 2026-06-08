# PostgreSQL Fintech Database

A production-style PostgreSQL database simulating the core data layer of a fintech platform — including user identity/KYC management, multi-type account tracking, transaction processing, and automated fraud flagging. Built to mirror real-world financial data workflows used in compliance, fraud operations, and customer support engineering.

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue?logo=postgresql)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker)
![GitHub Actions](https://img.shields.io/badge/CI-GitHub%20Actions-2088FF?logo=githubactions)
![Bash](https://img.shields.io/badge/Automation-Bash-4EAA25?logo=gnubash)

---

## Overview

This project demonstrates database engineering fundamentals applied to a realistic fintech use case:

- Normalized relational schema with foreign key constraints and status lifecycle enforcement
- Seed data simulating verified, pending, and rejected KYC users with associated accounts and transactions
- Analytical SQL queries that mirror real support and compliance workflows (fraud review, KYC audits, balance reporting)
- Automated `pg_dump` backup system with timestamped restore files
- Containerized local environment via Docker Compose
- GitHub Actions CI pipeline validating stack integrity on every push

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| PostgreSQL 15 | Relational database engine |
| Docker Compose | Containerized local dev environment |
| Bash | Backup automation and restore scripts |
| GitHub Actions | CI validation on push |

---

## Schema

Four tables modeling a fintech platform's core identity and transaction data:
users
└── accounts (1:many)
└── transactions (1:many)
└── fraud_flags (1:1)

text

### Table Reference

| Table | Description |
|-------|-------------|
| `users` | Customer records with KYC verification status (`pending`, `verified`, `rejected`) |
| `accounts` | Multi-type accounts (`checking`, `savings`, `credit`) with balance and lifecycle status |
| `transactions` | Full transaction history with type, merchant, and status (`completed`, `pending`, `failed`, `flagged`) |
| `fraud_flags` | Compliance review queue for flagged transactions, with reason and review state |

### Entity Relationships

```sql
users (1) ──── (many) accounts
accounts (1) ──── (many) transactions
transactions (1) ──── (0..1) fraud_flags
```

---

## Analytical Queries

Located in `queries/analysis.sql`. These queries simulate the kind of investigative SQL a Technical Support or Fraud Operations engineer would run when handling a customer escalation.

| Query | Use Case |
|-------|---------|
| KYC Status Breakdown | Audit how many users are verified vs. pending vs. rejected |
| Flagged Transactions w/ User Context | Surface open fraud flags with full customer and account detail |
| Account Balance Summary | Net balance per user across all account types |
| High-Value Transaction Report | All transactions over $1,000 for risk review |
| Fraud Review Queue (24h+) | Unreviewed flags open longer than 24 hours — SLA breach detection |

**Example — Fraud Review Queue:**
```sql
SELECT
    f.id AS flag_id,
    u.username,
    t.amount,
    f.flag_reason,
    f.flagged_at,
    NOW() - f.flagged_at AS time_open
FROM fraud_flags f
JOIN transactions t ON f.transaction_id = t.id
JOIN accounts a ON t.account_id = a.id
JOIN users u ON a.user_id = u.id
WHERE f.reviewed = FALSE
  AND f.flagged_at < NOW() - INTERVAL '24 hours'
ORDER BY f.flagged_at ASC;
```

---

## Backup Automation

`backup.sh` automates `pg_dump` to produce timestamped `.sql` backup files — simulating a production DBA backup workflow:

```bash
bash backup.sh
# Output: /backups/backup_20260522_013045.sql
```

Backups are named by UTC timestamp for auditability and can be restored with:

```bash
psql -U admin -d fintechdb < /backups/backup_<timestamp>.sql
```

---

## CI Pipeline

GitHub Actions (`validate.yml`) runs on every push to `main`:

- Spins up a PostgreSQL 15 service container
- Applies `schema.sql` to validate DDL syntax
- Validates Docker Compose configuration

---

## How to Run Locally

**Prerequisites:** Docker Desktop installed and running

```bash
# 1. Clone the repo
git clone https://github.com/CTURIN01/project-postgresql.git
cd project-postgresql

# 2. Start the PostgreSQL container
docker-compose up -d

# 3. Load schema
docker exec -it postgres_db psql -U admin -d fintechdb -f /docker-entrypoint-initdb.d/schema.sql

# 4. Seed sample data
docker exec -it postgres_db psql -U admin -d fintechdb -f /docker-entrypoint-initdb.d/seed.sql

# 5. Connect and run queries
docker exec -it postgres_db psql -U admin -d fintechdb
\i /queries/analysis.sql
```

---

## Project Structure
project-postgresql/
├── docker-compose.yml # PostgreSQL 15 service definition
├── schema.sql # DDL — table definitions with constraints
├── seed.sql # Sample fintech data (users, accounts, transactions, flags)
├── backup.sh # pg_dump backup automation script
├── queries/
│ └── analysis.sql # Analytical queries for fraud, KYC, and reporting
└── .github/
└── workflows/
└── validate.yml # GitHub Actions CI pipeline

text

---

## Key Concepts Demonstrated

- Relational data modeling with referential integrity (FK constraints, CASCADE)
- Data lifecycle management with status fields and CHECK constraints
- Analytical SQL with multi-table JOINs, GROUP BY, and time-based filtering
- Operational automation with timestamped backups and restore workflow
- Containerization via Docker Compose and CI validation on GitHub Actions

---

## Author

**Chris Turin**  
[GitHub](https://github.com/CTURIN01) • [LinkedIn](https://linkedin.com/in/christurin)

---

## Troubleshooting

### Git Bash path conversion on Windows
If `docker exec ... -f /schema.sql` turns into a `C:/Program Files/Git/...` error, disable Git Bash path conversion for that command:

```bash
MSYS_NO_PATHCONV=1 docker cp schema.sql postgres_db:/schema.sql
MSYS_NO_PATHCONV=1 docker cp seed.sql postgres_db:/seed.sql
MSYS_NO_PATHCONV=1 docker cp queries/analysis.sql postgres_db:/analysis.sql

MSYS_NO_PATHCONV=1 docker exec -it postgres_db psql -U appuser -d appdb -f /schema.sql
MSYS_NO_PATHCONV=1 docker exec -it postgres_db psql -U appuser -d appdb -f /seed.sql
MSYS_NO_PATHCONV=1 docker exec -it postgres_db psql -U appuser -d appdb -f /analysis.sql
```

### Common PostgreSQL connection issues
- If `role "admin" does not exist`, check `POSTGRES_USER` in `docker-compose.yml`.
- If `database "appuser" does not exist`, specify the database explicitly with `-d appdb`.
- If tables already exist, PostgreSQL may have partially loaded the schema in a previous run.

# cleanup
