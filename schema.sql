CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE,
    kyc_status VARCHAR(20) DEFAULT 'pending'
        CHECK (kyc_status IN ('pending', 'verified', 'rejected')),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    account_type VARCHAR(20) NOT NULL
        CHECK (account_type IN ('checking', 'savings', 'credit')),
    balance NUMERIC(15,2) DEFAULT 0.00,
    status VARCHAR(20) DEFAULT 'active'
        CHECK (status IN ('active', 'frozen', 'closed')),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE transactions (
    id SERIAL PRIMARY KEY,
    account_id INT NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    amount NUMERIC(15,2) NOT NULL,
    transaction_type VARCHAR(20) NOT NULL
        CHECK (transaction_type IN ('deposit', 'withdrawal', 'transfer')),
    merchant VARCHAR(150),
    status VARCHAR(20) DEFAULT 'completed'
        CHECK (status IN ('completed', 'pending', 'failed', 'flagged')),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE fraud_flags (
    id SERIAL PRIMARY KEY,
    transaction_id INT NOT NULL REFERENCES transactions(id) ON DELETE CASCADE,
    flag_reason VARCHAR(255) NOT NULL,
    reviewed BOOLEAN DEFAULT FALSE,
    flagged_at TIMESTAMP DEFAULT NOW()
);
