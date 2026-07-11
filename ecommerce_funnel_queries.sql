-- ============================================================================
-- E-COMMERCE FUNNEL ANALYSIS - SQL QUERIES
-- Compatible with PostgreSQL and MySQL (minor syntax notes marked where they differ)
-- ============================================================================
-- MENTOR NOTE: In a real job, SQL is how you'd pull this data out of a
-- production database in the first place. Below we (1) create the table,
-- (2) load the cleaned CSV, then (3) run 40+ queries organized from basic
-- to advanced, each with a Business Purpose, SQL Logic, and how to read Output.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- SECTION 0: TABLE CREATION
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS funnel_sessions;

CREATE TABLE funnel_sessions (
    user_id             VARCHAR(20),
    session_id          VARCHAR(20) PRIMARY KEY,
    session_date        DATE,
    traffic_source      VARCHAR(30),
    device_type         VARCHAR(20),
    region              VARCHAR(20),
    product_category    VARCHAR(30),
    product_id          VARCHAR(20),
    page_view           INT,
    product_view        INT,
    add_to_cart         INT,
    checkout            INT,
    purchase            INT,
    time_on_page        DECIMAL(8,2),
    bounce_flag         INT,
    payment_method      VARCHAR(20),
    discount            INT,
    order_value         DECIMAL(10,2),
    is_returning_user   INT,
    day_name            VARCHAR(15),
    is_weekend          INT,
    month_name          VARCHAR(15),
    week_number         INT,
    funnel_stage_reached VARCHAR(20),
    cart_abandoned      INT,
    checkout_abandoned  INT
);

-- Load data (PostgreSQL syntax shown; for MySQL use LOAD DATA INFILE)
-- COPY funnel_sessions FROM '/path/to/ecommerce_funnel_clean.csv' DELIMITER ',' CSV HEADER;


-- ============================================================================
-- SECTION 1: BASIC RETRIEVAL - SELECT, WHERE, ORDER BY
-- ============================================================================

-- Q1. Business Purpose: Quick look at raw session data for a sanity check.
-- Logic: Simple SELECT with LIMIT.
-- Output: First 10 raw session rows.
SELECT * FROM funnel_sessions LIMIT 10;

-- Q2. Business Purpose: Find all sessions that resulted in a purchase.
-- Logic: Filter WHERE purchase = 1.
-- Output: Every converted session - useful for revenue/behavior deep dives.
SELECT session_id, user_id, product_category, order_value
FROM funnel_sessions
WHERE purchase = 1;

-- Q3. Business Purpose: Find high-value orders (>5000) to understand premium buyers.
-- Logic: WHERE with comparison operator on order_value.
SELECT session_id, product_category, order_value
FROM funnel_sessions
WHERE order_value > 5000
ORDER BY order_value DESC;

-- Q4. Business Purpose: List the most recent 20 purchase sessions for a freshness check.
-- Logic: ORDER BY session_date DESC combined with LIMIT.
SELECT session_id, session_date, product_category, order_value
FROM funnel_sessions
WHERE purchase = 1
ORDER BY session_date DESC
LIMIT 20;

-- Q5. Business Purpose: Find all mobile sessions that bounced (never viewed a product).
-- Logic: Multi-condition WHERE with AND.
SELECT session_id, device_type, time_on_page
FROM funnel_sessions
WHERE device_type = 'Mobile' AND bounce_flag = 1;

-- Q6. Business Purpose: Find sessions from Electronics OR Fashion categories.
-- Logic: WHERE with OR / IN.
SELECT session_id, product_category, order_value
FROM funnel_sessions
WHERE product_category IN ('Electronics', 'Fashion');

-- Q7. Business Purpose: Identify unusually long browsing sessions (possible confused users).
-- Logic: WHERE with BETWEEN.
SELECT session_id, time_on_page
FROM funnel_sessions
WHERE time_on_page BETWEEN 200 AND 400
ORDER BY time_on_page DESC;


-- ============================================================================
-- SECTION 2: AGGREGATE FUNCTIONS & GROUP BY
-- ============================================================================

-- Q8. Business Purpose: Total number of sessions per traffic source (channel volume).
-- Logic: COUNT(*) grouped by traffic_source.
SELECT traffic_source, COUNT(*) AS total_sessions
FROM funnel_sessions
GROUP BY traffic_source
ORDER BY total_sessions DESC;

-- Q9. Business Purpose: Overall conversion rate by device type.
-- Logic: AVG on a 0/1 flag = proportion; multiply by 100 for %.
SELECT device_type,
       ROUND(AVG(purchase) * 100, 2) AS conversion_rate_pct
FROM funnel_sessions
GROUP BY device_type
ORDER BY conversion_rate_pct DESC;

-- Q10. Business Purpose: Total and average revenue per product category.
-- Logic: SUM + AVG only over purchased rows.
SELECT product_category,
       SUM(order_value) AS total_revenue,
       ROUND(AVG(order_value) FILTER (WHERE purchase = 1), 2) AS avg_order_value
       -- MySQL alternative: AVG(CASE WHEN purchase = 1 THEN order_value END)
FROM funnel_sessions
GROUP BY product_category
ORDER BY total_revenue DESC;

-- Q11. Business Purpose: Only show regions where average order value exceeds ₹2000.
-- Logic: GROUP BY + HAVING (filters on aggregated result, unlike WHERE).
SELECT region, ROUND(AVG(order_value), 2) AS avg_order_value
FROM funnel_sessions
WHERE purchase = 1
GROUP BY region
HAVING AVG(order_value) > 2000
ORDER BY avg_order_value DESC;

-- Q12. Business Purpose: Find categories with more than 100 total purchases (proven demand).
-- Logic: GROUP BY + HAVING on COUNT.
SELECT product_category, SUM(purchase) AS total_purchases
FROM funnel_sessions
GROUP BY product_category
HAVING SUM(purchase) > 100
ORDER BY total_purchases DESC;

-- Q13. Business Purpose: Min, Max, Avg time on page overall (engagement benchmarks).
-- Logic: Multiple aggregates in a single SELECT.
SELECT MIN(time_on_page) AS min_time,
       MAX(time_on_page) AS max_time,
       ROUND(AVG(time_on_page), 2) AS avg_time
FROM funnel_sessions;

-- Q14. Business Purpose: Bounce rate by traffic source (which channels bring "junk" clicks).
-- Logic: AVG on bounce_flag grouped by source.
SELECT traffic_source, ROUND(AVG(bounce_flag) * 100, 2) AS bounce_rate_pct
FROM funnel_sessions
GROUP BY traffic_source
ORDER BY bounce_rate_pct DESC;


-- ============================================================================
-- SECTION 3: CASE STATEMENTS
-- ============================================================================

-- Q15. Business Purpose: Bucket sessions into engagement tiers for reporting.
-- Logic: CASE WHEN creates a new categorical column from a numeric one.
SELECT session_id, time_on_page,
       CASE
           WHEN time_on_page < 20 THEN 'Low Engagement'
           WHEN time_on_page BETWEEN 20 AND 100 THEN 'Medium Engagement'
           ELSE 'High Engagement'
       END AS engagement_tier
FROM funnel_sessions;

-- Q16. Business Purpose: Count sessions per engagement tier (using CASE inside aggregate).
-- Logic: SUM(CASE WHEN ... THEN 1 ELSE 0 END) is a classic "conditional count" pattern.
SELECT
    SUM(CASE WHEN time_on_page < 20 THEN 1 ELSE 0 END) AS low_engagement,
    SUM(CASE WHEN time_on_page BETWEEN 20 AND 100 THEN 1 ELSE 0 END) AS medium_engagement,
    SUM(CASE WHEN time_on_page > 100 THEN 1 ELSE 0 END) AS high_engagement
FROM funnel_sessions;

-- Q17. Business Purpose: Label each session by the deepest funnel stage reached.
-- Logic: Nested CASE WHEN checking flags in priority order.
SELECT session_id,
       CASE
           WHEN purchase = 1 THEN 'Purchase'
           WHEN checkout = 1 THEN 'Checkout'
           WHEN add_to_cart = 1 THEN 'Add to Cart'
           WHEN product_view = 1 THEN 'Product View'
           ELSE 'Bounced'
       END AS deepest_stage
FROM funnel_sessions;


-- ============================================================================
-- SECTION 4: JOINS
-- ============================================================================
-- MENTOR NOTE: Our dataset is a single flat table (common in analytics/BI
-- exports). To demonstrate JOIN skills (a MUST for interviews), we create two
-- small reference/lookup tables and join them to the main table.

CREATE TABLE region_targets (
    region VARCHAR(20) PRIMARY KEY,
    monthly_target_revenue DECIMAL(12,2)
);

INSERT INTO region_targets VALUES
('North', 900000), ('South', 950000), ('East', 700000),
('West', 950000), ('Central', 450000), ('Unknown', 0);

CREATE TABLE category_manager (
    product_category VARCHAR(30) PRIMARY KEY,
    category_manager VARCHAR(50)
);

INSERT INTO category_manager VALUES
('Electronics', 'Aarav Shah'), ('Fashion', 'Priya Nair'),
('Home & Kitchen', 'Rohit Verma'), ('Beauty', 'Sneha Iyer'),
('Sports', 'Karan Mehta'), ('Books', 'Divya Rao'), ('Grocery', 'Aditya Kumar');

-- Q18. Business Purpose: Compare actual revenue per region vs its monthly target.
-- Logic: INNER JOIN region_targets to funnel_sessions on region.
SELECT f.region,
       SUM(f.order_value) AS actual_revenue,
       r.monthly_target_revenue,
       ROUND(SUM(f.order_value) * 100.0 / r.monthly_target_revenue, 2) AS pct_of_target
FROM funnel_sessions f
INNER JOIN region_targets r ON f.region = r.region
GROUP BY f.region, r.monthly_target_revenue;

-- Q19. Business Purpose: Attach the responsible category manager to revenue figures for reporting.
-- Logic: LEFT JOIN ensures categories show up even if manager mapping is missing.
SELECT f.product_category, cm.category_manager, SUM(f.order_value) AS total_revenue
FROM funnel_sessions f
LEFT JOIN category_manager cm ON f.product_category = cm.product_category
GROUP BY f.product_category, cm.category_manager
ORDER BY total_revenue DESC;

-- Q20. Business Purpose: Find regions that exist in our data but have NO target set (data gap check).
-- Logic: LEFT JOIN + WHERE IS NULL is the standard "anti-join" pattern.
SELECT DISTINCT f.region
FROM funnel_sessions f
LEFT JOIN region_targets r ON f.region = r.region
WHERE r.region IS NULL;


-- ============================================================================
-- SECTION 5: SUBQUERIES
-- ============================================================================

-- Q21. Business Purpose: Find categories whose average order value beats the overall average.
-- Logic: Subquery in WHERE clause computes the overall benchmark first.
SELECT product_category, ROUND(AVG(order_value), 2) AS avg_value
FROM funnel_sessions
WHERE purchase = 1
GROUP BY product_category
HAVING AVG(order_value) > (
    SELECT AVG(order_value) FROM funnel_sessions WHERE purchase = 1
);

-- Q22. Business Purpose: Find the single highest-value order per category (top performer).
-- Logic: Correlated subquery matching MAX(order_value) per category.
SELECT f.product_category, f.session_id, f.order_value
FROM funnel_sessions f
WHERE f.order_value = (
    SELECT MAX(f2.order_value)
    FROM funnel_sessions f2
    WHERE f2.product_category = f.product_category
);

-- Q23. Business Purpose: List users whose average order value is above the platform average
--      (identify high-value/VIP customers for loyalty targeting).
-- Logic: Subquery in HAVING clause.
SELECT user_id, ROUND(AVG(order_value), 2) AS user_avg_value
FROM funnel_sessions
WHERE purchase = 1
GROUP BY user_id
HAVING AVG(order_value) > (SELECT AVG(order_value) FROM funnel_sessions WHERE purchase = 1)
ORDER BY user_avg_value DESC;


-- ============================================================================
-- SECTION 6: CTEs (Common Table Expressions)
-- ============================================================================

-- Q24. Business Purpose: Build a clean, reusable funnel summary table using a CTE.
-- Logic: WITH clause names a temporary result set we can query cleanly afterward.
WITH funnel_summary AS (
    SELECT
        SUM(page_view)     AS total_page_views,
        SUM(product_view)  AS total_product_views,
        SUM(add_to_cart)   AS total_add_to_cart,
        SUM(checkout)      AS total_checkout,
        SUM(purchase)      AS total_purchase
    FROM funnel_sessions
)
SELECT *,
       ROUND(total_purchase * 100.0 / total_page_views, 2) AS overall_conversion_pct
FROM funnel_summary;

-- Q25. Business Purpose: Rank traffic sources by conversion rate using a readable CTE.
-- Logic: CTE computes rate, outer query orders/labels it.
WITH source_rates AS (
    SELECT traffic_source, ROUND(AVG(purchase) * 100, 2) AS conv_rate
    FROM funnel_sessions
    GROUP BY traffic_source
)
SELECT *,
       CASE WHEN conv_rate >= 8 THEN 'Healthy' ELSE 'Needs Attention' END AS status
FROM source_rates
ORDER BY conv_rate DESC;

-- Q26. Business Purpose: Multi-step CTE chain - first compute cart totals, then abandonment rate.
-- Logic: Two chained CTEs, a common real-world pattern for readability.
WITH cart_stats AS (
    SELECT device_type,
           SUM(add_to_cart) AS total_carts,
           SUM(cart_abandoned) AS abandoned_carts
    FROM funnel_sessions
    GROUP BY device_type
),
abandonment_calc AS (
    SELECT device_type,
           total_carts,
           abandoned_carts,
           ROUND(abandoned_carts * 100.0 / NULLIF(total_carts, 0), 2) AS abandonment_rate_pct
    FROM cart_stats
)
SELECT * FROM abandonment_calc ORDER BY abandonment_rate_pct DESC;


-- ============================================================================
-- SECTION 7: WINDOW FUNCTIONS - RANKING, RUNNING TOTALS
-- ============================================================================

-- Q27. Business Purpose: Rank product categories by revenue (for a leaderboard).
-- Logic: RANK() window function over revenue.
SELECT product_category,
       SUM(order_value) AS total_revenue,
       RANK() OVER (ORDER BY SUM(order_value) DESC) AS revenue_rank
FROM funnel_sessions
GROUP BY product_category;

-- Q28. Business Purpose: Rank regions within each category by revenue (nested leaderboard).
-- Logic: PARTITION BY resets ranking per category.
SELECT product_category, region,
       SUM(order_value) AS revenue,
       RANK() OVER (PARTITION BY product_category ORDER BY SUM(order_value) DESC) AS rank_in_category
FROM funnel_sessions
GROUP BY product_category, region;

-- Q29. Business Purpose: Running (cumulative) daily revenue total, to track month-to-date progress.
-- Logic: SUM() OVER with ORDER BY creates a running total.
SELECT session_date,
       SUM(order_value) AS daily_revenue,
       SUM(SUM(order_value)) OVER (ORDER BY session_date) AS running_total_revenue
FROM funnel_sessions
GROUP BY session_date
ORDER BY session_date;

-- Q30. Business Purpose: Day-over-day change in purchases (growth/decline detection).
-- Logic: LAG() window function pulls the previous row's value for comparison.
WITH daily_purchases AS (
    SELECT session_date, SUM(purchase) AS purchases
    FROM funnel_sessions
    GROUP BY session_date
)
SELECT session_date, purchases,
       purchases - LAG(purchases) OVER (ORDER BY session_date) AS change_vs_prev_day
FROM daily_purchases
ORDER BY session_date;

-- Q31. Business Purpose: Identify each user's most recent (latest) session for re-engagement targeting.
-- Logic: ROW_NUMBER() partitioned by user, ordered by date descending, keep rank 1.
WITH ranked_sessions AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY session_date DESC) AS rn
    FROM funnel_sessions
)
SELECT user_id, session_id, session_date, product_category
FROM ranked_sessions
WHERE rn = 1;

-- Q32. Business Purpose: Percentile ranking of order values (find top 10% "big spender" orders).
-- Logic: NTILE(10) splits purchases into 10 equal buckets by value.
SELECT session_id, order_value,
       NTILE(10) OVER (ORDER BY order_value DESC) AS decile
FROM funnel_sessions
WHERE purchase = 1;


-- ============================================================================
-- SECTION 8: DATE FUNCTIONS
-- ============================================================================

-- Q33. Business Purpose: Monthly revenue trend (executive reporting cadence).
-- Logic: DATE_TRUNC groups timestamps into calendar months (PostgreSQL).
-- MySQL alternative: DATE_FORMAT(session_date, '%Y-%m')
SELECT DATE_TRUNC('month', session_date) AS month, SUM(order_value) AS revenue
FROM funnel_sessions
GROUP BY 1
ORDER BY 1;

-- Q34. Business Purpose: Conversion rate by day of week (staffing/marketing scheduling).
-- Logic: EXTRACT(DOW ...) or the pre-built day_name column.
SELECT day_name, ROUND(AVG(purchase) * 100, 2) AS conversion_rate_pct
FROM funnel_sessions
GROUP BY day_name
ORDER BY conversion_rate_pct DESC;

-- Q35. Business Purpose: Weekend vs Weekday conversion comparison.
-- Logic: Uses the pre-engineered is_weekend flag.
SELECT CASE WHEN is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type,
       ROUND(AVG(purchase) * 100, 2) AS conversion_rate_pct
FROM funnel_sessions
GROUP BY is_weekend;

-- Q36. Business Purpose: Week-over-week conversion trend (early warning system for decline).
-- Logic: Uses ISO week_number column, grouped and ordered chronologically.
SELECT week_number, ROUND(AVG(purchase) * 100, 2) AS conversion_rate_pct
FROM funnel_sessions
GROUP BY week_number
ORDER BY week_number;


-- ============================================================================
-- SECTION 9: FUNNEL & ROOT-CAUSE SPECIFIC QUERIES
-- ============================================================================

-- Q37. Business Purpose: THE core funnel query - stage-by-stage counts and drop-off %.
-- Logic: UNION ALL stacks each stage as a row so Tableau/Excel can plot it directly.
SELECT 'Page View' AS stage, SUM(page_view) AS sessions, 1 AS stage_order FROM funnel_sessions
UNION ALL
SELECT 'Product View', SUM(product_view), 2 FROM funnel_sessions
UNION ALL
SELECT 'Add to Cart', SUM(add_to_cart), 3 FROM funnel_sessions
UNION ALL
SELECT 'Checkout', SUM(checkout), 4 FROM funnel_sessions
UNION ALL
SELECT 'Purchase', SUM(purchase), 5 FROM funnel_sessions
ORDER BY stage_order;

-- Q38. Business Purpose: Cart abandonment rate segmented by device (root cause pinpointing).
-- Logic: Conditional aggregation of the cart_abandoned flag.
SELECT device_type,
       SUM(add_to_cart) AS total_carts,
       SUM(cart_abandoned) AS abandoned,
       ROUND(SUM(cart_abandoned) * 100.0 / NULLIF(SUM(add_to_cart), 0), 2) AS abandonment_rate_pct
FROM funnel_sessions
GROUP BY device_type
ORDER BY abandonment_rate_pct DESC;

-- Q39. Business Purpose: Checkout abandonment rate by payment method (find the "leaky" payment options).
-- Logic: Same pattern as Q38 applied to checkout_abandoned.
SELECT payment_method,
       SUM(checkout) AS total_checkouts,
       SUM(checkout_abandoned) AS abandoned,
       ROUND(SUM(checkout_abandoned) * 100.0 / NULLIF(SUM(checkout), 0), 2) AS abandonment_rate_pct
FROM funnel_sessions
GROUP BY payment_method
ORDER BY abandonment_rate_pct DESC;

-- Q40. Business Purpose: Multi-dimensional root cause - conversion rate by Device x Traffic Source.
-- Logic: GROUP BY two columns reveals interaction effects a single dimension would hide.
SELECT device_type, traffic_source,
       COUNT(*) AS sessions,
       ROUND(AVG(purchase) * 100, 2) AS conversion_rate_pct
FROM funnel_sessions
GROUP BY device_type, traffic_source
ORDER BY conversion_rate_pct ASC;

-- Q41. Business Purpose: Does a discount actually rescue abandoned carts? Compare abandonment with/without discount.
-- Logic: Conditional aggregation split by discount flag.
SELECT discount,
       SUM(add_to_cart) AS total_carts,
       ROUND(SUM(cart_abandoned) * 100.0 / NULLIF(SUM(add_to_cart), 0), 2) AS abandonment_rate_pct
FROM funnel_sessions
GROUP BY discount;

-- Q42. Business Purpose: New vs returning user funnel comparison at every stage.
-- Logic: Grouped conditional sums across all funnel flags at once.
SELECT is_returning_user,
       ROUND(AVG(product_view) * 100, 2) AS view_rate,
       ROUND(AVG(add_to_cart) * 100, 2) AS cart_rate,
       ROUND(AVG(checkout) * 100, 2) AS checkout_rate,
       ROUND(AVG(purchase) * 100, 2) AS purchase_rate
FROM funnel_sessions
GROUP BY is_returning_user;

-- Q43. Business Purpose: Revenue lost estimate - if worst device matched best device's conversion rate.
-- Logic: Subquery gets best rate, then projects it onto worst device's session volume.
WITH device_rates AS (
    SELECT device_type, COUNT(*) AS sessions, AVG(purchase) AS conv_rate,
           AVG(order_value) FILTER (WHERE purchase = 1) AS aov
    FROM funnel_sessions
    GROUP BY device_type
)
SELECT device_type,
       sessions,
       ROUND(conv_rate * 100, 2) AS current_conv_pct,
       ROUND((SELECT MAX(conv_rate) FROM device_rates) * 100, 2) AS best_conv_pct,
       ROUND(sessions * ((SELECT MAX(conv_rate) FROM device_rates) - conv_rate) * aov, 2) AS estimated_revenue_opportunity
FROM device_rates
ORDER BY estimated_revenue_opportunity DESC;

-- Q44. Business Purpose: A reusable VIEW for Tableau to connect to directly (funnel by segment).
-- Logic: CREATE VIEW packages a common query for repeated use / BI tool connection.
CREATE OR REPLACE VIEW vw_funnel_by_segment AS
SELECT device_type, traffic_source, region, product_category,
       COUNT(*) AS sessions,
       SUM(product_view) AS product_views,
       SUM(add_to_cart) AS add_to_carts,
       SUM(checkout) AS checkouts,
       SUM(purchase) AS purchases,
       SUM(order_value) AS revenue
FROM funnel_sessions
GROUP BY device_type, traffic_source, region, product_category;

SELECT * FROM vw_funnel_by_segment LIMIT 20;

-- Q45. Business Purpose: A VIEW summarizing daily KPIs for an executive dashboard.
-- Logic: Same VIEW pattern, time-based instead of segment-based.
CREATE OR REPLACE VIEW vw_daily_kpis AS
SELECT session_date,
       COUNT(*) AS sessions,
       SUM(purchase) AS purchases,
       ROUND(AVG(purchase) * 100, 2) AS conversion_rate_pct,
       SUM(order_value) AS revenue
FROM funnel_sessions
GROUP BY session_date;

SELECT * FROM vw_daily_kpis ORDER BY session_date;
