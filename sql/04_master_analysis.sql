-- 04_master_analysis.sql
-- Final business insights and reports.

\echo '===== TOP 5 CHAMPIONS ====='
SELECT customer_id, segment, city, recency_days, frequency, monetary, rfm_score, segment_label
FROM rfm_segments
WHERE segment_label = 'Champions'
ORDER BY monetary DESC
LIMIT 5;

\echo '===== TOP 5 AT-RISK CUSTOMERS ====='
SELECT customer_id, segment, city, recency_days, frequency, monetary, rfm_score, segment_label
FROM rfm_segments
WHERE segment_label IN ('At Risk', 'Lost')
ORDER BY recency_days DESC
LIMIT 5;

\echo '===== RFM SEGMENT DISTRIBUTION ====='
SELECT 
    segment_label,
    COUNT(*) AS customer_count,
    ROUND(AVG(monetary), 2) AS avg_monetary,
    ROUND(AVG(recency_days), 1) AS avg_recency_days
FROM rfm_segments
GROUP BY segment_label
ORDER BY avg_monetary DESC;

\echo '===== COHORT RETENTION SUMMARY (First 6 Months) ====='
SELECT * FROM cohort_retention_matrix 
WHERE month_index <= 5
ORDER BY cohort_month DESC, month_index;