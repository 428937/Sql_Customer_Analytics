-- 00_schema.sql
-- Core schema with improved indexing.

DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

CREATE TABLE customers (
    customer_id   INT PRIMARY KEY,
    signup_date   DATE NOT NULL,
    city          VARCHAR(50),
    segment       VARCHAR(20)
);

CREATE TABLE orders (
    order_id      INT PRIMARY KEY,
    customer_id   INT NOT NULL REFERENCES customers(customer_id),
    order_date    DATE NOT NULL,
    amount        DECIMAL(10,2) NOT NULL CHECK (amount >= 0)
);

CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_customers_signup ON customers(signup_date);