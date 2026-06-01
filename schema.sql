-- Plaid Fintech Database Schema
-- Run: psql -U postgres -d your_database -f schema.sql

CREATE TABLE IF NOT EXISTS customers (
    customer_id   SERIAL PRIMARY KEY,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(100) NOT NULL UNIQUE,
    phone         VARCHAR(20),
    kyc_status    VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                  CHECK (kyc_status IN ('PENDING', 'VERIFIED', 'FAILED')),
    created_at    TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS accounts (
    account_id      SERIAL PRIMARY KEY,
    customer_id     INT NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    account_type    VARCHAR(20) NOT NULL
                    CHECK (account_type IN ('CHECKING', 'SAVINGS', 'CREDIT')),
    current_balance NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    currency        VARCHAR(3) NOT NULL DEFAULT 'USD',
    status          VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
                    CHECK (status IN ('ACTIVE', 'FROZEN', 'CLOSED')),
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS transactions (
    transaction_id   SERIAL PRIMARY KEY,
    account_id       INT NOT NULL REFERENCES accounts(account_id) ON DELETE CASCADE,
    amount           NUMERIC(12,2) NOT NULL,
    merchant_name    VARCHAR(100),
    category         VARCHAR(50),
    country          VARCHAR(3),
    status           VARCHAR(20) NOT NULL DEFAULT 'SETTLED'
                     CHECK (status IN ('SETTLED', 'PENDING', 'REVERSED')),
    transaction_time TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS fraud_flags (
    flag_id        SERIAL PRIMARY KEY,
    transaction_id INT NOT NULL REFERENCES transactions(transaction_id) ON DELETE CASCADE,
    reason         TEXT NOT NULL,
    status         VARCHAR(20) NOT NULL DEFAULT 'OPEN'
                   CHECK (status IN ('OPEN', 'REVIEWED', 'DISMISSED')),
    flagged_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_accounts_customer_id ON accounts(customer_id);
CREATE INDEX IF NOT EXISTS idx_transactions_account_id ON transactions(account_id);
CREATE INDEX IF NOT EXISTS idx_transactions_status ON transactions(status);
CREATE INDEX IF NOT EXISTS idx_fraud_flags_status ON fraud_flags(status);
CREATE INDEX IF NOT EXISTS idx_customers_kyc_status ON customers(kyc_status);
