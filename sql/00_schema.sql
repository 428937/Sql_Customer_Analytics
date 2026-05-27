-- 00_schema.sql
-- Creates tables for orders and customers.

DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

CREATE TABLE customers (
    customer_id   INT PRIMARY KEY,
    signup_date   DATE NOT NULL,
    city          VARCHAR(50),
    segment       VARCHAR(20)   -- e.g. 'Consumer', 'Corporate'
);

CREATE TABLE orders (
    order_id      INT PRIMARY KEY,
    customer_id   INT NOT NULL REFERENCES customers(customer_id),
    order_date    DATE NOT NULL,
    amount        DECIMAL(10,2) NOT NULL CHECK (amount >= 0)
);

CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);