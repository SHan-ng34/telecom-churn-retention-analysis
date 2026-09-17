import pandas as pd

# File paths
input_file = r"C:\Users\hanus\OneDrive\Documents\telco_churn\data\raw\WA_Fn-UseC_-Telco-Customer-Churn.csv"
output_file = r"C:\Users\hanus\OneDrive\Documents\telco_churn\data\cleaned\telco_churn_cleaned.csv"

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