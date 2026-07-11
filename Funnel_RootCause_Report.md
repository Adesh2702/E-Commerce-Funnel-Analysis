# Interview Preparation — E-Commerce Funnel Analysis Project

---

## 🗄️ SQL Questions (30)

1. **What is the difference between WHERE and HAVING?**
   WHERE filters individual rows before aggregation; HAVING filters groups after GROUP BY/aggregation. E.g., we used HAVING to keep only regions with avg order value > ₹2000.

2. **What is a Primary Key vs Foreign Key?**
   A Primary Key uniquely identifies each row in a table (e.g., `session_id`). A Foreign Key is a column referencing a Primary Key in another table, enforcing referential integrity (e.g., `region` in `funnel_sessions` referencing `region_targets`).

3. **Explain INNER JOIN vs LEFT JOIN.**
   INNER JOIN returns only matching rows from both tables. LEFT JOIN returns all rows from the left table plus matches from the right (NULL if no match) — I used LEFT JOIN to find regions missing a revenue target.

4. **What is a subquery? Give an example from your project.**
   A query nested inside another query. I used one to find categories whose average order value exceeds the platform-wide average.

5. **What is a CTE and why use it over a subquery?**
   A Common Table Expression (WITH clause) is a named, temporary result set. It improves readability for multi-step logic and can be referenced multiple times, unlike a subquery.

6. **Explain window functions and how they differ from GROUP BY.**
   Window functions (RANK, ROW_NUMBER, LAG, SUM() OVER) compute values across a set of rows related to the current row WITHOUT collapsing rows like GROUP BY does — you keep row-level detail plus an aggregate context.

7. **Difference between RANK(), DENSE_RANK(), and ROW_NUMBER()?**
   RANK() skips numbers after a tie (1,2,2,4); DENSE_RANK() doesn't skip (1,2,2,3); ROW_NUMBER() gives a unique sequential number regardless of ties.

8. **What does PARTITION BY do?**
   It divides rows into groups (partitions) for a window function to operate on independently — e.g., ranking regions within each category separately.

9. **How would you calculate a running total in SQL?**
   `SUM(value) OVER (ORDER BY date)` — used in our project to track cumulative daily revenue.

10. **What is the difference between UNION and UNION ALL?**
    UNION removes duplicate rows across combined result sets; UNION ALL keeps all rows (faster). We used UNION ALL to stack funnel stage counts into one table for charting.

11. **What does NULLIF do, and why did you use it in your queries?**
    NULLIF(x, 0) returns NULL if x = 0, avoiding a divide-by-zero error — used when calculating abandonment rate in case a segment had zero sessions.

12. **How do you find duplicate rows in SQL?**
    `SELECT col, COUNT(*) FROM table GROUP BY col HAVING COUNT(*) > 1;`

13. **What's the difference between DELETE, TRUNCATE, and DROP?**
    DELETE removes rows (can use WHERE, is logged, rollback possible); TRUNCATE removes all rows fast (no WHERE, minimal logging); DROP removes the entire table structure.

14. **What is a VIEW and why use one?**
    A VIEW is a saved, reusable virtual table based on a query. I created `vw_funnel_by_segment` so Tableau could connect to a pre-aggregated, always-current data source without re-writing the query.

15. **How do you calculate a conversion rate in SQL?**
    `AVG(purchase_flag) * 100` — since the flag is 0/1, its average is the proportion of 1s, i.e., the conversion rate.

16. **What's the purpose of the CASE statement?**
    It creates conditional logic inline in a query — I used it to bucket sessions into engagement tiers and label the deepest funnel stage reached.

17. **Explain the difference between COUNT(*), COUNT(column), and COUNT(DISTINCT column).**
    COUNT(*) counts all rows; COUNT(column) counts non-NULL values in that column; COUNT(DISTINCT column) counts unique non-NULL values.

18. **What is an index and why does it matter for performance?**
    An index is a data structure that speeds up row lookups on a column (like a book's index), critical for large tables — e.g., indexing `session_date` speeds up date-range filtering.

19. **How would you find the second-highest order value?**
    `SELECT MAX(order_value) FROM funnel_sessions WHERE order_value < (SELECT MAX(order_value) FROM funnel_sessions);` or using `DENSE_RANK()`.

20. **What does GROUP BY do internally?**
    It groups rows sharing the same value(s) in specified columns so aggregate functions (SUM, AVG, COUNT) can be applied per group instead of the whole table.

21. **How do you handle NULL values in aggregations?**
    Most aggregate functions ignore NULLs automatically (e.g., AVG skips NULLs) — but COUNT(*) counts rows including those with NULLs in other columns.

22. **What is the difference between a correlated and non-correlated subquery?**
    A correlated subquery references the outer query's columns and runs once per outer row (e.g., our max order value per category query); a non-correlated subquery runs independently once.

23. **How would you calculate week-over-week percentage change in SQL?**
    Using `LAG()`: `(current - LAG(current) OVER (ORDER BY week)) / LAG(current) OVER (ORDER BY week) * 100`.

24. **What's the difference between a clustered and non-clustered index?**
    A clustered index determines the physical row order on disk (one per table); a non-clustered index is a separate structure pointing to row locations (multiple allowed).

25. **How do you optimize a slow SQL query?**
    Check execution plan (EXPLAIN), add indexes on filtered/joined columns, avoid SELECT *, avoid functions on indexed columns in WHERE, and reduce unnecessary subqueries/joins.

26. **What is normalization? Name the first three normal forms briefly.**
    Normalization organizes data to reduce redundancy. 1NF: atomic values, no repeating groups. 2NF: 1NF + no partial dependency on a composite key. 3NF: 2NF + no transitive dependency on non-key columns.

27. **How would you find users who purchased in every month of the dataset?**
    Group by user and month, count distinct months, compare to total number of months in the dataset using HAVING.

28. **What's the difference between a scalar subquery and a table subquery?**
    A scalar subquery returns a single value (usable in SELECT/WHERE with =); a table subquery returns multiple rows/columns (usable with IN, EXISTS, or as a derived table in FROM).

29. **How do you pivot data in SQL (rows to columns)?**
    Using conditional aggregation: `SUM(CASE WHEN device_type='Mobile' THEN purchase ELSE 0 END) AS mobile_purchases`, repeated per column, or native PIVOT in some databases.

30. **Why did you build both raw SELECT queries and a VIEW for this project?**
    Ad-hoc SELECTs are for one-time investigation; the VIEW packages the most frequently needed aggregation for repeated use — specifically so Tableau always pulls fresh, pre-shaped data without duplicating query logic.

---

## 🐍 Python Questions (20)

1. **Why use Pandas for this project instead of raw Python?**
   Pandas provides vectorized operations (fast, no manual loops), built-in handling for missing data, groupby aggregation, and easy CSV I/O — essential for tabular data at scale.

2. **How did you handle missing values in the Region column?**
   Filled with `"Unknown"` using `fillna()` rather than dropping rows, preserving valid funnel events while flagging incomplete geo data.

3. **What's the difference between `dropna()` and `fillna()`?**
   `dropna()` removes rows/columns with missing values; `fillna()` replaces them with a specified value (mean, median, constant, etc.), preserving row count.

4. **How do you detect and remove duplicate rows in Pandas?**
   `df.duplicated().sum()` to detect, `df.drop_duplicates()` to remove exact duplicate rows.

5. **What is feature engineering, and give an example from your project.**
   Creating new, more useful columns from existing data — e.g., deriving `Is_Weekend` from `Date`, or `Cart_Abandoned` from `Add_to_Cart` and `Purchase` flags.

6. **Explain `groupby()` and how you used it.**
   `groupby()` splits data into groups by a column's values, applies an aggregation, and combines results — used throughout for conversion rate by device/source/region.

7. **What does `np.select()` do, and why use it over nested `if`?**
   It vectorizes multi-condition logic across an array, applying the first matching condition per row — much faster than looping with if/else, used to assign `Funnel_Stage_Reached`.

8. **How do you convert a column to datetime in Pandas?**
   `pd.to_datetime(df['Date'])`, which enables `.dt` accessor methods like `.dt.day_name()` or `.dt.weekday`.

9. **What's the difference between `.loc[]` and `.iloc[]`?**
   `.loc[]` selects by label/condition; `.iloc[]` selects by integer position.

10. **How did you validate your cleaned dataset?**
    Used `assert` statements to confirm funnel logic (e.g., no purchase without checkout) and no logical mismatches between Purchase and Order_Value — this fails loudly if cleaning introduced errors.

11. **What is vectorization, and why does it matter in Pandas/NumPy?**
    Performing operations on entire arrays at once instead of row-by-row loops — dramatically faster because it uses optimized C code under the hood.

12. **How would you find the correlation between two numeric columns?**
    `df['col1'].corr(df['col2'])` or `df.corr()` for a full matrix.

13. **What's the purpose of `random.seed()` / `np.random.seed()` in your data generation script?**
    Ensures reproducibility — running the script again produces the exact same "random" dataset, which matters for debugging and consistent portfolio results.

14. **How do you handle outliers in a numeric column?**
    Options include IQR-based capping, z-score filtering, or domain-driven capping (e.g., we didn't remove outliers in Order_Value since large purchases are legitimate business events, not errors).

15. **What's the difference between `apply()` and vectorized operations?**
    `apply()` runs a Python function row-by-row (flexible but slower); vectorized operations use built-in Pandas/NumPy methods operating on whole columns at once (faster).

16. **How did you calculate conversion rate for each segment in Python?**
    `df.groupby('Device_Type')['Purchase'].mean() * 100` — mean of a 0/1 flag equals the proportion of 1s.

17. **What library did you use for visualization, and why both Matplotlib and Seaborn?**
    Matplotlib for base plotting control; Seaborn for statistical plots with better default styling (e.g., `barplot`, `boxplot`) built on top of Matplotlib.

18. **How do you save a Pandas DataFrame to CSV?**
    `df.to_csv('path.csv', index=False)` — `index=False` avoids writing the DataFrame's row index as an extra column.

19. **What's a boxplot useful for, and where did you use one?**
    Shows median, quartiles, and outliers of a numeric distribution — used to compare Time_On_Page between bounced vs engaged sessions.

20. **How would you scale this analysis if the dataset were 50 million rows instead of 50,000?**
    Move processing to SQL/a database or a distributed engine (Spark/BigQuery) rather than loading everything into Pandas in memory; use chunked reading, sampling for EDA, and push aggregations upstream.

---

## 📊 Tableau Questions (20)

1. **What is a calculated field, and give one you used.**
   A custom field defined by a formula, e.g., `Conversion Rate = SUM([Purchase])/SUM([Page View])`.

2. **What's the difference between a dimension and a measure?**
   Dimensions are qualitative/categorical fields used to slice data (Device Type, Region); measures are quantitative fields that get aggregated (Order Value, Purchase count).

3. **What is a dashboard action, and which did you configure?**
   An interaction that connects worksheets — I set up a filter action so clicking a Traffic Source bar filters the Funnel Overview and Drop-off charts to that source.

4. **Filter action vs Highlight action — what's the difference?**
   A filter action actually removes non-matching data from other views; a highlight action just visually emphasizes matching marks while keeping all data visible.

5. **What's a Level of Detail (LOD) expression, and when would you use one?**
   LOD expressions (FIXED/INCLUDE/EXCLUDE) compute aggregations at a different granularity than the view — e.g., calculating each user's lifetime average order value independent of current filters.

6. **How do you create a KPI scorecard in Tableau?**
   Use a Text table or a single large "BAN" (Big Ass Number) worksheet showing one measure with large formatting, often placed in a dashboard header.

7. **What is a parameter, and how might you use one in this project?**
   A parameter is a user-adjustable input (like a dropdown or slider) that can dynamically change a calculation — e.g., a parameter to switch the funnel chart between "Count" and "% of Total" view.

8. **How do you handle a field that isn't automatically recognized as geographic (like our custom Region names)?**
   Assign a Geographic Role manually, or map custom region names to actual states/coordinates via a join, or use them for a non-map visualization instead.

9. **What's a Sankey/flow chart useful for, and did you consider one?**
   Shows flow and volume loss between sequential stages — well-suited for the funnel drop-off itself, requiring workaround techniques in Tableau (dual-axis polygon technique) since it's not a native chart type.

10. **What's the difference between a live connection and an extract in Tableau?**
    A live connection queries the source database in real time; an extract is a saved, compressed snapshot of the data that's faster to work with but needs manual/scheduled refreshing.

11. **How would you show both Revenue and Conversion Rate on the same chart?**
    Use a dual-axis chart — one measure as bars, the other as a line on a secondary axis, synchronized.

12. **What's a Quick Filter, and how does it differ from a Context Filter?**
    A Quick Filter is an interactive on-dashboard filter control; a Context Filter is applied first and creates a temporary "context" that other filters/calculations run against, useful for performance and dependent filtering.

13. **How do you make a dashboard mobile-friendly?**
    Use the Device Designer in Tableau to create a phone/tablet-specific layout with simplified, stacked worksheets.

14. **What's the purpose of Tableau Public vs Tableau Desktop?**
    Tableau Public is a free platform to publish and share dashboards publicly (great for portfolios); Tableau Desktop is the full authoring tool, often requiring a paid license, with private workbook options.

15. **How would you show week-over-week decline visually?**
    A line chart with reference lines for a target/average, or a KPI trend arrow calculated field comparing current vs prior period.

16. **What's the difference between discrete and continuous fields in Tableau (blue vs green pills)?**
    Discrete fields (blue) create separate headers/categories; continuous fields (green) create a continuous axis — this affects how a date field renders (as buckets vs a trend line).

17. **How do you combine data from SQL and a CSV in Tableau?**
    Use Tableau's Data Relationships/Joins feature or a Union/Blend, connecting to both sources and relating them on a common key.

18. **What is the purpose of a Tooltip, and how did you customize one in this project?**
    Tooltips show contextual detail on hover — customized to show segment-level conversion rate and revenue when hovering over funnel/category bars.

19. **How would you set up an automatic data refresh for a live dashboard?**
    Schedule an extract refresh via Tableau Server/Cloud, or use a live connection if the underlying database supports real-time queries efficiently.

20. **Why present both an HTML preview and a Tableau dashboard in this project?**
    The HTML preview (built with Chart.js) lets anyone view the results instantly with zero software required — useful for quick portfolio review — while Tableau demonstrates hands-on skill with the industry-standard BI tool employers expect.

---

## 💼 Business Questions (20)

1. **Why is a declining conversion rate a serious business problem even if revenue looks stable?**
   It signals inefficiency: the business is paying to acquire visitors that aren't converting, meaning rising acquisition cost per sale and vulnerability if traffic ever dips.

2. **How do you decide which metric is the "North Star" for this project?**
   Overall Conversion Rate, because it's the single metric that captures the entire funnel's health and is directly tied to revenue, while sub-metrics (cart/checkout rate) explain *why* it moves.

3. **Why look at cart abandonment and checkout abandonment separately?**
   They represent different problems — cart abandonment often reflects browsing/comparison behavior, while checkout abandonment usually reflects friction (forms, payment, trust) at the final commitment step.

4. **If mobile has more sessions but lower conversion, should the business reduce mobile marketing?**
   No — mobile represents the majority of demand; the fix is improving the mobile experience, not suppressing mobile traffic, since that traffic still converts, just less efficiently than desktop.

5. **How would you prioritize which root cause to fix first?**
   By estimated revenue impact and implementation cost — in this project, mobile checkout friction had both the largest volume and a clear, addressable UX fix, so it was prioritized first.

6. **What's the risk of only offering blanket discounts to fix conversion?**
   It erodes margin on customers who would have purchased anyway; targeted discounts (e.g., only at cart-abandonment risk) are more cost-effective.

7. **How do you know the conversion issue isn't a data tracking bug rather than a real behavior?**
   By validating funnel logic (no purchase without checkout, etc.) and checking that traffic volume is stable — a tracking bug would usually show up as an impossible pattern, which we ruled out during data cleaning.

8. **Why does the Region field matter for this analysis?**
   It can reveal external factors like logistics/delivery quality or regional payment preferences that a device/channel-only view would miss.

9. **What's the business value of segmenting new vs returning users?**
   It clarifies whether the conversion problem is an acquisition/trust problem (new users) or a retention/experience problem (returning users), pointing to very different fixes.

10. **How would you explain "Add to Cart → Checkout drop-off" to a non-technical stakeholder?**
    "Customers are picking items but changing their mind — or hitting a wall — right before they try to pay. That's the single biggest point where we're losing sales."

11. **What's the difference between correlation and causation, and where does it matter here?**
    Correlation shows two things move together; causation means one causes the other. E.g., discount correlating with higher conversion doesn't prove discounts cause purchases for users who would have bought anyway — an A/B test would be needed to confirm causation.

12. **How would you measure whether your recommendations actually worked after implementation?**
    Set up a before/after comparison (or ideally an A/B test) tracking the same funnel KPIs post-launch, isolating the specific stage targeted by the fix.

13. **What's an appropriate timeframe to expect results after implementing the mobile checkout fix?**
    Typically 4-8 weeks to gather enough session volume for statistically meaningful before/after comparison, depending on traffic.

14. **Why is Average Order Value (AOV) important alongside Conversion Rate?**
    A high conversion rate with a very low AOV might still generate less revenue than a lower conversion rate with a high AOV — both metrics are needed for a complete revenue picture.

15. **How would you pitch the ₹35.6L revenue opportunity to leadership?**
    Frame it as a "no incremental marketing spend required" opportunity — it is unlocked entirely by fixing existing traffic's conversion efficiency, which is usually cheaper than acquiring new traffic.

16. **What stakeholders would you involve to actually fix the mobile checkout issue?**
    Product/UX team (design changes), Engineering (implementation), and Payments team (payment gateway integration), with Analytics providing ongoing measurement.

17. **Why analyze weekday vs weekend behavior?**
    It informs marketing scheduling and staffing (e.g., customer support availability) and can reveal whether the audience is more "planned purchase" or "casual browsing" oriented on different days.

18. **What's a limitation of this analysis you'd disclose to stakeholders?**
    The dataset is simulated for portfolio purposes (not live production data), so absolute numbers are illustrative — the analytical approach and query/dashboard structure are what transfer directly to a real company's data.

19. **How would this analysis differ for a subscription-based business instead of one-time purchases?**
    You'd extend the funnel to include renewal/churn stages, and weight recommendations toward retention metrics (churn rate, LTV) rather than just first-purchase conversion.

20. **What would you do next if this were a real, live project?**
    Recommend an A/B test on the top fix (e.g., guest checkout), instrument more granular event tracking (exact drop-off screen/step), and set up a recurring weekly dashboard refresh with automated alerts on conversion-rate drops.

---

## 🧩 Project-Based Questions (20)

1. **Walk me through this project end-to-end.**
   Simulated realistic funnel session data → cleaned and validated it in Python → explored it visually (12 charts, 14 insights) → queried it in SQL (45 queries covering joins/CTEs/window functions) → quantified funnel metrics and root causes → built a Tableau dashboard → translated findings into prioritized business recommendations.

2. **Why did you choose to simulate data instead of using a public dataset?**
   Simulating let me control realistic, explainable relationships (mobile friction, payment method issues) so the "insights" are genuine, teachable signal rather than random noise from an unfamiliar public dataset with unclear ground truth.

3. **What was the hardest part of this project?**
   Balancing realism with clarity — I intentionally embedded known effects (device, channel, payment) into the data generation so the analysis would surface real, explainable patterns rather than noise, while still including genuine data-quality issues (duplicates, missing values, invalid entries) to solve.

4. **How did you decide which charts to include in your EDA?**
   Based on the business questions in Phase 1 — every chart maps directly back to a stated question (device, source, region, category, time, discount, payment) rather than being included just because it was possible to make.

5. **What would you change if you had two more weeks on this project?**
   Add a proper cohort/retention analysis for returning users, build a genuine Tableau Sankey-style funnel chart, and add statistical significance testing (chi-square) to the segment differences.

6. **How did you ensure your SQL queries and Python analysis produce consistent numbers?**
   Both operate on the exact same cleaned CSV (`ecommerce_funnel_clean.csv`), and I cross-validated core aggregates (like device conversion rate) between the two to confirm they matched.

7. **What assumptions did you make in this analysis?**
   That a session-level grain (not user-level) is appropriate for funnel analysis, that "Purchase" flag is the ground truth for conversion, and that time-on-page reliably proxies engagement.

8. **How is this project different from a typical Kaggle notebook?**
   It goes beyond a single Python notebook — it includes SQL querying, a full data cleaning pipeline with validation, a Tableau dashboard, and business-facing deliverables (recommendations, resume content), mirroring a real analyst's actual workflow end-to-end.

9. **How would you present this project in a 5-minute interview walkthrough?**
   Start with the headline finding (59.3% drop at cart→checkout, ₹35.6L opportunity), show the funnel chart, show 1-2 root cause charts (device, payment), then close with the top 2 recommendations — leading with the "so what," not the process.

10. **What's the one insight you'd lead with if you only had 30 seconds?**
    "We're not losing customers to bad marketing — we're losing them at checkout, mostly on mobile, and fixing that alone is worth an estimated ₹35 lakh without spending anything extra on ads."

11. **How did you validate your cleaned dataset was actually correct?**
    Used assertion checks confirming funnel-stage logic held (no purchase without checkout, etc.) and manually spot-checked aggregate totals before and after cleaning steps.

12. **Why organize the GitHub repo into separate Dataset/Python/SQL/Tableau/Reports folders?**
    Mirrors how real analytics teams organize deliverables by function, making it easy for a reviewer (or future me) to find any artifact without digging through a single messy notebook.

13. **What's the purpose of the requirements.txt file?**
    Lets anyone reproduce the exact Python environment used, avoiding "works on my machine" issues — standard practice for any shareable code project.

14. **How would you extend this project to include a full cohort retention analysis?**
    Track each user's sessions over time by signup/first-purchase date, group into cohorts (e.g., by acquisition month), and measure repeat purchase rate over subsequent months.

15. **What would you do differently if this were a live, production analytics pipeline instead of a static CSV?**
    Automate ingestion via scheduled ETL (Airflow), store cleaned data in a warehouse (Snowflake/BigQuery/Postgres), and connect Tableau live rather than to a static CSV extract.

16. **How do you know your synthetic data's patterns are realistic rather than arbitrary?**
    I grounded each embedded effect (mobile checkout friction, payment method risk, channel intent quality) in well-documented, real-world e-commerce UX research rather than assigning random probabilities.

17. **What's the significance of including intentional data quality issues in your synthetic dataset?**
    It lets the project genuinely demonstrate a cleaning workflow (missing values, duplicates, invalid entries) rather than skipping straight to "clean data," which is unrealistic for any real analyst role.

18. **How would a hiring manager verify you actually understand this project versus just having AI generate it?**
    By asking me to explain any single query's logic, justify a specific insight's business reasoning, or modify a chart live — which I can do because I understand every phase, not just the final output.

19. **What's the difference between this project and simply running an off-the-shelf funnel report from Google Analytics?**
    GA gives you the "what" (aggregate drop-off numbers); this project goes further into the "why" through custom segmentation (SQL/Python) and translates it into specific, prioritized, quantified business recommendations.

20. **If your manager disagreed with your root-cause conclusion, how would you respond?**
    Ask what alternative explanation they see, then go back to the segmented data (e.g., check if the mobile/payment effect holds even after controlling for other variables) rather than defending the conclusion on authority alone — data disagreements should be resolved with more data, not opinion.
