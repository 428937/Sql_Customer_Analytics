-- 02_rfm_analysis.sql
-- Improved RFM with AOV, Churn Flag, and Lifetime Days.

DROP TABLE IF EXISTS rfm_segments;

CREATE TABLE rfm_segments AS
WITH 
analysis_date AS (
    SELECT '2026-05-27'::DATE AS analysis_date
),
rfm_raw AS (
    SELECT
        c.customer_id,
        c.segment,
        c.city,
        c.signup_date,
        (a.analysis_date - MAX(o.order_date))::INTEGER AS recency_days,
        COUNT(o.order_id)                              AS frequency,
        SUM(o.amount)                                  AS monetary,
        ROUND(SUM(o.amount)::NUMERIC / COUNT(o.order_id), 2) AS avg_order_value,
        (a.analysis_date - c.signup_date)::INTEGER     AS lifetime_days,
        MAX(o.order_date)                              AS last_order_date
    FROM customers c
    CROSS JOIN analysis_date a
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.segment, c.city, c.signup_date, a.analysis_date
),
scored AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days ASC)  AS r_score,   -- 5 = most recent
        NTILE(5) OVER (ORDER BY frequency DESC)    AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC)     AS m_score
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
        WHEN r_score <= 2 AND f_score >= 4 THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Lost'
        WHEN r_score >= 3 AND f_score <= 2 AND m_score <= 2 THEN 'New Customers'
        ELSE 'Others'
    END AS segment_label,
    CASE WHEN recency_days > 90 THEN 'High Risk' ELSE 'Active' END AS churn_flag
FROM scored;

-- Quick preview
SELECT * FROM rfm_segments ORDER BY monetary DESC LIMIT 10;