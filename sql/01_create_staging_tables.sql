-- Run this first in MySQL 8.0+.
-- Create the project database and tables that receive the four staged CSV files.

CREATE DATABASE IF NOT EXISTS ecommerce_dbw
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE ecommerce_dbw;

-- Import data/staging/customers_staged.csv into stg_customers
CREATE TABLE IF NOT EXISTS stg_customers (
    customer_id VARCHAR(50),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    signup_date VARCHAR(30)
);

-- Import data/staging/products_staged.csv into stg_products
CREATE TABLE IF NOT EXISTS stg_products (
    product_id VARCHAR(50),
    product_name VARCHAR(255),
    category VARCHAR(100),
    price VARCHAR(50),
    cost VARCHAR(50)
);

-- Import data/staging/orders_staged.csv into stg_orders
CREATE TABLE IF NOT EXISTS stg_orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_date VARCHAR(30),
    order_status VARCHAR(50),
    payment_status VARCHAR(50),
    shipping_status VARCHAR(50)
);

-- Import data/staging/order_items_staged.csv into stg_order_items
CREATE TABLE IF NOT EXISTS stg_order_items (
    order_item_id VARCHAR(50),
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    quantity VARCHAR(50),
    unit_price VARCHAR(50)
);

-- Import the CSVs using MySQL Workbench's Table Data Import Wizard:
--   customers_staged.csv   -> stg_customers
--   products_staged.csv    -> stg_products
--   orders_staged.csv      -> stg_orders
--   order_items_staged.csv -> stg_order_items
-- Ensure the wizard maps columns by name and does not import the header as data.
-- If re-running imports, truncate the relevant stg_* table first to avoid duplicates.
