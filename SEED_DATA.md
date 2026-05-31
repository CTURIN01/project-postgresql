# Seed Data

## Overview
The database is seeded with realistic mock data using PostgreSQL's built-in
`generate_series()` function. No external libraries or scripts required —
all data is generated inside SQL.

---

## Customers
500 customers with randomized names, emails, and KYC statuses.

```sql
INSERT INTO customers (full_name, email, phone, kyc_status)
SELECT
  'Customer ' || i,
  'customer' || i || '@example.com',
  '555-' || LPAD(i::TEXT, 7, '0'),
  (ARRAY['PENDING', 'VERIFIED', 'FAILED'])[FLOOR(RANDOM() * 3 + 1)]
FROM generate_series(1, 500) AS s(i);
```

---

## Accounts
One or two accounts per customer, randomized account type and balance.

```sql
INSERT INTO accounts (customer_id, account_type, current_balance, currency, status)
SELECT
  (RANDOM() * 499 + 1)::INT,
  (ARRAY['CHECKING', 'SAVINGS', 'CREDIT'])[FLOOR(RANDOM() * 3 + 1)],
  ROUND((RANDOM() * 9000 + 100)::NUMERIC, 2),
  'USD',
  (ARRAY['ACTIVE', 'FROZEN', 'CLOSED'])[FLOOR(RANDOM() * 3 + 1)]
FROM generate_series(1, 750) AS s(i);
```

---

## Transactions
500 transactions across accounts, spread over the last 90 days.

```sql
INSERT INTO transactions (account_id, amount, merchant_name, category, country, status, transaction_time)
SELECT
  (RANDOM() * 749 + 1)::INT,
  ROUND((RANDOM() * 1000 - 100)::NUMERIC, 2),
  (ARRAY['Starbucks', 'Amazon', 'Uber', 'Walmart', 'Netflix', 'Apple', 'Target'])[FLOOR(RANDOM() * 7 + 1)],
  (ARRAY['Food', 'Shopping', 'Transport', 'Entertainment', 'Transfer'])[FLOOR(RANDOM() * 5 + 1)],
  (ARRAY['USA', 'GBR', 'CAN', 'DEU', 'FRA'])[FLOOR(RANDOM() * 5 + 1)],
  (ARRAY['SETTLED', 'PENDING', 'REVERSED'])[FLOOR(RANDOM() * 3 + 1)],
  NOW() - (RANDOM() * INTERVAL '90 days')
FROM generate_series(1, 500) AS s(i);
```

---

## Fraud Flags
~10% of transactions flagged with randomized fraud reasons.

```sql
INSERT INTO fraud_flags (transaction_id, reason, status)
SELECT
  transaction_id,
  (ARRAY[
    'Unusual country for account',
    'High-value transaction above threshold',
    'Multiple transactions in short window',
    'Merchant category mismatch'
  ])[FLOOR(RANDOM() * 4 + 1)],
  (ARRAY['OPEN', 'REVIEWED', 'DISMISSED'])[FLOOR(RANDOM() * 3 + 1)]
FROM transactions
WHERE RANDOM() < 0.10;
```

---

## Notes
- All data is synthetic — no real PII.
- Re-seed at any time by truncating tables and re-running the above blocks.
- `generate_series()` is a PostgreSQL set-returning function that avoids
  application-level loops entirely.
