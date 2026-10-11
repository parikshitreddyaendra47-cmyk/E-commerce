-- Run after importing staging data and building dimensions/facts.
USE ecommerce_dbw;

SELECT 'stg_customers' AS table_name, COUNT(*) AS row_count FROM stg_customers
UNION ALL SELECT 'stg_products', COUNT(*) FROM stg_products
UNION ALL SELECT 'stg_orders', COUNT(*) FROM stg_orders
UNION ALL SELECT 'stg_order_items', COUNT(*) FROM stg_order_items
UNION ALL SELECT 'dim_customers', COUNT(*) FROM dim_customers
UNION ALL SELECT 'dim_products', COUNT(*) FROM dim_products
UNION ALL SELECT 'dim_dates', COUNT(*) FROM dim_dates
UNION ALL SELECT 'fact_sales', COUNT(*) FROM fact_sales;

-- Check for order items that did not make it into the fact table.
SELECT oi.order_item_id, oi.order_id, oi.product_id, oi.quantity, oi.unit_price
FROM stg_order_items oi
LEFT JOIN fact_sales f ON f.order_item_id = TRIM(oi.order_item_id)
WHERE f.order_item_id IS NULL;

-- Check that fact sales amounts equal quantity multiplied by unit price.
SELECT COUNT(*) AS incorrect_sales_amount_rows
FROM fact_sales
WHERE sales_amount <> quantity * unit_price;

-- Sample business metrics.
SELECT SUM(sales_amount) AS total_sales_amount,
       SUM(quantity) AS total_units_sold,
       COUNT(DISTINCT order_id) AS total_orders,
       COUNT(*) AS order_item_rows
FROM fact_sales;

-- Revenue by product category.
SELECT p.category, SUM(f.sales_amount) AS sales_amount
FROM fact_sales f
JOIN dim_products p ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY sales_amount DESC;

-- Revenue by month.
SELECT d.year_number, d.month_number, d.month_name,
       SUM(f.sales_amount) AS sales_amount
FROM fact_sales f
JOIN dim_dates d ON d.date_key = f.order_date_key
GROUP BY d.year_number, d.month_number, d.month_name
ORDER BY d.year_number, d.month_number;
