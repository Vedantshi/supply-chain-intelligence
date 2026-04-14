# Supply Chain Intelligence: Global Logistics Analytics

> **Status: 🚧 In Progress** — Python pipeline and SQL layer complete. Excel, Power BI, and case study coming soon.

---

## Business Problem

A global consumer goods company with 65,000+ annual shipments had no unified visibility across route performance, inventory health, and fulfillment risk. Logistics costs were rising with no data-backed explanation. Three critical questions were unanswered:

- Which routes are consistently late and what is the financial cost?
- Where is the company at risk of running out of stock?
- Are we shipping profitably or is freight cost silently destroying margins?

---

## Tools & Techniques

| Tool | Purpose |
|------|---------|
| **Python** (pandas, numpy) | Data cleaning, feature engineering, inventory simulation |
| **Excel** | Power Query ETL, What-If Data Tables, INDEX/MATCH KPI dashboard |
| **SQL Server** | CTEs, window functions, IQR anomaly detection, PERCENT_RANK scoring |
| **Power BI** | Star schema, DAX measures, Row-Level Security, What-If simulation |

---

## Key Findings

1. **First Class shipping has 0% on-time rate** — customers paying premium prices receive the worst delivery performance
2. **92.6% of route combinations** have costs exceeding 80% of revenue
3. **50 routes are outright unprofitable** — freight cost exceeds order revenue
4. **19.8% of all orders are statistical anomalies** in delivery delay (13,027 outliers)
5. **21 products at critical stockout risk** with 7 days or fewer of stock remaining

---

## Project Progress

| Phase | Status |
|-------|--------|
| Python — Data Cleaning & Feature Engineering | ✅ Complete |
| SQL Server — 7 Analytics Scripts | ✅ Complete |
| Excel — Power Query & Scenario Workbook | 🚧 In Progress |
| Power BI — 5 Dashboards | ⏳ Pending |
| Case Study PDF | ⏳ Pending |

---

## SQL Scripts

| Script | Business Question |
|--------|------------------|
| `01_lead_time_delay_engine.sql` | How long does each order take vs how long it should? |
| `02_route_segment_scorecard.sql` | Which routes deliver value and which need restructuring? |
| `03_inventory_health.sql` | Where are we about to run out of stock? |
| `04_iqr_anomaly_detection.sql` | Which shipments are statistical outliers in delay? |
| `05_cost_erosion_analysis.sql` | Which routes are shipping us into losses? |
| `06_fulfillment_risk_scoring.sql` | Which corridors carry the highest operational risk? |
| `07_rolling_trends.sql` | Are shipping modes getting better or worse over time? |

---

## Dataset

**DataCo Global Supply Chain** — [Download from Kaggle](https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis)

Raw dataset not included due to file size. Download from Kaggle and run the Python script to regenerate all cleaned files.

> Note: Inventory levels were simulated from order history as the dataset contains demand data but not warehouse stock snapshots. In production this would connect to a WMS or ERP system.

---

## How to Reproduce

```bash
# 1. Download dataset from Kaggle link above
# 2. Rename to dataco_supply_chain_raw.csv and place in data/

# 3. Install dependencies
pip install -r python/requirements.txt

# 4. Run the cleaning and feature engineering pipeline
python python/00_data_cleaning_and_feature_engineering.py

# 5. Import inventory_simulated.csv and route_segment_lookup.csv
#    into SQL Server using the pyodbc method (see notes in python script)

# 6. Run SQL scripts 01 through 07 in order in SSMS

# 7. Open Power BI file and refresh data source (coming soon)
```

---

## Repository Structure

```
supply-chain-intelligence/
|
|-- data/
|   |-- inventory_simulated.csv       (simulated inventory layer)
|   |-- route_segment_lookup.csv      (route segment reference)
|
|-- python/
|   |-- 00_data_cleaning_and_feature_engineering.py
|   |-- requirements.txt
|
|-- sql/
|   |-- 01_lead_time_delay_engine.sql
|   |-- 02_route_segment_scorecard.sql
|   |-- 03_inventory_health.sql
|   |-- 04_iqr_anomaly_detection.sql
|   |-- 05_cost_erosion_analysis.sql
|   |-- 06_fulfillment_risk_scoring.sql
|   |-- 07_rolling_trends.sql
|
|-- excel/                            (coming soon)
|-- powerbi/                          (coming soon)
|-- screenshots/                      (coming soon)
```

---

*This project is part of a data analytics portfolio demonstrating end-to-end capability across Python, SQL, Excel, and Power BI.*
