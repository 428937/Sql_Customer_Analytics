-- 02_rfm_analysis.sql
-- RFM Analysis with corrected scoring logic.

DROP TABLE IF EXISTS rfm_segments;

CREATE TABLE rfm_segments AS
WITH 
analysis_date AS (
    SELECT '2023-12-31'::DATE AS analysis_date
),
rfm_raw AS (
    SELECT
        c.customer_id,
        c.segment,
        c.city,
        -- Recency: days since last purchase
        (a.analysis_date - MAX(o.order_date))::INTEGER AS recency_days,
        COUNT(o.order_id) AS frequency,
        SUM(o.amount)     AS monetary,
        MAX(o.order_date) AS last_order_date
    FROM customers c
    CROSS JOIN analysis_date a
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.segment, c.city, a.analysis_date
),
scored AS (
    SELECT
        *,
        NTILE(5) OVER (ORDER BY recency_days ASC)  AS r_score,   -- Lower days = higher score (better)
        NTILE(5) OVER (ORDER BY frequency DESC)    AS f_score,   -- Higher = better
        NTILE(5) OVER (ORDER BY monetary DESC)     AS m_score    -- Higher = better
    FROM rfm_raw
    WHERE recency_days IS NOT NULL  -- Only customers who made at least one purchase
)
SELECT
    customer_id,
    segment,
    city,
    recency_days,
    frequency,
    monetary,
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
    END AS segment_label
FROM scored;

-- Show top customers by monetary value
SELECT * FROM rfm_segments 
ORDER BY monetary DESC 
LIMIT 10;