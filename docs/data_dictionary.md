# Data Dictionary — DataCo Supply Chain

Tài liệu gồm 53 trường dữ liệu nguồn, được chia thành 7 nhóm nghiệp vụ. Giá trị *Trống* biểu thị ô ví dụ để trống trong file nguồn; `NULL` là giá trị ví dụ được ghi nguyên văn trong file.

Các giá trị trong cột **Validation Rule** là quy tắc đã quan sát hoặc dùng để kiểm tra chất lượng dữ liệu. Chúng không mặc nhiên là database constraints đã được triển khai trong DDL.

## A. Thông tin thanh toán và giao hàng

| Field Name | Data Type | Field Length | Validation Rule | Description | Example |
|---|---|---:|---|---|---|
| `order_type` | `VARCHAR` | `20` | `NOT NULL` | Phương thức hoặc loại giao dịch thanh toán của đơn hàng. Tên gốc: Type. | `DEBIT` |
| `days_for_shipping_real` | `INTEGER` | `—` | `NOT NULL; expected >= 0` | Số ngày shipping thực tế được ghi nhận trong nguồn. Đối với canceled orders, giá trị này không chứng minh đơn đã được giao thành công cho khách hàng. | `3` |
| `days_for_shipment_scheduled` | `INTEGER` | `—` | `NOT NULL; expected >= 0` | Số ngày shipping dự kiến theo phương thức vận chuyển được ghi nhận trong nguồn. | `4` |
| `delivery_status` | `VARCHAR` | `30` | `NOT NULL` | Trạng thái delivery do nguồn cung cấp. `Shipping canceled` đã được xác minh tương ứng với `CANCELED` và `SUSPECTED_FRAUD`. | `Advance shipping` |
| `late_delivery_risk` | `INTEGER` | `—` | `NOT NULL; expected IN (0,1)` | Cờ delivery do nguồn cung cấp: 1 = được gắn Late Delivery, 0 = không được gắn late. Giá trị 0 không chứng minh giao đúng hạn vì canceled/fraud orders cũng được gắn 0. | `0` |
| `shipping_date` | `TIMESTAMP` | `—` | `NOT NULL` | Ngày và giờ vận chuyển của đơn hàng. Tên gốc: shipping date (DateOrders). | `2018-02-03 22:56:00` |
| `shipping_mode` | `VARCHAR` | `30` | `NOT NULL` | Phương thức hoặc cấp độ dịch vụ vận chuyển được chọn. | `Standard Class` |

## B. Chỉ số doanh thu, chiết khấu và lợi nhuận

| Field Name | Data Type | Field Length | Validation Rule | Description | Example |
|---|---|---:|---|---|---|
| `benefit_per_order` | `NUMERIC` | `12,2` | `Nullable; may be negative` | Lợi nhuận ở cấp order item. Đã được xác minh trùng với `order_profit_per_order` trên toàn bộ 180,519 dòng; không cộng đồng thời hai trường. | `91.25` |
| `sales_per_customer` | `NUMERIC` | `12,2` | `Expected >= 0` | Giá trị trùng với `order_item_total` trên toàn bộ dữ liệu. Mặc dù tên có “per customer”, đây không phải tổng doanh thu khách hàng mà vẫn ở cấp order item. | `314.64` |
| `order_item_discount` | `NUMERIC` | `12,2` | `Expected >= 0` | Số tiền discount thực tế của dòng sản phẩm. | `13.11` |
| `order_item_discount_rate` | `NUMERIC` | `6,4` | `Expected BETWEEN 0 AND 1` | Tỷ lệ discount được lưu sau khi làm tròn. Không dùng để tính chính xác discount amount; nếu cần tỷ lệ thực tế, tính `order_item_discount / NULLIF(sales_amount, 0)`. | `0.0400` |
| `order_item_product_price` | `NUMERIC` | `12,2` | `Expected >= 0` | Đơn giá niêm yết của sản phẩm tại thời điểm phát sinh giao dịch. | `327.75` |
| `order_item_profit_ratio` | `NUMERIC` | `8,4` | `Nullable; may be negative` | Item Profit Ratio, tương ứng `order_profit_per_order / NULLIF(order_item_total, 0)`. Không dùng `AVG()` đơn giản để tính Profit Margin tổng hợp. | `0.2900` |
| `order_item_quantity` | `INTEGER` | `—` | `NOT NULL; CHECK > 0` | Số lượng sản phẩm trong dòng đơn hàng. | `1` |
| `sales_amount` | `NUMERIC` | `12,2` | `Expected >= 0` | Gross Sales ở cấp order item trước discount. Đã xác minh bằng `order_item_product_price × order_item_quantity`. Tên gốc: Sales. | `327.75` |
| `order_item_total` | `NUMERIC` | `12,2` | `Expected >= 0` | Recorded Net Sales ở cấp order item sau discount. Không mặc nhiên được xem là recognized revenue. | `314.64` |
| `order_profit_per_order` | `NUMERIC` | `12,2` | `Nullable; may be negative` | Profit ở cấp order item, mặc dù tên có cụm “per order”. Phải cộng các dòng để tính profit của đơn hoặc nhóm phân tích. | `91.25` |

## C. Danh mục và phòng ban

| Field Name | Data Type | Field Length | Validation Rule | Description | Example |
|---|---|---:|---|---|---|
| `category_id` | `INTEGER` | `—` | `NOT NULL; FK candidate` | Mã định danh danh mục sản phẩm gắn với dòng giao dịch. | `73` |
| `category_name` | `VARCHAR` | `50` | `NOT NULL` | Tên danh mục sản phẩm. | `Sporting Goods` |
| `department_id` | `INTEGER` | `—` | `NOT NULL; FK candidate` | Mã định danh phòng ban hoặc nhóm kinh doanh quản lý danh mục. | `2` |
| `department_name` | `VARCHAR` | `50` | `NOT NULL` | Tên phòng ban hoặc nhóm kinh doanh. | `Fitness` |

## D. Thông tin khách hàng

| Field Name | Data Type | Field Length | Validation Rule | Description | Example |
|---|---|---:|---|---|---|
| `customer_id` | `INTEGER` | `—` | `NOT NULL; FK candidate` | Mã định danh khách hàng. Có thể xuất hiện trong nhiều đơn hàng. | `20755` |
| `customer_first_name` | `VARCHAR` | `100` | `Nullable` | Tên của khách hàng. | `Cally` |
| `customer_last_name` | `VARCHAR` | `100` | `Nullable` | Họ của khách hàng. | `Holloway` |
| `customer_email` | `VARCHAR` | `255` | `Nullable; sensitive/unused` | Địa chỉ email khách hàng. Trong bản dữ liệu được chia sẻ, giá trị thường đã được che. | `XXXXXXXXX` |
| `customer_password` | `VARCHAR` | `100` | `Nullable; sensitive/unused` | Mật khẩu khách hàng đã được che hoặc ẩn danh. Không nên sử dụng trong phân tích. | `XXXXXXXXX` |
| `customer_segment` | `VARCHAR` | `30` | `NOT NULL` | Phân khúc khách hàng theo mô hình kinh doanh. | `Consumer` |
| `customer_city` | `VARCHAR` | `100` | `Nullable` | Thành phố trong địa chỉ đăng ký của khách hàng | `Caguas` |
| `customer_country` | `VARCHAR` | `100` | `Nullable` | Quốc gia trong địa chỉ đăng ký khách hàng. | `Puerto Rico` |
| `customer_state` | `VARCHAR` | `100` | `Nullable` | Bang/tỉnh trong địa chỉ đăng ký của khách hàng | `PR` |
| `customer_street` | `VARCHAR` | `255` | `Nullable; sensitive` | Địa chỉ đường/phố của khách hàng. Không cần thiết cho phần lớn phân tích BI. | `5365 Noble Nectar Island` |
| `customer_zipcode` | `VARCHAR` | `20` | `Nullable` | Mã bưu chính của khách hàng. Dùng VARCHAR để bảo toàn số 0 ở đầu. | `725` |
| `latitude` | `NUMERIC` | `10,7` | `Nullable; expected BETWEEN -90 AND 90` | Vĩ độ gắn với vị trí địa lý của khách hàng. | `18.2514534` |
| `longitude` | `NUMERIC` | `10,7` | `Nullable; expected BETWEEN -180 AND 180` | Kinh độ gắn với vị trí địa lý của khách hàng. | `-66.0370560` |

## E. Thông tin thị trường và đơn hàng

| Field Name | Data Type | Field Length | Validation Rule | Description | Example |
|---|---|---:|---|---|---|
| `market` | `VARCHAR` | `50` | `NOT NULL` | Thị trường kinh doanh cấp cao nơi đơn hàng được ghi nhận. | `Pacific Asia` |
| `order_id` | `INTEGER` | `—` | `NOT NULL; grouping key` | Mã định danh đơn hàng. Không duy nhất ở staging vì một đơn có thể chứa nhiều order items. Được sử dụng làm key để tạo `vw_order_analysis`. | `77202` |
| `order_customer_id` | `INTEGER` | `—` | `NOT NULL; FK candidate` | Mã khách hàng được lưu tại đơn hàng. Thông thường cần bằng customer_id. | `20755` |
| `order_date` | `TIMESTAMP` | `—` | `NOT NULL` | Ngày và giờ khách hàng đặt đơn hàng. Tên gốc: order date (DateOrders). | `2018-01-31 22:56:00` |
| `order_status` | `VARCHAR` | `30` | `NOT NULL` | Trạng thái xử lý hoặc thanh toán của đơn hàng. | `COMPLETE` |
| `order_city` | `VARCHAR` | `100` | `Nullable` | Thành phố đích của đơn hàng hoặc thành phố giao hàng. | `Bekasi` |
| `order_country` | `VARCHAR` | `100` | `Nullable` | Quốc gia đích của đơn hàng hoặc quốc gia giao hàng. | `Indonesia` |
| `order_region` | `VARCHAR` | `50` | `Nullable` | Khu vực địa lý cấp vùng của đơn hàng. | `Southeast Asia` |
| `order_state` | `VARCHAR` | `100` | `Nullable` | Bang, tỉnh hoặc khu vực hành chính tại địa chỉ giao hàng. | `Java Occidental` |
| `order_zipcode` | `VARCHAR` | `20` | `Nullable` | Mã bưu chính của địa chỉ đơn hàng. Cột này có nhiều giá trị thiếu trong dữ liệu mẫu. |  |

## F. Dòng sản phẩm trong đơn hàng

| Field Name | Data Type | Field Length | Validation Rule | Description | Example |
|---|---|---:|---|---|---|
| `order_item_id` | `INTEGER` | `—` | `PK candidate; NOT NULL; UNIQUE` | order_item_id được sử dụng làm grain key (khóa xác định cấp độ dòng) của vw_order_item_analysis. | `180517` |
| `order_item_cardprod_id` | `INTEGER` | `—` | `NOT NULL; FK candidate` | Mã sản phẩm được lưu trên dòng đơn hàng. Thường tương ứng với product_card_id. | `1360` |

## G. Thông tin sản phẩm

| Field Name | Data Type | Field Length | Validation Rule | Description | Example |
|---|---|---:|---|---|---|
| `product_card_id` | `INTEGER` | `—` | `NOT NULL; FK candidate` | Mã định danh sản phẩm. Có thể lặp lại trên nhiều dòng giao dịch. | `1360` |
| `product_category_id` | `INTEGER` | `—` | `NOT NULL; FK candidate` | Mã danh mục được lưu trong thông tin sản phẩm. Thông thường cần bằng category_id. | `73` |
| `product_name` | `VARCHAR` | `255` | `NOT NULL` | Tên sản phẩm. Cần dùng TRIM() vì dữ liệu có thể chứa khoảng trắng cuối chuỗi. | `Smart watch` |
| `product_description` | `TEXT` | `—` | `Nullable` | Nội dung mô tả chi tiết sản phẩm. Phần lớn bản dữ liệu có thể để trống. |  |
| `product_image` | `TEXT` | `—` | `Nullable` | URL hình ảnh sản phẩm. Có thể chứa khoảng trắng hoặc URL không còn hoạt động. | `http://images.acmesports.sports/Smart+watch` |
| `product_price` | `NUMERIC` | `12,2` | `Expected >= 0` | Giá niêm yết hoặc giá chuẩn trong danh mục sản phẩm. | `327.75` |
| `product_status` | `INTEGER` | `—` | `NOT NULL; categorical` | Trạng thái sản phẩm được mã hóa bằng số. Dataset mẫu chủ yếu sử dụng 0; cần kiểm tra tập giá trị trước khi diễn giải. | `0` |

## H. Analysis Layer Mapping

Analysis layer phân biệt hai reporting scopes:

| View | Scope | Grain | Main use |
|---|---|---|---|
| `vw_order_item_analysis` | Scope A — All recorded orders | Một dòng mỗi `order_item_id` | Source reconciliation, order-status và sensitivity analysis |
| `vw_order_analysis` | Scope A — All recorded orders | Một dòng mỗi `order_id` | Recorded-order reconciliation, status và cancellation analysis |
| `vw_order_item_analysis_non_canceled` | Scope B — Non-canceled orders | Một dòng mỗi `order_item_id` | Primary product, category, sales, discount và profit analysis |
| `vw_order_analysis_non_canceled` | Scope B — Non-canceled orders | Một dòng mỗi `order_id` | Primary order, customer, market và delivery analysis |

Scope B loại `CANCELED` và `SUSPECTED_FRAUD`. Scope này được gọi là **non-canceled orders**, không gọi là completed orders vì vẫn chứa các status chưa hoàn tất khác.

### H.1. Scope A order-item analysis view

View: `vw_order_item_analysis`

Grain: Một dòng đại diện cho một `order_item_id`.

View này được giữ làm Scope A và được sử dụng cho:

- Source reconciliation.
- Order-status analysis.
- Cancellation và financial sensitivity analysis.
- Đối chiếu với order-level Scope A view.

#### Mapping từ staging → analysis

| Source field (`stg_dataco`) | Analysis field (`vw_order_item_analysis`) | Purpose |
|---|---|---|
| `order_item_id` | `order_item_id` | Key của order item |
| `order_id` | `order_id` | Liên kết với đơn hàng |
| `customer_id` | `customer_id` | Khách hàng |
| `product_card_id` | `product_card_id` | Sản phẩm |
| `order_date` | `order_datetime` | Ngày giờ đặt hàng |
| `order_date` | `order_date` | Ngày đặt hàng |
| `order_date` | `order_month` | Tháng đặt hàng |
| `order_date` | `order_quarter` | Quý đặt hàng |
| `order_date` | `order_year` | Năm đặt hàng |
| `category_name` | `category_name` | Danh mục |
| `product_name` | `product_name` | Sản phẩm |
| `customer_segment` | `customer_segment` | Phân khúc khách hàng |
| `market` | `market` | Thị trường |
| `order_region` | `order_region` | Khu vực |
| `order_country` | `order_country` | Quốc gia giao hàng |
| `shipping_mode` | `shipping_mode` | Phương thức vận chuyển |
| `order_status` | `order_status` | Trạng thái đơn |
| `delivery_status` | `delivery_status` | Trạng thái giao hàng |
| `late_delivery_risk` | `late_delivery_risk` | Rủi ro giao trễ |
| `days_for_shipping_real` | `actual_shipping_days` | Số ngày shipping thực tế được ghi nhận |
| `days_for_shipment_scheduled` | `scheduled_shipping_days` | Số ngày shipping dự kiến được ghi nhận |
| `order_item_quantity` | `quantity` | Số lượng bán |
| `sales_amount` | `gross_sales` | Doanh thu trước discount |
| `order_item_discount` | `discount_amount` | Tiền discount thực tế |
| `order_item_total` | `net_sales` | Doanh thu sau discount |
| `order_profit_per_order` | `line_profit` | Lợi nhuận ở cấp order item |

#### Derived fields

Các field sau không tồn tại trực tiếp trong dataset gốc mà được tạo trong analysis view:

| Analysis field | Formula | Purpose |
|---|---|---|
| `actual_discount_rate` | `discount_amount / NULLIF(gross_sales, 0)` | Tỷ lệ discount thực tế |
| `line_profit_margin` | `line_profit / NULLIF(net_sales, 0)` | Item Profit Ratio |
| `order_date` | Derived from `order_datetime` | Phân tích theo ngày |
| `order_month` | `DATE_TRUNC('month', order_datetime)` | Phân tích theo tháng |
| `order_quarter` | `DATE_TRUNC('quarter', order_datetime)` | Phân tích theo quý |
| `order_year` | `EXTRACT(YEAR FROM order_datetime)` | Phân tích theo năm |

`actual_discount_rate` được tính lại từ số tiền discount thực tế thay vì sử dụng trực tiếp `order_item_discount_rate`, vì `order_item_discount_rate` trong dataset đã được làm tròn.

### H.2. Scope A order-level analysis view

View: `vw_order_analysis`

Grain: Một dòng đại diện cho một `order_id`.

View này được giữ làm Scope A và được sử dụng cho:

- Recorded Orders và recorded financial reconciliation.
- Order Status và cancellation analysis.
- Scope A/Scope B sensitivity.
- Đối chiếu với order-item Scope A view.

#### Order-level fields

| Field | Source / Calculation | Meaning |
|---|---|---|
| `order_id` | `order_id` | Key của đơn hàng |
| `customer_id` | Representative value from order items | Khách hàng của đơn |
| `order_datetime` | `order_datetime` | Thời điểm đặt đơn |
| `order_date` | `order_date` | Ngày đặt đơn |
| `order_month` | `order_month` | Tháng đặt đơn |
| `order_quarter` | `order_quarter` | Quý đặt đơn |
| `order_year` | `order_year` | Năm đặt đơn |
| `customer_segment` | Representative value | Phân khúc khách hàng |
| `market` | Representative value | Thị trường |
| `order_region` | Representative value | Khu vực |
| `order_country` | Representative value | Quốc gia giao hàng |
| `shipping_mode` | Representative value | Phương thức vận chuyển |
| `order_status` | Representative value | Trạng thái đơn |
| `delivery_status` | Representative value | Trạng thái giao hàng |
| `late_delivery_risk` | Representative value | Rủi ro giao trễ |
| `actual_shipping_days` | Representative value | Số ngày shipping thực tế được ghi nhận |
| `scheduled_shipping_days` | Representative value | Số ngày shipping dự kiến được ghi nhận |
| `order_line_count` | `COUNT(*)` | Số order item trong đơn |
| `distinct_product_count` | `COUNT(DISTINCT product_card_id)` | Số sản phẩm khác nhau |
| `total_quantity` | `SUM(quantity)` | Tổng số sản phẩm trong đơn |
| `gross_sales` | `SUM(gross_sales)` | Doanh thu gộp của đơn |
| `discount_amount` | `SUM(discount_amount)` | Tổng discount của đơn |
| `net_sales` | `SUM(net_sales)` | Doanh thu thuần của đơn |
| `order_profit` | `SUM(line_profit)` | Tổng lợi nhuận của đơn |
| `order_profit_margin` | `SUM(line_profit) / NULLIF(SUM(net_sales), 0)` | Tỷ suất lợi nhuận của đơn |

Các trường như `customer_id`, `market`, `shipping_mode`, `order_status` và delivery attributes chỉ được lấy bằng giá trị đại diện sau khi đã kiểm tra tính nhất quán trong cùng `order_id`.

### H.3. Scope B non-canceled views

Hai view Scope B kế thừa toàn bộ fields từ hai view Scope A và chỉ áp dụng analytical filter:

```sql
order_status IS DISTINCT FROM 'CANCELED'
AND order_status IS DISTINCT FROM 'SUSPECTED_FRAUD'
```

Sử dụng `IS DISTINCT FROM` giúp không âm thầm loại các dòng có `order_status IS NULL`. Dữ liệu nguồn và Scope A views không bị xóa hoặc sửa để tạo Scope B.

| Scope B view | Inherited from | Default use |
|---|---|---|
| `vw_order_item_analysis_non_canceled` | `vw_order_item_analysis` | Product, category, time, sales, discount và profit analysis |
| `vw_order_analysis_non_canceled` | `vw_order_analysis` | Order, customer, market, Average Order Value và delivery analysis |

## I. KPI source mapping

Các KPI chính của project sử dụng các view sau:

| KPI | Default Scope | Source View | Grain | Formula |
|---|---|---|---|---|
| Recorded Orders | Scope A | `vw_order_analysis` | Order | `COUNT(*)` |
| Recorded Net Sales | Scope A | `vw_order_item_analysis` | Order item | `SUM(net_sales)` |
| Recorded Total Profit | Scope A | `vw_order_item_analysis` | Order item | `SUM(line_profit)` |
| Cancellation Rate | Scope A | `vw_order_analysis` | Order | `1.0 × COUNT(*) FILTER (WHERE order_status IN ('CANCELED', 'SUSPECTED_FRAUD')) / NULLIF(COUNT(*), 0)` |
| Core Orders | Scope B | `vw_order_analysis_non_canceled` | Order | `COUNT(*)` |
| Core Net Sales | Scope B | `vw_order_item_analysis_non_canceled` | Order item | `SUM(net_sales)` |
| Core Total Profit | Scope B | `vw_order_item_analysis_non_canceled` | Order item | `SUM(line_profit)` |
| Profit Margin | Scope B; Scope A for sensitivity | Scope-appropriate item view | Analysis group | `SUM(line_profit) / NULLIF(SUM(net_sales), 0)` |
| Average Order Value | Scope B | `vw_order_analysis_non_canceled` | Order | `SUM(net_sales) / NULLIF(COUNT(*), 0)` |
| Units Sold | Scope B | `vw_order_item_analysis_non_canceled` | Order item | `SUM(quantity)` |
| Total Discount | Scope B | `vw_order_item_analysis_non_canceled` | Order item | `SUM(discount_amount)` |
| Discount Rate | Scope B | `vw_order_item_analysis_non_canceled` | Analysis group | `SUM(discount_amount) / NULLIF(SUM(gross_sales), 0)` |
| Late Delivery Rate | Scope B | `vw_order_analysis_non_canceled` | Order | `1.0 × late_orders / NULLIF(delivery_eligible_orders, 0)` |
| Repeat Customer Rate | Scope B | Customer summary from `vw_order_analysis_non_canceled` | Customer | `repeat_customers / NULLIF(total_customers, 0)` |

## J. Field usage rules

- Hai view Scope A được sử dụng cho source reconciliation, status analysis, cancellation analysis và sensitivity.
- Hai view Scope B được sử dụng cho primary business-performance, product, customer, market và delivery analysis.
- Không tính Total Orders bằng `COUNT(*)` trên order-item view.
- Không tính AOV bằng `AVG(net_sales)` trên order-item view.
- Không tính Total Discount bằng `SUM(gross_sales × order_item_discount_rate)`.
- Không tính tổng Profit Margin bằng `AVG(line_profit_margin)`.
- Không cộng trực tiếp các order-level measures sau khi join hai view nếu việc join làm nhân bản order items.
- Không xếp canceled/fraud orders vào nhóm `Not Late` chỉ vì `late_delivery_risk = 0`.
- Mọi bảng kết quả phải ghi rõ Scope A hoặc Scope B.
- `order_item_discount_rate` được xem là field tham khảo vì đã được làm tròn.
- `sales_per_customer` không được sử dụng làm Customer Lifetime Value hoặc tổng doanh thu của khách hàng.
- `benefit_per_order` không cần sử dụng trong analysis layer vì đã được xác minh trùng với `order_profit_per_order`.
