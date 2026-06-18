-- 03_cohort_retention.sql
-- Monthly cohort retention matrix..

DROP VIEW IF EXISTS cohort_retention_matrix;

CREATE VIEW cohort_retention_matrix AS
WITH
cohort_data AS (
    -- FIXED: DISTINCT removes duplicate rows caused by multiple orders
    -- per customer in the same month. Without this, a customer with 3 orders
    -- in a given month would be counted 3 times in retention_raw.
    SELECT DISTINCT
        o.customer_id,
        DATE_TRUNC('month', MIN(o.order_date) OVER (PARTITION BY o.customer_id)) AS cohort_month,
        DATE_TRUNC('month', o.order_date)                                         AS order_month
    FROM orders o
),
cohort_age AS (
    SELECT
        customer_id,
        cohort_month,
        order_month,
        (
            EXTRACT(YEAR  FROM age(order_month, cohort_month)) * 12 +
            EXTRACT(MONTH FROM age(order_month, cohort_month))
        )::INTEGER AS month_index
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
    ROUND(
        100.0 * r.customers_ordered::NUMERIC / NULLIF(c.total_customers, 0),
        2
    ) AS retention_percentage
FROM retention_raw r
JOIN cohort_size c ON r.cohort_month = c.cohort_month
ORDER BY r.cohort_month, r.month_index;


-- Pivot for readability.
-- FIXED: expanded from 6 to 13 columns (Month 0–12).
-- Your earliest cohort is Jan 2024 and analysis_date is May 2026 (~28 months),
-- so Month 0–12 captures the critical first-year retention window cleanly.
-- If you need further months just add more CASE WHEN lines below.
SELECT
    cohort_month,
    total_customers,
    MAX(CASE WHEN month_index =  0 THEN retention_percentage END) AS "Month 0",
    MAX(CASE WHEN month_index =  1 THEN retention_percentage END) AS "Month 1",
    MAX(CASE WHEN month_index =  2 THEN retention_percentage END) AS "Month 2",
    MAX(CASE WHEN month_index =  3 THEN retention_percentage END) AS "Month 3",
    MAX(CASE WHEN month_index =  4 THEN retention_percentage END) AS "Month 4",
    MAX(CASE WHEN month_index =  5 THEN retention_percentage END) AS "Month 5",
    MAX(CASE WHEN month_index =  6 THEN retention_percentage END) AS "Month 6",
    MAX(CASE WHEN month_index =  7 THEN retention_percentage END) AS "Month 7",
    MAX(CASE WHEN month_index =  8 THEN retention_percentage END) AS "Month 8",
    MAX(CASE WHEN month_index =  9 THEN retention_percentage END) AS "Month 9",
    MAX(CASE WHEN month_index = 10 THEN retention_percentage END) AS "Month 10",
    MAX(CASE WHEN month_index = 11 THEN retention_percentage END) AS "Month 11",
    MAX(CASE WHEN month_index = 12 THEN retention_percentage END) AS "Month 12"
FROM cohort_retention_matrix
GROUP BY cohort_month, total_customers
ORDER BY cohort_month;
