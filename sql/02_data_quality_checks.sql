/* =========================================================
1. Missing values in critical fields
Grain: order item
Scope: all source rows
========================================================= */

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE order_item_id IS NULL) AS missing_order_item_id,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS missing_order_id,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS missing_customer_id,
    COUNT(*) FILTER (WHERE product_card_id IS NULL) AS missing_product_card_id,
    COUNT(*) FILTER (WHERE order_date IS NULL) AS missing_order_date,
    COUNT(*) FILTER (WHERE shipping_date IS NULL) AS missing_shipping_date,
    COUNT(*) FILTER (WHERE order_status IS NULL) AS missing_order_status,
    COUNT(*) FILTER (WHERE customer_segment IS NULL) AS missing_customer_segment,
    COUNT(*) FILTER (WHERE market IS NULL) AS missing_market,
    COUNT(*) FILTER (WHERE order_region IS NULL) AS missing_order_region,
    COUNT(*) FILTER (WHERE shipping_mode IS NULL) AS missing_shipping_mode,
    COUNT(*) FILTER (WHERE delivery_status IS NULL) AS missing_delivery_status,
    COUNT(*) FILTER (WHERE late_delivery_risk IS NULL) AS missing_late_delivery_risk,
    COUNT(*) FILTER (WHERE order_item_quantity IS NULL) AS missing_quantity,
    COUNT(*) FILTER (WHERE order_item_product_price IS NULL) AS missing_product_price,
    COUNT(*) FILTER (WHERE order_item_total IS NULL) AS missing_net_sales,
    COUNT(*) FILTER (WHERE order_profit_per_order IS NULL) AS missing_profit
FROM stg_dataco;

/* 2. Duplicate checks */
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE order_item_id IS NULL) AS missing_order_item_id,
    COUNT(DISTINCT order_item_id)AS distinct_order_item_id,
    COUNT(*) - COUNT(DISTINCT order_item_id) AS difference_from_unique_key
FROM stg_dataco;

/* 3. Date quality checks */
/* 3.1. Date range */
SELECT
    MIN(order_date) AS minimum_order_date,
    MAX(order_date) AS maximum_order_date,
    MIN(shipping_date) AS minimum_shipping_date,
    MAX(shipping_date) AS maximum_shipping_date
FROM stg_dataco;

/* 3.2. Count invalid date sequences */
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE shipping_date < order_date) AS shipping_before_order_rows
FROM stg_dataco;

/* 4. Numeric validity checks */
SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE order_item_quantity <= 0) AS invalid_quantity_rows,
    COUNT(*) FILTER (WHERE order_item_product_price < 0) AS negative_price_rows,
    COUNT(*) FILTER (WHERE sales_amount < 0) AS negative_sales_amount_rows,
    COUNT(*) FILTER (WHERE order_item_total < 0) AS negative_net_sales_rows,
    COUNT(*) FILTER (WHERE order_item_discount < 0) AS negative_discount_rows,

    COUNT(*) FILTER (
        WHERE order_item_discount_rate < 0
           OR order_item_discount_rate > 1
    ) AS invalid_discount_rate_rows,

    COUNT(*) FILTER (WHERE order_item_discount > sales_amount) AS discount_above_gross_sales_rows
FROM stg_dataco;

/* 5. Category consistency checks */
SELECT
    LOWER(TRIM(order_status)) AS normalized_status,
    ARRAY_AGG(DISTINCT order_status) AS original_values,
    COUNT(*) AS order_item_rows,
    COUNT(DISTINCT order_id) AS orders
FROM stg_dataco
GROUP BY LOWER(TRIM(order_status))
ORDER BY normalized_status;

SELECT
    LOWER(TRIM(delivery_status)) AS normalized_delivery_status,
    ARRAY_AGG(DISTINCT delivery_status) AS original_values,
    COUNT(*) AS number_of_rows,
    COUNT(DISTINCT order_id) AS orders
FROM stg_dataco
GROUP BY LOWER(TRIM(delivery_status))
ORDER BY normalized_delivery_status;

SELECT
    LOWER(TRIM(shipping_mode)) AS normalized_shipping_mode,
    ARRAY_AGG(DISTINCT shipping_mode) AS original_values,
    COUNT(*) AS number_of_rows,
    COUNT(DISTINCT order_id) AS orders
FROM stg_dataco
GROUP BY LOWER(TRIM(shipping_mode))
ORDER BY normalized_shipping_mode;

SELECT
    LOWER(TRIM(customer_segment)) AS normalized_customer_segment,
    ARRAY_AGG(DISTINCT customer_segment) AS original_values,
    COUNT(*) AS number_of_rows,
    COUNT(DISTINCT order_id) AS orders
FROM stg_dataco
GROUP BY LOWER(TRIM(customer_segment))
ORDER BY normalized_customer_segment;

/* 7. Order status, delivery status and late-risk relationship*/
SELECT
    order_status,
    delivery_status,
    late_delivery_risk,
    COUNT(DISTINCT order_id) AS orders
FROM stg_dataco
GROUP BY
    order_status,
    delivery_status,
    late_delivery_risk
ORDER BY
    order_status,
    delivery_status,
    late_delivery_risk;
   
/* 7.1. Validate canceled and suspected-fraud mapping */
SELECT
    order_status,
    delivery_status,
    late_delivery_risk,
    COUNT(DISTINCT order_id) AS orders
FROM stg_dataco
WHERE order_status IN ('CANCELED', 'SUSPECTED_FRAUD')
GROUP BY
    order_status,
    delivery_status,
    late_delivery_risk
ORDER BY order_status;

/* 8. Shipping-day exceptions by order and delivery status */
WITH order_shipping AS (
    SELECT
        order_id,
        MAX(order_status) AS order_status,
        MAX(delivery_status) AS delivery_status,
        MAX(late_delivery_risk) AS late_delivery_risk,
        MAX(days_for_shipping_real) AS actual_shipping_days,
        MAX(days_for_shipment_scheduled) AS scheduled_shipping_days
    FROM stg_dataco
    GROUP BY order_id
)

SELECT
    order_status,
    delivery_status,
    late_delivery_risk,

    COUNT(*) AS orders,

    COUNT(*) FILTER (WHERE actual_shipping_days > scheduled_shipping_days
    ) AS actual_above_scheduled_orders,

    COUNT(*) FILTER (
        WHERE actual_shipping_days = scheduled_shipping_days
    ) AS actual_equal_scheduled_orders,

    COUNT(*) FILTER (
        WHERE actual_shipping_days < scheduled_shipping_days
    ) AS actual_below_scheduled_orders

FROM order_shipping
GROUP BY
    order_status,
    delivery_status,
    late_delivery_risk
ORDER BY order_status, delivery_status, late_delivery_risk;

/* 9.1. Compare order counts between reporting scopes */
SELECT
    COUNT(DISTINCT order_id) AS scope_a_all_orders,

    COUNT(DISTINCT order_id) FILTER (
        WHERE order_status IS DISTINCT FROM 'CANCELED'
          AND order_status IS DISTINCT FROM 'SUSPECTED_FRAUD'
    ) AS scope_b_non_canceled_orders,

    COUNT(DISTINCT order_id) FILTER (
        WHERE order_status IN ('CANCELED', 'SUSPECTED_FRAUD')
    ) AS excluded_orders

FROM stg_dataco;