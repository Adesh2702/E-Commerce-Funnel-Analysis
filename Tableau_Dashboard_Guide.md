# Tableau Dashboard Build Guide — E-Commerce Funnel Analysis

**Data source:** `tableau_extract.csv` (in this folder) — connect Tableau directly to this file, or to the `vw_funnel_by_segment` / `vw_daily_kpis` SQL views if you have a live database connection.

---

## 1. Calculated Fields to Create First

Create these in Tableau (Analysis → Create Calculated Field) before building any worksheet:

| Field Name | Formula | Purpose |
|---|---|---|
| `Conversion Rate` | `SUM([Purchase]) / SUM([Page View])` | Core KPI, format as % |
| `Cart Abandonment Rate` | `SUM([Cart Abandoned]) / SUM([Add to Cart])` | Root cause metric |
| `Checkout Abandonment Rate` | `SUM([Checkout Abandoned]) / SUM([Checkout])` | Root cause metric |
| `Bounce Rate` | `SUM([Bounce Flag]) / COUNT([Session ID])` | Engagement KPI |
| `Avg Order Value` | `SUM([Order Value]) / SUM([Purchase])` | Revenue KPI |
| `Funnel Stage (Numeric)` | `IF [Purchase]=1 THEN 5 ELSEIF [Checkout]=1 THEN 4 ELSEIF [Add to Cart]=1 THEN 3 ELSEIF [Product View]=1 THEN 2 ELSE 1 END` | Enables funnel chart sorting |
| `Revenue` | `SUM([Order Value])` | Simple alias for clarity in tooltips |

---

## 2. Worksheets to Build

### Worksheet 1 — "Funnel Overview" (Funnel Chart)
- **Chart type:** Horizontal bar / Funnel chart
- **Columns:** `SUM([Page View])`, `SUM([Product View])`, `SUM([Add to Cart])`, `SUM([Checkout])`, `SUM([Purchase])` (use a manually unioned/melted data source, or build 5 separate measures as one bar chart sorted descending)
- **Explanation:** This is the single most important chart — it visually shows the narrowing funnel. Label each bar with both the count and % of the top-of-funnel value.

### Worksheet 2 — "KPI Scorecards" (Executive Summary)
- **Chart type:** Text tables / BANs (Big Ass Numbers)
- **Measures:** Total Sessions, Overall Conversion Rate, Cart Abandonment Rate, Checkout Abandonment Rate, Total Revenue, Avg Order Value
- **Explanation:** These are the numbers a CEO looks at in the first 5 seconds. Use large, bold text with a small trend sparkline beside each if possible.

### Worksheet 3 — "Conversion Trend"
- **Chart type:** Line chart
- **Columns:** `Date` (continuous, by week)
- **Rows:** `Conversion Rate`
- **Explanation:** Shows whether the drop is a trend or a one-time event.

### Worksheet 4 — "Traffic Source Analysis"
- **Chart type:** Horizontal bar chart
- **Rows:** `Traffic Source`
- **Columns:** `Conversion Rate`
- **Color:** by Conversion Rate (diverging color scale, red = low)
- **Explanation:** Immediately flags which channels are underperforming.

### Worksheet 5 — "Device Analysis"
- **Chart type:** Bar chart
- **Rows:** `Device Type`
- **Columns:** `Conversion Rate` and `Bounce Rate` (dual axis)
- **Explanation:** Shows the mobile conversion gap clearly.

### Worksheet 6 — "Regional Map"
- **Chart type:** Filled/Symbol map
- **Requires:** Region needs Geographic Role assigned (Map → Geographic Role → State/Province, or use a custom polygon if regions are custom zones like "North/South/East/West/Central")
- **Color:** by `Conversion Rate`
- **Size:** by `Revenue`
- **Explanation:** Instantly shows geographic weak points.

### Worksheet 7 — "Category Performance"
- **Chart type:** Bar chart, dual-axis (Revenue as bars, Conversion Rate as a line/reference)
- **Rows:** `Product Category`
- **Explanation:** Separates "revenue leaders" from "conversion leaders" — they're not always the same.

### Worksheet 8 — "Drop-off Analysis" (Sankey-style or stacked bar)
- **Chart type:** Stacked bar showing Add to Cart vs Cart Abandoned, and Checkout vs Checkout Abandoned side by side
- **Explanation:** Pinpoints exactly where in the post-cart journey users vanish.

### Worksheet 9 — "Revenue Trend"
- **Chart type:** Area chart
- **Columns:** `Date` (by week or month)
- **Rows:** `Revenue`
- **Explanation:** Ties funnel health directly to money — the language executives respond to.

---

## 3. Filters to Add (Dashboard-level)

Add these as **Filter Actions** on the dashboard (not just worksheet filters), so clicking one chart filters all others:

1. **Date Range filter** — apply to `Date` field, set to relative or custom range
2. **Device filter** — quick filter (multi-select) on `Device Type`
3. **Region filter** — quick filter on `Region`
4. **Category filter** — quick filter on `Product Category`

---

## 4. Dashboard Layout

```
┌─────────────────────────────────────────────────────────┐
│                   KPI SCORECARDS (Worksheet 2)            │
├───────────────────────────┬───────────────────────────────┤
│   FUNNEL OVERVIEW (WS 1)   │   CONVERSION TREND (WS 3)     │
├───────────────┬────────────┼───────────────┬───────────────┤
│ TRAFFIC SOURCE │  DEVICE    │  REGIONAL MAP │   CATEGORY    │
│    (WS 4)      │  (WS 5)    │    (WS 6)     │    (WS 7)     │
├───────────────┴────────────┴───────────────┴───────────────┤
│   DROP-OFF ANALYSIS (WS 8)   |   REVENUE TREND (WS 9)       │
└─────────────────────────────────────────────────────────────┘
   [Date Filter] [Device Filter] [Region Filter] [Category Filter]
```

Combine into one Dashboard (Dashboard → New Dashboard), set size to "Automatic" or a fixed 1366x768 for consistent portfolio screenshots.

---

## 5. Dashboard Actions to Configure

1. **Filter Action:** Click on any bar in "Traffic Source Analysis" → filters Funnel Overview and Drop-off Analysis to that source only.
2. **Highlight Action:** Hovering over a region in the map highlights matching bars in Category Performance.
3. **URL Action (optional):** Clicking a KPI scorecard could link out to the full EDA_Insights_Report.md in your GitHub repo, for viewers who want the full story.

---

## 6. Publishing for Portfolio

- Publish to **Tableau Public** (free) so you get a shareable link.
- Take a full-dashboard screenshot and save it to `/Dashboard/dashboard_screenshot.png` for your README and LinkedIn post.
- Add the Tableau Public link to your resume and LinkedIn project post.
