# Analysis Findings Part 2 — Customer, Market and Delivery

## 0. Reporting scope and update rule

Day 5 uses **Scope B — non-canceled orders** for primary customer, market,
region and delivery analysis.

Scope B excludes:

- `CANCELED`;
- `SUSPECTED_FRAUD`.

Known Scope B baseline from Day 3–4:

| Metric | Scope B baseline |
|---|---:|
| Orders | 62,897 |
| Recorded Net Sales | 31,644,664.75 |
| Recorded Profit | 3,806,420.63 |
| Profit Margin | 12.03% |

The results from the previous Day 5 file were calculated on Scope A and are
retained below only as historical references. They must not be presented as
current Scope B findings.

After rerunning each SQL section:

- always enter the new Scope B values;
- write `unchanged` only when both the value and conclusion are unchanged;
- write `ranking/finding remained stable` when values changed but the main
  ranking or directional conclusion did not;
- rewrite the finding when the leading group, ranking or interpretation changed.

---

## 1. Customer segment performance revalidation

### Business question

Which customer segment contributes the most business value under Scope B?

### Previous Scope A reference

| Check | Previous Scope A result | Scope B result |
|---|---:|---:|
| Leading segment by Net Sales | Consumer | Consumer |
| Consumer Net Sales | 17,164,278.19 | 16,417,549.44 |
| Consumer Sales Share | 45.20% | 51.88% |
| Consumer Profit | 2,073,487.67 | 1,982,863.62 |
| Consumer Profit Margin | 12.08% | 12.08% |
| Consumer Average Order Value | 503.07 | 503.39 |
| Consumer late orders/evaluable orders | 18,672 / 34,119 | 18,672 / 32,614 |
| Consumer Late Delivery Rate | 54.73% | 57.25% |
| Gap from second-ranked segment | 7,133,628.39 | 6,555,497.86 |
|

### Scope B conclusion

Consumer remained the leading customer segment under Scope B, generating
`16,417,549.44` in recorded Net Sales and `1,982,863.62` in recorded Profit.

After excluding canceled and suspected-fraud orders, Consumer's Net Sales and
Profit decreased, but its leading position and Profit Margin of 12.08% remained
stable. It still exceeded the second-ranked segment by 6,555,497.86.

Consumer's Late Delivery Rate increased from `54.73%` to `57.25%`. The number of
late orders remained `18,672`, while evaluable orders decreased from `34,119` to
`32,614`. Therefore, Consumer remains the most important segment by business
value but also requires continued delivery-performance monitoring.

### SQL reference

Section `01_CUSTOMER_SEGMENT_PERFORMANCE`.

---

## 2. Repeat-customer contribution revalidation

### Business question

How much recorded value comes from customers with at least two observed orders?

### Previous Scope A reference

| Check | Previous Scope A result | Scope B result |
|---|---:|---:|
| Total observed customers | 20,652 | 20,261 |
| Repeat customers | 11,768 | 11,644 |
| Repeat Customer Rate | 56.98% | 57.47% |
| Repeat Revenue Share | 92.41% | 92.21% |
| Repeat Revenue per Customer | 2,595.52 | 2,505.85 |
| One-time Revenue per Customer | 282.56 | 286.25 |

### Scope B conclusion

Repeat customers remained the main source of recorded customer value under
Scope B. They represented `11,644` of `20,261` observed customers, equivalent to
a Repeat Customer Rate of `57.47%`, and contributed `92.21%` of recorded Net Sales.

Revenue per Repeat Customer was `2,505.85` which is
approximately `8.76` times the `286.25` recorded for One-time Customers.

This shows that customers with multiple observed orders contributed a
disproportionately large share of recorded Net Sales

### Interpretation guardrails

- `Repeat` means at least two orders observed inside the dataset period.
- It does not prove loyalty or retention.
- `first_observed_order` is not necessarily the customer's first-ever order.
- Revenue per Customer is not Customer Lifetime Value.

### SQL reference

Sections `02_CUSTOMER_SUMMARY` and `03_REPEAT_CUSTOMER_RATE`.

---

## 3. Customer revenue concentration revalidation

### Business question

How concentrated is recorded Net Sales among the highest-value customers?

### Previous Scope A reference

| Check | Previous Scope A result | Scope B result |
|---|---:|---:|
| Total observed customers | 20,652 | 20,261 |
| Top 10 customer Revenue Share | 0.25% | 0.26% |
| Top 10% customer Revenue Share | 29.22% | 29.08% |
| Top 10% customer count | 2,065 | 2,027 |


### Scope B conclusion

Under Scope B, the Top 10% of customers, equivalent to `2,027` customers,
contributed `29.08%` of recorded Net Sales. Meanwhile, the Top 10 customers
contributed only `0.26%`.

Compared with Scope A, the Top 10% Revenue Share decreased slightly from
`29.22%` to `29.08%`, while the overall conclusion remained stable. Recorded Net
Sales was concentrated across a broader group of high-value customers rather
than depending heavily on only a few individual customers.

### Interpretation guardrails

- Report the exact revenue share before describing concentration.
- Do not classify concentration as an official business risk without a
  company-defined threshold.
- A high-value observed customer is not automatically a loyal customer.
- These results describe customer value only within the observed dataset
  period.

### SQL reference

Section `04_CUSTOMER_REVENUE_CONCENTRATION`.

---

## 4. Market and region performance revalidation

### Business questions

- Which market contributes the most recorded Net Sales and Profit?
- Which regions combine high business value with weak delivery performance?
- Is high Late Delivery Rate isolated or widespread?

### Previous Scope A reference

| Check | Previous Scope A result | Scope B result |
|---|---:|---:|
| Overall Late Delivery Rate | 54.82% | 57.31% |
| Late orders/evaluable orders | 36,048 / 65,752 | 36,048 / 62,897 |
| Regions with Late Delivery Rate ≥ 50% | 22 / 23 | 23 / 23 |
| Share of regions with majority late | 95.65% | 100% |
| Minimum region Late Delivery Rate | 49.51% | 52.58% |
| Median region Late Delivery Rate | 54.87% | 57.28% |
| Maximum region Late Delivery Rate | 57.55% | 60.04% |
| Leading market by Net Sales | Europe | Europe |
| Priority high-value/high-late regions | Western Europe, Central America, Southeast Asia, South Asia, East of USA | Western Europe, Southeast Asia, South Asia, Eastern Asia, East of USA |

### Confirmed consistency check

The late-order count remained 36,048, while the evaluable-order denominator
decreased from 65,752 to 62,897 after canceled and suspected-fraud orders were
excluded. Consequently, the Late Delivery Rate increased to 57.31%.

### Scope B conclusion

Late delivery remained a widespread operational issue under Scope B. The
overall Late Delivery Rate increased from 54.82% to 57.31% because the 2,855
excluded orders had `late_delivery_risk = 0`, while the number of late orders
remained unchanged at 36,048.

All 23 regions had a Late Delivery Rate of at least 50%. Europe remained the leading market by recorded Net Sales.

The priority-region list changed slightly: Western Europe, Southeast Asia,
South Asia and East of USA remained priorities, while Eastern Asia replaced
Central America. This finding supports investigating delivery performance
across the overall operation, with priority given to regions combining high
business value, high late-order volume and high Late Delivery Rate.

### Interpretation guardrails

- A rate below the median means relatively better, not necessarily good.
- The 50% threshold only describes whether a majority of orders are late; it
  is not a Service Level Agreement target.
- Region is an analytical dimension, not proven to be the cause of lateness.
- Prioritize using business value, late-order volume and Late Delivery Rate
  together; do not rank by rate alone.

### SQL reference

Sections `05_MARKET_ANALYSIS`, `06_REGION_ANALYSIS` and `08_OVERALL_DELIVERY_KPI`.

---

## 5. Shipping-mode performance

### Business question

Which shipping modes show the weakest observed delivery performance under
Scope B, and in which important markets do they appear?

### Required Scope B evidence

| Check | Scope B result |
|---|---:|
| Shipping mode with highest Late Delivery Rate | First Class |
| Late orders/evaluable orders for that mode | 9,602 / 9,602 |
| Average Actual Shipping Days | 2 |
| Average Scheduled Shipping Days | 1 |
| Average Delay Days | 1 |
| Recorded Net Sales | 4,860,949.70 |
| Profit Margin | 12.68% |
| Important market + mode combination to investigate | Europe + First Class and Second Class |

### Scope B conclusion

First Class showed the weakest delivery performance: all 9,602 evaluable
orders were flagged late. Average Actual Shipping Days was 2 days compared
with 1 scheduled day.

Within Europe, First Class had a 100% Late Delivery Rate, while Second Class
had an 80.17% rate. These combinations should be prioritized because they
combine substantial recorded Net Sales with high late-order volumes. However,
the results do not prove that shipping mode causes lateness.

### Interpretation guardrails

- Always show late-order count and evaluable-order count beside the rate.
- Do not conclude that shipping mode causes lateness.
- Differences may reflect market, region, product, time or service-level mix.
- Do not create an official minimum sample-size threshold without a business rule.

### SQL reference

Sections `10_SHIPPING_MODE_PERFORMANCE` and `11_MARKET_AND_SHIPPING_MODE`.

---

## 6. Late versus Not Late comparison

### Business question

How do the observed order and financial characteristics differ between Late
and Not Late orders in Scope B?

### Required Scope B evidence

| Metric | Late | Not Late | Difference |
|---|---:|---:|---:|
| Orders | 36,048 | 26,849 | 9,199 |
| Recorded Net Sales | 18,082,855.11 | 13,562,109.64 | 4,520,745.47 |
| Average Order Value | 501.62 | 505.13 | -3.51 |
| Recorded Profit | 2,041,058.68 | 1,666,368.95 | 374,689.73 |
| Profit Margin | 11.83% | 12.29% | -0.46 percentage points |
| Average Quantity per Order | 5.84 | 5.85 | -0.01 |
| Average Distinct Products per Order | 2.43 | 2.43 | 0.00 |

| Dimension | Group | Late share | Not Late share | Difference |
|---|---|---:|---:|---:|
| Market | Europe | 28.29% | 28.17% | +0.12 pp |
| Market | Pacific Asia | 26.96% | 26.57% | +0.39 pp |
| Market | LATAM | 25.91% | 26.35% | -0.44 pp |
| Region | Western Europe | 15.49% | 14.82% | +0.67 pp |
| Region | Central America | 14.30% | 14.32% | -0.02 pp |
| Shipping Mode | Standard Class | 41.60% | 84.31% | -42.71 pp |
| Shipping Mode | Second Class | 27.19% | 9.14% | +18.05 pp |
| Shipping Mode | First Class | 26.64% | 0.00% | +26.64 pp |
| Shipping Mode | Same Day | 4.57% | 6.55% | -1.98 pp |

### Scope B conclusion

Market and region composition was broadly similar between Late and Not Late
orders, with only small differences among the leading groups.

Shipping-mode composition differed substantially. First Class represented
`26.64%` of Late orders but no Not Late orders, while Second Class represented
`27.19%` of Late orders compared with `9.14%` of Not Late orders. Standard Class
accounted for `84.31%` of Not Late orders but only `41.60%` of Late orders.

The strongest observed difference between the two delivery groups was
therefore associated with shipping mode rather than market or region.
However, this association does not prove that shipping mode caused lateness.

### SQL reference

Section `12_LATE_VERSUS_NOT_LATE`.

---

## 7. Scope A delivery exception retained for audit

The following is a data-quality and scope observation, not a Scope B delivery
performance finding:

- `CANCELED` and `SUSPECTED_FRAUD` map to `Shipping canceled`;
- these orders are recorded with `late_delivery_risk = 0`;
- `1,650` excluded orders have Actual Shipping Days above Scheduled Shipping
  Days while still carrying risk `0`.

These records remain in Scope A for reconciliation and cancellation analysis,
but are excluded from Scope B delivery KPIs. Shipping-duration values do not
prove that canceled orders were successfully delivered.

### SQL reference

Sections `07A` and `09A`.

---

## 8. Final reconciliation checklist

Day 5 is complete only when all checks below pass:

| Validation | Expected result |
|---|---:|
| Scope B order rows = distinct orders | 62,897 = 62,897 |
| Excluded statuses inside Scope B | 0 |
| Scope B Net Sales | 31,644,664.75 |
| Scope B Profit | 3,806,420.63 |
| Customer-summary grain difference | 0 |
| Segment Net Sales − baseline Net Sales | 0 |
| Market Net Sales − baseline Net Sales | 0 |
| Region Net Sales − baseline Net Sales | 0 |
| Delivery-group orders − baseline orders | 0 |
| Customer-summary orders − baseline orders | 0 |
| Customer-summary Net Sales − baseline Net Sales | 0 |
| Customer-summary Profit − baseline Profit | 0 |

### SQL reference

Sections `00_SCOPE_AND_MODEL_VALIDATION` and `13_FINAL_RECONCILIATION`.
