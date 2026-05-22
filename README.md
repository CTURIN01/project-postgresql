# Project: PostgreSQL + Docker + Backup Automation

A DevOps portfolio project demonstrating a production-style PostgreSQL setup
using Docker Compose, automated backup and restore scripts, pgAdmin for
database management, and GitHub Actions for config validation.

## What this project demonstrates

- PostgreSQL running in Docker with persistent volumes
- pgAdmin web UI for database management
- Real relational schema with users, products, and orders tables
- Automated pg_dump backup script with timestamped files
- Restore script with input validation
- GitHub Actions validating docker-compose and SQL on every push

## Quick start

Start the stack:
docker-compose up -d

Access pgAdmin at http://localhost:5050
- Email: admin@admin.com
- Password: admin

Connect pgAdmin to Postgres:
- Host: postgres
- Port: 5432
- Database: appdb
- Username: appuser
- Password: apppassword

## Backup and restore

Run a backup:
bash scripts/backup.sh

Restore from backup:
bash scripts/restore.sh backups/backup_YYYYMMDD_HHMMSS.sql

## Repository structure

- docker-compose.yml — Postgres and pgAdmin services
- schema/init.sql — table definitions and seed data
- scripts/backup.sh — automated pg_dump backup
- scripts/restore.sh — restore from backup file
- docs/runbook.md — operational notes and common issues
- .github/workflows/validate.yml — CI validation pipeline
