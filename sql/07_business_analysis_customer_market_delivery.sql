/* =========================================================
DAY 5 — CUSTOMER, MARKET AND DELIVERY ANALYSIS
Dataset: DataCo Smart Supply Chain
Reporting period: 2015-01-01 to 2018-01-31

Primary reporting scope: Scope B — Non-canceled orders
Excluded statuses: CANCELED and SUSPECTED_FRAUD
Primary grain: one row per order
Primary source: vw_order_analysis_non_canceled

Scope A is used only in explicitly labeled audit queries that
explain why canceled/fraud orders are excluded from delivery KPIs.
========================================================= */

-- =========================================================
-- 00_SCOPE_AND_MODEL_VALIDATION
-- Run these checks before the analysis sections.
-- =========================================================

-- 00A. Scope B baseline
-- Expected known values:
-- orders = 62,897
-- excluded_status_orders = 0
-- net_sales = 31,644,664.75
-- profit = 3,806,420.63

SELECT
    COUNT(*) AS order_rows,
    COUNT(DISTINCT order_id) AS distinct_orders,

    COUNT(*) FILTER (
        WHERE order_status IN ('CANCELED', 'SUSPECTED_FRAUD')
    ) AS excluded_status_orders,

    COUNT(DISTINCT customer_id) AS customers,
    ROUND(SUM(net_sales), 2) AS net_sales,
    ROUND(SUM(order_profit), 2) AS profit
FROM vw_order_analysis_non_canceled;

-- 00B. Confirm order-level attributes are consistent before
-- representative values are used in the order-level view.
-- Expected result: 0 rows.

SELECT
    order_id,
    COUNT(DISTINCT customer_id) AS customer_count,
    COUNT(DISTINCT customer_segment) AS segment_count,
    COUNT(DISTINCT market) AS market_count,
    COUNT(DISTINCT order_region) AS region_count,
    COUNT(DISTINCT shipping_mode) AS shipping_mode_count,
    COUNT(DISTINCT late_delivery_risk) AS late_risk_count
FROM vw_order_item_analysis_non_canceled
GROUP BY order_id
HAVING COUNT(DISTINCT customer_id) > 1
    OR COUNT(DISTINCT customer_segment) > 1
    OR COUNT(DISTINCT market) > 1
    OR COUNT(DISTINCT order_region) > 1
    OR COUNT(DISTINCT shipping_mode) > 1
    OR COUNT(DISTINCT late_delivery_risk) > 1;

-- =========================================================
-- 01_CUSTOMER_SEGMENT_PERFORMANCE — Scope B
-- =========================================================

WITH segment_summary AS (
    SELECT
        COALESCE(customer_segment, 'Unknown') AS customer_segment,
        COUNT(DISTINCT customer_id) AS customers,
        COUNT(DISTINCT order_id) AS orders,
        SUM(net_sales) AS net_sales,
        SUM(order_profit) AS profit,
        COUNT(DISTINCT order_id) FILTER (
            WHERE late_delivery_risk = 1
        ) AS late_orders,
        COUNT(DISTINCT order_id) FILTER (
            WHERE late_delivery_risk IN (0, 1)
        ) AS evaluable_delivery_orders
    FROM vw_order_analysis_non_canceled
    GROUP BY COALESCE(customer_segment, 'Unknown')
)
SELECT
    customer_segment,
    customers,
    orders,
    ROUND(net_sales, 2) AS net_sales,

    ROUND(
        100.0 * net_sales
        / NULLIF(SUM(net_sales) OVER (), 0),
        2
    ) AS sales_share_pct,

    ROUND(profit, 2) AS profit,
    ROUND(100.0 * profit / NULLIF(net_sales, 0), 2)
        AS profit_margin_pct,
    ROUND(net_sales / NULLIF(orders, 0), 2)
        AS average_order_value,
    ROUND(orders::numeric / NULLIF(customers, 0), 2)
        AS orders_per_customer,
    ROUND(net_sales / NULLIF(customers, 0), 2)
        AS revenue_per_customer,
    late_orders,
    evaluable_delivery_orders,
    ROUND(
        100.0 * late_orders
        / NULLIF(evaluable_delivery_orders, 0),
        2
    ) AS late_delivery_rate_pct,
    DENSE_RANK() OVER (ORDER BY net_sales DESC) AS revenue_rank
FROM segment_summary
ORDER BY revenue_rank, customer_segment;

-- =========================================================
-- 02_CUSTOMER_SUMMARY — Scope B
-- One row represents one observed customer.
-- =========================================================

DROP VIEW IF EXISTS customer_summary;
CREATE TEMP VIEW customer_summary AS
SELECT
    customer_id,
    MIN(order_datetime) AS first_observed_order,
    MAX(order_datetime) AS last_observed_order,
    COUNT(DISTINCT order_id) AS order_count,
    SUM(net_sales) AS net_sales,
    SUM(order_profit) AS profit
FROM vw_order_analysis_non_canceled
GROUP BY customer_id;

-- 02A. Prove the customer-level grain.
-- Expected: customer_rows = distinct_customers.

SELECT
    COUNT(*) AS customer_rows,
    COUNT(DISTINCT customer_id) AS distinct_customers,
    COUNT(*) - COUNT(DISTINCT customer_id) AS grain_difference
FROM customer_summary;

-- =========================================================
-- 03_REPEAT_CUSTOMER_RATE — Scope B
-- Repeat means at least two observed orders in this dataset;
-- it does not prove loyalty or full customer lifetime value.
-- =========================================================

SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (WHERE order_count = 1) AS one_time_customers,
    COUNT(*) FILTER (WHERE order_count >= 2) AS repeat_customers,

    ROUND(
        (100.0 
        	* COUNT(*) FILTER (WHERE order_count >= 2)
            / NULLIF(COUNT(*), 0)
        ), 2
    ) AS repeat_customer_rate_pct,

    ROUND(
        (100.0
            * SUM(net_sales) FILTER (WHERE order_count >= 2)
            / NULLIF(SUM(net_sales), 0)
        ), 2
    ) AS repeat_revenue_share_pct
FROM customer_summary;

-- 03B. Compare one-time and repeat customers
WITH tagged_customers AS (
    SELECT
        customer_id,
        order_count,
        net_sales,
        profit,
        CASE
            WHEN order_count = 1 THEN 'One-time'
            WHEN order_count >= 2 THEN 'Repeat'
            ELSE 'Unknown'
        END AS customer_type
    FROM customer_summary
),

group_summary AS (
    SELECT
        customer_type,
        COUNT(*) AS customers,
        SUM(order_count) AS orders,
        SUM(net_sales) AS net_sales,
        SUM(profit) AS profit
    FROM tagged_customers
    GROUP BY customer_type
)

SELECT
    customer_type,
    customers,
	orders,
	net_sales,
	profit,
    ROUND((100.0 * customers / NULLIF(SUM(customers) OVER (), 0)), 2) AS customer_share_pct,
    ROUND((100.0 * net_sales / NULLIF(SUM(net_sales) OVER (), 0)), 2) AS revenue_share_pct,
    ROUND((100.0 * profit / NULLIF(net_sales, 0)), 2) AS profit_margin_pct,
    ROUND((net_sales / NULLIF(customers, 0)), 2) AS revenue_per_customer
FROM group_summary
ORDER BY net_sales DESC;


-- =========================================================
-- 04_CUSTOMER_REVENUE_CONCENTRATION — Scope B
-- 04A. Top customers and cumulative revenue share
-- =========================================================
WITH ranked_customers AS (
    SELECT
        customer_id,
        order_count,
        net_sales,
        profit,
        ROW_NUMBER() OVER (ORDER BY net_sales DESC, customer_id) AS revenue_rank,
        COUNT(*) OVER () AS total_customers,
        SUM(net_sales) OVER () AS total_net_sales,

        SUM(net_sales) OVER (ORDER BY net_sales DESC, customer_id
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS cumulative_net_sales
    FROM customer_summary
)

SELECT
    customer_id,
    order_count,
    net_sales,
    profit,
    revenue_rank,

    ROUND(
        (100.0 * net_sales
            / NULLIF(total_net_sales, 0)
        ), 4
    ) AS individual_revenue_share_pct,

    ROUND(
        (100.0 * cumulative_net_sales
            / NULLIF(total_net_sales, 0)
        ), 4
    ) AS cumulative_revenue_share_pct
FROM ranked_customers
ORDER BY revenue_rank
LIMIT 100;


-- 04B. Top 10 customers and Top 10% of customers
WITH ranked_customers AS (
    SELECT
        customer_id,
        net_sales,
        ROW_NUMBER() OVER (ORDER BY net_sales DESC, customer_id) AS revenue_rank,
        COUNT(*) OVER () AS total_customers,
        SUM(net_sales) OVER () AS total_net_sales
    FROM customer_summary
)

SELECT
    MAX(total_customers) AS total_customers,
    SUM(net_sales) FILTER (WHERE revenue_rank <= 10) AS top_10_customer_sales,

    ROUND(
        (100.0
            * SUM(net_sales) FILTER (WHERE revenue_rank <= 10)
            / NULLIF(MAX(total_net_sales), 0)
        ), 2
    ) AS top_10_customer_revenue_share_pct,

    CEIL(0.10 * MAX(total_customers)) AS top_10_pct_customer_count,

    ROUND(
        (100.0
            * SUM(net_sales) FILTER (WHERE revenue_rank <= CEIL(0.10 * total_customers))
            / NULLIF(MAX(total_net_sales), 0)
        ), 2
    ) AS top_10_pct_revenue_share_pct
FROM ranked_customers;

-- =========================================================
-- 05_MARKET_ANALYSIS — Scope B
-- =========================================================

WITH market_summary AS (
    SELECT
        COALESCE(market, 'Unknown') AS market,
        COUNT(DISTINCT customer_id) AS customers,
        COUNT(DISTINCT order_id) AS orders,
        SUM(net_sales) AS net_sales,
        SUM(order_profit) AS profit,
        COUNT(DISTINCT order_id) FILTER (WHERE late_delivery_risk = 1) AS late_orders,
        COUNT(DISTINCT order_id) FILTER (WHERE late_delivery_risk IN (0, 1)) AS evaluable_delivery_orders
    FROM vw_order_analysis_non_canceled
    GROUP BY COALESCE(market, 'Unknown')
)

SELECT
    market,
    customers,
    orders,
    net_sales,
    
    ROUND(
        (100.0 * net_sales
            / NULLIF(SUM(net_sales) OVER (), 0)
        ), 2
    ) AS sales_share_pct,

    profit,

    ROUND(
        (100.0 * profit
            / NULLIF(net_sales, 0)
        ), 2
    ) AS profit_margin_pct,

    ROUND(net_sales / NULLIF(orders, 0), 2) AS average_order_value,

    late_orders,
    evaluable_delivery_orders,

    ROUND(
        (100.0 * late_orders
            / NULLIF(evaluable_delivery_orders, 0)
        ), 2
    ) AS late_delivery_rate_pct

FROM market_summary
ORDER BY net_sales DESC;


-- =========================================================
-- 06_REGION_ANALYSIS — Scope B
-- 06A. Region performance and ranking
-- =========================================================
WITH region_summary AS (
    SELECT
        COALESCE(order_region, 'Unknown') AS order_region,
        COUNT(DISTINCT customer_id) AS customers,
        COUNT(DISTINCT order_id) AS orders,
        SUM(net_sales) AS net_sales,
        SUM(order_profit) AS profit,
        COUNT(DISTINCT order_id) FILTER (WHERE late_delivery_risk = 1) AS late_orders,
        COUNT(DISTINCT order_id) FILTER (WHERE late_delivery_risk IN (0, 1)) AS evaluable_delivery_orders
    FROM vw_order_analysis_non_canceled
    GROUP BY COALESCE(order_region, 'Unknown')
),

region_metrics AS (
    SELECT 
    	*,
		100.0 * profit / NULLIF(net_sales, 0) AS profit_margin_pct,
        net_sales / NULLIF(orders, 0) AS average_order_value,
        100.0 * late_orders / NULLIF(evaluable_delivery_orders, 0) AS late_delivery_rate_pct
    FROM region_summary
)

SELECT
    order_region,
    customers,
    orders,
    net_sales,

 	ROUND(
        (100.0 * net_sales
            / NULLIF(SUM(net_sales) OVER (), 0)
        ), 2
    ) AS sales_share_pct,

    profit,
    ROUND(profit_margin_pct, 2) AS profit_margin_pct,
    ROUND(average_order_value, 2) AS average_order_value,

    late_orders,
    evaluable_delivery_orders,
    ROUND(late_delivery_rate_pct, 2) AS late_delivery_rate_pct,

    DENSE_RANK() OVER (ORDER BY net_sales DESC) AS revenue_rank,
    DENSE_RANK() OVER (ORDER BY profit DESC) AS profit_rank,
    DENSE_RANK() OVER (ORDER BY late_delivery_rate_pct DESC NULLS LAST ) AS late_rate_rank

FROM region_metrics
ORDER BY revenue_rank, order_region;

-- 06B. Region investigation priority
WITH region_summary AS (
    SELECT
        COALESCE(order_region, 'Unknown') AS order_region,
        COUNT(DISTINCT order_id) AS scope_orders,
        COUNT(DISTINCT order_id) FILTER (WHERE late_delivery_risk IN (0, 1)) AS evaluable_orders,
        COUNT(DISTINCT order_id) FILTER (WHERE late_delivery_risk = 1) AS late_orders,
        SUM(net_sales) AS net_sales,
        SUM(order_profit) AS profit
    FROM vw_order_analysis_non_canceled
    GROUP BY COALESCE(order_region, 'Unknown')
),

region_metrics AS (
    SELECT
        *,
        100.0 * late_orders / NULLIF(evaluable_orders, 0) late_delivery_rate_pct,
        100.0 * profit / NULLIF(net_sales, 0) AS profit_margin_pct
    FROM region_summary
),

benchmarks AS (
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY net_sales) AS median_net_sales,

        100.0 * SUM(late_orders)
            / NULLIF(SUM(evaluable_orders), 0)
            AS overall_late_delivery_rate_pct
    FROM region_metrics
)

SELECT
    r.order_region,
    r.scope_orders,
    r.evaluable_orders,
    r.late_orders,
    ROUND(r.late_delivery_rate_pct, 2) AS late_delivery_rate_pct,
    r.net_sales,
    
    ROUND(
        (100.0 * r.net_sales
            / NULLIF(SUM(r.net_sales) OVER (), 0)
        ), 2
    ) AS sales_share_pct,

    r.profit,
    ROUND(r.profit_margin_pct, 2) AS profit_margin_pct,
    ROUND(b.overall_late_delivery_rate_pct, 2) AS overall_late_delivery_rate_pct,

    CASE
        WHEN r.late_delivery_rate_pct IS NULL THEN 'Unknown'
        WHEN r.late_delivery_rate_pct >= 50 THEN 'Majority of orders late'
        ELSE 'Less than majority late'
    END AS absolute_delivery_condition,

    CASE
        WHEN r.net_sales >= b.median_net_sales
         AND r.late_delivery_rate_pct >= b.overall_late_delivery_rate_pct
            THEN 'Priority 1 - High value and high relative late rate'

        WHEN r.net_sales >= b.median_net_sales
         AND r.late_delivery_rate_pct >= 50
            THEN 'Priority 2 - High value and majority late'

        WHEN r.net_sales < b.median_net_sales
         AND r.late_delivery_rate_pct >= b.overall_late_delivery_rate_pct
            THEN 'Priority 3 - Lower value but high relative late rate'

        ELSE 'Monitor - Lower relative rate, not necessarily good'
    END AS investigation_priority,

    DENSE_RANK() OVER (ORDER BY r.late_orders DESC) AS late_order_volume_rank,
    DENSE_RANK() OVER (ORDER BY r.net_sales DESC) AS revenue_rank,
    DENSE_RANK() OVER (ORDER BY r.late_delivery_rate_pct DESC NULLS LAST) AS late_rate_rank

FROM region_metrics r
CROSS JOIN benchmarks b
ORDER BY
    CASE
        WHEN r.net_sales >= b.median_net_sales
         AND r.late_delivery_rate_pct >= b.overall_late_delivery_rate_pct
            THEN 1

        WHEN r.net_sales >= b.median_net_sales
         AND r.late_delivery_rate_pct >= 50
            THEN 2

        WHEN r.net_sales < b.median_net_sales
         AND r.late_delivery_rate_pct >= b.overall_late_delivery_rate_pct
            THEN 3
            
        ELSE 4
    END,
    r.net_sales DESC;

-- 06C. Region-level delivery distribution summary.
-- This query directly supports statements such as "x of y regions
-- have a majority of orders flagged late".

WITH region_delivery AS (
    SELECT
        COALESCE(order_region, 'Unknown') AS order_region,
        COUNT(DISTINCT order_id) FILTER (
            WHERE late_delivery_risk IN (0, 1)
        ) AS evaluable_orders,

        COUNT(DISTINCT order_id) FILTER (
            WHERE late_delivery_risk = 1
        ) AS late_orders
        
    FROM vw_order_analysis_non_canceled
    GROUP BY COALESCE(order_region, 'Unknown')
),
region_rates AS (
    SELECT
        order_region,
        evaluable_orders,
        late_orders,
        100.0 * late_orders / NULLIF(evaluable_orders, 0) late_delivery_rate_pct
    FROM region_delivery
)
SELECT
    COUNT(*) AS total_regions,
    COUNT(*) FILTER (WHERE late_delivery_rate_pct >= 50) AS regions_with_majority_late,

    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE late_delivery_rate_pct >= 50
        ) / NULLIF(COUNT(*), 0), 2
    ) AS regions_with_majority_late_pct,

    ROUND(MIN(late_delivery_rate_pct), 2) AS minimum_region_late_rate_pct,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY late_delivery_rate_pct), 2) AS median_region_late_rate_pct,
    ROUND(MAX(late_delivery_rate_pct), 2) AS maximum_region_late_rate_pct
FROM region_rates;
    
   
-- =========================================================
-- 07_DELIVERY_STATUS_AND_RISK_VALIDATION
-- =========================================================

-- 07A. Scope A audit — intentionally includes all statuses.
-- Purpose: preserve evidence that CANCELED and SUSPECTED_FRAUD
-- map to Shipping canceled and late_delivery_risk = 0.

SELECT
    order_status,
    COALESCE(delivery_status, 'Unknown') AS delivery_status,
    late_delivery_risk,
    COUNT(DISTINCT order_id) AS orders
FROM vw_order_analysis
GROUP BY
    order_status,
    COALESCE(delivery_status, 'Unknown'),
    late_delivery_risk
ORDER BY order_status, delivery_status, late_delivery_risk;

-- 07B. Scope B mapping used by primary delivery analysis.

SELECT
    COALESCE(delivery_status, 'Unknown') AS delivery_status,
    late_delivery_risk,
    COUNT(DISTINCT order_id) AS orders
FROM vw_order_analysis_non_canceled
GROUP BY COALESCE(delivery_status, 'Unknown'), late_delivery_risk
ORDER BY delivery_status, late_delivery_risk;

-- =========================================================
-- 08_OVERALL_DELIVERY_KPI — Scope B
-- Expected consistency check if all excluded orders have risk 0:
-- late_orders remains 36,048 and scope orders becomes 62,897.
-- Rerun this query before recording the final percentage.
-- =========================================================

SELECT
    COUNT(DISTINCT order_id) AS scope_orders,
    COUNT(DISTINCT order_id) FILTER (WHERE late_delivery_risk IN (0, 1)) AS evaluable_delivery_orders,
 	COUNT(DISTINCT order_id) FILTER (WHERE late_delivery_risk = 1) AS late_orders,
 	
    COUNT(DISTINCT order_id)
        FILTER (
            WHERE late_delivery_risk IS NULL
               OR late_delivery_risk NOT IN (0, 1)
        ) AS unknown_delivery_orders,

    ROUND(
        (100.0
            * COUNT(DISTINCT order_id) FILTER (WHERE late_delivery_risk = 1)
            / NULLIF(
                COUNT(DISTINCT order_id) FILTER (WHERE late_delivery_risk IN (0, 1)), 0)
        ), 2
    ) AS late_delivery_rate_pct
FROM vw_order_analysis_non_canceled;

-- =========================================================
-- 09_ACTUAL_VERSUS_SCHEDULED_SHIPPING_DAYS
-- =========================================================

-- 09A. Scope A exception audit — intentionally examines only
-- the excluded statuses. Known result: 1,650 orders have
-- actual days above scheduled while late_delivery_risk = 0.

SELECT
    order_status,
    delivery_status,
    late_delivery_risk,
    COUNT(DISTINCT order_id) AS orders,

    COUNT(DISTINCT order_id) FILTER (
        WHERE actual_shipping_days > scheduled_shipping_days
    ) AS orders_actual_above_scheduled
FROM vw_order_analysis
WHERE order_status IN ('CANCELED', 'SUSPECTED_FRAUD')
GROUP BY order_status, delivery_status, late_delivery_risk
ORDER BY order_status, delivery_status, late_delivery_risk;

-- 09B. Primary comparison by late-risk group — Scope B.

SELECT
    late_delivery_risk,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(AVG(actual_shipping_days),2) AS avg_actual_shipping_days,

    ROUND(AVG(scheduled_shipping_days),2) AS avg_scheduled_shipping_days,

    ROUND(
        AVG(actual_shipping_days - scheduled_shipping_days), 2
    ) AS avg_delay_days,

    COUNT(DISTINCT order_id) FILTER (
        WHERE actual_shipping_days > scheduled_shipping_days
    ) AS orders_actual_above_scheduled
    
FROM vw_order_analysis_non_canceled
GROUP BY late_delivery_risk
ORDER BY late_delivery_risk;

-- =========================================================
-- 10_SHIPPING_MODE_PERFORMANCE — Scope B
-- =========================================================

WITH shipping_summary AS (
    SELECT
        COALESCE(shipping_mode, 'Unknown') AS shipping_mode,
        COUNT(DISTINCT order_id) AS scope_orders,
        COUNT(DISTINCT order_id) FILTER (WHERE late_delivery_risk IN (0, 1)) AS evaluable_delivery_orders,
        COUNT(DISTINCT order_id) FILTER (WHERE late_delivery_risk = 1) AS late_orders,
        SUM(net_sales) AS net_sales,
        SUM(order_profit) AS profit,
        AVG(actual_shipping_days) FILTER (WHERE actual_shipping_days IS NOT NULL) AS avg_actual_shipping_days,
		AVG(scheduled_shipping_days) AS avg_scheduled_shipping_days,
        AVG(actual_shipping_days - scheduled_shipping_days) 
        FILTER (
            WHERE actual_shipping_days IS NOT NULL
              AND scheduled_shipping_days IS NOT NULL
        ) AS avg_delay_days

    FROM vw_order_analysis_non_canceled
    GROUP BY COALESCE(shipping_mode, 'Unknown')
)

SELECT
    shipping_mode,
    scope_orders,
    evaluable_delivery_orders,
    late_orders,

    ROUND(
        (100.0 * late_orders
            / NULLIF(evaluable_delivery_orders, 0)
        ), 2
    ) AS late_delivery_rate_pct,

    ROUND(avg_actual_shipping_days, 2) AS avg_actual_shipping_days,
    ROUND(avg_scheduled_shipping_days, 2) AS avg_scheduled_shipping_days,
    ROUND(avg_delay_days, 2) AS avg_delay_days,
    net_sales,
    ROUND((100.0 * profit / NULLIF(net_sales, 0)), 2) AS profit_margin_pct

FROM shipping_summary
ORDER BY late_delivery_rate_pct DESC NULLS LAST;

-- =========================================================
-- 11_MARKET_AND_SHIPPING_MODE — Scope B
-- Show both numerator and denominator; do not infer causality.
-- =========================================================

SELECT
    COALESCE(market, 'Unknown') AS market,
    COALESCE(shipping_mode, 'Unknown') AS shipping_mode,
    COUNT(DISTINCT order_id) AS scope_orders,
    COUNT(DISTINCT order_id) FILTER (WHERE late_delivery_risk IN (0, 1)) AS evaluable_delivery_orders,
    COUNT(DISTINCT order_id) FILTER (WHERE late_delivery_risk = 1) AS late_orders,

    ROUND(
        (100.0
            * COUNT(DISTINCT order_id) FILTER (WHERE late_delivery_risk = 1)
            / NULLIF(
                COUNT(DISTINCT order_id) FILTER (WHERE late_delivery_risk IN (0, 1)),0
                )
        ), 2
    ) AS late_delivery_rate_pct,

    SUM(net_sales) AS net_sales
FROM vw_order_analysis_non_canceled
GROUP BY
    COALESCE(market, 'Unknown'),
    COALESCE(shipping_mode, 'Unknown')
ORDER BY market, shipping_mode;

-- =========================================================
-- 12_LATE_VERSUS_NOT_LATE — Scope B
-- Association only: differences do not prove that lateness
-- caused changes in sales, profit or margin.
-- =========================================================

WITH delivery_groups AS (
    SELECT
        order_id,
        market,
        order_region,
        shipping_mode,
        net_sales,
        order_profit,
        total_quantity,
        distinct_product_count,

        CASE
            WHEN late_delivery_risk = 1 THEN 'Late'
            WHEN late_delivery_risk = 0 THEN 'Not Late'
            ELSE 'Unknown'
        END AS delivery_group
    FROM vw_order_analysis_non_canceled
)

SELECT
    delivery_group,
    COUNT(DISTINCT order_id) AS orders,
    SUM(net_sales) AS net_sales,
    
	ROUND(
        (SUM(net_sales)
            / NULLIF(COUNT(DISTINCT order_id), 0)
        ), 2
    ) AS average_order_value,
    
    SUM(order_profit) AS profit,

    ROUND(
        (100.0 * SUM(order_profit)
            / NULLIF(SUM(net_sales), 0)
        ), 2
    ) AS profit_margin_pct,

    ROUND(AVG(total_quantity), 2) AS avg_quantity_per_order,
    ROUND(AVG(distinct_product_count), 2) AS avg_distinct_products_per_order

FROM delivery_groups
GROUP BY delivery_group;

-- 12B. Compare market, region and shipping-mode mix within
-- each delivery group.

WITH delivery_mix AS (
    SELECT
        CASE
            WHEN late_delivery_risk = 1 THEN 'Late'
            WHEN late_delivery_risk = 0 THEN 'Not Late'
            ELSE 'Unknown'
        END AS delivery_group,
        'Market' AS dimension_name,
        COALESCE(market, 'Unknown') AS dimension_value,
        COUNT(DISTINCT order_id) AS orders
    FROM vw_order_analysis_non_canceled
    GROUP BY delivery_group, dimension_value

    UNION ALL

    SELECT
        CASE
            WHEN late_delivery_risk = 1 THEN 'Late'
            WHEN late_delivery_risk = 0 THEN 'Not Late'
            ELSE 'Unknown'
        END AS delivery_group,
        'Order Region' AS dimension_name,
        COALESCE(order_region, 'Unknown') AS dimension_value,
        COUNT(DISTINCT order_id) AS orders
    FROM vw_order_analysis_non_canceled
    GROUP BY delivery_group, dimension_value

    UNION ALL

    SELECT
        CASE
            WHEN late_delivery_risk = 1 THEN 'Late'
            WHEN late_delivery_risk = 0 THEN 'Not Late'
            ELSE 'Unknown'
        END AS delivery_group,
        'Shipping Mode' AS dimension_name,
        COALESCE(shipping_mode, 'Unknown') AS dimension_value,
        COUNT(DISTINCT order_id) AS orders
    FROM vw_order_analysis_non_canceled
    GROUP BY delivery_group, dimension_value
)

SELECT
    delivery_group,
    dimension_name,
    dimension_value,
    orders,
    
    ROUND(
        (100.0 * orders
            / NULLIF(
                SUM(orders) OVER (
                    PARTITION BY delivery_group, dimension_name
                ), 0 )
        ), 2
    ) AS share_within_delivery_group_pct

FROM delivery_mix
ORDER BY delivery_group, dimension_name, orders DESC;

-- =========================================================
-- 13_FINAL_RECONCILIATION — Scope B
-- =========================================================

-- 13A. Baseline. Must match the Day 4 Scope B baseline.

WITH baseline AS (
    SELECT
        COUNT(DISTINCT order_id) AS orders,
        COUNT(DISTINCT customer_id) AS customers,
        SUM(net_sales) AS net_sales,
        SUM(order_profit) AS profit
    FROM vw_order_analysis_non_canceled
)
SELECT *
FROM baseline;

-- 13B. Reconcile Net Sales by dimension.
-- No extra date filter is applied because every component must
-- use exactly the same Scope B view and reporting period.

WITH baseline AS (
    SELECT
        SUM(net_sales) AS baseline_net_sales
    FROM vw_order_analysis_non_canceled
),

segment_total AS (
    SELECT
        SUM(net_sales) AS segment_net_sales
    FROM (
        SELECT
            COALESCE(customer_segment, 'Unknown') AS customer_segment,
            SUM(net_sales) AS net_sales
        FROM vw_order_analysis_non_canceled
        GROUP BY COALESCE(customer_segment, 'Unknown')
    ) s
),

market_total AS (
    SELECT
        SUM(net_sales) AS market_net_sales
    FROM (
        SELECT
            COALESCE(market, 'Unknown') AS market,
            SUM(net_sales) AS net_sales
        FROM vw_order_analysis_non_canceled
        GROUP BY COALESCE(market, 'Unknown')
    ) m
),

region_total AS (
    SELECT
        SUM(net_sales) AS region_net_sales
    FROM (
        SELECT
            COALESCE(order_region, 'Unknown') AS order_region,
            SUM(net_sales) AS net_sales
        FROM vw_order_analysis_non_canceled
        GROUP BY COALESCE(order_region, 'Unknown')
    ) r
)

SELECT
    baseline_net_sales,
    segment_net_sales,
    market_net_sales,
    region_net_sales,

    segment_net_sales - baseline_net_sales  AS segment_difference,
    market_net_sales - baseline_net_sales AS market_difference,
    region_net_sales - baseline_net_sales AS region_difference

FROM baseline
CROSS JOIN segment_total
CROSS JOIN market_total
CROSS JOIN region_total;

-- 13C. Reconcile the three delivery groups.
-- This version genuinely groups the orders before comparing
-- the sum back to the baseline.

WITH baseline AS (
    SELECT
        COUNT(DISTINCT order_id) AS baseline_orders
    FROM vw_order_analysis_non_canceled
),

delivery_group_counts AS (
    SELECT
        CASE
            WHEN late_delivery_risk = 1 THEN 'Late'
            WHEN late_delivery_risk = 0 THEN 'Not Late'
            ELSE 'Unknown'
        END AS delivery_group,
        COUNT(DISTINCT order_id) AS orders
    FROM vw_order_analysis_non_canceled
    GROUP BY delivery_group
),

delivery_total AS (
    SELECT
        SUM(orders) AS grouped_orders
    FROM delivery_group_counts
)

SELECT
    baseline_orders,
    grouped_orders,
    grouped_orders - baseline_orders AS difference
FROM baseline
CROSS JOIN delivery_total;

-- 13D. Reconcile customer summary back to Scope B.

WITH order_baseline AS (
    SELECT
        COUNT(DISTINCT customer_id) AS customers,
        COUNT(DISTINCT order_id) AS orders,
        SUM(net_sales) AS net_sales,
        SUM(order_profit) AS profit
    FROM vw_order_analysis_non_canceled
),
customer_total AS (
    SELECT
        COUNT(*) AS customers,
        SUM(order_count) AS orders,
        SUM(net_sales) AS net_sales,
        SUM(profit) AS profit
    FROM customer_summary
)
SELECT
    o.customers AS baseline_customers,
    c.customers AS customer_summary_rows,
    c.customers - o.customers AS customer_difference,

    o.orders AS baseline_orders,
    c.orders AS customer_summary_orders,
    c.orders - o.orders AS order_difference,

    ROUND((c.net_sales - o.net_sales)::numeric, 6)
        AS net_sales_difference,
    ROUND((c.profit - o.profit)::numeric, 6)
        AS profit_difference
FROM order_baseline AS o
CROSS JOIN customer_total AS c;
