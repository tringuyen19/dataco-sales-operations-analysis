# Analysis Model Validation

## 1. Model overview

| View | Scope | Grain | Expected key | Main use |
|---|---|---|---|---|
| `vw_order_item_analysis` | A — All recorded orders | One row per order item | `order_item_id` | Source reconciliation, status and sensitivity analysis |
| `vw_order_analysis` | A — All recorded orders | One row per order | `order_id` | Recorded orders and order-status analysis |
| `vw_order_item_analysis_non_canceled` | B — Non-canceled orders | One row per order item | `order_item_id` | Primary product, sales, discount and profit analysis |
| `vw_order_analysis_non_canceled` | B — Non-canceled orders | One row per order | `order_id` | Primary order, customer, market and delivery analysis |

Scope B excludes only `CANCELED` and `SUSPECTED_FRAUD`. It is not described
as completed orders because unresolved statuses remain included.

## 2. Scope A grain validation

| Check | Result | Status |
|---|---:|---|
| Rows in order-item view | 180,519 | Pass |
| Distinct `order_item_id` | 180,519 | Pass |
| Rows in order view | 65,752 | Pass |
| Distinct `order_id` | 65,752 | Pass |

## 3. Scope A reconciliation

| Measure | Order-item view | Order view | Difference | Status |
|---|---:|---:|---:|---|
| Total Quantity | 180,519 | 180,519 | 0 | Pass |
| Gross Sales | 36,784,734.31 | 36,784,734.31 | 0 | Pass |
| Total Discount | 3,730,378.40 | 3,730,378.40 | 0 | Pass |
| Net Sales | 33,054,402.04 | 33,054,402.04 | 0 | Pass |
| Total Profit | 3,966,902.97 | 3,966,902.97 | 0 | Pass |

These are recorded totals for Scope A, not the default business-performance
baseline.

## 4. Scope B validation

### 4.1. Order-count reconciliation

| Check | Result | Status |
|---|---:|---|
| Scope A orders | 65,752 | Pass |
| Excluded `CANCELED` / `SUSPECTED_FRAUD` orders | 2,855 | Pass |
| Scope B orders | 62,897 | Pass |
| Scope A minus excluded equals Scope B | 62,897 | Pass |

### 4.2. Financial baseline

| Measure | Scope A | Scope B | Excluded amount |
|---|---:|---:|---:|
| Net Sales | 33,054,402.04 | 31,644,664.75 | 1,409,737.29 |
| Total Profit | 3,966,902.97 | 3,806,420.63 | 160,482.34 |
| Profit Margin | 12.00% | 12.03% | — |

### 4.3. Required view checks

After creating the Scope B views, run the validation queries in
`05_create_analysis_views.sql` and confirm:

- rows in `vw_order_item_analysis_non_canceled` equal distinct
  `order_item_id`;
- rows in `vw_order_analysis_non_canceled` equal distinct `order_id`;
- Scope B contains 62,897 orders;
- no Scope B row has `CANCELED` or `SUSPECTED_FRAUD` status;
- quantity, Gross Sales, Total Discount, Net Sales and Total Profit reconcile
  between the Scope B order-item and order views with zero difference.

Do not mark these checks as passed until the SQL has been executed.

## 5. Order-level attribute validation

The existing validation passed for:

- `delivery_status`;
- `late_delivery_risk`;
- `actual_shipping_days`;
- `scheduled_shipping_days`.

The expanded check in `04_cleaning_transformation.sql` must also return zero
inconsistent orders for:

- `customer_id`;
- `customer_segment`;
- `market`;
- `order_region`;
- `order_country`;
- `shipping_mode`;
- `order_status`.

Do not mark the expanded check as passed until it has been executed. This is
especially important for `order_status`: consistent status within each order
ensures that Scope B filters the same orders at both grains.

## 6. Delivery-scope validation

- `CANCELED` and `SUSPECTED_FRAUD` map to `Shipping canceled`.
- These orders are retained in Scope A and excluded from Scope B.
- They must not be classified as `Not Late` merely because
  `late_delivery_risk = 0`.
- Late Delivery Rate is calculated from
  `vw_order_analysis_non_canceled`, with late orders and eligible orders shown
  explicitly.

## 7. Final conclusion

The original two views remain the Scope A reconciliation layer. The two
non-canceled views provide the default Scope B layer for subsequent analysis.

- Day 4 Scope A results remain available for audit and sensitivity.
- Day 4 business tables must be rerun or revalidated under Scope B.
- Day 5 customer, market and delivery analysis must use the Scope B views.

**SQL reference:** `sql/05_create_analysis_views.sql`
