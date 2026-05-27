-- 03_cohort_retention.sql
-- Monthly cohort retention analysis.

DROP VIEW IF EXISTS cohort_retention_matrix;

CREATE VIEW cohort_retention_matrix AS
WITH 
cohort_data AS (
    SELECT
        o.customer_id,
        DATE_TRUNC('month', MIN(o.order_date) OVER (PARTITION BY o.customer_id)) AS cohort_month,
        DATE_TRUNC('month', o.order_date) AS order_month
    FROM orders o
),
cohort_age AS (
    SELECT
        customer_id,
        cohort_month,
        order_month,
        (EXTRACT(YEAR FROM age(order_month, cohort_month)) * 12 +
         EXTRACT(MONTH FROM age(order_month, cohort_month))) AS month_index
    FROM cohort_data
),
retention_raw AS (
    SELECT
        cohort_month,
        month_index,
        COUNT(DISTINCT customer_id) AS customers_ordered
    FROM cohort_age
    GROUP BY cohort_month, month_index
),
cohort_size AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT customer_id) AS total_customers
    FROM cohort_age
    WHERE month_index = 0
    GROUP BY cohort_month
)
SELECT
    r.cohort_month::DATE,
    r.month_index,
    r.customers_ordered,
    c.total_customers,
    ROUND(100.0 * r.customers_ordered::NUMERIC / c.total_customers, 2) AS retention_percentage
FROM retention_raw r
JOIN cohort_size c ON r.cohort_month = c.cohort_month
ORDER BY r.cohort_month, r.month_index;

-- Pivot view for easy reading
SELECT
    cohort_month,
    MAX(CASE WHEN month_index = 0 THEN retention_percentage END) AS "Month 0",
    MAX(CASE WHEN month_index = 1 THEN retention_percentage END) AS "Month 1",
    MAX(CASE WHEN month_index = 2 THEN retention_percentage END) AS "Month 2",
    MAX(CASE WHEN month_index = 3 THEN retention_percentage END) AS "Month 3",
    MAX(CASE WHEN month_index = 4 THEN retention_percentage END) AS "Month 4",
    MAX(CASE WHEN month_index = 5 THEN retention_percentage END) AS "Month 5"
FROM cohort_retention_matrix
GROUP BY cohort_month
ORDER BY cohort_month;