-- 02_rfm_analysis.sql
-- RFM with AOV, Churn Flag, Lifetime Days, and Lifetime Metrics view.

DROP TABLE IF EXISTS rfm_segments;

CREATE TABLE rfm_segments AS
WITH
analysis_date AS (
    -- Change this for point-in-time snapshots, or use CURRENT_DATE for live runs.
    SELECT '2026-05-27'::DATE AS analysis_date
),
rfm_raw AS (
    SELECT
        c.customer_id,
        c.segment,
        c.city,
        c.signup_date,
        (a.analysis_date - MAX(o.order_date))::INTEGER          AS recency_days,
        COUNT(o.order_id)                                        AS frequency,
        SUM(o.amount)                                            AS monetary,
        ROUND(SUM(o.amount)::NUMERIC / COUNT(o.order_id), 2)    AS avg_order_value,
        (a.analysis_date - c.signup_date)::INTEGER               AS lifetime_days,
        MAX(o.order_date)                                        AS last_order_date
    FROM customers c
    CROSS JOIN analysis_date a
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.segment, c.city, c.signup_date, a.analysis_date
),
scored AS (
    SELECT
        *,
        -- FIXED: DESC so that the smallest recency_days (most recent) gets score 5.
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency    DESC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary     DESC) AS m_score
    FROM rfm_raw
    WHERE recency_days IS NOT NULL
)
SELECT
    customer_id,
    segment,
    city,
    signup_date,
    recency_days,
    frequency,
    monetary,
    avg_order_value,
    lifetime_days,
    last_order_date,
    r_score,
    f_score,
    m_score,
    CONCAT(r_score, '-', f_score, '-', m_score) AS rfm_score,
    CASE
        WHEN r_score = 5 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND (f_score >= 3 OR m_score >= 3) THEN 'Potential Loyalists'
        WHEN r_score <= 2 AND f_score >= 4                   THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2  THEN 'Lost'
        WHEN r_score >= 3 AND f_score <= 2 AND m_score <= 2  THEN 'New Customers'
        ELSE 'Others'
    END AS segment_label,
    CASE
        WHEN recency_days > 90 THEN 'High Risk'
        ELSE 'Active'
    END AS churn_flag
FROM scored;

-- Lifetime metrics view (referenced in README, added here).
DROP VIEW IF EXISTS customer_lifetime_metrics;

CREATE VIEW customer_lifetime_metrics AS
SELECT
    customer_id,
    city,
    segment,
    signup_date,
    lifetime_days,
    frequency,
    monetary,
    avg_order_value,
    -- Revenue per day active (spend velocity)
    ROUND(monetary::NUMERIC / NULLIF(lifetime_days, 0), 4) AS revenue_per_day,
    segment_label,
    churn_flag
FROM rfm_segments
ORDER BY monetary DESC;

-- Quick preview
SELECT * FROM rfm_segments ORDER BY monetary DESC LIMIT 10;
