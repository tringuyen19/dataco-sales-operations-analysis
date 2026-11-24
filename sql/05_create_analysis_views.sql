/* =========================================================
Day 3 - Analysis views

Scope A views:
- vw_order_item_analysis
- vw_order_analysis

Scope B views:
- vw_order_item_analysis_non_canceled
- vw_order_analysis_non_canceled

Không xóa hoặc sửa dữ liệu nguồn để tạo Scope B.
========================================================= */

/* 1. Create Scope A order-item analysis view
   Grain: One row represents one order_item_id. */
CREATE OR REPLACE VIEW vw_order_item_analysis AS
WITH typed_order_items AS (
    SELECT
        order_item_id,
        order_id,
        customer_id,
        product_card_id,
        order_date AS order_datetime,

        NULLIF(BTRIM(category_name), '') AS category_name,
        NULLIF(BTRIM(product_name), '') AS product_name,
        NULLIF(BTRIM(customer_segment), '') AS customer_segment,
        NULLIF(BTRIM(market), '') AS market,
        NULLIF(BTRIM(order_region), '') AS order_region,
        NULLIF(BTRIM(order_country), '') AS order_country,
        NULLIF(BTRIM(shipping_mode), '') AS shipping_mode,
        NULLIF(BTRIM(order_status), '') AS order_status,
        NULLIF(BTRIM(delivery_status), '') AS delivery_status,

        late_delivery_risk,
        days_for_shipping_real AS actual_shipping_days,
        days_for_shipment_scheduled AS scheduled_shipping_days,
            

        order_item_quantity AS quantity,
        sales_amount AS gross_sales,
        order_item_discount AS discount_amount,
        order_item_total AS net_sales,
        order_profit_per_order AS line_profit
    FROM stg_dataco
)
SELECT
    order_item_id,
    order_id,
    customer_id,
    product_card_id,
    
    order_datetime,
    order_datetime::DATE AS order_date,
    DATE_TRUNC('month', order_datetime)::DATE AS order_month,
    DATE_TRUNC('quarter', order_datetime)::DATE AS order_quarter,
    EXTRACT(YEAR FROM order_datetime)::INTEGER AS order_year,

    category_name,
    product_name,
    customer_segment,
    market,
    order_region,
    order_country,
    shipping_mode,
    order_status,
    delivery_status,

    late_delivery_risk,
    actual_shipping_days,
    scheduled_shipping_days,

    quantity,
    gross_sales,
    discount_amount,
    net_sales,
    line_profit,

    discount_amount / NULLIF(gross_sales, 0)
        AS actual_discount_rate,

    line_profit / NULLIF(net_sales, 0)
        AS line_profit_margin
FROM typed_order_items;

/* 2. Create Scope A order-level analysis view
   Grain: One row represents one order_id. */
CREATE OR REPLACE VIEW vw_order_analysis AS
SELECT
    order_id,

    MIN(customer_id) AS customer_id,
    MIN(order_datetime) AS order_datetime,
    MIN(order_date) AS order_date,
    MIN(order_month) AS order_month,
    MIN(order_quarter) AS order_quarter,
    MIN(order_year) AS order_year,

    MIN(customer_segment) AS customer_segment,
    MIN(market) AS market,
    MIN(order_region) AS order_region,
    MIN(order_country) AS order_country,
    MIN(shipping_mode) AS shipping_mode,
    MIN(order_status) AS order_status,
    MIN(delivery_status) AS delivery_status,

    MIN(late_delivery_risk) AS late_delivery_risk,
    MIN(actual_shipping_days) AS actual_shipping_days,
    MIN(scheduled_shipping_days) AS scheduled_shipping_days,

    COUNT(*) AS order_line_count,
    COUNT(DISTINCT product_card_id) AS distinct_product_count,
    SUM(quantity) AS total_quantity,

    SUM(gross_sales) AS gross_sales,
    SUM(discount_amount) AS discount_amount,
    SUM(net_sales) AS net_sales,
    SUM(line_profit) AS order_profit,

    SUM(line_profit)
        / NULLIF(SUM(net_sales), 0)
        AS order_profit_margin
FROM vw_order_item_analysis
GROUP BY order_id;

/* 3. Create Scope B order-item view
   Excludes only CANCELED and SUSPECTED_FRAUD.
   IS DISTINCT FROM retains NULL status instead of silently dropping it. */
CREATE OR REPLACE VIEW vw_order_item_analysis_non_canceled AS
SELECT *
FROM vw_order_item_analysis
WHERE order_status IS DISTINCT FROM 'CANCELED'
  AND order_status IS DISTINCT FROM 'SUSPECTED_FRAUD';

/* 4. Create Scope B order-level view */
CREATE OR REPLACE VIEW vw_order_analysis_non_canceled AS
SELECT *
FROM vw_order_analysis
WHERE order_status IS DISTINCT FROM 'CANCELED'
  AND order_status IS DISTINCT FROM 'SUSPECTED_FRAUD';

/* 5. Reconcile Scope A order-item and order views
   Expected result: all differences equal 0. */
WITH item_totals AS (
    SELECT
        SUM(quantity) AS total_quantity,
        SUM(gross_sales) AS gross_sales,
        SUM(discount_amount) AS discount_amount,
        SUM(net_sales) AS net_sales,
        SUM(line_profit) AS total_profit
    FROM vw_order_item_analysis
),
order_totals AS (
    SELECT
        SUM(total_quantity) AS total_quantity,
        SUM(gross_sales) AS gross_sales,
        SUM(discount_amount) AS discount_amount,
        SUM(net_sales) AS net_sales,
        SUM(order_profit) AS total_profit
    FROM vw_order_analysis
)
SELECT
    i.total_quantity - o.total_quantity AS quantity_difference,
    ROUND(i.gross_sales - o.gross_sales, 2) AS gross_sales_difference,
    ROUND(i.discount_amount - o.discount_amount, 2) AS discount_difference,
    ROUND(i.net_sales - o.net_sales, 2) AS net_sales_difference,
    ROUND(i.total_profit - o.total_profit, 2) AS profit_difference
FROM item_totals AS i
CROSS JOIN order_totals AS o;

/* 6. Reconcile Scope B order-item and order views
   Expected result: all differences equal 0. */
WITH item_totals AS (
    SELECT
        SUM(quantity) AS total_quantity,
        SUM(gross_sales) AS gross_sales,
        SUM(discount_amount) AS discount_amount,
        SUM(net_sales) AS net_sales,
        SUM(line_profit) AS total_profit
    FROM vw_order_item_analysis_non_canceled
),
order_totals AS (
    SELECT
        SUM(total_quantity) AS total_quantity,
        SUM(gross_sales) AS gross_sales,
        SUM(discount_amount) AS discount_amount,
        SUM(net_sales) AS net_sales,
        SUM(order_profit) AS total_profit
    FROM vw_order_analysis_non_canceled
)
SELECT
    i.total_quantity - o.total_quantity AS quantity_difference,
    ROUND(i.gross_sales - o.gross_sales, 2) AS gross_sales_difference,
    ROUND(i.discount_amount - o.discount_amount, 2) AS discount_difference,
    ROUND(i.net_sales - o.net_sales, 2) AS net_sales_difference,
    ROUND(i.total_profit - o.total_profit, 2) AS profit_difference
FROM item_totals AS i
CROSS JOIN order_totals AS o;

/* 7. Scope comparison smoke test
   Expected orders: Scope A = 65,752; Scope B = 62,897. */
SELECT
    (SELECT COUNT(*) FROM vw_order_analysis) AS scope_a_orders,
    (SELECT COUNT(*) FROM vw_order_analysis_non_canceled) AS scope_b_orders,
    (
        SELECT COUNT(*)
            FROM vw_order_analysis
        WHERE order_status IN ('CANCELED', 'SUSPECTED_FRAUD')
    ) AS excluded_orders;

/* 8. Scope A reconciliation KPIs
   Use for recorded totals, status analysis and sensitivity checks. */
SELECT
    ROUND(SUM(net_sales), 2) AS recorded_net_sales,
    ROUND(SUM(order_profit), 2) AS recorded_total_profit,
    ROUND(SUM(order_profit) / NULLIF(SUM(net_sales), 0), 4) AS recorded_profit_margin,
    COUNT(*) AS recorded_orders,
    ROUND(SUM(net_sales)/ NULLIF(COUNT(*), 0), 2) AS recorded_average_order_value,

    ROUND(
        1.0 * COUNT(*) FILTER (
            WHERE order_status IN ('CANCELED', 'SUSPECTED_FRAUD')
        ) / NULLIF(COUNT(*), 0), 4
    ) AS cancellation_rate
FROM vw_order_analysis;

/* 9. Scope B primary KPI smoke test
   Use for primary business and delivery analysis. */
SELECT
    ROUND(SUM(net_sales), 2) AS core_net_sales,
    ROUND(SUM(order_profit), 2) AS core_total_profit,
    ROUND(SUM(order_profit) / NULLIF(SUM(net_sales), 0), 4) AS core_profit_margin,
    COUNT(*) AS core_orders,
    ROUND(SUM(net_sales) / NULLIF(COUNT(*), 0), 2) AS average_order_value,
    COUNT(*) FILTER (WHERE late_delivery_risk = 1) AS late_orders,
    COUNT(*) FILTER (WHERE late_delivery_risk IN (0, 1)) AS delivery_eligible_orders,

    ROUND(
        1.0 * COUNT(*) FILTER (
            WHERE late_delivery_risk = 1
        ) / NULLIF(
            COUNT(*) FILTER (
                WHERE late_delivery_risk IN (0, 1)
            ), 0
        ), 4
    ) AS late_delivery_rate
FROM vw_order_analysis_non_canceled;
