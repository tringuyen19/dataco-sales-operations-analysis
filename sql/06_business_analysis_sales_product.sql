/* =========================================================
DAY 4 — BUSINESS ANALYSIS: SALES AND PRODUCT

Primary reporting scope: Scope B — Non-canceled orders
Excluded statuses: CANCELED and SUSPECTED_FRAUD

Primary sources:
- vw_order_analysis_non_canceled      (one row = one order)
- vw_order_item_analysis_non_canceled (one row = one order item)

The two original views remain unchanged and represent Scope A.
Only the reporting-scope audit below intentionally reads Scope A.
========================================================= */

-- =========================================================
-- 00_SCOPE_B_VALIDATION
-- Confirm that the primary analytical scope contains no
-- CANCELED or SUSPECTED_FRAUD orders.
-- Expected known results:
-- scope_b_orders = 62,897
-- excluded_status_orders_in_scope_b = 0
-- scope_b_net_sales = 31,644,664.75
-- scope_b_total_profit = 3,806,420.63
-- =========================================================

SELECT
    COUNT(*) AS scope_b_orders,

    COUNT(*) FILTER (
        WHERE order_status IN ('CANCELED', 'SUSPECTED_FRAUD')
    ) AS excluded_status_orders_in_scope_b,

    ROUND(SUM(net_sales), 2) AS scope_b_net_sales,
    ROUND(SUM(order_profit), 2) AS scope_b_total_profit
FROM vw_order_analysis_non_canceled;

-- =========================================================
-- 01_REPORTING_SCOPE_AUDIT
-- Financial impact by order status.
-- This query intentionally uses Scope A so excluded statuses
-- remain visible for reconciliation and sensitivity analysis.
-- It is not the primary Day 4 KPI baseline.
-- =========================================================

SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(SUM(net_sales), 2) AS net_sales,
    ROUND(SUM(order_profit), 2) AS total_profit,
	
    ROUND(
        100.0 * SUM(order_profit)
        / NULLIF(SUM(net_sales), 0),
        2
    ) AS profit_margin_pct
FROM vw_order_analysis
GROUP BY order_status
ORDER BY total_orders DESC;

-- 01B. Scope A versus Scope B financial sensitivity

SELECT
    'Scope A - All recorded orders' AS reporting_scope,
    COUNT(*) AS total_orders,
    ROUND(SUM(net_sales), 2) AS net_sales,
    ROUND(SUM(order_profit), 2) AS total_profit,
    ROUND(
        100.0 * SUM(order_profit)
        / NULLIF(SUM(net_sales), 0),
        2
    ) AS profit_margin_pct
FROM vw_order_analysis

UNION ALL

SELECT
    'Scope B - Non-canceled orders' AS reporting_scope,
    COUNT(*) AS total_orders,
    ROUND(SUM(net_sales), 2) AS net_sales,
    ROUND(SUM(order_profit), 2) AS total_profit,
    ROUND(
        100.0 * SUM(order_profit)
        / NULLIF(SUM(net_sales), 0),
        2
    ) AS profit_margin_pct
FROM vw_order_analysis_non_canceled
ORDER BY reporting_scope;

-- =========================================================
-- 02_BUSINESS_OVERVIEW
-- One-row KPI baseline for Scope B
-- =========================================================

WITH item_kpis AS (
    SELECT
        SUM(gross_sales) AS gross_sales,
        SUM(discount_amount) AS total_discount,
        SUM(net_sales) AS net_sales,
        SUM(line_profit) AS total_profit,
        SUM(quantity) AS units_sold
    FROM vw_order_item_analysis_non_canceled
),
order_kpis AS (
    SELECT
        COUNT(*) AS total_orders,
        COUNT(DISTINCT customer_id) AS total_customers,
        SUM(net_sales) / NULLIF(COUNT(*), 0)
            AS average_order_value
    FROM vw_order_analysis_non_canceled
)
SELECT
    ROUND(i.gross_sales, 2) AS gross_sales,
    ROUND(i.total_discount, 2) AS total_discount,
    ROUND(i.net_sales, 2) AS net_sales,
    ROUND(i.total_profit, 2) AS total_profit,

    ROUND(
        100.0 * i.total_profit / NULLIF(i.net_sales, 0), 2
    ) AS profit_margin_pct,

    o.total_orders,
    i.units_sold,
    o.total_customers,

    ROUND(o.average_order_value, 2) AS average_order_value,

    ROUND(
        100.0 * i.total_discount / NULLIF(i.gross_sales, 0), 2
    ) AS discount_rate_pct
FROM item_kpis AS i
CROSS JOIN order_kpis AS o;

-- =========================================================
-- 03_MONTHLY_TREND
-- Scope B
-- 03A. Boundary-month check
-- =========================================================

WITH limits AS (
    SELECT
        MIN(order_date) AS min_order_date,
        MAX(order_date) AS max_order_date
    FROM vw_order_analysis_non_canceled
)
SELECT
    order_month,
    MIN(order_date) AS first_date_in_data,
    MAX(order_date) AS last_date_in_data,
    COUNT(*) AS total_orders,

    CASE
        WHEN order_month = DATE_TRUNC('month', l.min_order_date)
          OR order_month = DATE_TRUNC('month', l.max_order_date)
        THEN 'BOUNDARY_MONTH_CHECK_COMPLETENESS'
        ELSE 'INTERIOR_MONTH'
    END AS coverage_note
FROM vw_order_analysis_non_canceled
CROSS JOIN limits AS l
GROUP BY
    order_month,
    l.min_order_date,
    l.max_order_date
ORDER BY order_month;

-- 03B. Monthly KPIs and Month-over-Month change

WITH monthly AS (
    SELECT
        order_month,
        COUNT(*) AS total_orders,
        SUM(total_quantity) AS units_sold,
        SUM(net_sales) AS net_sales,
        SUM(order_profit) AS total_profit
    FROM vw_order_analysis_non_canceled
    GROUP BY order_month
),
with_previous_month AS (
    SELECT
        m.*,
        LAG(net_sales) OVER (ORDER BY order_month) AS previous_net_sales,
        LAG(total_profit) OVER ( ORDER BY order_month) AS previous_profit
    FROM monthly AS m
)
SELECT
    order_month,
    net_sales,
    total_profit,
    ROUND(100.0 * total_profit / NULLIF(net_sales, 0), 2) AS profit_margin_pct,
    total_orders,
    ROUND(net_sales / NULLIF(total_orders, 0), 2) AS average_order_value,
    units_sold,
    ROUND(net_sales - previous_net_sales, 2) AS net_sales_change,

    ROUND(
        100.0 * (net_sales - previous_net_sales)
        / NULLIF(previous_net_sales, 0), 2
    ) AS net_sales_change_pct,

    ROUND( total_profit - previous_profit, 2) AS profit_change
FROM with_previous_month
ORDER BY order_month;

-- =========================================================
-- 04_CATEGORY_ANALYSIS
-- Scope B
-- 04A. Category metrics, contribution and ranking
-- =========================================================

WITH category_metrics AS (
    SELECT
    	COALESCE(category_name, '[MISSING_CATEGORY]') AS category_name ,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(DISTINCT product_card_id) AS distinct_products,
        
        SUM(quantity) AS units_sold,
        SUM(gross_sales) AS gross_sales,
        SUM(discount_amount) AS total_discount,
        SUM(net_sales) AS net_sales,
        SUM(line_profit) AS total_profit
    FROM vw_order_item_analysis_non_canceled
    GROUP BY category_name
)
SELECT
    category_name,
    total_orders,
    distinct_products,
    units_sold,
    ROUND(net_sales, 2) AS net_sales,
    ROUND(total_profit, 2) AS total_profit,

    ROUND(100.0 * total_profit / NULLIF(net_sales, 0), 2) AS profit_margin_pct,
    ROUND(100.0 * total_discount / NULLIF(gross_sales, 0), 2) AS discount_rate_pct,
    
    ROUND(
        100.0 * net_sales
        / NULLIF(SUM(net_sales) OVER (), 0), 2
    ) AS revenue_contribution_pct,

    DENSE_RANK() OVER (ORDER BY net_sales DESC) AS revenue_rank
FROM category_metrics
ORDER BY revenue_rank, category_name;

-- =========================================================
-- 05_PRODUCT_ANALYSIS
-- Scope B
-- 05A. Top 10 products by Net Sales
-- =========================================================

WITH product_metrics AS (
    SELECT
        product_card_id,
        COALESCE(product_name, '[MISSING_PRODUCT_NAME]') AS product_name,
        COALESCE(category_name,'[MISSING_CATEGORY]') AS category_name,

        COUNT(DISTINCT order_id) AS total_orders,
        SUM(quantity) AS units_sold,
        SUM(gross_sales) AS gross_sales,
        SUM(discount_amount) AS total_discount,
        SUM(net_sales) AS net_sales,
        SUM(line_profit) AS total_profit
    FROM vw_order_item_analysis_non_canceled
    GROUP BY
        product_card_id,
        product_name,
        category_name
)
SELECT
    product_card_id,
    product_name,
    category_name,
    total_orders,
    units_sold,
    
    ROUND(net_sales, 2) AS net_sales,
    ROUND(total_profit, 2) AS total_profit,
    ROUND(100.0 * total_profit / NULLIF(net_sales, 0), 2) AS profit_margin_pct,
    ROUND(100.0 * total_discount / NULLIF(gross_sales, 0), 2) AS discount_rate_pct
FROM product_metrics
ORDER BY net_sales DESC
LIMIT 10;

--Tìm product doanh thu cao nhưng lợi nhuận âm
-- 05B. High-sales products with negative profit

WITH product_metrics AS (
    SELECT
        product_card_id,
        COALESCE(product_name, '[MISSING_PRODUCT_NAME]') AS product_name,
        COALESCE(category_name, '[MISSING_CATEGORY]') AS category_name,

        COUNT(DISTINCT order_id) AS total_orders,
        SUM(gross_sales) AS gross_sales,
        SUM(discount_amount) AS total_discount,
        SUM(net_sales) AS net_sales,
        SUM(line_profit) AS total_profit
    FROM vw_order_item_analysis_non_canceled
    GROUP BY
        product_card_id,
        product_name,
        category_name
),
benchmark AS (
    SELECT
        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY net_sales)
            AS median_product_net_sales
    FROM product_metrics
)
SELECT
    p.product_card_id,
    p.product_name,
    p.category_name,
    p.total_orders,
    
    ROUND(p.net_sales, 2) AS net_sales,
    ROUND(p.total_profit, 2) AS total_profit,
    ROUND(100.0 * p.total_profit / NULLIF(p.net_sales, 0), 2) AS profit_margin_pct,
    ROUND(100.0 * p.total_discount / NULLIF(p.gross_sales, 0), 2) AS discount_rate_pct
FROM product_metrics AS p
CROSS JOIN benchmark AS b
WHERE p.net_sales >= b.median_product_net_sales
  AND p.total_profit < 0
ORDER BY p.net_sales DESC;

--Kiểm tra sâu một product bất thường
-- 05C. Drill-down for one selected product
SELECT
    order_month,
    market,
    order_region,
    order_status,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS units_sold,
    ROUND(SUM(net_sales), 2) AS net_sales,
    ROUND(SUM(line_profit), 2) AS total_profit,

    ROUND(
        100.0 * SUM(discount_amount)
        / NULLIF(SUM(gross_sales), 0),
        2
    ) AS discount_rate_pct
FROM vw_order_item_analysis_non_canceled
WHERE product_card_id = 208
GROUP BY
    order_month,
    market,
    order_region,
    order_status
ORDER BY order_month, net_sales DESC;

--Đo mức tập trung doanh thu
-- 05D. Product revenue concentration

WITH product_sales AS (
    SELECT
        product_card_id,
        COALESCE(product_name, '[MISSING_PRODUCT_NAME]') AS product_name,
        SUM(net_sales) AS net_sales
    FROM vw_order_item_analysis_non_canceled
    GROUP BY
        product_card_id,
        product_name
),
ranked AS (
    SELECT
        product_card_id,
        product_name,
        net_sales,

        DENSE_RANK() OVER (ORDER BY net_sales DESC) AS revenue_rank,

        SUM(net_sales) OVER () AS all_product_net_sales,

        SUM(net_sales) OVER (
            ORDER BY net_sales DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS cumulative_net_sales
    FROM product_sales
)
SELECT
    product_card_id,
    product_name,
    revenue_rank,
    ROUND(net_sales, 2) AS net_sales,

    ROUND(
        100.0 * net_sales
        / NULLIF(all_product_net_sales, 0), 2
    ) AS product_share_pct,

    ROUND(
        100.0 * cumulative_net_sales
        / NULLIF(all_product_net_sales, 0),2
    ) AS cumulative_share_pct
FROM ranked
ORDER BY revenue_rank, product_card_id;

-- =========================================================
-- 06_SCOPE_B_RECONCILIATION
-- Reconcile the order-level and item-level Scope B views.
-- Expected: order_count_difference and all financial/
-- quantity differences equal 0 (within source precision).
-- =========================================================

WITH order_level AS (
    SELECT
        COUNT(*) AS total_orders,
        SUM(total_quantity) AS units_sold,
        SUM(gross_sales) AS gross_sales,
        SUM(discount_amount) AS total_discount,
        SUM(net_sales) AS net_sales,
        SUM(order_profit) AS total_profit
    FROM vw_order_analysis_non_canceled
),
item_level AS (
    SELECT
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(quantity) AS units_sold,
        SUM(gross_sales) AS gross_sales,
        SUM(discount_amount) AS total_discount,
        SUM(net_sales) AS net_sales,
        SUM(line_profit) AS total_profit
    FROM vw_order_item_analysis_non_canceled
)
SELECT
    o.total_orders AS order_view_orders,
    i.total_orders AS item_view_distinct_orders,
    o.total_orders - i.total_orders AS order_count_difference,

    ROUND((o.units_sold - i.units_sold), 2) AS units_sold_difference,
    ROUND((o.gross_sales - i.gross_sales), 2) AS gross_sales_difference,
    ROUND((o.total_discount - i.total_discount), 2) AS discount_difference,
    ROUND((o.net_sales - i.net_sales), 2) AS net_sales_difference,
    ROUND((o.total_profit - i.total_profit), 2) AS profit_difference
FROM order_level AS o
CROSS JOIN item_level AS i;