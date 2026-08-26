# Business Question Tree

## 1. Stakeholder decision

The Sales & Operations Manager needs to determine:

> Which products, markets and delivery processes should receive attention
> to protect revenue, improve profitability and reduce late delivery?

## 2. Business performance

Primary business-performance questions use Scope B. Scope A is retained only
for recorded-total reconciliation, order-status analysis and sensitivity.

### Core questions

- How do Core Net Sales, Core Total Profit and Profit Margin change over time?
- Are sales and profit moving in the same direction?
- Which periods have high sales but low Profit Margin?
- Is business performance driven by order volume or Average Order Value?
- How much do recorded results change when canceled/fraud orders are excluded?

### KPIs

- Core Net Sales
- Core Total Profit
- Profit Margin
- Core Orders
- Average Order Value
- Units Sold
- Recorded Net Sales and Recorded Orders for sensitivity only

### Main dimensions

- Month
- Quarter
- Order Status for Scope A sensitivity/status analysis
- Market
- Region

## 3. Product and discount performance

### Core questions

These questions use Scope B unless the question explicitly investigates order
status or cancellation.

- Which categories and products contribute the most Core Net Sales?
- Which high-sales products generate low or negative profit?
- Which categories have high weighted Discount Rate?
- Is revenue concentrated in a small number of categories or products?
- Do high-discount groups also have lower Profit Margin?

### KPIs

- Core Net Sales
- Core Total Profit
- Profit Margin
- Discount Rate
- Units Sold
- Revenue contribution

### Main dimensions

- Category
- Product
- Market
- Region
- Time

### Interpretation limitation

A relationship between discount and profit does not prove that discount
caused low profit. Other factors such as product mix, geography and order
status must also be investigated.

## 4. Customer and market performance

Customer and market performance use Scope B so canceled/fraud orders do not
inflate customer value, repeat behavior or regional performance.

### Core questions

- Which customer segments contribute the most sales and profit?
- Which markets have high sales but low Profit Margin?
- Which customers have placed multiple orders?
- How different are sales, profit and Average Order Value across regions?

### KPIs

- Core Net Sales
- Core Total Profit
- Profit Margin
- Core Orders
- Total Customers
- Average Order Value

### Main dimensions

- Customer Segment
- Customer
- Market
- Region
- Country

## 5. Delivery performance

Delivery KPIs use Scope B. Canceled/fraud orders are excluded before creating
the Late and Not Late groups.

### Core questions

- What is the overall Late Delivery Rate?
- Which markets and regions have the highest Late Delivery Rate?
- How does delivery performance differ by Shipping Mode?
- Which groups have longer Actual Shipping Days?
- Do late orders show different sales and profit outcomes from non-late orders?
- What share of Scope A orders is excluded from delivery analysis?

### KPIs

- Late Delivery Rate
- Average Actual Delivery Days
- Core Orders
- Core Net Sales
- Profit Margin
- Cancellation Rate for Scope A context

### Main dimensions

- Shipping Mode
- Market
- Region
- Delivery Status
- Order Status

## 6. Analysis principles

- Use `vw_order_analysis` and `vw_order_item_analysis` for Scope A
  reconciliation, status analysis and sensitivity checks.
- Use `vw_order_analysis_non_canceled` for primary order, customer, market and
  delivery metrics.
- Use `vw_order_item_analysis_non_canceled` for primary product, sales,
  discount and profit analysis.
- Do not classify canceled/fraud orders as `Not Late` merely because
  `late_delivery_risk = 0`.
- Do not join an order view to its order-item view and then aggregate the
  financial measures.
- Do not interpret correlation as causation.
- Label every output with its reporting scope.
- Every finding must include a number, comparison or query result.
