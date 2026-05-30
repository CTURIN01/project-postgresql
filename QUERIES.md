# PostgreSQL Sample Queries

## 1. Per-user balance summary
Summarize total balance per customer across all accounts.

```sql
SELECT
  c.customer_id,
  c.full_name,
  SUM(a.current_balance) AS total_balance
FROM customers c
JOIN accounts a ON a.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_balance DESC;
```

## 2. Recent high-value transactions
Show recent transactions above a configurable threshold.

```sql
SELECT
  t.transaction_id,
  t.account_id,
  t.amount,
  t.merchant_name,
  t.category,
  t.status,
  t.transaction_time
FROM transactions t
WHERE
  t.transaction_time >= NOW() - INTERVAL '7 days'
  AND t.amount >= 500
ORDER BY t.transaction_time DESC;
```

## 3. Simple fraud queue (rule-based)
Flag transactions that look suspicious based on amount and status.

```sql
SELECT
  t.transaction_id,
  t.account_id,
  t.amount,
  t.merchant_name,
  t.country,
  t.transaction_time,
  f.reason
FROM transactions t
JOIN fraud_flags f ON f.transaction_id = t.transaction_id
WHERE f.status = 'OPEN'
ORDER BY t.transaction_time DESC;
```

## 4. KYC verification breakdown
Count customers per KYC status.

```sql
SELECT
  kyc_status,
  COUNT(*) AS customer_count
FROM customers
GROUP BY kyc_status
ORDER BY customer_count DESC;
```

## 5. Daily volume by country
Help support answer "is this spike normal?" questions.

```sql
SELECT
  DATE(t.transaction_time) AS txn_date,
  t.country,
  COUNT(*) AS txn_count,
  SUM(t.amount) AS total_amount
FROM transactions t
GROUP BY DATE(t.transaction_time), t.country
ORDER BY txn_date DESC, total_amount DESC;
```
