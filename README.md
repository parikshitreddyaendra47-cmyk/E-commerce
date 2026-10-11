# E-Commerce Data Engineering & Analytics Platform

## Overview

An end-to-end data engineering and analytics platform for an e-commerce business.

## Objectives

- Collect e-commerce data
- Build data pipelines
- Clean and transform data
- Store data in a structured warehouse
- Perform data quality checks
- Create analytical models
- Build business dashboards
- Automate the pipeline

## Technology Stack

- Python
- SQL
- PostgreSQL
- PySpark
- Apache Airflow
- dbt
- Power BI
- Docker
- Git & GitHub
- AWS

## Project Status

Project initialization completed.

--------------------------------------------------
# KPI's
Total Revenue
= SUM(order_items.quantity × order_items.unit_price)

Total Orders
= COUNT(DISTINCT orders.order_id)

Total Customers
= COUNT(DISTINCT orders.customer_id)

Average Order Value
= Total Revenue / Total Orders

Items Sold
= SUM(order_items.quantity)

Revenue per Customer
= Total Revenue / Total Customers

Cancellation Rate
= Cancelled Orders / Total Orders

Delivery Rate
= Delivered Orders / Total Orders

----------------------------------------------
Your warehouse model can use these relationships:
CUSTOMERS
   │
   │ customer_id
   ▼
ORDERS
   │
   │ order_id
   ▼
ORDER_ITEMS
   │
   │ product_id
   ▼
PRODUCTS
---------------------------------------------------
customer.csv:
customer_id 
first_name
last_name
email
city
state
country
signup_date

products.csv
product_id
product_name
category
price
cost

orders.csv:
order_id
customer_id
order_date
order_status
payment_status
shipping_status

Orderitems.csv
order_item_id
order_id
product_id
quantity
unit_price
