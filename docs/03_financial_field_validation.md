# Financial Field Validation

## 1. Revenue formula validation

| Validation                                                            |                   Matching rows | Matching rate | Conclusion                                                                                                                                                                                  |
| --------------------------------------------------------------------- | ------------------------------: | ------------: | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `sales_amount = order_item_product_price × order_item_quantity`       |                         180,519 |          100% | `sales_amount` là **doanh thu gộp trước giảm giá** ở cấp dòng sản phẩm trong đơn hàng (*order item*).                                                                                       |
| `order_item_discount = sales_amount × order_item_discount_rate`       |                         170,490 |        94.44% | `order_item_discount_rate` được lưu dưới dạng **tỷ lệ đã làm tròn**, nên không thể dùng `sales_amount × order_item_discount_rate` để tính/chứng minh chính xác tiền giảm giá.               |
| `order_item_total = sales_amount - order_item_discount`               |                         180,519 |          100% | `order_item_total` là **doanh thu thuần sau giảm giá** ở cấp order item. Đây là trường doanh thu phù hợp để dùng cho KPI chính.                                                             |
| `sales_per_customer = order_item_total`                               |                         180,519 |          100% | `sales_per_customer` thực chất lặp lại doanh thu thuần của từng dòng sản phẩm; không phải tổng doanh thu vòng đời của khách hàng. Không cần giữ cả hai trường trong mô hình phân tích.      |
| `benefit_per_order = order_profit_per_order`                          |                         180,519 |          100% | Hai trường có cùng giá trị ở tất cả các dòng. Chỉ giữ `order_profit_per_order` trong mô hình để tránh dư thừa.                                                                              |
| Kiểm tra `order_profit_per_order` giữa các dòng cùng `order_id`       | Profit thay đổi theo order item |             — | Dù tên cột có cụm “per order”, lợi nhuận thực tế thuộc **cấp order item**, không phải một giá trị lặp lại cho toàn bộ đơn hàng. Có thể cộng lợi nhuận giữa các dòng để tính tổng lợi nhuận. |

---

## 2. Interpretation of financial fields

### 2.1. Revenue fields

Mỗi dòng trong `stg_dataco` đại diện cho một **order item**. Vì vậy, các trường doanh thu và lợi nhuận được xác nhận chủ yếu ở cấp dòng sản phẩm:

* `sales_amount`: doanh thu gộp trước giảm giá.
* `order_item_discount`: số tiền giảm giá thực tế của dòng sản phẩm.
* `order_item_total`: doanh thu thuần sau giảm giá.
* `order_profit_per_order`: lợi nhuận của dòng sản phẩm, mặc dù tên cột có thể gây hiểu nhầm là lợi nhuận cấp đơn hàng.
* `order_item_profit_ratio`: tỷ suất lợi nhuận của dòng sản phẩm.

Quan hệ công thức được xác nhận:

```text
Gross Sales = sales_amount

Net Sales = sales_amount - order_item_discount
          = order_item_total

Item Profit Ratio = order_profit_per_order / NULLIF(order_item_total, 0)
```

### 2.2. Discount-rate limitation

`order_item_discount_rate` không phải là tỷ lệ chiết khấu có độ chính xác đầy đủ. Tỷ lệ này đã được làm tròn, nên khi nhân ngược với `sales_amount` có thể tạo ra chênh lệch với `order_item_discount`.

Ví dụ: tiền giảm giá thực tế có thể tương ứng với tỷ lệ 5.5%, nhưng dataset lưu thành 0.06 (6%) sau khi làm tròn.

**Decision:**

* Dùng `order_item_discount` để tính tổng tiền giảm giá.
* Không dùng `sales_amount × order_item_discount_rate` để tính lại chính xác discount.
* `order_item_discount_rate` chỉ dùng để tham khảo hoặc phân nhóm mức giảm giá.
* Nếu cần tỷ lệ giảm giá thực tế, tính lại bằng:

```sql
order_item_discount / NULLIF(sales_amount, 0)
```

---

## 3. KPI decision

Các KPI tài chính chính của project được định nghĩa như sau:

| KPI                   | Correct calculation                                              | Reason                                                                                           |
| --------------------- | ---------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| Gross Sales           | `SUM(sales_amount)`                                              | Tổng doanh thu trước giảm giá ở cấp order item.                                                  |
| Total Discount        | `SUM(order_item_discount)`                                       | Dùng số tiền giảm giá thực tế, không tính lại từ discount rate đã làm tròn.                      |
| Net Sales             | `SUM(order_item_total)`                                          | Doanh thu sau giảm giá; được xác minh khớp 100% với `sales_amount - order_item_discount`.        |
| Total Profit          | `SUM(order_profit_per_order)`                                    | Lợi nhuận thay đổi theo từng order item và không bị lặp lại nguyên giá trị cho toàn bộ đơn hàng. |
| Profit Margin         | `SUM(order_profit_per_order) / NULLIF(SUM(order_item_total), 0)` | Là tỷ suất lợi nhuận có trọng số theo doanh thu.                                                 |
| Average Discount Rate | `SUM(order_item_discount) / NULLIF(SUM(sales_amount), 0)`        | Phản ánh tỷ lệ giảm giá thực tế của toàn bộ dữ liệu.                                             |

Không dùng các cách tính sau:

```sql
-- Sai: sales là doanh thu trước giảm giá
SUM(sales_amount) AS net_sales

-- Sai: discount rate đã được làm tròn
SUM(sales_amount * order_item_discount_rate) AS total_discount

-- Sai: trung bình đơn giản làm mỗi dòng có trọng số như nhau
AVG(order_item_profit_ratio) AS profit_margin
```

---

## 4. Profit validation conclusion

`benefit_per_order` và `order_profit_per_order` là hai trường trùng nhau hoàn toàn. Để tránh dư thừa, mô hình phân tích chỉ giữ `order_profit_per_order`.

Mặc dù có tên là `order_profit_per_order`, trường này được xác định là lợi nhuận ở cấp **order item** vì:

1. Giá trị lợi nhuận thay đổi giữa các dòng sản phẩm trong cùng một `order_id`.
2. Giá trị này khớp với công thức:

```text
order_item_profit_ratio
= order_profit_per_order / order_item_total
```

3. Do đó, tổng lợi nhuận của toàn bộ doanh nghiệp có thể tính bằng:

```sql
SUM(order_profit_per_order)
```

Lợi nhuận âm là giá trị hợp lệ trong dataset. Nó cho thấy một dòng sản phẩm hoặc đơn hàng bị lỗ sau khi xét doanh thu thuần và chi phí được phản ánh trong dữ liệu; không tự động coi đó là lỗi dữ liệu.

## 5. Reporting-scope financial sensitivity

### 5.1. Why the scope was reviewed

Data-quality and delivery validation identified 2,855 orders with
`CANCELED` or `SUSPECTED_FRAUD` status. These orders correspond to
`Shipping canceled`.

Although these orders contain recorded net sales and profit, the dataset
does not provide accounting rules confirming whether the amounts were
recognized after cancellation.

The project therefore compares two scopes.

### 5.2. Scope comparison

| Metric | Scope A: All recorded orders | Scope B: Non-canceled orders | Difference |
|---|---:|---:|---:|
| Orders | 65,752 | 62,897 | -2,855 |
| Net Sales | 33,054,402.04 | 31,644,664.75 | -1,409,737.29 |
| Profit | 3,966,902.97 | 3,806,420.63 | -160,482.34 |
| Profit Margin | 12.00% | 12.03% | +0.03 percentage point |

### 5.3. Interpretation

Orders with `CANCELED` and `SUSPECTED_FRAUD` status account for:

- 4.34% of all recorded orders;
- 4.26% of recorded net sales;
- 4.05% of recorded profit.

Excluding these orders reduces total net sales and profit by
approximately 4%, while overall Profit Margin changes only slightly
from 12.00% to 12.03%.

This means the all-status financial results are not completely invalid.
However, they represent all recorded transactions rather than
non-canceled business performance.

Stable total Profit Margin does not guarantee that monthly trends,
category rankings, product rankings or customer results remain stable.
Those breakdowns must be revalidated under Scope B.

### 5.4. Analytical decision

- Scope A is retained for source reconciliation, order-status analysis
  and financial sensitivity checks.
- Scope B is used as the primary scope for non-canceled business
  performance.
- Financial values are described as `recorded net sales` and
  `recorded profit`.
- Scope B is not described as completed orders or recognized revenue
  because unresolved statuses remain included.