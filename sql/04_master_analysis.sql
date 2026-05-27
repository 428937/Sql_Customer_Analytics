-- 04_master_analysis.sql
-- Final bussiness insight and reports (Enhanced)

\echo '===== TOP 5 CHAMPIONS ====='
SELECT customer_id, segment, city, recency_days, frequency, monetary, avg_order_value, segment_label
FROM rfm_segments
WHERE segment_label = 'Champions'
ORDER BY monetary DESC LIMIT 5;

\echo '===== HIGH-RISK CUSTOMERS (At Risk + Lost) ====='
SELECT customer_id, segment, city, recency_days, frequency, monetary, churn_flag, segment_label
FROM rfm_segments
WHERE segment_label IN ('At Risk', 'Lost') OR churn_flag = 'High Risk'
ORDER BY recency_days DESC LIMIT 8;

\echo '===== RFM SEGMENT DISTRIBUTION & REVENUE CONTRIBUTION ====='
SELECT 
    segment_label,
    COUNT(*) AS customer_count,
    ROUND(SUM(monetary), 2) AS total_revenue,
    ROUND(100.0 * SUM(monetary) / NULLIF(SUM(SUM(monetary)) OVER (), 0), 2) AS revenue_pct,
    ROUND(AVG(monetary), 2) AS avg_monetary,
    ROUND(AVG(recency_days), 1) AS avg_recency
FROM rfm_segments
GROUP BY segment_label
ORDER BY total_revenue DESC;

\echo '===== COHORT RETENTION SUMMARY (First 6 Months) ====='
SELECT * FROM cohort_retention_matrix 
WHERE month_index <= 5
ORDER BY cohort_month DESC, month_index;