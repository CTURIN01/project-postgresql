-- bulk_seed.sql
-- Generates realistic volume test data for the fintech database.
-- Run AFTER schema.sql and seed.sql have already been applied.

-- ============================================================
-- 500 mock transactions across existing accounts
-- ============================================================
INSERT INTO transactions (account_id, amount, transaction_type, merchant, status, created_at)
SELECT
    (ARRAY[1,2,3,4,5])[floor(random() * 5 + 1)::int],
    round((random() * 9900 + 100)::numeric, 2),
    (ARRAY['deposit','withdrawal','transfer'])[floor(random() * 3 + 1)::int],
    (ARRAY['Amazon','Stripe','PayPal','Shopify','Square','Venmo','Wise','Plaid'])[floor(random() * 8 + 1)::int],
    (ARRAY['completed','pending','failed','flagged'])[floor(random() * 4 + 1)::int],
    NOW() - (random() * interval '90 days')
FROM generate_series(1, 500);

-- ============================================================
-- 50 mock fraud flags against random transactions
-- ============================================================
INSERT INTO fraud_flags (transaction_id, flag_reason, reviewed, flagged_at)
SELECT
    t.id,
    (ARRAY[
        'Unusual transaction amount',
        'Multiple transactions in short window',
        'Transaction from unrecognized location',
        'Account flagged for KYC review',
        'Velocity check failed'
    ])[floor(random() * 5 + 1)::int],
    (random() > 0.5),
    NOW() - (random() * interval '90 days')
FROM transactions t
ORDER BY random()
LIMIT 50;

-- ============================================================
-- Verification counts
-- ============================================================
SELECT 'users'         AS table_name, COUNT(*) AS row_count FROM users
UNION ALL
SELECT 'accounts',       COUNT(*) FROM accounts
UNION ALL
SELECT 'transactions',   COUNT(*) FROM transactions
UNION ALL
SELECT 'fraud_flags',    COUNT(*) FROM fraud_flags;
