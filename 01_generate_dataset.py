"""
04_funnel_rootcause.py
------------------------
MENTOR NOTE: This script formalizes Phase 6 (Funnel Metrics) and Phase 7
(Root Cause Analysis). We compute every funnel KPI precisely, then break
each one down by the 8 dimensions the business asked about, producing a
single root-cause report that feeds directly into our recommendations.
"""

import pandas as pd

CLEAN_PATH = "/home/claude/E-Commerce-Funnel-Analysis/Dataset/ecommerce_funnel_clean.csv"
df = pd.read_csv(CLEAN_PATH, parse_dates=["Date"])

report_lines = ["# Funnel Metrics & Root Cause Analysis Report\n"]

# ---------------------------------------------------------
# PHASE 6: Core Funnel Metrics
# ---------------------------------------------------------
total_sessions = len(df)
product_views = df["Product_View"].sum()
add_to_carts = df["Add_to_Cart"].sum()
checkouts = df["Checkout"].sum()
purchases = df["Purchase"].sum()

metrics = {
    "Total Visitors (Sessions)": total_sessions,
    "Product View Rate": product_views / total_sessions * 100,
    "Add to Cart Rate (of Product Views)": add_to_carts / product_views * 100,
    "Checkout Rate (of Add to Cart)": checkouts / add_to_carts * 100,
    "Purchase Rate (of Checkout)": purchases / checkouts * 100,
    "Overall Conversion Rate (Purchases / Sessions)": purchases / total_sessions * 100,
    "Cart Abandonment Rate": df["Cart_Abandoned"].sum() / add_to_carts * 100,
    "Checkout Abandonment Rate": df["Checkout_Abandoned"].sum() / checkouts * 100,
    "Bounce Rate": df["Bounce_Flag"].sum() / total_sessions * 100,
}

report_lines.append("## Phase 6: Core Funnel Metrics\n")
report_lines.append("| Metric | Value |\n|---|---|")
for k, v in metrics.items():
    if isinstance(v, float):
        report_lines.append(f"| {k} | {v:.2f}% |" if "Rate" in k else f"| {k} | {v:,.0f} |")
    else:
        report_lines.append(f"| {k} | {v:,.0f} |")

# Identify biggest percentage drop between consecutive stages
stage_counts = {
    "Page View": total_sessions,
    "Product View": product_views,
    "Add to Cart": add_to_carts,
    "Checkout": checkouts,
    "Purchase": purchases,
}
stages = list(stage_counts.items())
drop_report = []
for i in range(len(stages) - 1):
    (name_a, val_a), (name_b, val_b) = stages[i], stages[i + 1]
    drop_pct = (1 - val_b / val_a) * 100
    drop_report.append((f"{name_a} -> {name_b}", drop_pct))

biggest_drop = max(drop_report, key=lambda x: x[1])
report_lines.append(f"\n**Biggest Drop-off Point:** `{biggest_drop[0]}` "
                     f"with a **{biggest_drop[1]:.1f}%** drop.\n")

report_lines.append("\n### Drop-off at Every Stage\n| Transition | % Drop |\n|---|---|")
for name, pct in drop_report:
    report_lines.append(f"| {name} | {pct:.1f}% |")

# ---------------------------------------------------------
# PHASE 7: Root Cause Analysis by 8 dimensions
# ---------------------------------------------------------
report_lines.append("\n## Phase 7: Root Cause Analysis by Segment\n")

dimensions = {
    "Traffic Source": "Traffic_Source",
    "Device": "Device_Type",
    "Region": "Region",
    "Category": "Product_Category",
    "Payment Method": "Payment_Method",
    "Weekend vs Weekday": "Is_Weekend",
    "New vs Returning User": "Is_Returning_User",
    "Discount Offered": "Discount",
}

for label, col in dimensions.items():
    seg = df.groupby(col)["Purchase"].agg(["count", "mean"]).sort_values("mean", ascending=False)
    seg["mean"] = (seg["mean"] * 100).round(2)
    seg = seg.rename(columns={"count": "Sessions", "mean": "Conversion_Rate_%"})
    report_lines.append(f"\n### By {label}\n")
    report_lines.append(seg.to_markdown())

# ---------------------------------------------------------
# Revenue Opportunity Estimate
# ---------------------------------------------------------
device_stats = df.groupby("Device_Type").agg(
    sessions=("Session_ID", "count"),
    conv_rate=("Purchase", "mean"),
).reset_index()
device_stats["aov"] = df[df["Purchase"] == 1].groupby("Device_Type")["Order_Value"].mean().reindex(
    device_stats["Device_Type"]).values

best_rate = device_stats["conv_rate"].max()
device_stats["opportunity_revenue"] = device_stats["sessions"] * (best_rate - device_stats["conv_rate"]) * device_stats["aov"]
total_opportunity = device_stats["opportunity_revenue"].clip(lower=0).sum()

report_lines.append(f"\n## Estimated Revenue Opportunity\n")
report_lines.append(
    f"If every device matched the best-performing device's conversion rate "
    f"({best_rate*100:.2f}%), the business could recover approximately "
    f"**₹{total_opportunity:,.0f}** in additional revenue from the current session volume.\n"
)

with open("/home/claude/E-Commerce-Funnel-Analysis/Reports/Funnel_RootCause_Report.md", "w") as f:
    f.write("\n".join(report_lines))

print("Funnel & Root Cause report generated.")
print(f"\nOverall Conversion Rate: {metrics['Overall Conversion Rate (Purchases / Sessions)']:.2f}%")
print(f"Biggest Drop-off: {biggest_drop[0]} ({biggest_drop[1]:.1f}%)")
print(f"Estimated Revenue Opportunity: Rs {total_opportunity:,.0f}")
