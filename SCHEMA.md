# Database Schema

## customers
Stores core customer identity and KYC verification status.

| Column        | Type         | Notes                          |
|---------------|--------------|--------------------------------|
| customer_id   | SERIAL PK    | Auto-incrementing primary key  |
| full_name     | VARCHAR(100) | Customer full name             |
| email         | VARCHAR(100) | Unique, not null               |
| phone         | VARCHAR(20)  |                                |
| kyc_status    | VARCHAR(20)  | PENDING, VERIFIED, FAILED      |
| created_at    | TIMESTAMP    | Defaults to NOW()              |

## accounts
Each customer can have multiple accounts (checking, savings, etc.).

| Column          | Type          | Notes                          |
|-----------------|---------------|--------------------------------|
| account_id      | SERIAL PK     |                                |
| customer_id     | INT FK        | References customers           |
| account_type    | VARCHAR(20)   | CHECKING, SAVINGS, CREDIT      |
| current_balance | NUMERIC(12,2) | Current account balance        |
| currency        | VARCHAR(3)    | USD, EUR, etc.                 |
| status          | VARCHAR(20)   | ACTIVE, FROZEN, CLOSED         |
| created_at      | TIMESTAMP     | Defaults to NOW()              |

## transactions
Individual debit/credit events linked to an account.

| Column           | Type          | Notes                          |
|------------------|---------------|--------------------------------|
| transaction_id   | SERIAL PK     |                                |
| account_id       | INT FK        | References accounts            |
| amount           | NUMERIC(12,2) | Positive = credit, negative = debit |
| merchant_name    | VARCHAR(100)  |                                |
| category         | VARCHAR(50)   | e.g. Food, Travel, Transfer    |
| country          | VARCHAR(3)    | ISO country code               |
| status           | VARCHAR(20)   | SETTLED, PENDING, REVERSED     |
| transaction_time | TIMESTAMP     | When transaction occurred      |

## fraud_flags
Flags suspicious transactions for review.

| Column         | Type        | Notes                          |
|----------------|-------------|--------------------------------|
| flag_id        | SERIAL PK   |                                |
| transaction_id | INT FK      | References transactions        |
| reason         | TEXT        | Description of fraud signal    |
| status         | VARCHAR(20) | OPEN, REVIEWED, DISMISSED      |
| flagged_at     | TIMESTAMP   | Defaults to NOW()              |
