-- Project PostgreSQL: Sample application schema

CREATE TABLE IF NOT EXISTS users (
    id          SERIAL PRIMARY KEY,
    username    VARCHAR(50) UNIQUE NOT NULL,
    email       VARCHAR(100) UNIQUE NOT NULL,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    price       NUMERIC(10, 2) NOT NULL,
    stock       INTEGER DEFAULT 0,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
    id          SERIAL PRIMARY KEY,
    user_id     INTEGER REFERENCES users(id),
    product_id  INTEGER REFERENCES products(id),
    quantity    INTEGER NOT NULL,
    total       NUMERIC(10, 2) NOT NULL,
    ordered_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seed data
INSERT INTO users (username, email) VALUES
    ('chris_turin', 'chris@example.com'),
    ('jane_doe', 'jane@example.com'),
    ('john_smith', 'john@example.com');

INSERT INTO products (name, price, stock) VALUES
    ('Laptop', 999.99, 50),
    ('Keyboard', 49.99, 200),
    ('Monitor', 299.99, 75);

INSERT INTO orders (user_id, product_id, quantity, total) VALUES
    (1, 1, 1, 999.99),
    (2, 2, 2, 99.98),
    (3, 3, 1, 299.99);
