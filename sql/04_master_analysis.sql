-- 04_master_analysis.sql
-- Business reports: Champions, High-Risk, Segment Distribution, Cohort Summary.
--
-- CHANGED: Replaced \echo with DO $$ RAISE NOTICE $$ blocks.
--   \echo is a psql CLI meta-command. It throws a syntax error in DBeaver,
--   pgAdmin, TablePlus, and most other GUI tools. RAISE NOTICE works
--   everywhere (psql, pgAdmin, DBeaver, etc.).

-- 1. TOP 5 CHAMPIONS
DO $$ BEGIN RAISE NOTICE '===== TOP 5 CHAMPIONS ====='; END $$;

SELECT
    customer_id,
    segment,
    city,
    recency_days,
    frequency,
    monetary,
    avg_order_value,
    segment_label
FROM rfm_segments
WHERE segment_label = 'Champions'
ORDER BY monetary DESC
LIMIT 5;


-- 2. HIGH-RISK CUSTOMERS (At Risk + Lost + churn_flag)
DO $$ BEGIN RAISE NOTICE '===== HIGH-RISK CUSTOMERS (At Risk + Lost) ====='; END $$;

SELECT
    customer_id,
    segment,
    city,
    recency_days,
    frequency,
    monetary,
    churn_flag,
    segment_label
FROM rfm_segments
WHERE segment_label IN ('At Risk', 'Lost')
   OR churn_flag = 'High Risk'
ORDER BY recency_days DESC
LIMIT 8;


-- 3. RFM SEGMENT DISTRIBUTION & REVENUE CONTRIBUTION
DO $$ BEGIN RAISE NOTICE '===== RFM SEGMENT DISTRIBUTION & REVENUE CONTRIBUTION ====='; END $$;

SELECT
    segment_label,
    COUNT(*)                                                                          AS customer_count,
    ROUND(SUM(monetary), 2)                                                           AS total_revenue,
    ROUND(100.0 * SUM(monetary) / NULLIF(SUM(SUM(monetary)) OVER (), 0), 2)          AS revenue_pct,
    ROUND(AVG(monetary), 2)                                                           AS avg_monetary,
    ROUND(AVG(recency_days), 1)                                                       AS avg_recency
FROM rfm_segments
GROUP BY segment_label
ORDER BY total_revenue DESC;


-- 4. COHORT RETENTION SUMMARY (First 6 Months)
DO $$ BEGIN RAISE NOTICE '===== COHORT RETENTION SUMMARY (First 6 Months) ====='; END $$;

SELECT *
FROM cohort_retention_matrix
WHERE month_index <= 5
ORDER BY cohort_month DESC, month_index;


-- 5. CUSTOMER LIFETIME METRICS (top 10 by revenue)
DO $$ BEGIN RAISE NOTICE '===== CUSTOMER LIFETIME METRICS ====='; END $$;

SELECT *
FROM customer_lifetime_metrics
LIMIT 10;
