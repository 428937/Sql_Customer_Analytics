# Sql_Customer_Analytics

### Customer Cohort Retention & RFM Analysis (PostgreSQL)

A clean, modular, and production-ready SQL project for analyzing e-commerce customer behavior using **RFM Segmentation** and **Cohort Retention Analysis**.

---

## Project Objective

This project helps businesses understand:
- Who are the most valuable customers (Champions, Loyal)
- Which customers are at risk of churning
- How different customer cohorts retain over time
- Revenue contribution by customer segment
- Customer lifetime value and spend velocity

---

## Features

- **RFM Analysis** with correct scoring (Recency, Frequency, Monetary)
- Business metrics: Average Order Value (AOV), Lifetime Days, Revenue Per Day, Churn Flag
- **Monthly Cohort Retention** matrix with 13-month pivot view (Month 0–12)
- `customer_lifetime_metrics` view for lifetime value reporting
- Rich sample data (2024–2026)
- Modular script structure
- Clear business reports in master analysis
- GUI-compatible (works in psql, pgAdmin, DBeaver, TablePlus)
- Performance indexes and best practices

---

## Project Structure

```
sql_customer_analytics/
├── README.md
├── .gitignore
├── Makefile
├── sql/
│   ├── 00_schema.sql
│   ├── 01_sample_data.sql
│   ├── 02_rfm_analysis.sql
│   ├── 03_cohort_retention.sql
│   └── 04_master_analysis.sql
└── output/                  # Generated CSV files (git-ignored)
```

---

## Database Requirements

- **PostgreSQL 13+**
- No external extensions required (optional: `tablefunc` for advanced pivoting)

---

## Setup Instructions

### 1. Create Database

```bash
createdb customer_analytics
# or inside psql:
# CREATE DATABASE customer_analytics;
```

### 2. Run Scripts (Recommended)

Use the Makefile:

```bash
make all
```

Or run manually in order:

```bash
psql -d customer_analytics -f sql/00_schema.sql
psql -d customer_analytics -f sql/01_sample_data.sql
psql -d customer_analytics -f sql/02_rfm_analysis.sql
psql -d customer_analytics -f sql/03_cohort_retention.sql
psql -d customer_analytics -f sql/04_master_analysis.sql
```

### 3. Clean & Reset

```bash
make clean
```

---

## Script Explanations

### `00_schema.sql`
- Creates `customers` and `orders` tables.
- Adds proper foreign key, constraints, and performance indexes.
- Composite index on `(customer_id, order_date)` for fast RFM aggregation.

### `01_sample_data.sql`
- Inserts realistic customers and orders from **2024 to May 2026**.
- Includes new and returning customers for meaningful retention analysis.

### `02_rfm_analysis.sql`
**Core RFM Logic:**
- Uses fixed `analysis_date = '2026-05-27'` for reproducible results.
- Correct **Recency scoring**: `ORDER BY recency_days DESC` so score 5 = most recent customer.
- Calculates: Recency, Frequency, Monetary, AOV, Lifetime Days, Revenue Per Day.
- Segment labels: Champions, Loyal Customers, Potential Loyalists, At Risk, Lost, New Customers, Others.
- `churn_flag`: High Risk if recency > 90 days, otherwise Active.
- Creates `customer_lifetime_metrics` view for lifetime value reporting.

### `03_cohort_retention.sql`
- Creates monthly cohort retention view with correct customer deduplication.
- Shows retention percentage by cohort month and age (Month 0–12).
- Pivot table covers the full first-year retention window.

### `04_master_analysis.sql`
Generates business-ready reports:
- Top Champions
- High-Risk customers (At Risk, Lost, or churn_flag = High Risk)
- Segment distribution with **revenue contribution %**
- Cohort retention summary (first 6 months)
- Customer lifetime metrics (top 10 by revenue)

---

## Key Metrics Explained

| Metric                 | Description                                   | Business Use              |
|------------------------|-----------------------------------------------|---------------------------|
| **Recency**            | Days since last purchase                      | Churn detection           |
| **Frequency**          | Total number of orders                        | Loyalty level             |
| **Monetary**           | Total spend                                   | Value ranking             |
| **AOV**                | Average order value                           | Spending behavior         |
| **Lifetime Days**      | Days since signup                             | Customer age              |
| **Revenue Per Day**    | Monetary / Lifetime Days                      | Spend velocity            |
| **RFM Score**          | e.g. `5-4-5`                                  | Quick segmentation        |
| **Segment Label**      | Champions, At Risk, etc.                      | Marketing action          |
| **Churn Flag**         | High Risk / Active                            | Retention campaigns       |
| **Retention %**        | % of cohort still buying in month X           | Acquisition quality       |

---

## RFM Segment Reference

| Segment Label          | Typical RFM Profile                           | Recommended Action        |
|------------------------|-----------------------------------------------|---------------------------|
| **Champions**          | R=5, F≥4, M≥4                                 | Reward, upsell            |
| **Loyal Customers**    | R≥4, F≥4, M≥3                                 | Loyalty program           |
| **Potential Loyalists**| R≥4, F or M ≥3                               | Nurture, cross-sell       |
| **At Risk**            | R≤2, F≥4                                      | Win-back campaign         |
| **Lost**               | R≤2, F≤2, M≤2                                 | Low-cost re-engagement    |
| **New Customers**      | R≥3, F≤2, M≤2                                 | Onboarding, first repeat  |
| **Others**             | Mixed signals                                 | Monitor                   |

---

## How to Export Results

```sql
-- Export RFM segments
COPY (SELECT * FROM rfm_segments ORDER BY monetary DESC)
TO '/path/to/output/rfm_segments.csv' WITH CSV HEADER;

-- Export cohort retention matrix
COPY (SELECT * FROM cohort_retention_matrix)
TO '/path/to/output/retention_matrix.csv' WITH CSV HEADER;

-- Export lifetime metrics
COPY (SELECT * FROM customer_lifetime_metrics)
TO '/path/to/output/lifetime_metrics.csv' WITH CSV HEADER;
```

---

## Customization Tips

- Change `analysis_date` in `02_rfm_analysis.sql` for point-in-time snapshots, or switch to `CURRENT_DATE` for live runs.
- Modify cohort granularity: replace `DATE_TRUNC('month', ...)` with `DATE_TRUNC('week', ...)` for weekly cohorts.
- Extend the pivot in `03_cohort_retention.sql` by adding more `CASE WHEN month_index = N` lines.
- Adjust the `churn_flag` threshold (default: 90 days) to match your business cycle.
- Replace sample data with your own tables — schema is minimal and easy to map.
- Extend RFM segment rules in the `CASE WHEN` block to fit your business logic.
