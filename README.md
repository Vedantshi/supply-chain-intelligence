# Supply Chain Intelligence: Global Logistics Analytics

End-to-end analytics platform turning 65,000+ shipment records into actionable findings across carriers, inventory, and routes.

**Stack:** Python · SQL Server · Excel · Power BI

---

## Dashboard Preview

> *Early preview of the Power BI layer — full 5-dashboard platform releasing soon.*

![Control Tower Dashboard](screenshots/01_control_tower.png)
*Supply Chain Control Tower — real-time visibility across on-time rate, delay trends, and revenue at risk from late deliveries.*

![Route Scorecard Dashboard](screenshots/02_route_scorecard.png)
*Route Segment Scorecard — composite reliability scoring across cost, delay, and on-time performance.*

---

## The Business Problem

A global consumer goods company with 65,000+ annual shipments had no unified visibility across route performance, inventory health, and fulfillment risk. Logistics costs were rising with no data-backed explanation. Three questions were unanswered:

- Which routes are consistently late — and what's the financial cost?
- Where are we about to run out of stock?
- Are we actually shipping profitably, or is freight cost destroying margins?

---

## Key Findings

| # | Finding | Business Impact |
|---|---------|----------------|
| 1 | First Class shipping has a **0% on-time rate** | Customers paying premium prices get the worst service |
| 2 | **92.6% of route combinations** have costs exceeding 80% of revenue | Systemic margin erosion across the network |
| 3 | **50 routes are outright unprofitable** — freight cost exceeds order revenue | Immediate candidates for renegotiation or elimination |
| 4 | **19.8% of orders** are statistical anomalies in delivery delay (13,027 outliers) | Signals carrier-level operational breakdown |
| 5 | **21 products** at critical stockout risk (≤7 days cover) | Revenue loss risk in the next replenishment cycle |

---

## What's Inside

### Python — Data Pipeline
Cleaned 180K+ raw records down to 65K analysis-ready shipments. Engineered features the raw data didn't contain: delivery date derivation, route segment construction, and a simulated inventory layer.

### SQL Server — 7 Analytics Scripts

| Script | Question Answered |
|--------|------------------|
| `01_lead_time_delay_engine.sql` | How long does each order take vs. how long it should? |
| `02_route_segment_scorecard.sql` | Which routes deliver value and which need restructuring? |
| `03_inventory_health.sql` | Where are we about to run out of stock? |
| `04_iqr_anomaly_detection.sql` | Which shipments are statistical outliers in delay? |
| `05_cost_erosion_analysis.sql` | Which routes are shipping us into losses? |
| `06_fulfillment_risk_scoring.sql` | Which corridors carry the highest operational risk? |
| `07_rolling_trends.sql` | Are shipping modes improving or deteriorating over time? |

Techniques: CTEs, window functions, IQR anomaly detection, PERCENT_RANK composite scoring.

### Power BI — 5-Dashboard Platform *(Preview live — full release in progress)*
Star schema data model, 19+ DAX measures, Row-Level Security, compound What-If simulation, decomposition tree, and geographic maps.

### Excel — Scenario Workbook *(in progress)*
Power Query ETL, What-If Data Tables, INDEX/MATCH KPI dashboard.

---

## Project Status

| Phase | Status |
|-------|--------|
| Python — Data Cleaning & Feature Engineering | Complete |
| SQL Server — 7 Analytics Scripts | Complete |
| Power BI — Control Tower & Route Scorecard | Preview Released |
| Power BI — Remaining 3 Dashboards | In Progress |
| Excel — Power Query & Scenario Workbook | In Progress |
| Case Study PDF | Pending |

---

## Reproduce Locally

```bash
# 1. Download dataset from Kaggle (link below)
# 2. Rename to dataco_supply_chain_raw.csv and place in data/

pip install -r python/requirements.txt
python python/00_data_cleaning_and_feature_engineering.py

# 3. Import cleaned CSVs into SQL Server, then run sql/01 to 07 in order
# 4. Open powerbi/supply_chain_intelligence.pbix and refresh
```

**Dataset:** [DataCo Global Supply Chain — Kaggle](https://www.kaggle.com/datasets/shashwatwork/dataco-smart-supply-chain-for-big-data-analysis)

> *Inventory levels were simulated from order history as the dataset contains demand data but not warehouse snapshots. In production this would connect to a WMS or ERP system.*

---

## Repository Structure

```
supply-chain-intelligence/
├── data/                 # simulated inventory & route lookup
├── python/               # cleaning & feature engineering pipeline
├── sql/                  # 7 analytics scripts
├── powerbi/              # .pbix file (preview)
├── screenshots/          # dashboard images
├── excel/                # scenario workbook (coming soon)
└── README.md
```

---

*Part of a data analytics portfolio demonstrating end-to-end delivery across Python, SQL, Excel, and Power BI.*
