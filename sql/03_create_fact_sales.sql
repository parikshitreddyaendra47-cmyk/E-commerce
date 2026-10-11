-- Requires MySQL 8.0+ and successful execution of 01 and 02.
USE ecommerce_dbw;

CREATE TABLE IF NOT EXISTS fact_sales (
    sales_key BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    order_item_id VARCHAR(50) NOT NULL,
    order_id VARCHAR(50) NOT NULL,
    customer_key BIGINT UNSIGNED NOT NULL,
    product_key BIGINT UNSIGNED NOT NULL,
    order_date_key INT NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    sales_amount DECIMAL(14,2) NOT NULL,
    order_status VARCHAR(50),
    payment_status VARCHAR(50),
    shipping_status VARCHAR(50),
    PRIMARY KEY (sales_key),
    UNIQUE KEY uq_fact_sales_order_item_id (order_item_id),
    KEY ix_fact_sales_order_id (order_id),
    KEY ix_fact_sales_customer_key (customer_key),
    KEY ix_fact_sales_product_key (product_key),
    KEY ix_fact_sales_order_date_key (order_date_key),
    CONSTRAINT fk_fact_sales_customer FOREIGN KEY (customer_key) REFERENCES dim_customers(customer_key),
    CONSTRAINT fk_fact_sales_product FOREIGN KEY (product_key) REFERENCES dim_products(product_key),
    CONSTRAINT fk_fact_sales_date FOREIGN KEY (order_date_key) REFERENCES dim_dates(date_key),
    CONSTRAINT chk_fact_sales_quantity CHECK (quantity > 0),
    CONSTRAINT chk_fact_sales_unit_price CHECK (unit_price >= 0)
);

-- Rebuild the fact table contents on each development run.
DELETE FROM fact_sales;

INSERT INTO fact_sales
    (order_item_id, order_id, customer_key, product_key, order_date_key,
     quantity, unit_price, sales_amount, order_status, payment_status, shipping_status)
SELECT
    TRIM(oi.order_item_id),
    TRIM(o.order_id),
    dc.customer_key,
    dp.product_key,
    CAST(DATE_FORMAT(parsed.order_date_value, '%Y%m%d') AS UNSIGNED),
    CAST(TRIM(oi.quantity) AS UNSIGNED),
    CAST(TRIM(oi.unit_price) AS DECIMAL(12,2)),
    CAST(TRIM(oi.quantity) AS DECIMAL(12,0)) * CAST(TRIM(oi.unit_price) AS DECIMAL(12,2)),
    NULLIF(TRIM(o.order_status), ''),
    NULLIF(TRIM(o.payment_status), ''),
    NULLIF(TRIM(o.shipping_status), '')
FROM stg_order_items oi
JOIN stg_orders o
  ON TRIM(o.order_id) = TRIM(oi.order_id)
JOIN dim_customers dc
  ON dc.customer_id = TRIM(o.customer_id)
JOIN dim_products dp
  ON dp.product_id = TRIM(oi.product_id)
JOIN (
    SELECT order_id,
           COALESCE(STR_TO_DATE(TRIM(order_date), '%Y-%m-%d'),
                    STR_TO_DATE(TRIM(order_date), '%m/%d/%Y')) AS order_date_value
    FROM stg_orders
) parsed
  ON parsed.order_id = o.order_id
JOIN dim_dates dd
  ON dd.full_date = parsed.order_date_value
WHERE oi.order_item_id IS NOT NULL AND TRIM(oi.order_item_id) <> ''
  AND TRIM(oi.quantity) REGEXP '^[0-9]+$'
  AND CAST(TRIM(oi.quantity) AS UNSIGNED) > 0
  AND TRIM(oi.unit_price) REGEXP '^[0-9]+([.][0-9]+)?$'
  AND CAST(TRIM(oi.unit_price) AS DECIMAL(12,2)) >= 0
  AND parsed.order_date_value IS NOT NULL;

-- Fact rows that do not join because a reference/date is missing are not inserted.
-- Review the unmatched-record checks in 04_validate_data_model.sql.
