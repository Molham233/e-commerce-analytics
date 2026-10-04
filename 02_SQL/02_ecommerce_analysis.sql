-- ============================================================
-- PROJECT 2: E-Commerce Analytics
-- Maven Fuzzy Factory
-- File: ecommerce_analysis.sql
--
-- IMPORTANT:
-- 1) Import the 6 CSV data tables into MySQL first.
-- 2) The table names expected by this script are:
--    website_sessions, website_pageviews, orders,
--    order_items, order_item_refunds, products
-- 3) Run this file section by section in MySQL Workbench.
-- ============================================================

-- ------------------------------------------------------------
-- 00. DATABASE
-- ------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS maven_fuzzy_factory;
USE maven_fuzzy_factory;

-- ------------------------------------------------------------
-- 01. DATA CHECKS
-- ------------------------------------------------------------

SELECT 'website_sessions' AS table_name, COUNT(*) AS row_count
FROM website_sessions;

SELECT 'website_pageviews' AS table_name, COUNT(*) AS row_count
FROM website_pageviews;

SELECT 'orders' AS table_name, COUNT(*) AS row_count
FROM orders;

SELECT 'order_items' AS table_name, COUNT(*) AS row_count
FROM order_items;

SELECT 'order_item_refunds' AS table_name, COUNT(*) AS row_count
FROM order_item_refunds;

SELECT 'products' AS table_name, COUNT(*) AS row_count
FROM products;


-- ============================================================
-- 02. BASIC BUSINESS KPIs
-- ============================================================

-- Total Sessions
SELECT
    COUNT(DISTINCT website_session_id) AS total_sessions
FROM website_sessions;

-- Total Pageviews
SELECT
    COUNT(DISTINCT website_pageview_id) AS total_pageviews
FROM website_pageviews;

-- Total Users
SELECT
    COUNT(DISTINCT user_id) AS total_users
FROM website_sessions;

-- Total Orders
SELECT
    COUNT(DISTINCT order_id) AS total_orders
FROM orders;

-- Total Products
SELECT
    COUNT(DISTINCT product_id) AS total_products
FROM products;


-- ============================================================
-- 03. REVENUE & PROFIT
-- ============================================================

-- Total Revenue
SELECT
    ROUND(SUM(price_usd), 2) AS total_revenue
FROM orders;

-- Total COGS
SELECT
    ROUND(SUM(cogs_usd), 2) AS total_cogs
FROM orders;

-- Gross Profit
SELECT
    ROUND(SUM(price_usd - cogs_usd), 2) AS gross_profit
FROM orders;

-- Gross Margin
SELECT
    ROUND(
        SUM(price_usd - cogs_usd) / NULLIF(SUM(price_usd), 0) * 100,
        2
    ) AS gross_margin_pct
FROM orders;

-- Average Order Value
SELECT
    ROUND(
        SUM(price_usd) / NULLIF(COUNT(DISTINCT order_id), 0),
        2
    ) AS average_order_value
FROM orders;


-- ============================================================
-- 04. OVERALL CONVERSION
-- ============================================================

SELECT
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(
        COUNT(DISTINCT o.order_id)
        / NULLIF(COUNT(DISTINCT ws.website_session_id), 0) * 100,
        2
    ) AS conversion_rate_pct
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id;


-- ============================================================
-- 05. MONTHLY PERFORMANCE
-- ============================================================

-- Monthly Sessions
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
GROUP BY DATE_FORMAT(created_at, '%Y-%m')
ORDER BY month;

-- Monthly Orders
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    COUNT(DISTINCT order_id) AS orders
FROM orders
GROUP BY DATE_FORMAT(created_at, '%Y-%m')
ORDER BY month;

-- Monthly Revenue
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    ROUND(SUM(price_usd), 2) AS revenue
FROM orders
GROUP BY DATE_FORMAT(created_at, '%Y-%m')
ORDER BY month;

-- Monthly Profit
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    ROUND(SUM(price_usd - cogs_usd), 2) AS gross_profit
FROM orders
GROUP BY DATE_FORMAT(created_at, '%Y-%m')
ORDER BY month;

-- Monthly Conversion Rate
SELECT
    DATE_FORMAT(ws.created_at, '%Y-%m') AS month,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(
        COUNT(DISTINCT o.order_id)
        / NULLIF(COUNT(DISTINCT ws.website_session_id), 0) * 100,
        2
    ) AS conversion_rate_pct
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY DATE_FORMAT(ws.created_at, '%Y-%m')
ORDER BY month;

-- Monthly AOV
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(price_usd), 2) AS revenue,
    ROUND(
        SUM(price_usd) / NULLIF(COUNT(DISTINCT order_id), 0),
        2
    ) AS aov
FROM orders
GROUP BY DATE_FORMAT(created_at, '%Y-%m')
ORDER BY month;


-- ============================================================
-- 06. MARKETING CHANNEL ANALYSIS
-- ============================================================

-- Sessions by UTM Source
SELECT
    COALESCE(utm_source, 'Direct / Unknown') AS source,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
GROUP BY COALESCE(utm_source, 'Direct / Unknown')
ORDER BY sessions DESC;

-- Sessions and Orders by Source
SELECT
    COALESCE(ws.utm_source, 'Direct / Unknown') AS source,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY COALESCE(ws.utm_source, 'Direct / Unknown')
ORDER BY sessions DESC;

-- Conversion Rate by Source
SELECT
    COALESCE(ws.utm_source, 'Direct / Unknown') AS source,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(
        COUNT(DISTINCT o.order_id)
        / NULLIF(COUNT(DISTINCT ws.website_session_id), 0) * 100,
        2
    ) AS conversion_rate_pct
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY COALESCE(ws.utm_source, 'Direct / Unknown')
ORDER BY conversion_rate_pct DESC;

-- Revenue by Source
SELECT
    COALESCE(ws.utm_source, 'Direct / Unknown') AS source,
    ROUND(SUM(o.price_usd), 2) AS revenue
FROM website_sessions ws
JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY COALESCE(ws.utm_source, 'Direct / Unknown')
ORDER BY revenue DESC;

-- Revenue per Session by Source
SELECT
    COALESCE(ws.utm_source, 'Direct / Unknown') AS source,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    ROUND(COALESCE(SUM(o.price_usd), 0), 2) AS revenue,
    ROUND(
        COALESCE(SUM(o.price_usd), 0)
        / NULLIF(COUNT(DISTINCT ws.website_session_id), 0),
        2
    ) AS revenue_per_session
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY COALESCE(ws.utm_source, 'Direct / Unknown')
ORDER BY revenue_per_session DESC;

-- Marketing Campaign Performance
SELECT
    COALESCE(utm_source, 'Direct / Unknown') AS source,
    COALESCE(utm_campaign, 'No Campaign') AS campaign,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
GROUP BY
    COALESCE(utm_source, 'Direct / Unknown'),
    COALESCE(utm_campaign, 'No Campaign')
ORDER BY sessions DESC;


-- ============================================================
-- 07. DEVICE ANALYSIS
-- ============================================================

SELECT
    COALESCE(ws.device_type, 'Unknown') AS device_type,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(
        COUNT(DISTINCT o.order_id)
        / NULLIF(COUNT(DISTINCT ws.website_session_id), 0) * 100,
        2
    ) AS conversion_rate_pct,
    ROUND(COALESCE(SUM(o.price_usd), 0), 2) AS revenue
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY COALESCE(ws.device_type, 'Unknown')
ORDER BY sessions DESC;


-- ============================================================
-- 08. NEW VS REPEAT SESSIONS
-- ============================================================

-- Session volume
SELECT
    CASE
        WHEN is_repeat_session = 1 THEN 'Repeat'
        ELSE 'New'
    END AS session_type,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
GROUP BY is_repeat_session
ORDER BY is_repeat_session;

-- Conversion by session type
SELECT
    CASE
        WHEN ws.is_repeat_session = 1 THEN 'Repeat'
        ELSE 'New'
    END AS session_type,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(
        COUNT(DISTINCT o.order_id)
        / NULLIF(COUNT(DISTINCT ws.website_session_id), 0) * 100,
        2
    ) AS conversion_rate_pct
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY ws.is_repeat_session
ORDER BY ws.is_repeat_session;


-- ============================================================
-- 09. PRODUCT PERFORMANCE
-- ============================================================

-- Units, Revenue and COGS by Product
SELECT
    p.product_id,
    p.product_name,
    COUNT(oi.order_item_id) AS units_sold,
    ROUND(SUM(oi.price_usd), 2) AS revenue,
    ROUND(SUM(oi.cogs_usd), 2) AS cogs,
    ROUND(SUM(oi.price_usd - oi.cogs_usd), 2) AS gross_profit
FROM products p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY revenue DESC;

-- Product Profit Margin
SELECT
    p.product_id,
    p.product_name,
    ROUND(SUM(oi.price_usd), 2) AS revenue,
    ROUND(SUM(oi.price_usd - oi.cogs_usd), 2) AS gross_profit,
    ROUND(
        SUM(oi.price_usd - oi.cogs_usd)
        / NULLIF(SUM(oi.price_usd), 0) * 100,
        2
    ) AS gross_margin_pct
FROM products p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY gross_profit DESC;

-- Monthly Product Revenue
SELECT
    DATE_FORMAT(oi.created_at, '%Y-%m') AS month,
    p.product_name,
    ROUND(SUM(oi.price_usd), 2) AS revenue,
    COUNT(oi.order_item_id) AS units_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    DATE_FORMAT(oi.created_at, '%Y-%m'),
    p.product_name
ORDER BY month, revenue DESC;


-- ============================================================
-- 10. REFUND ANALYSIS
-- ============================================================

-- Total Refund Amount
SELECT
    ROUND(SUM(refund_amount_usd), 2) AS total_refunds
FROM order_item_refunds;

-- Number of Refunded Items
SELECT
    COUNT(DISTINCT order_item_id) AS refunded_items
FROM order_item_refunds;

-- Refund Rate by Order Item
SELECT
    COUNT(DISTINCT r.order_item_id) AS refunded_items,
    COUNT(DISTINCT oi.order_item_id) AS total_items,
    ROUND(
        COUNT(DISTINCT r.order_item_id)
        / NULLIF(COUNT(DISTINCT oi.order_item_id), 0) * 100,
        2
    ) AS refund_rate_pct
FROM order_items oi
LEFT JOIN order_item_refunds r
    ON oi.order_item_id = r.order_item_id;

-- Refunds by Product
SELECT
    p.product_name,
    COUNT(DISTINCT r.order_item_refund_id) AS refund_count,
    ROUND(SUM(r.refund_amount_usd), 2) AS refund_amount
FROM order_item_refunds r
JOIN order_items oi
    ON r.order_item_id = oi.order_item_id
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY refund_amount DESC;


-- ============================================================
-- 11. WEBSITE PAGE ANALYSIS
-- ============================================================

-- Most Viewed Pages
SELECT
    pageview_url,
    COUNT(*) AS pageviews,
    COUNT(DISTINCT website_session_id) AS unique_sessions
FROM website_pageviews
GROUP BY pageview_url
ORDER BY pageviews DESC;

-- Pageviews by Month
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS month,
    COUNT(*) AS pageviews,
    COUNT(DISTINCT website_session_id) AS unique_sessions
FROM website_pageviews
GROUP BY DATE_FORMAT(created_at, '%Y-%m')
ORDER BY month;


-- ============================================================
-- 12. LANDING PAGE ANALYSIS
-- ============================================================

-- First pageview for each session
WITH first_pageview AS (
    SELECT
        website_session_id,
        MIN(created_at) AS first_pageview_time
    FROM website_pageviews
    GROUP BY website_session_id
)
SELECT
    wp.pageview_url AS landing_page,
    COUNT(DISTINCT wp.website_session_id) AS sessions
FROM website_pageviews wp
JOIN first_pageview fp
    ON wp.website_session_id = fp.website_session_id
    AND wp.created_at = fp.first_pageview_time
GROUP BY wp.pageview_url
ORDER BY sessions DESC;


-- ============================================================
-- 13. SESSION -> ORDER ANALYSIS
-- ============================================================

-- Sessions that converted vs did not convert
SELECT
    CASE
        WHEN o.order_id IS NOT NULL THEN 'Converted'
        ELSE 'Not Converted'
    END AS session_status,
    COUNT(DISTINCT ws.website_session_id) AS sessions
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY
    CASE
        WHEN o.order_id IS NOT NULL THEN 'Converted'
        ELSE 'Not Converted'
    END;


-- ============================================================
-- 14. DATA QUALITY CHECKS
-- ============================================================

-- Duplicate session IDs
SELECT
    website_session_id,
    COUNT(*) AS row_count
FROM website_sessions
GROUP BY website_session_id
HAVING COUNT(*) > 1;

-- Duplicate order IDs
SELECT
    order_id,
    COUNT(*) AS row_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Duplicate product IDs
SELECT
    product_id,
    COUNT(*) AS row_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Orders with missing session IDs
SELECT
    COUNT(*) AS missing_session_id
FROM orders
WHERE website_session_id IS NULL;

-- Order items with missing order IDs
SELECT
    COUNT(*) AS missing_order_id
FROM order_items
WHERE order_id IS NULL;

-- Refunds with missing order item IDs
SELECT
    COUNT(*) AS missing_order_item_id
FROM order_item_refunds
WHERE order_item_id IS NULL;


-- ============================================================
-- END OF SQL ANALYSIS
-- ============================================================
