INSERT INTO users (username, email, kyc_status) VALUES
('alice_m', 'alice@example.com', 'verified'),
('bob_k', 'bob@example.com', 'pending'),
('carol_t', 'carol@example.com', 'verified'),
('dan_r', 'dan@example.com', 'rejected');

INSERT INTO accounts (user_id, account_type, balance, status) VALUES
(1, 'checking', 5200.00, 'active'),
(1, 'savings', 18000.00, 'active'),
(2, 'checking', 300.00, 'active'),
(3, 'credit', -750.00, 'frozen'),
(4, 'checking', 0.00, 'closed');

INSERT INTO transactions (account_id, amount, transaction_type, merchant, status) VALUES
(1, 200.00, 'deposit', 'ACH Transfer', 'completed'),
(1, 5500.00, 'withdrawal', 'Wire Transfer', 'flagged'),
(2, 18000.00, 'deposit', 'Payroll', 'completed'),
(3, 50.00, 'withdrawal', 'ATM', 'completed'),
(3, 9999.00, 'transfer', 'Unknown Merchant', 'flagged');

INSERT INTO fraud_flags (transaction_id, flag_reason) VALUES
(2, 'Large withdrawal exceeding 30-day average by 400%'),
(5, 'Transfer to unknown merchant over 5,000 threshold');
