# Data

The original CSV dataset is intentionally not included in the portfolio ZIP because the raw files are large.

For the complete local package, the six CSV files are included separately.

Expected files:
- website_sessions.csv
- website_pageviews.csv
- orders.csv
- order_items.csv
- order_item_refunds.csv
- products.csv
- maven_fuzzy_factory_data_dictionary.csv

Place the six CSV files in this folder before running:
`03_Python/ecommerce_analysis.py`

For MySQL loading, update the path placeholders in:
`02_SQL/01_create_database_and_load_data.sql`
