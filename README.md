# Sql_Customer_Analytics

## Customer Cohort Retention & RFM Analysis (PostgreSQL)

A clean, modular, and production-ready SQL project for analyzing e-commerce customer behavior using **RFM Segmentation** and **Cohort Retention Analysis**.

---

## Project Objective

This project helps businesses understand:
- Who are the most valuable customers (Champions, Loyal)
- Which customers are at risk of churning
- How different customer cohorts retain over time
- Revenue contribution by customer segment

---

## Features

- **RFM Analysis** with scoring (Recency, Frequency, Monetary)
- Added business metrics: Average Order Value (AOV), Lifetime Days, Churn Flag
- **Monthly Cohort Retention** matrix with pivot view
- Rich sample data (2024–2026)
- Modular script structure
- Clear business reports in master analysis
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
└── output/                  # Generated CSV files (add to .gitignore)
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

### `01_sample_data.sql`
- Inserts realistic customers and orders from **2024 to May 2026**.
- Includes new and returning customers for meaningful retention analysis.

### `02_rfm_analysis.sql`
**Core RFM Logic** (Improved):
- Uses fixed `analysis_date = '2026-05-27'`
- Correct **Recency scoring** (lower days = better score)
- Calculates: Recency, Frequency, Monetary, AOV, Lifetime Days
- Advanced segment labels: Champions, Loyal Customers, Potential Loyalists, At Risk, Lost, New Customers, Others
- Adds `churn_flag` (High Risk if recency > 90 days)

### `03_cohort_retention.sql`
- Creates monthly cohort retention view.
- Shows retention percentage by cohort month and age (Month 0, 1, 2...).
- Includes pivot table for easy reading.

### `04_master_analysis.sql`
Generates business-ready reports:
- Top Champions
- High-Risk customers
- Segment distribution with **revenue contribution %**
- Recent cohort retention summary

---

## Key Metrics Explained

| Metric              | Description                              | Business Use |
|---------------------|------------------------------------------|--------------|
| **Recency**         | Days since last purchase                 | Churn detection |
| **Frequency**       | Total orders                             | Loyalty level |
| **Monetary**        | Total spend                              | Value ranking |
| **AOV**             | Average order value                      | Spending behavior |
| **RFM Score**       | e.g. `5-4-5`                             | Quick segmentation |
| **Segment Label**   | Champions, At Risk, etc.                 | Marketing action |
| **Churn Flag**      | High Risk / Active                       | Retention campaigns |
| **Retention %**     | % of cohort still buying in month X      | Acquisition quality |

---

## How to Export Results

```sql
-- Export RFM segments
COPY (SELECT * FROM rfm_segments ORDER BY monetary DESC)
TO '/path/to/output/rfm_segments.csv' WITH CSV HEADER;

-- Export retention matrix
COPY (SELECT * FROM cohort_retention_matrix)
TO '/path/to/output/retention_matrix.csv' WITH CSV HEADER;
```

---

## Customization Tips

- Change `analysis_date` in `02_rfm_analysis.sql` for different snapshots.
- Modify cohort granularity (`DATE_TRUNC('week', ...)` for weekly cohorts).
- Replace sample data with your own tables.
- Extend segments logic based on your business rules.