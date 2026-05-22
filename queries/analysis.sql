-- 1. KYC status breakdown
--    How many users are pending, verified, or rejected.
SELECT kyc_status, COUNT(*) AS user_count
FROM users
GROUP BY kyc_status
ORDER BY user_count DESC;

-- 2. Flagged transactions with user context
--    Used when a customer reports a frozen/flagged transaction.
SELECT
    u.username,
    u.email,
    a.id AS account_id,
    t.id AS transaction_id,
    t.amount,
    t.merchant,
    t.status,
    f.flag_reason,
    f.flagged_at
FROM fraud_flags f
JOIN transactions t ON f.transaction_id = t.id
JOIN accounts a ON t.account_id = a.id
JOIN users u ON a.user_id = u.id
WHERE f.reviewed = FALSE
ORDER BY f.flagged_at DESC;

-- 3. Account balance summary per user
--    Snapshot of total balance and account mix per customer.
SELECT
    u.username,
    u.kyc_status,
    COUNT(a.id) AS total_accounts,
    SUM(a.balance) AS net_balance
FROM users u
JOIN accounts a ON u.id = a.user_id
GROUP BY u.username, u.kyc_status
ORDER BY net_balance DESC;

-- 4. High-value transaction report (> 1,000)
--    For risk review and manual QA.
SELECT
    t.id AS transaction_id,
    u.username,
    a.id AS account_id,
    t.amount,
    t.transaction_type,
    t.merchant,
    t.status,
    t.created_at
FROM transactions t
JOIN accounts a ON t.account_id = a.id
JOIN users u ON a.user_id = u.id
WHERE t.amount > 1000
ORDER BY t.amount DESC;

-- 5. Fraud review queue — unreviewed flags older than 24 hours
--    Simulates an SLA for fraud/compliance review.
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
