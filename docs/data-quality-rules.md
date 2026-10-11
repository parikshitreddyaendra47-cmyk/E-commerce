# E-Commerce Data Platform — Data Quality Rules

## 1. Purpose

This document defines the data quality rules for the E-Commerce Data Engineering & Analytics Platform.

These rules help ensure that customer, product, order, and order item data is accurate, complete, consistent, and suitable for downstream analytics.

## 2. Scope

The rules apply to the following raw datasets:

- `customers.csv`
- `products.csv`
- `orders.csv`
- `order_items.csv`

## 3. Data Quality Rules

| Rule ID | Dataset | Column(s) | Quality Rule | Severity |
|---|---|---|---|---|
| DQ001 | customers.csv | customer_id | Customer ID must not be null or duplicated. | Critical |
| DQ002 | products.csv | product_id | Product ID must not be null or duplicated. | Critical |
| DQ003 | orders.csv | order_id | Order ID must not be null or duplicated. | Critical |
| DQ004 | order_items.csv | order_item_id | Order item ID must not be null or duplicated. | Critical |
| DQ005 | orders.csv | customer_id | Every order must reference an existing customer. | Critical |
| DQ006 | order_items.csv | order_id | Every order item must reference an existing order. | Critical |
| DQ007 | order_items.csv | product_id | Every order item must reference an existing product. | Critical |
| DQ008 | order_items.csv | quantity | Quantity must be greater than zero. | High |
| DQ009 | order_items.csv | unit_price | Unit price must not be negative. | High |
| DQ010 | products.csv | price | Product price must not be negative. | High |
| DQ011 | products.csv | cost | Product cost must not be negative. | High |
| DQ012 | customers.csv | signup_date | Signup date must be a valid date. | High |
| DQ013 | orders.csv | order_date | Order date must be a valid date. | High |
| DQ014 | orders.csv | order_status | Order status must belong to the approved business values. | Medium |
| DQ015 | orders.csv | payment_status | Payment status must belong to the approved business values. | Medium |
| DQ016 | orders.csv | shipping_status | Shipping status must belong to the approved business values. | Medium |

## 4. Initial Validation Results

The following checks have been executed using `src/validate_raw_data.py`.

| Validation | Result |
|---|---|
| Order customer references | PASS |
| Order item order references | PASS |
| Order item product references | PASS |
| Positive quantities | PASS |
| Non-negative order item prices | PASS |

The initial profiling also reported no missing values and no duplicate complete rows in the four raw datasets.

**Note:** Primary-key uniqueness, valid dates, product price and cost rules, and approved status values still require explicit validation. The profiling results do not prove that all these rules pass.

## 5. Handling Data Quality Failures

When a record fails a critical rule, it must not silently enter the trusted analytics layer.

The engineering team should:

1. Identify the dataset and affected records.
2. Record the failed rule and the number of affected records.
3. Investigate whether the issue originated in the source data or during processing.
4. Correct the source or apply an approved transformation when appropriate.
5. Re-run the relevant validation.
6. Document the resolution.

Records that fail non-critical rules should be reviewed according to the business impact and the agreed project policy.

## 6. Business Rules Requiring Confirmation

The following details must be confirmed before all rules can be enforced:

- The approved values for order, payment, and shipping statuses.
- Whether product cost may exceed product selling price.
- Whether future signup and order dates are permitted.
- How cancelled orders and refunded payments should be represented in analytics.

## 7. Next Steps

- Complete validation of primary keys and missing values.
- Validate dates, numeric fields, and status values.
- Record validation results.
- Clean and standardize the data in the staging layer.
- Build dimension and fact tables after the staging data meets the agreed quality requirements.
