# 🛒 E-Commerce Funnel Analysis: Root Cause of Conversion Drop

**Author:** [Adesh Kishor Dakhore] · **Tools:** SQL · Python (Pandas, Matplotlib, Seaborn) · Tableau

An end-to-end data analytics project investigating why customers drop off during the online purchase journey, identifying the exact root causes with segment-level analysis, and delivering a Tableau dashboard + actionable business recommendations.

---

## 📌 Business Problem

The company observed a declining overall conversion rate despite stable website traffic. Leadership needed to know **where** in the funnel customers were dropping off and **why**, in order to prioritize fixes over guesswork.

## 🎯 Key Finding

> The biggest leak in the funnel is between **Add to Cart → Checkout (a 59.3% drop)** — driven disproportionately by **Mobile users** and by friction in **COD / Net Banking** payment flows. Closing this gap represents an estimated **₹35.6 Lakh** in recoverable revenue from current traffic alone — no additional marketing spend required.

## 📊 Dashboard Preview

Open [`dashboard_preview.html`](dashboard_preview.html) in any browser for an interactive preview of the KPIs and charts (built with Chart.js from the same cleaned data). For the full Tableau version, follow [`Tableau_Dashboard_Guide.md`](Tableau_Dashboard_Guide.md).

*Tip: take a screenshot of the HTML preview or your published Tableau dashboard and save it here as `Dashboard/dashboard_screenshot.png` to embed in this README for GitHub/LinkedIn.*

---

## 🗂️ Project Structure

```
E-Commerce-Funnel-Analysis/
│
├── Dataset/
│   ├── ecommerce_funnel_raw.csv         # Simulated raw data (with realistic quality issues)
│   └── ecommerce_funnel_clean.csv       # Cleaned, validated, feature-engineered dataset
│
├── Python/
│   ├── 01_generate_dataset.py           # Synthetic dataset generator
│   ├── 02_data_cleaning.py              # Missing values, duplicates, validation
│   ├── 03_eda_analysis.py               # 12 charts + business insights
│   └── 04_funnel_rootcause.py           # Funnel KPIs + root cause by 8 dimensions
│
├── SQL/
│   └── ecommerce_funnel_queries.sql     # 45 queries: joins, CTEs, window functions, views
│
├── Tableau/
│   ├── tableau_extract.csv              # Clean data ready to connect in Tableau
│   └── Tableau_Dashboard_Guide.md       # Full build guide: calc fields, worksheets, actions
│
├── Dashboard/
│   ├── dashboard_preview.html           # Standalone interactive HTML preview
│   └── dashboard_data.json              # Data backing the preview
│
├── Images/                              # 12 exported EDA charts (PNG)
│
├── Reports/
│   ├── EDA_Insights_Report.md           # 14 insights: observation → insight → recommendation
│   └── Funnel_RootCause_Report.md       # Full funnel metrics + segment-level root cause
│
├── requirements.txt
└── README.md
```

---

## 🔧 Tech Stack

| Layer | Tool | Purpose |
|---|---|---|
| Data Generation & Cleaning | Python (Pandas, NumPy) | Simulate realistic session data, clean & validate |
| Analysis | Python (Matplotlib, Seaborn) | Exploratory data analysis, 12 charts |
| Querying | SQL (PostgreSQL/MySQL syntax) | 45 business queries: joins, CTEs, window functions |
| Visualization | Tableau | Interactive executive dashboard |

---

## 📈 Funnel Overview

| Stage | Sessions | % of Top |
|---|---|---|
| Page View | 50,000 | 100% |
| Product View | 31,373 | 62.7% |
| Add to Cart | 13,551 | 27.1% |
| Checkout | 5,522 | 11.0% |
| Purchase | 3,655 | **7.3%** |

**Overall Conversion Rate: 7.31%** | **Cart Abandonment: 73.0%** | **Checkout Abandonment: 33.8%**

---

## 🔍 Root Cause Highlights

- **Device:** Desktop converts at 9.86% vs Mobile at 5.94% — a ~40% relative gap, concentrated at the checkout step.
- **Traffic Source:** Email (9.21%) and Direct (8.91%) far outperform Paid Ads (6.00%) and Social Media (6.20%).
- **Payment Method:** UPI/Wallet complete checkout at ~69-70%, while COD/Net Banking complete at only 57-61%.
- **Discount:** Sessions with a discount convert measurably higher than those without.
- **User Type:** Returning users convert notably higher than first-time visitors.

Full breakdown with numbers: [`funnel_rootcause.py`](funnel_rootcause.py)

---

## ✅ Recommendations

1. **Mobile checkout audit** — reduce form fields, add one-tap UPI/wallet payment, test load speed on 3G/4G.
2. **Guest checkout** — remove forced login at the Add to Cart → Checkout step (single biggest leak).
3. **Fix COD/Net Banking friction** — investigate OTP delays and bank redirect failures.
4. **Shift ad spend** from Paid Ads/Social toward Email/Direct-style retention channels, or improve targeting quality.
5. **Targeted cart-recovery discounts** instead of blanket site-wide discounting.

---

## 🚀 How to Reproduce

```bash
pip install -r requirements.txt
python Python/01_generate_dataset.py
python Python/02_data_cleaning.py
python Python/03_eda_analysis.py
python Python/04_funnel_rootcause.py
```

Then load `SQL/ecommerce_funnel_queries.sql` into PostgreSQL/MySQL, and connect Tableau to `Tableau/tableau_extract.csv`.

---

## 📄 License

MIT License — free to use and adapt for learning purposes.
