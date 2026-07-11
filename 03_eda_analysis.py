"""
02_data_cleaning.py
--------------------
MENTOR NOTE: Real-world data is ALWAYS messy. Before any analysis, a Data Analyst's
job #1 is to make sure the data can be trusted. We will go step by step:

1. Import & Inspect      -> understand shape, types, and first impressions
2. Missing Values        -> decide: drop, fill, or flag
3. Duplicates            -> remove exact duplicate tracking events
4. Incorrect Values      -> fix impossible values (negative time, inconsistent text)
5. Data Type Conversion  -> make sure dates are dates, flags are integers, etc.
6. Feature Engineering   -> create new useful columns for analysis
7. Validation            -> sanity-check the final cleaned data
8. Save                  -> export a clean CSV that Phase 4/5/6/7 will all use
"""

import pandas as pd
import numpy as np

RAW_PATH = "/home/claude/E-Commerce-Funnel-Analysis/Dataset/ecommerce_funnel_raw.csv"
CLEAN_PATH = "/home/claude/E-Commerce-Funnel-Analysis/Dataset/ecommerce_funnel_clean.csv"

# ---------------------------------------------------------
# STEP 1: Import & Inspect
# ---------------------------------------------------------
df = pd.read_csv(RAW_PATH)

print("=" * 60)
print("STEP 1: INITIAL INSPECTION")
print("=" * 60)
print(f"Shape: {df.shape}")
print("\nData types:\n", df.dtypes)
print("\nMissing values per column:\n", df.isnull().sum()[df.isnull().sum() > 0])
print(f"\nExact duplicate rows: {df.duplicated().sum()}")

# ---------------------------------------------------------
# STEP 2: Missing Value Treatment
# ---------------------------------------------------------
# WHY: 'Region' has some missing values (simulating a tracking bug where
# geo-IP lookup failed). Since Region is a categorical business dimension,
# dropping these rows would lose valid funnel events. Instead we label them
# "Unknown" so we don't lose the session, but we can still exclude them
# from region-specific analysis if needed.
print("\n" + "=" * 60)
print("STEP 2: MISSING VALUE TREATMENT")
print("=" * 60)

missing_before = df["Region"].isnull().sum()
df["Region"] = df["Region"].fillna("Unknown")
print(f"Filled {missing_before} missing Region values with 'Unknown'")

# ---------------------------------------------------------
# STEP 3: Duplicate Removal
# ---------------------------------------------------------
# WHY: Duplicate rows usually happen when a tracking pixel/event fires twice
# (e.g., user double-clicks, or page reloads re-sends the event). These
# inflate our funnel counts artificially, so we must remove exact duplicates.
print("\n" + "=" * 60)
print("STEP 3: DUPLICATE REMOVAL")
print("=" * 60)

before = len(df)
df = df.drop_duplicates()
after = len(df)
print(f"Removed {before - after} exact duplicate rows ({before} -> {after})")

# ---------------------------------------------------------
# STEP 4: Fixing Incorrect Values
# ---------------------------------------------------------
print("\n" + "=" * 60)
print("STEP 4: FIXING INCORRECT VALUES")
print("=" * 60)

# 4a. Time_On_Page cannot be negative -> these are broken tracking events.
#     We replace negative values with the median time for that same bounce
#     status (bounced vs engaged), since bounced/engaged sessions have very
#     different typical durations.
neg_time_count = (df["Time_On_Page"] < 0).sum()
median_bounced = df.loc[df["Bounce_Flag"] == 1, "Time_On_Page"].median()
median_engaged = df.loc[df["Bounce_Flag"] == 0, "Time_On_Page"].median()

df.loc[(df["Time_On_Page"] < 0) & (df["Bounce_Flag"] == 1), "Time_On_Page"] = median_bounced
df.loc[(df["Time_On_Page"] < 0) & (df["Bounce_Flag"] == 0), "Time_On_Page"] = median_engaged
print(f"Fixed {neg_time_count} negative Time_On_Page values using median imputation")

# 4b. Device_Type has inconsistent casing ('mobile' vs 'Mobile') -> standardize
inconsistent_case = df["Device_Type"].str.istitle().eq(False).sum()
df["Device_Type"] = df["Device_Type"].str.strip().str.title()
print(f"Standardized casing for {inconsistent_case} Device_Type values")

# 4c. Trim whitespace / standardize text across all object (string) columns
obj_cols = df.select_dtypes(include="object").columns
for col in obj_cols:
    df[col] = df[col].astype(str).str.strip()
print(f"Trimmed whitespace across {len(obj_cols)} text columns")

# ---------------------------------------------------------
# STEP 5: Data Type Conversion
# ---------------------------------------------------------
print("\n" + "=" * 60)
print("STEP 5: DATA TYPE CONVERSION")
print("=" * 60)

df["Date"] = pd.to_datetime(df["Date"])
flag_cols = ["Page_View", "Product_View", "Add_to_Cart", "Checkout", "Purchase",
             "Bounce_Flag", "Discount", "Is_Returning_User"]
df[flag_cols] = df[flag_cols].astype(int)
df["Order_Value"] = df["Order_Value"].astype(float).round(2)
print("Converted: Date -> datetime, funnel/flag columns -> int, Order_Value -> float")

# ---------------------------------------------------------
# STEP 6: Feature Engineering
# ---------------------------------------------------------
# WHY: Raw columns tell us WHAT happened. Engineered features help us answer
# WHY it happened and let SQL/Tableau slice data more easily later.
print("\n" + "=" * 60)
print("STEP 6: FEATURE ENGINEERING")
print("=" * 60)

df["Day_Name"] = df["Date"].dt.day_name()
df["Is_Weekend"] = df["Day_Name"].isin(["Saturday", "Sunday"]).astype(int)
df["Month"] = df["Date"].dt.month_name()
df["Week_Number"] = df["Date"].dt.isocalendar().week

# A session "converted" only if it completed the full funnel to Purchase
df["Funnel_Stage_Reached"] = np.select(
    [
        df["Purchase"] == 1,
        df["Checkout"] == 1,
        df["Add_to_Cart"] == 1,
        df["Product_View"] == 1,
    ],
    ["Purchase", "Checkout", "Add_to_Cart", "Product_View"],
    default="Page_View_Only",
)

# Cart abandonment: added to cart but never purchased
df["Cart_Abandoned"] = np.where((df["Add_to_Cart"] == 1) & (df["Purchase"] == 0), 1, 0)
# Checkout abandonment: reached checkout but never purchased
df["Checkout_Abandoned"] = np.where((df["Checkout"] == 1) & (df["Purchase"] == 0), 1, 0)

print("Created columns: Day_Name, Is_Weekend, Month, Week_Number, "
      "Funnel_Stage_Reached, Cart_Abandoned, Checkout_Abandoned")

# ---------------------------------------------------------
# STEP 7: Data Validation (sanity checks)
# ---------------------------------------------------------
print("\n" + "=" * 60)
print("STEP 7: VALIDATION")
print("=" * 60)

# Logical rule: you cannot purchase without checking out, cannot check out without
# adding to cart, cannot add to cart without viewing a product.
invalid_funnel_logic = df[
    ((df["Purchase"] == 1) & (df["Checkout"] == 0)) |
    ((df["Checkout"] == 1) & (df["Add_to_Cart"] == 0)) |
    ((df["Add_to_Cart"] == 1) & (df["Product_View"] == 0))
]
print(f"Rows violating funnel logic (should be 0): {len(invalid_funnel_logic)}")

# Order value should be 0 only when Purchase == 0, and > 0 when Purchase == 1
mismatch = df[((df["Purchase"] == 1) & (df["Order_Value"] <= 0)) |
              ((df["Purchase"] == 0) & (df["Order_Value"] > 0))]
print(f"Rows with Order_Value / Purchase mismatch (should be 0): {len(mismatch)}")

assert len(invalid_funnel_logic) == 0, "Funnel logic broken - investigate!"
assert len(mismatch) == 0, "Order value logic broken - investigate!"
print("All validation checks passed.")

# ---------------------------------------------------------
# STEP 8: Save Cleaned Dataset
# ---------------------------------------------------------
df.to_csv(CLEAN_PATH, index=False)
print("\n" + "=" * 60)
print(f"CLEANED DATASET SAVED: {CLEAN_PATH}")
print(f"Final shape: {df.shape}")
print("=" * 60)
