
from pathlib import Path
import pandas as pd

# Location of raw CSV files
RAW_DIR = Path("data/raw")

# Check that the raw data folder exists
if not RAW_DIR.exists():
    raise FileNotFoundError(
        f"Raw data folder not found: {RAW_DIR.resolve()}"
    )

# Load all four CSV files
customers = pd.read_csv(RAW_DIR / "customers.csv")
products = pd.read_csv(RAW_DIR / "products.csv")
orders = pd.read_csv(RAW_DIR / "orders.csv")
items = pd.read_csv(RAW_DIR / "order_items.csv")

# Remove accidental spaces from ID values
for df, columns in [
    (customers, ["customer_id"]),
    (products, ["product_id"]),
    (orders, ["order_id", "customer_id"]),
    (items, ["order_item_id", "order_id", "product_id"]),
]:
    for column in columns:
        df[column] = df[column].astype("string").str.strip()

# Check 1: Does every order reference an existing customer?
missing_customers = orders[
    ~orders["customer_id"].isin(customers["customer_id"])
]

# Check 2: Does every order item reference an existing order?
missing_orders = items[
    ~items["order_id"].isin(orders["order_id"])
]

# Check 3: Does every order item reference an existing product?
missing_products = items[
    ~items["product_id"].isin(products["product_id"])
]

# Check 4: Are quantities positive?
invalid_quantities = items[items["quantity"] <= 0]

# Check 5: Are item prices non-negative?
invalid_item_prices = items[items["unit_price"] < 0]

# Print the results
print("\n===== DATA RELATIONSHIP VALIDATION =====")

print("\nOrders with missing customer references:")
print(missing_customers[["order_id", "customer_id"]].to_string(index=False)
      if not missing_customers.empty else "PASS - No missing customers")

print("\nItems with missing order references:")
print(missing_orders[["order_item_id", "order_id"]].to_string(index=False)
      if not missing_orders.empty else "PASS - No missing orders")

print("\nItems with missing product references:")
print(missing_products[["order_item_id", "product_id"]].to_string(index=False)
      if not missing_products.empty else "PASS - No missing products")

print("\nItems with invalid quantities:")
print(invalid_quantities.to_string(index=False)
      if not invalid_quantities.empty else "PASS - All quantities are positive")

print("\nItems with negative prices:")
print(invalid_item_prices.to_string(index=False)
      if not invalid_item_prices.empty else "PASS - No negative item prices")

print("\n===== VALIDATION COMPLETED =====")

