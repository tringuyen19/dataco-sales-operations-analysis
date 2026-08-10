/* 1. Sales = product price × quantity */
SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE ABS(
            sales_amount - order_item_product_price * order_item_quantity
        ) <= 0.01
    ) AS matching_rows,

    COUNT(*) FILTER (
        WHERE ABS(
            sales_amount - order_item_product_price * order_item_quantity
        ) > 0.01
    ) AS mismatching_rows,

    ROUND(
        100.0 
        * COUNT(*) FILTER (
            WHERE ABS(
                sales_amount - order_item_product_price * order_item_quantity
            ) <= 0.01
        ) / COUNT(*),
        2
    ) AS matching_percentage
FROM stg_dataco;

/* 2. Discount = sales × discount rate */
SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE ABS(
            order_item_discount - sales_amount * order_item_discount_rate
        ) <= 0.01
    ) AS matching_rows,

    COUNT(*) FILTER (
        WHERE ABS(
            order_item_discount - sales_amount * order_item_discount_rate
        ) > 0.01
    ) AS mismatching_rows,

    ROUND(
        100.0
        * COUNT(*) FILTER (
            WHERE ABS(
                order_item_discount - sales_amount * order_item_discount_rate
            ) <= 0.01
        ) / COUNT(*),
        2
    ) AS matching_percentage
FROM stg_dataco;

/* 3. Order item total = sales - discount */
SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE ABS(
            order_item_total - (sales_amount - order_item_discount)
        ) <= 0.01
    ) AS matching_rows,

    COUNT(*) FILTER (
        WHERE ABS(
            order_item_total - (sales_amount - order_item_discount)
        ) > 0.01
    ) AS mismatching_rows,

    ROUND(
        100.0
        * COUNT(*) FILTER (
            WHERE ABS(
                order_item_total - (sales_amount - order_item_discount)
            ) <= 0.01
        )
        / COUNT(*),
        2
    ) AS matching_percentage
FROM stg_dataco;

/* 4. Compare sales_per_customer vs order_item_total */
SELECT 
	count(*) AS total_rows ,

	count(*) FILTER (
		WHERE ABS(
            sales_per_customer - order_item_total
        ) <= 0.01
	) AS matching_rows,

    MAX(
        ABS(
            sales_per_customer - order_item_total
        )
    ) AS maximum_difference
FROM stg_dataco sd

/* 5. Compare benefit_per_order vs order_profit_per_order */
SELECT
    COUNT(*) AS total_rows,

    COUNT(*) FILTER (
        WHERE ABS(
            benefit_per_order - order_profit_per_order
        ) <= 0.01
    ) AS matching_rows,

    MAX(
        ABS(
            benefit_per_order - order_profit_per_order
        )
    ) AS maximum_difference

FROM stg_dataco;

/* 6. Validate profit ratio */
SELECT
    order_item_id,
    order_item_total,
    order_profit_per_order,
    order_item_profit_ratio,
    order_profit_per_order
        / NULLIF(order_item_total, 0) AS expected_profit_ratio
FROM stg_dataco
WHERE ABS(
          order_item_profit_ratio
          - (
                order_profit_per_order
                / NULLIF(order_item_total, 0)
            )
      ) > 0.01;

/* 7. Check whether profit is repeated within each order */
SELECT
    order_id,
    COUNT(*) AS number_of_lines,
    COUNT(DISTINCT order_profit_per_order) AS different_profit_values,
    MIN(order_profit_per_order) AS min_profit,
    MAX(order_profit_per_order) AS max_profit
FROM stg_dataco
GROUP BY order_id
HAVING COUNT(*) > 1 
AND COUNT(DISTINCT order_profit_per_order) != count(*)
ORDER BY number_of_lines DESC	