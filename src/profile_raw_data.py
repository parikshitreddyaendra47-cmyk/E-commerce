
from pathlib import Path
import pandas as pd

RAW_DIR = Path("data/raw")

if not RAW_DIR.exists():
    raise FileNotFoundError(
        f"Raw data folder not found: {RAW_DIR.resolve()}"
    )

csv_files = sorted(RAW_DIR.glob("*.csv"))

if not csv_files:
    raise FileNotFoundError(
        "No CSV files found inside data/raw/"
    )

for file_path in csv_files:
    print("\n" + "=" * 60)
    print(f"FILE: {file_path.name}")
    print("=" * 60)

    df = pd.read_csv(file_path)

    print(f"Rows: {len(df)}")
    print(f"Columns: {len(df.columns)}")

    print("\nColumn names:")
    print(df.columns.tolist())

    print("\nData types:")
    print(df.dtypes.to_string())

    print("\nMissing values per column:")
    print(df.isna().sum().to_string())

    print(f"\nDuplicate rows: {df.duplicated().sum()}")

    key_candidates = {
        "customers.csv": "customer_id",
        "products.csv": "product_id",
        "orders.csv": "order_id",
        "order_items.csv": "order_item_id",
    }

    key = key_candidates.get(file_path.name)

    if key and key in df.columns:
        print(f"\nMissing {key}: {df[key].isna().sum()}")
        print(f"Duplicate {key}: {df[key].duplicated().sum()}")

    print("\nFirst 5 rows:")
    print(df.head().to_string(index=False))
