# Data Quality Report

## 1. Scope of quality assessment

Data quality checks are performed on Scope A, containing all 180,519
order-item rows and 65,752 recorded orders.

No order status is removed during source-data profiling.

The quality assessment distinguishes between:

- source-data validity;
- analytical eligibility for business-performance reporting.

Orders with `CANCELED` and `SUSPECTED_FRAUD` statuses remain in the
source dataset but are excluded from Scope B, the non-canceled analytical
scope used for primary business-performance analysis.

## 2. Summary

| Area | Result | Severity | Decision |
|---|---|---|---|
| Row-level key | `180,519` rows; `180,519` distinct `order_item_id`; 0 missing | Passed | Use `order_item_id` as the row-level key |
| Distinct orders | `65,752` recorded orders | Passed | Count orders with `COUNT(DISTINCT order_id)` at item grain |
| Missing critical fields | `0`| Passed | |
| Full-row duplicates | `0` | Passed |  |
| Date sequence | `0` | Passed | |
| Quantity | No values less than or equal to 0 | Passed | Retain |
| Discount rate | No values outside 0–1 | Passed | Retain |
| Other numeric fields | `0` | Passed |  |
| Financial fields | Validated separately | See `03_financial_field_validation.md` | Do not duplicate financial formulas here |
| Category labels | [Điền kết quả query 6] | Medium if inconsistent | Standardize only if inconsistencies exist |
| Canceled/fraud orders | `2,855` orders, equal to `4.34%` of all orders | High analytical impact | Retain in Scope A; exclude from Scope B |
| Shipping-day exception | `1,650` risk-0 orders have actual days above scheduled; all are Shipping canceled | Medium | Exclude canceled orders from primary delivery KPI |

## 3. Validations passed

- `stg_dataco` contains 180,519 order-item rows.
- No `order_item_id` is missing.
- No duplicate `order_item_id` is detected.
- `order_item_id` is suitable as the row-level key.
- No `order_item_quantity` is less than or equal to 0.
- No `order_item_discount_rate` is outside the interval from 0 to 1.
- Order-level attributes are consistent within the same `order_id`.
- `CANCELED` and `SUSPECTED_FRAUD` orders consistently map to
  `Shipping canceled`.

## 4. Data quality observations and issues

### DQ-01 — Canceled and suspected-fraud orders are analytically ineligible

There are 2,855 orders with `CANCELED` or `SUSPECTED_FRAUD` status.
These orders correspond to `Shipping canceled`.

#### Decision

Retain these orders in Scope A for source reconciliation and cancellation
analysis. Exclude them from Scope B, which is used for primary
non-canceled business-performance analysis.

No source records are deleted.

### DQ-02 — Shipping canceled and late-risk logic

Among canceled/fraud orders, 1,650 have actual shipping days greater
than scheduled shipping days while `late_delivery_risk = 0`.

This does not prove that the orders were delivered to customers before
being canceled. It only shows that shipping-duration values were recorded
for canceled shipments.

#### Decision

Do not evaluate Shipping canceled orders using the same Late Delivery
Rate denominator as non-canceled orders.

## 5. Reporting-scope decision

### Scope A — All recorded orders

- 65,752 orders.
- Retains all source records for reconciliation and order-status analysis.

### Scope B — Non-canceled orders

Excludes:

- `CANCELED`;
- `SUSPECTED_FRAUD`.

Scope B contains:

- 62,897 orders.

Scope B is the primary analytical scope because canceled and
suspected-fraud orders are not eligible for non-canceled
business-performance and delivery analysis.

Scope B is called `non-canceled orders`, not `completed orders`, because
other unresolved statuses remain included.

**SQL reference:** `sql/02_data_quality_checks.sql`
