# E-Commerce Analytics — Maven Fuzzy Factory

An end-to-end e-commerce analytics portfolio project built with **MySQL, Python, and Power BI**.

## Project Objective

Analyze website traffic, marketing sources, customer behavior, product performance, profitability, and refunds to understand the business performance of an e-commerce store.

## Tools

- MySQL
- SQL
- Python
- Pandas
- NumPy
- Matplotlib
- Power BI

## Dataset

Maven Fuzzy Factory e-commerce dataset.

Analysis period:
**March 19, 2012 → March 19, 2015**

Core tables:

- `website_sessions`
- `website_pageviews`
- `orders`
- `order_items`
- `order_item_refunds`
- `products`

## Key Business KPIs

| KPI | Result |
|---|---:|
| Total Sessions | 472,871 |
| Total Pageviews | 1,188,124 |
| Total Users | 394,318 |
| Total Orders | 32,313 |
| Total Revenue | $1,938,509.75 |
| Total COGS | $722,370.25 |
| Gross Profit | $1,216,139.50 |
| Gross Margin | 62.72% |
| Average Order Value | $59.99 |
| Conversion Rate | 6.83% |
| Total Refunds | $85,338.69 |
| Refund Rate | 4.32% |

## Dashboard

The Power BI dashboard contains three pages:

### 1. Executive Overview
- Core business KPIs
- Monthly revenue
- Monthly orders
- Revenue by marketing source
- Conversion by device
- Revenue by product

### 2. Marketing & Customer Analysis
- Sessions by marketing source
- Revenue by marketing source
- Conversion rate by device
- New vs Repeat customer/session analysis

### 3. Product & Refund Analysis
- Revenue by product
- Gross profit by product
- Units sold
- Gross margin by product
- Refund amount by product
- Refund rate by product

## Selected Findings

- The business generated approximately **$1.94M in revenue** and **$1.22M in gross profit**.
- Overall website conversion was **6.83%**.
- Desktop conversion was **8.50%**, compared with **3.09%** for mobile sessions.
- `gsearch` generated approximately **$1.28M** in revenue and was the largest marketing source by revenue in this dataset.
- Repeat sessions had a conversion rate of approximately **7.83%**, compared with **6.64%** for new sessions.
- `The Original Mr. Fuzzy` generated approximately **$1.21M** in product revenue and about **24K units** sold.
- `The Birthday Sugar Panda` had the highest product refund rate at approximately **6.04%**.
- Total refund amount was approximately **$85.34K**, representing a **4.32% refunded-item rate**.

## Data Model

Main relationships:

```text
products
    1
    |
    *
order_items
    *
    |
    1
orders
    *
    |
    1
website_sessions
    |
    *
website_pageviews

order_items
    1
    |
    *
order_item_refunds
```

The Power BI model also uses the session, order, product, and refund relationships needed for the dashboard calculations.

## SQL Analysis

`02_SQL/01_create_database_and_load_data.sql`

Creates the database, tables, indexes, loads the CSV files, creates foreign-key relationships, and verifies row counts.

`02_SQL/02_ecommerce_analysis.sql`

Contains the business analysis queries, including:

- KPI calculations
- Revenue and profit
- Monthly performance
- Marketing source analysis
- Device analysis
- New vs repeat sessions
- Product performance
- Refund analysis
- Page performance
- Data-quality checks

## Python Analysis

`03_Python/ecommerce_analysis.py`

The Python workflow:

1. Loads all six CSV tables
2. Converts date fields
3. Checks missing values
4. Checks duplicate IDs
5. Calculates KPIs
6. Analyzes monthly performance
7. Analyzes marketing sources
8. Analyzes devices
9. Compares new vs repeat sessions
10. Analyzes products
11. Analyzes refunds
12. Analyzes website pages
13. Creates charts
14. Saves analysis outputs to CSV

The Python script was executed successfully against the project CSV data.

## Python Outputs

Generated outputs are stored in:

`03_Python/outputs/`

Including:

- `kpis.csv`
- `monthly_performance.csv`
- `marketing_performance.csv`
- `device_performance.csv`
- `new_vs_repeat.csv`
- `product_performance.csv`
- `refund_kpis.csv`
- `refunds_by_product.csv`
- `page_performance.csv`
- `missing_values.csv`
- `data_quality_checks.csv`

Charts are stored in:

`03_Python/outputs/charts/`

## How to Run

### MySQL

1. Put the six CSV files in `01_Data/`.
2. Open `02_SQL/01_create_database_and_load_data.sql`.
3. Replace `C:/YOUR_PROJECT_PATH` with the actual project path.
4. Run the loader script.
5. Verify the returned row counts.
6. Run `02_SQL/02_ecommerce_analysis.sql`.

### Python

Install requirements:

```bash
pip install -r 03_Python/requirements.txt
```

Then:

```bash
cd 03_Python
python ecommerce_analysis.py
```

### Power BI

Open:

`04_PowerBI/E-Commerce_Analytics_Dashboard.pbix`

## Portfolio Structure

```text
E-Commerce-Analytics-Portfolio/
│
├── 01_Data/
│   ├── README.md
│   └── maven_fuzzy_factory_data_dictionary.csv
│
├── 02_SQL/
│   ├── 01_create_database_and_load_data.sql
│   └── 02_ecommerce_analysis.sql
│
├── 03_Python/
│   ├── ecommerce_analysis.py
│   ├── requirements.txt
│   └── outputs/
│
├── 04_PowerBI/
│   ├── E-Commerce_Analytics_Dashboard.pbix
│   └── dashboard_previews/
│
└── README.md
```

## Validation

The project was checked across the SQL/Python calculations and the final Power BI dashboard values.

The main dashboard KPIs and product/refund metrics are consistent with the source data and analysis outputs.
