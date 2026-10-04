-- ============================================================
-- PROJECT 2: E-Commerce Analytics
-- Maven Fuzzy Factory
-- File: 01_create_database_and_load_data.sql
--
-- Purpose:
--   1. Create the MySQL database
--   2. Create all six source tables
--   3. Load the CSV files
--   4. Add indexes and foreign-key relationships
--   5. Verify row counts
--
-- IMPORTANT:
--   Replace C:/YOUR_PROJECT_PATH with the actual path to the
--   project's 01_Data folder before running this script.
--
-- MySQL Workbench:
--   LOCAL INFILE must be enabled.
--   If you get a "Loading local data is disabled" error, enable
--   local_infile in MySQL/Workbench and reconnect.
--
-- Expected CSV row counts:
--   website_sessions       472,871
--   website_pageviews    1,188,124
--   orders                 32,313
--   order_items            40,025
--   order_item_refunds      1,731
--   products                    4
-- ============================================================

CREATE DATABASE IF NOT EXISTS maven_fuzzy_factory;
USE maven_fuzzy_factory;

-- ------------------------------------------------------------
-- 01. CREATE TABLES
-- ------------------------------------------------------------

DROP TABLE IF EXISTS order_item_refunds;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS website_pageviews;
DROP TABLE IF EXISTS website_sessions;
DROP TABLE IF EXISTS products;

CREATE TABLE products (
    product_id INT NOT NULL,
    created_at DATETIME NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    PRIMARY KEY (product_id)
);

CREATE TABLE website_sessions (
    website_session_id BIGINT NOT NULL,
    created_at DATETIME NOT NULL,
    user_id BIGINT NOT NULL,
    is_repeat_session TINYINT NOT NULL,
    utm_source VARCHAR(100),
    utm_campaign VARCHAR(100),
    utm_content VARCHAR(100),
    device_type VARCHAR(50),
    http_referer VARCHAR(500),
    PRIMARY KEY (website_session_id),
    INDEX idx_sessions_user_id (user_id)
);

CREATE TABLE website_pageviews (
    website_pageview_id BIGINT NOT NULL,
    created_at DATETIME NOT NULL,
    website_session_id BIGINT NOT NULL,
    pageview_url VARCHAR(255) NOT NULL,
    PRIMARY KEY (website_pageview_id),
    INDEX idx_pageviews_session_id (website_session_id)
);

CREATE TABLE orders (
    order_id BIGINT NOT NULL,
    created_at DATETIME NOT NULL,
    website_session_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    primary_product_id INT,
    items_purchased INT,
    price_usd DECIMAL(12,2),
    cogs_usd DECIMAL(12,2),
    PRIMARY KEY (order_id),
    INDEX idx_orders_session_id (website_session_id),
    INDEX idx_orders_user_id (user_id),
    INDEX idx_orders_product_id (primary_product_id)
);

CREATE TABLE order_items (
    order_item_id BIGINT NOT NULL,
    created_at DATETIME NOT NULL,
    order_id BIGINT NOT NULL,
    product_id INT NOT NULL,
    is_primary_item TINYINT NOT NULL,
    price_usd DECIMAL(12,2),
    cogs_usd DECIMAL(12,2),
    PRIMARY KEY (order_item_id),
    INDEX idx_order_items_order_id (order_id),
    INDEX idx_order_items_product_id (product_id)
);

CREATE TABLE order_item_refunds (
    order_item_refund_id BIGINT NOT NULL,
    created_at DATETIME NOT NULL,
    order_item_id BIGINT NOT NULL,
    order_id BIGINT NOT NULL,
    refund_amount_usd DECIMAL(12,2),
    PRIMARY KEY (order_item_refund_id),
    INDEX idx_refunds_order_item_id (order_item_id),
    INDEX idx_refunds_order_id (order_id)
);

-- ------------------------------------------------------------
-- 02. LOAD CSV DATA
-- ------------------------------------------------------------
-- Windows paths are used below because this project was built
-- on Windows. Change only the YOUR_PROJECT_PATH part.
-- Example:
-- C:/Users/YourName/Documents/E-Commerce-Analytics-Portfolio/01_Data/website_sessions.csv

LOAD DATA LOCAL INFILE 'C:/YOUR_PROJECT_PATH/01_Data/website_sessions.csv'
INTO TABLE website_sessions
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(website_session_id, created_at, user_id, is_repeat_session,
 utm_source, utm_campaign, utm_content, device_type, http_referer);

LOAD DATA LOCAL INFILE 'C:/YOUR_PROJECT_PATH/01_Data/website_pageviews.csv'
INTO TABLE website_pageviews
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(website_pageview_id, created_at, website_session_id, pageview_url);

LOAD DATA LOCAL INFILE 'C:/YOUR_PROJECT_PATH/01_Data/orders.csv'
INTO TABLE orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(order_id, created_at, website_session_id, user_id,
 primary_product_id, items_purchased, price_usd, cogs_usd);

LOAD DATA LOCAL INFILE 'C:/YOUR_PROJECT_PATH/01_Data/order_items.csv'
INTO TABLE order_items
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(order_item_id, created_at, order_id, product_id,
 is_primary_item, price_usd, cogs_usd);

LOAD DATA LOCAL INFILE 'C:/YOUR_PROJECT_PATH/01_Data/order_item_refunds.csv'
INTO TABLE order_item_refunds
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(order_item_refund_id, created_at, order_item_id, order_id, refund_amount_usd);

LOAD DATA LOCAL INFILE 'C:/YOUR_PROJECT_PATH/01_Data/products.csv'
INTO TABLE products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(product_id, created_at, product_name);

-- ------------------------------------------------------------
-- 03. FOREIGN-KEY RELATIONSHIPS
-- ------------------------------------------------------------

ALTER TABLE website_pageviews
    ADD CONSTRAINT fk_pageviews_session
    FOREIGN KEY (website_session_id)
    REFERENCES website_sessions (website_session_id);

ALTER TABLE orders
    ADD CONSTRAINT fk_orders_session
    FOREIGN KEY (website_session_id)
    REFERENCES website_sessions (website_session_id);

ALTER TABLE order_items
    ADD CONSTRAINT fk_order_items_order
    FOREIGN KEY (order_id)
    REFERENCES orders (order_id);

ALTER TABLE order_items
    ADD CONSTRAINT fk_order_items_product
    FOREIGN KEY (product_id)
    REFERENCES products (product_id);

ALTER TABLE order_item_refunds
    ADD CONSTRAINT fk_refunds_order_item
    FOREIGN KEY (order_item_id)
    REFERENCES order_items (order_item_id);

ALTER TABLE order_item_refunds
    ADD CONSTRAINT fk_refunds_order
    FOREIGN KEY (order_id)
    REFERENCES orders (order_id);

-- ------------------------------------------------------------
-- 04. VERIFICATION
-- ------------------------------------------------------------

SELECT 'website_sessions' AS table_name, COUNT(*) AS row_count
FROM website_sessions
UNION ALL
SELECT 'website_pageviews', COUNT(*)
FROM website_pageviews
UNION ALL
SELECT 'orders', COUNT(*)
FROM orders
UNION ALL
SELECT 'order_items', COUNT(*)
FROM order_items
UNION ALL
SELECT 'order_item_refunds', COUNT(*)
FROM order_item_refunds
UNION ALL
SELECT 'products', COUNT(*)
FROM products;
