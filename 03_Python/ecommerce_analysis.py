"""
PROJECT 2: E-Commerce Analytics
Maven Fuzzy Factory

File: ecommerce_analysis.py

What this script does:
1. Loads the six CSV tables.
2. Performs basic data-quality checks.
3. Calculates business KPIs.
4. Performs monthly, marketing, device, product and refund analysis.
5. Creates charts.
6. Saves analysis outputs as CSV files.

Expected folder structure:

Project/
├── 01_Data/
│   ├── website_sessions.csv
│   ├── website_pageviews.csv
│   ├── orders.csv
│   ├── order_items.csv
│   ├── order_item_refunds.csv
│   └── products.csv
├── 02_SQL/
│   └── ecommerce_analysis.sql
└── 03_Python/
    └── ecommerce_analysis.py

Run from VS Code with:
    python ecommerce_analysis.py
"""

from pathlib import Path
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt


# ============================================================
# 01. PATHS
# ============================================================

SCRIPT_DIR = Path(__file__).resolve().parent
PROJECT_DIR = SCRIPT_DIR.parent
DATA_DIR = PROJECT_DIR / "01_Data"

OUTPUT_DIR = SCRIPT_DIR / "outputs"
CHART_DIR = OUTPUT_DIR / "charts"

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
CHART_DIR.mkdir(parents=True, exist_ok=True)


# ============================================================
# 02. LOAD DATA
# ============================================================

def load_csv(filename):
    path = DATA_DIR / filename

    if not path.exists():
        raise FileNotFoundError(
            f"Could not find {filename}.\n"
            f"Expected location: {path}\n\n"
            "Put your CSV files inside the project's 01_Data folder."
        )

    return pd.read_csv(path)


sessions = load_csv("website_sessions.csv")
pageviews = load_csv("website_pageviews.csv")
orders = load_csv("orders.csv")
order_items = load_csv("order_items.csv")
refunds = load_csv("order_item_refunds.csv")
products = load_csv("products.csv")


# ============================================================
# 03. DATE CONVERSION
# ============================================================

date_columns = {
    "sessions": (sessions, "created_at"),
    "pageviews": (pageviews, "created_at"),
    "orders": (orders, "created_at"),
    "order_items": (order_items, "created_at"),
    "refunds": (refunds, "created_at"),
    "products": (products, "created_at"),
}

for _, (df, column) in date_columns.items():
    df[column] = pd.to_datetime(df[column], errors="coerce")


# ============================================================
# 04. BASIC DATA QUALITY
# ============================================================

print("\n" + "=" * 70)
print("DATASET SHAPES")
print("=" * 70)

datasets = {
    "website_sessions": sessions,
    "website_pageviews": pageviews,
    "orders": orders,
    "order_items": order_items,
    "order_item_refunds": refunds,
    "products": products,
}

for name, df in datasets.items():
    print(f"{name:25s}: {df.shape[0]:>10,} rows | {df.shape[1]:>3} columns")


print("\n" + "=" * 70)
print("MISSING VALUES")
print("=" * 70)

missing_rows = []

for name, df in datasets.items():
    for column in df.columns:
        missing_rows.append({
            "table": name,
            "column": column,
            "missing_count": int(df[column].isna().sum()),
            "missing_pct": round(df[column].isna().mean() * 100, 2),
        })

missing_df = pd.DataFrame(missing_rows)
missing_df = missing_df[missing_df["missing_count"] > 0]
missing_df = missing_df.sort_values(
    ["table", "missing_count"],
    ascending=[True, False]
)

missing_df.to_csv(OUTPUT_DIR / "missing_values.csv", index=False)

if missing_df.empty:
    print("No missing values found.")
else:
    print(missing_df.to_string(index=False))


# ============================================================
# 05. BASIC KPIs
# ============================================================

total_sessions = sessions["website_session_id"].nunique()
total_pageviews = pageviews["website_pageview_id"].nunique()
total_users = sessions["user_id"].nunique()
total_orders = orders["order_id"].nunique()
total_products = products["product_id"].nunique()

total_revenue = orders["price_usd"].sum()
total_cogs = orders["cogs_usd"].sum()
gross_profit = total_revenue - total_cogs
gross_margin = gross_profit / total_revenue if total_revenue else np.nan
aov = total_revenue / total_orders if total_orders else np.nan
conversion_rate = total_orders / total_sessions if total_sessions else np.nan

kpis = pd.DataFrame({
    "KPI": [
        "Total Sessions",
        "Total Pageviews",
        "Total Users",
        "Total Orders",
        "Total Products",
        "Total Revenue",
        "Total COGS",
        "Gross Profit",
        "Gross Margin",
        "Average Order Value",
        "Conversion Rate",
    ],
    "Value": [
        total_sessions,
        total_pageviews,
        total_users,
        total_orders,
        total_products,
        total_revenue,
        total_cogs,
        gross_profit,
        gross_margin,
        aov,
        conversion_rate,
    ],
})

kpis.to_csv(OUTPUT_DIR / "kpis.csv", index=False)

print("\n" + "=" * 70)
print("KEY BUSINESS KPIs")
print("=" * 70)
print(f"Total Sessions       : {total_sessions:,.0f}")
print(f"Total Pageviews      : {total_pageviews:,.0f}")
print(f"Total Users          : {total_users:,.0f}")
print(f"Total Orders         : {total_orders:,.0f}")
print(f"Total Products       : {total_products:,.0f}")
print(f"Total Revenue        : ${total_revenue:,.2f}")
print(f"Total COGS           : ${total_cogs:,.2f}")
print(f"Gross Profit         : ${gross_profit:,.2f}")
print(f"Gross Margin         : {gross_margin:.2%}")
print(f"Average Order Value  : ${aov:,.2f}")
print(f"Conversion Rate      : {conversion_rate:.2%}")


# ============================================================
# 06. MONTHLY ANALYSIS
# ============================================================

sessions["month"] = sessions["created_at"].dt.to_period("M").astype(str)
orders["month"] = orders["created_at"].dt.to_period("M").astype(str)

monthly_sessions = (
    sessions.groupby("month")["website_session_id"]
    .nunique()
    .rename("sessions")
)

monthly_orders = (
    orders.groupby("month")["order_id"]
    .nunique()
    .rename("orders")
)

monthly_revenue = (
    orders.groupby("month")["price_usd"]
    .sum()
    .rename("revenue")
)

monthly_profit = (
    orders.assign(
        gross_profit=orders["price_usd"] - orders["cogs_usd"]
    )
    .groupby("month")["gross_profit"]
    .sum()
    .rename("gross_profit")
)

monthly = pd.concat(
    [
        monthly_sessions,
        monthly_orders,
        monthly_revenue,
        monthly_profit,
    ],
    axis=1,
).fillna(0)

monthly["conversion_rate"] = (
    monthly["orders"] / monthly["sessions"]
)

monthly["aov"] = (
    monthly["revenue"] / monthly["orders"]
)

monthly["revenue_growth_pct"] = (
    monthly["revenue"].pct_change() * 100
)

monthly = monthly.reset_index()

monthly.to_csv(OUTPUT_DIR / "monthly_performance.csv", index=False)

print("\n" + "=" * 70)
print("MONTHLY PERFORMANCE")
print("=" * 70)
print(monthly.tail(10).to_string(index=False))


# ============================================================
# 07. MARKETING ANALYSIS
# ============================================================

sessions["source"] = sessions["utm_source"].fillna("Direct / Unknown")

source_sessions = (
    sessions.groupby("source")["website_session_id"]
    .nunique()
    .rename("sessions")
)

source_orders = (
    sessions[["website_session_id", "source"]]
    .merge(
        orders[["website_session_id", "order_id", "price_usd"]],
        on="website_session_id",
        how="left",
    )
    .groupby("source")
    .agg(
        orders=("order_id", "nunique"),
        revenue=("price_usd", "sum"),
    )
)

marketing = source_sessions.to_frame().join(source_orders, how="left")
marketing = marketing.fillna(0)

marketing["conversion_rate"] = (
    marketing["orders"] / marketing["sessions"]
)

marketing["revenue_per_session"] = (
    marketing["revenue"] / marketing["sessions"]
)

marketing = marketing.reset_index()
marketing = marketing.sort_values(
    "revenue",
    ascending=False
)

marketing.to_csv(OUTPUT_DIR / "marketing_performance.csv", index=False)

print("\n" + "=" * 70)
print("MARKETING PERFORMANCE")
print("=" * 70)
print(marketing.to_string(index=False))


# ============================================================
# 08. DEVICE ANALYSIS
# ============================================================

sessions["device"] = sessions["device_type"].fillna("Unknown")

device_orders = (
    sessions[["website_session_id", "device"]]
    .merge(
        orders[["website_session_id", "order_id", "price_usd"]],
        on="website_session_id",
        how="left",
    )
    .groupby("device")
    .agg(
        orders=("order_id", "nunique"),
        revenue=("price_usd", "sum"),
    )
)

device_sessions = (
    sessions.groupby("device")["website_session_id"]
    .nunique()
    .rename("sessions")
)

device = device_sessions.to_frame().join(device_orders, how="left").fillna(0)

device["conversion_rate"] = (
    device["orders"] / device["sessions"]
)

device["revenue_per_session"] = (
    device["revenue"] / device["sessions"]
)

device = device.reset_index()

device.to_csv(OUTPUT_DIR / "device_performance.csv", index=False)

print("\n" + "=" * 70)
print("DEVICE PERFORMANCE")
print("=" * 70)
print(device.to_string(index=False))


# ============================================================
# 09. NEW VS REPEAT
# ============================================================

sessions["session_type"] = np.where(
    sessions["is_repeat_session"] == 1,
    "Repeat",
    "New",
)

repeat_orders = (
    sessions[["website_session_id", "session_type"]]
    .merge(
        orders[["website_session_id", "order_id", "price_usd"]],
        on="website_session_id",
        how="left",
    )
    .groupby("session_type")
    .agg(
        orders=("order_id", "nunique"),
        revenue=("price_usd", "sum"),
    )
)

repeat_sessions = (
    sessions.groupby("session_type")["website_session_id"]
    .nunique()
    .rename("sessions")
)

repeat_analysis = (
    repeat_sessions.to_frame()
    .join(repeat_orders, how="left")
    .fillna(0)
)

repeat_analysis["conversion_rate"] = (
    repeat_analysis["orders"] / repeat_analysis["sessions"]
)

repeat_analysis.to_csv(
    OUTPUT_DIR / "new_vs_repeat.csv"
)

print("\n" + "=" * 70)
print("NEW VS REPEAT")
print("=" * 70)
print(repeat_analysis.to_string())


# ============================================================
# 10. PRODUCT ANALYSIS
# ============================================================

product_analysis = (
    order_items
    .merge(
        products[["product_id", "product_name"]],
        on="product_id",
        how="left",
    )
    .groupby(["product_id", "product_name"])
    .agg(
        units_sold=("order_item_id", "count"),
        revenue=("price_usd", "sum"),
        cogs=("cogs_usd", "sum"),
    )
    .reset_index()
)

product_analysis["gross_profit"] = (
    product_analysis["revenue"] - product_analysis["cogs"]
)

product_analysis["gross_margin"] = (
    product_analysis["gross_profit"]
    / product_analysis["revenue"]
)

product_analysis = product_analysis.sort_values(
    "revenue",
    ascending=False
)

product_analysis.to_csv(
    OUTPUT_DIR / "product_performance.csv",
    index=False,
)

print("\n" + "=" * 70)
print("PRODUCT PERFORMANCE")
print("=" * 70)
print(product_analysis.to_string(index=False))


# ============================================================
# 11. REFUND ANALYSIS
# ============================================================

total_refunds = refunds["refund_amount_usd"].sum()
refunded_items = refunds["order_item_id"].nunique()
total_items = order_items["order_item_id"].nunique()

refund_rate = (
    refunded_items / total_items
    if total_items
    else np.nan
)

refund_kpis = pd.DataFrame({
    "KPI": [
        "Total Refund Amount",
        "Refunded Items",
        "Total Order Items",
        "Refund Rate",
    ],
    "Value": [
        total_refunds,
        refunded_items,
        total_items,
        refund_rate,
    ],
})

refund_kpis.to_csv(
    OUTPUT_DIR / "refund_kpis.csv",
    index=False,
)

refund_by_product = (
    refunds
    .merge(
        order_items[["order_item_id", "product_id"]],
        on="order_item_id",
        how="left",
    )
    .merge(
        products[["product_id", "product_name"]],
        on="product_id",
        how="left",
    )
    .groupby(["product_id", "product_name"])
    .agg(
        refund_count=("order_item_refund_id", "nunique"),
        refund_amount=("refund_amount_usd", "sum"),
    )
    .reset_index()
    .sort_values("refund_amount", ascending=False)
)

refund_by_product.to_csv(
    OUTPUT_DIR / "refunds_by_product.csv",
    index=False,
)

print("\n" + "=" * 70)
print("REFUND ANALYSIS")
print("=" * 70)
print(f"Total Refund Amount : ${total_refunds:,.2f}")
print(f"Refunded Items      : {refunded_items:,.0f}")
print(f"Refund Rate         : {refund_rate:.2%}")


# ============================================================
# 12. PAGEVIEW ANALYSIS
# ============================================================

page_analysis = (
    pageviews
    .groupby("pageview_url")
    .agg(
        pageviews=("website_pageview_id", "count"),
        unique_sessions=("website_session_id", "nunique"),
    )
    .reset_index()
    .sort_values("pageviews", ascending=False)
)

page_analysis.to_csv(
    OUTPUT_DIR / "page_performance.csv",
    index=False,
)

print("\n" + "=" * 70)
print("TOP WEBSITE PAGES")
print("=" * 70)
print(page_analysis.head(15).to_string(index=False))


# ============================================================
# 13. DATA QUALITY: DUPLICATES
# ============================================================

quality_checks = {
    "duplicate_session_ids": sessions["website_session_id"].duplicated().sum(),
    "duplicate_pageview_ids": pageviews["website_pageview_id"].duplicated().sum(),
    "duplicate_order_ids": orders["order_id"].duplicated().sum(),
    "duplicate_order_item_ids": order_items["order_item_id"].duplicated().sum(),
    "duplicate_refund_ids": refunds["order_item_refund_id"].duplicated().sum(),
    "duplicate_product_ids": products["product_id"].duplicated().sum(),
}

quality_df = pd.DataFrame(
    list(quality_checks.items()),
    columns=["check", "count"],
)

quality_df.to_csv(
    OUTPUT_DIR / "data_quality_checks.csv",
    index=False,
)


# ============================================================
# 14. CHARTS
# ============================================================

# Monthly Revenue
plt.figure(figsize=(12, 6))
plt.plot(monthly["month"], monthly["revenue"])
plt.title("Monthly Revenue")
plt.xlabel("Month")
plt.ylabel("Revenue (USD)")
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig(CHART_DIR / "monthly_revenue.png", dpi=150)
plt.close()


# Monthly Conversion Rate
plt.figure(figsize=(12, 6))
plt.plot(
    monthly["month"],
    monthly["conversion_rate"] * 100,
)
plt.title("Monthly Conversion Rate")
plt.xlabel("Month")
plt.ylabel("Conversion Rate (%)")
plt.xticks(rotation=45)
plt.tight_layout()
plt.savefig(CHART_DIR / "monthly_conversion_rate.png", dpi=150)
plt.close()


# Revenue by Marketing Source
marketing_chart = marketing.sort_values(
    "revenue",
    ascending=True,
)

plt.figure(figsize=(10, 6))
plt.barh(
    marketing_chart["source"],
    marketing_chart["revenue"],
)
plt.title("Revenue by Marketing Source")
plt.xlabel("Revenue (USD)")
plt.ylabel("Marketing Source")
plt.tight_layout()
plt.savefig(CHART_DIR / "revenue_by_source.png", dpi=150)
plt.close()


# Conversion by Device
device_chart = device.sort_values(
    "conversion_rate",
    ascending=True,
)

plt.figure(figsize=(8, 5))
plt.bar(
    device_chart["device"],
    device_chart["conversion_rate"] * 100,
)
plt.title("Conversion Rate by Device")
plt.xlabel("Device")
plt.ylabel("Conversion Rate (%)")
plt.tight_layout()
plt.savefig(CHART_DIR / "conversion_by_device.png", dpi=150)
plt.close()


# Product Revenue
product_chart = product_analysis.sort_values(
    "revenue",
    ascending=True,
)

plt.figure(figsize=(10, 6))
plt.barh(
    product_chart["product_name"],
    product_chart["revenue"],
)
plt.title("Revenue by Product")
plt.xlabel("Revenue (USD)")
plt.ylabel("Product")
plt.tight_layout()
plt.savefig(CHART_DIR / "revenue_by_product.png", dpi=150)
plt.close()


# ============================================================
# 15. FINAL OUTPUT
# ============================================================

print("\n" + "=" * 70)
print("ANALYSIS COMPLETE")
print("=" * 70)

print(f"Outputs saved to: {OUTPUT_DIR}")
print(f"Charts saved to : {CHART_DIR}")

print("\nFiles created:")
for path in sorted(OUTPUT_DIR.rglob("*")):
    if path.is_file():
        print(f" - {path.relative_to(OUTPUT_DIR)}")
