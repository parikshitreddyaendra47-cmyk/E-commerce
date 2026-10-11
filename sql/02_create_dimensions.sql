-- Requires MySQL 8.0+ and data imported into all four stg_* tables.
USE ecommerce_dbw;

CREATE TABLE IF NOT EXISTS dim_customers (
    customer_key BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    customer_id VARCHAR(50) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    signup_date DATE NULL,
    PRIMARY KEY (customer_key),
    UNIQUE KEY uq_dim_customers_customer_id (customer_id)
);

CREATE TABLE IF NOT EXISTS dim_products (
    product_key BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    product_id VARCHAR(50) NOT NULL,
    product_name VARCHAR(255),
    category VARCHAR(100),
    listed_price DECIMAL(12,2) NULL,
    product_cost DECIMAL(12,2) NULL,
    PRIMARY KEY (product_key),
    UNIQUE KEY uq_dim_products_product_id (product_id)
);

CREATE TABLE IF NOT EXISTS dim_dates (
    date_key INT NOT NULL,
    full_date DATE NOT NULL,
    day_of_month TINYINT UNSIGNED NOT NULL,
    month_number TINYINT UNSIGNED NOT NULL,
    month_name VARCHAR(15) NOT NULL,
    quarter_number TINYINT UNSIGNED NOT NULL,
    year_number SMALLINT UNSIGNED NOT NULL,
    day_of_week_name VARCHAR(15) NOT NULL,
    PRIMARY KEY (date_key),
    UNIQUE KEY uq_dim_dates_full_date (full_date)
);

-- Upsert dimensions so the script can be rerun without deleting rows
-- that may already be referenced by fact_sales.

INSERT INTO dim_customers
    (customer_id, first_name, last_name, email, city, state, country, signup_date)
SELECT
    TRIM(customer_id), NULLIF(TRIM(first_name), ''), NULLIF(TRIM(last_name), ''),
    NULLIF(TRIM(email), ''), NULLIF(TRIM(city), ''), NULLIF(TRIM(state), ''),
    NULLIF(TRIM(country), ''),
    CASE
      WHEN signup_date IS NULL OR TRIM(signup_date) = '' THEN NULL
      ELSE COALESCE(STR_TO_DATE(TRIM(signup_date), '%Y-%m-%d'),
                    STR_TO_DATE(TRIM(signup_date), '%m/%d/%Y'))
    END
FROM stg_customers
WHERE customer_id IS NOT NULL AND TRIM(customer_id) <> ''
ON DUPLICATE KEY UPDATE
    first_name = VALUES(first_name), last_name = VALUES(last_name),
    email = VALUES(email), city = VALUES(city), state = VALUES(state),
    country = VALUES(country), signup_date = VALUES(signup_date);

INSERT INTO dim_products
    (product_id, product_name, category, listed_price, product_cost)
SELECT
    TRIM(product_id), NULLIF(TRIM(product_name), ''), NULLIF(TRIM(category), ''),
    CASE WHEN TRIM(price) REGEXP '^-?[0-9]+([.][0-9]+)?$' THEN CAST(price AS DECIMAL(12,2)) ELSE NULL END,
    CASE WHEN TRIM(cost) REGEXP '^-?[0-9]+([.][0-9]+)?$' THEN CAST(cost AS DECIMAL(12,2)) ELSE NULL END
FROM stg_products
WHERE product_id IS NOT NULL AND TRIM(product_id) <> ''
ON DUPLICATE KEY UPDATE
    product_name = VALUES(product_name), category = VALUES(category),
    listed_price = VALUES(listed_price), product_cost = VALUES(product_cost);

-- Build the date dimension for every date between the earliest and latest order.
-- The fact script also handles an empty orders table (no dates inserted).
INSERT IGNORE INTO dim_dates
    (date_key, full_date, day_of_month, month_number, month_name,
     quarter_number, year_number, day_of_week_name)
WITH RECURSIVE date_series AS (
    SELECT MIN(parsed_order_date) AS d
    FROM (
      SELECT COALESCE(STR_TO_DATE(TRIM(order_date), '%Y-%m-%d'),
                      STR_TO_DATE(TRIM(order_date), '%m/%d/%Y')) AS parsed_order_date
      FROM stg_orders
    ) parsed
    WHERE parsed_order_date IS NOT NULL
    UNION ALL
    SELECT DATE_ADD(d, INTERVAL 1 DAY)
    FROM date_series
    WHERE d < (
      SELECT MAX(parsed_order_date)
      FROM (
        SELECT COALESCE(STR_TO_DATE(TRIM(order_date), '%Y-%m-%d'),
                        STR_TO_DATE(TRIM(order_date), '%m/%d/%Y')) AS parsed_order_date
        FROM stg_orders
      ) parsed_max
      WHERE parsed_order_date IS NOT NULL
    )
)
SELECT
    CAST(DATE_FORMAT(d, '%Y%m%d') AS UNSIGNED), d, DAY(d), MONTH(d),
    DATE_FORMAT(d, '%M'), QUARTER(d), YEAR(d), DATE_FORMAT(d, '%W')
FROM date_series
WHERE d IS NOT NULL;
