
from pathlib import Path
import pandas as pd

RAW_DIR = Path("data/raw")
STAGING_DIR = Path("data/staging")
REJECTED_DIR = STAGING_DIR / "rejected"

FILES = {
    "customers": "customers.csv",
    "products": "products.csv",
    "orders": "orders.csv",
    "order_items": "order_items.csv",
}


def load_data():
    if not RAW_DIR.exists():
        raise FileNotFoundError(
            f"Raw data folder not found: {RAW_DIR.resolve()}"
        )

    data = {
        name: pd.read_csv(RAW_DIR / filename)
        for name, filename in FILES.items()
    }

    id_columns = {
        "customers": ["customer_id"],
        "products": ["product_id"],
        "orders": ["order_id", "customer_id"],
        "order_items": [
            "order_item_id", "order_id", "product_id"
        ],
    }

    for name, columns in id_columns.items():
        df = data[name]
        for column in columns:
            if column not in df.columns:
                raise ValueError(
                    f"Missing column '{column}' in {FILES[name]}"
                )
            df[column] = df[column].astype("string").str.strip()

    return data


def split_valid_invalid(df, valid_mask):
    valid_mask = valid_mask.fillna(False)
    return df.loc[valid_mask].copy(), df.loc[~valid_mask].copy()


def stage_data():
    STAGING_DIR.mkdir(parents=True, exist_ok=True)
    REJECTED_DIR.mkdir(parents=True, exist_ok=True)

    data = load_data()

    customers = data["customers"]
    products = data["products"]
    orders = data["orders"]
    items = data["order_items"]

    # Validate customer records used as order references.
    valid_customer_ids = set(customers["customer_id"].dropna())
    valid_product_ids = set(products["product_id"].dropna())
    valid_order_ids = set(orders["order_id"].dropna())

    # Reject orders with missing customer references.
    valid_orders_mask = (
        orders["customer_id"].notna()
        & orders["customer_id"].isin(valid_customer_ids)
    )
    valid_orders, rejected_orders = split_valid_invalid(
        orders, valid_orders_mask
    )

    # Reject items with missing order/product references,
    # non-positive quantities, or negative prices.
    valid_items_mask = (
        items["order_id"].notna()
        & items["order_id"].isin(valid_order_ids)
        & items["product_id"].notna()
        & items["product_id"].isin(valid_product_ids)
        & items["quantity"].gt(0)
        & items["unit_price"].ge(0)
    )

    valid_items, rejected_items = split_valid_invalid(
        items, valid_items_mask
    )

    # Customer and product tables have no row-level rejection
    # rules in the validation code provided so far.
    staged = {
        "customers": customers.copy(),
        "products": products.copy(),
        "orders": valid_orders,
        "order_items": valid_items,
    }

    rejected = {
        "orders": rejected_orders,
        "order_items": rejected_items,
    }

    # Save staged files.
    for name, df in staged.items():
        df.to_csv(STAGING_DIR / f"{name}_staged.csv", index=False)

    # Save rejected records for investigation.
    for name, df in rejected.items():
        df.to_csv(REJECTED_DIR / f"{name}_rejected.csv", index=False)

    # Report row counts.
    print("\n===== STAGING SUMMARY =====")

    for name in FILES:
        processed = len(data[name])
        accepted = len(staged[name])
        rejected_count = len(rejected.get(name, []))

        print(
            f"{name}: processed={processed}, "
            f"accepted={accepted}, rejected={rejected_count}"
        )

    print(f"\nStaged files: {STAGING_DIR.resolve()}")
    print(f"Rejected files: {REJECTED_DIR.resolve()}")


if __name__ == "__main__":
    stage_data()
