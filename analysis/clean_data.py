from pathlib import Path
import pandas as pd

# Project root = parent directory of this script's folder
project_root = Path(__file__).resolve().parent.parent

# File paths
input_file = project_root / "data" / "raw" / "WA_Fn-UseC_-Telco-Customer-Churn.csv"
output_file = project_root / "data" / "cleaned" / "telco_churn_cleaned.csv"

# Load raw data
df = pd.read_csv(input_file)

# Convert whitespace-only TotalCharges values to missing values
df["TotalCharges"] = pd.to_numeric(df["TotalCharges"], errors="coerce")

# Save cleaned copy
df.to_csv(output_file, index=False)

print(f"Rows: {len(df)}")
print(f"Columns: {len(df.columns)}")
print(f"Missing TotalCharges: {df['TotalCharges'].isna().sum()}")
print(f"Cleaned file saved to: {output_file}")