# Data Dictionary — DataCo Supply Chain

Tài liệu gồm 53 trường dữ liệu, được chia thành 7 nhóm nghiệp vụ. Giá trị *Trống* biểu thị ô ví dụ để trống trong file nguồn; `NULL` là giá trị ví dụ được ghi nguyên văn trong file.

## A. Thông tin thanh toán và giao hàng

| Field Name | Data Type | Field Length | Constraint | Description | Example |
|---|---|---:|---|---|---|
| `order_type` | `VARCHAR` | `20` | `NOT NULL` | Phương thức hoặc loại giao dịch thanh toán của đơn hàng. Tên gốc: Type. | `DEBIT` |
| `days_for_shipping_real` | `INTEGER` | `—` | `NOT NULL; CHECK >= 0` | Số ngày giao hàng thực tế, tính từ ngày đặt hàng đến ngày vận chuyển/giao hàng được ghi nhận. | `3` |
| `days_for_shipment_scheduled` | `INTEGER` | `—` | `NOT NULL; CHECK >= 0` | Số ngày giao hàng dự kiến theo phương thức vận chuyển đã chọn. | `4` |
| `delivery_status` | `VARCHAR` | `30` | `NOT NULL` | Trạng thái thực hiện giao hàng, được xác định dựa trên tiến độ thực tế so với kế hoạch. | `Advance shipping` |
| `late_delivery_risk` | `INTEGER` | `—` | `NOT NULL; CHECK IN (0,1)` | Biến nhị phân cho biết đơn hàng có nguy cơ hoặc đã giao trễ hay không: 1 = trễ, 0 = không trễ. | `0` |
| `shipping_date` | `TIMESTAMP` | `—` | `NOT NULL` | Ngày và giờ vận chuyển của đơn hàng. Tên gốc: shipping date (DateOrders). | `2018-02-03 22:56:00` |
| `shipping_mode` | `VARCHAR` | `30` | `NOT NULL` | Phương thức hoặc cấp độ dịch vụ vận chuyển được chọn. | `Standard Class` |

## B. Chỉ số doanh thu, chiết khấu và lợi nhuận

| Field Name | Data Type | Field Length | Constraint | Description | Example |
|---|---|---:|---|---|---|
| `benefit_per_order` | `NUMERIC` | `12.2` | `Nullable` | Lợi nhuận được ghi nhận cho giao dịch/đơn hàng. Trong dataset, giá trị này thường trùng với order_profit_per_order. Có thể âm nếu giao dịch bị lỗ. | `91.25` |
| `sales_per_customer` | `NUMERIC` | `12.2` | `CHECK >= 0` | Giá trị bán hàng sau chiết khấu gắn với khách hàng trên dòng giao dịch. Thường trùng với order_item_total. | `314.64` |
| `order_item_discount` | `NUMERIC` | `12.2` | `CHECK >= 0` | Số tiền chiết khấu của dòng sản phẩm. | `13.11` |
| `order_item_discount_rate` | `NUMERIC` | `6.4` | `CHECK BETWEEN 0 AND 1` | Tỷ lệ giảm giá đã được làm tròn<br>Không dùng để tính chính xác tiền giảm giá; nếu cần tỷ lệ thực tế, tính order_item_discount / sales_amount | `0.0400` |
| `order_item_product_price` | `NUMERIC` | `12.2` | `CHECK >= 0` | Đơn giá niêm yết của sản phẩm tại thời điểm phát sinh giao dịch. | `327.75` |
| `order_item_profit_ratio` | `NUMERIC` | `8.4` | `Nullable` | Tỷ suất lợi nhuận của dòng sản phẩm. Có thể âm khi dòng giao dịch bị lỗ. | `0.2900` |
| `order_item_quantity` | `INTEGER` | `—` | `NOT NULL; CHECK > 0` | Số lượng sản phẩm trong dòng đơn hàng. | `1` |
| `sales_amount` | `NUMERIC` | `12.2` | `CHECK >= 0` | Doanh thu trước chiết khấu của dòng sản phẩm. Thường bằng đơn giá nhân số lượng. Tên gốc: Sales. | `327.75` |
| `order_item_total` | `NUMERIC` | `12.2` | `CHECK >= 0` | Tổng tiền thực thu của dòng sản phẩm sau khi trừ chiết khấu. | `314.64` |
| `order_profit_per_order` | `NUMERIC` | `12.2` | `Nullable` | Lợi nhuận được ghi nhận cho đơn hàng/dòng dữ liệu. Có thể âm. | `91.25` |

## C. Danh mục và phòng ban

| Field Name | Data Type | Field Length | Constraint | Description | Example |
|---|---|---:|---|---|---|
| `category_id` | `INTEGER` | `—` | `NOT NULL; FK candidate` | Mã định danh danh mục sản phẩm gắn với dòng giao dịch. | `73` |
| `category_name` | `VARCHAR` | `50` | `NOT NULL` | Tên danh mục sản phẩm. | `Sporting Goods` |
| `department_id` | `INTEGER` | `—` | `NOT NULL; FK candidate` | Mã định danh phòng ban hoặc nhóm kinh doanh quản lý danh mục. | `2` |
| `department_name` | `VARCHAR` | `50` | `NOT NULL` | Tên phòng ban hoặc nhóm kinh doanh. | `Fitness` |

## D. Thông tin khách hàng

| Field Name | Data Type | Field Length | Constraint | Description | Example |
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
| `latitude` | `NUMERIC` | `10.7` | `Nullable; CHECK -90 TO 90` | Vĩ độ gắn với vị trí địa lý của khách hàng. | `182514534` |
| `longitude` | `NUMERIC` | `10.7` | `Nullable; CHECK -180 TO 180` | Kinh độ gắn với vị trí địa lý của khách hàng. | `-660370560` |

## E. Thông tin thị trường và đơn hàng

| Field Name | Data Type | Field Length | Constraint | Description | Example |
|---|---|---:|---|---|---|
| `market` | `VARCHAR` | `50` | `NOT NULL` | Thị trường kinh doanh cấp cao nơi đơn hàng được ghi nhận. | `Pacific Asia` |
| `order_id` | `INTEGER` | `—` | `NOT NULL; FK/grouping key` | Mã định danh đơn hàng. Không duy nhất ở cấp dòng vì một đơn có thể chứa nhiều sản phẩm. | `77202` |
| `order_customer_id` | `INTEGER` | `—` | `NOT NULL; FK candidate` | Mã khách hàng được lưu tại đơn hàng. Thông thường cần bằng customer_id. | `20755` |
| `order_date` | `TIMESTAMP` | `—` | `NOT NULL` | Ngày và giờ khách hàng đặt đơn hàng. Tên gốc: order date (DateOrders). | `2018-01-31 22:56:00` |
| `order_status` | `VARCHAR` | `30` | `NOT NULL` | Trạng thái xử lý hoặc thanh toán của đơn hàng. | `COMPLETE` |
| `order_city` | `VARCHAR` | `100` | `Nullable` | Thành phố đích của đơn hàng hoặc thành phố giao hàng. | `Bekasi` |
| `order_country` | `VARCHAR` | `100` | `Nullable` | Quốc gia đích của đơn hàng hoặc quốc gia giao hàng. | `Indonesia` |
| `order_region` | `VARCHAR` | `50` | `Nullable` | Khu vực địa lý cấp vùng của đơn hàng. | `Southeast Asia` |
| `order_state` | `VARCHAR` | `100` | `Nullable` | Bang, tỉnh hoặc khu vực hành chính tại địa chỉ giao hàng. | `Java Occidental` |
| `order_zipcode` | `VARCHAR` | `20` | `Nullable` | Mã bưu chính của địa chỉ đơn hàng. Cột này có nhiều giá trị thiếu trong dữ liệu mẫu. |  |

## F. Dòng sản phẩm trong đơn hàng

| Field Name | Data Type | Field Length | Constraint | Description | Example |
|---|---|---:|---|---|---|
| `order_item_id` | `INTEGER` | `—` | `PK candidate; NOT NULL; UNIQUE` | Mã định danh duy nhất của từng dòng sản phẩm trong đơn hàng. Đây là ứng viên khóa chính | `180517` |
| `order_item_cardprod_id` | `INTEGER` | `—` | `NOT NULL; FK candidate` | Mã sản phẩm được lưu trên dòng đơn hàng. Thường tương ứng với product_card_id. | `1360` |

## G. Thông tin sản phẩm

| Field Name | Data Type | Field Length | Constraint | Description | Example |
|---|---|---:|---|---|---|
| `product_card_id` | `INTEGER` | `—` | `NOT NULL; FK candidate` | Mã định danh sản phẩm. Có thể lặp lại trên nhiều dòng giao dịch. | `1360` |
| `product_category_id` | `INTEGER` | `—` | `NOT NULL; FK candidate` | Mã danh mục được lưu trong thông tin sản phẩm. Thông thường cần bằng category_id. | `73` |
| `product_name` | `VARCHAR` | `255` | `NOT NULL` | Tên sản phẩm. Cần dùng TRIM() vì dữ liệu có thể chứa khoảng trắng cuối chuỗi. | `Smart watch` |
| `product_description` | `TEXT` | `—` | `Nullable` | Nội dung mô tả chi tiết sản phẩm. Phần lớn bản dữ liệu có thể để trống. |  |
| `product_image` | `TEXT` | `—` | `Nullable` | URL hình ảnh sản phẩm. Có thể chứa khoảng trắng hoặc URL không còn hoạt động. | `http://images.acmesports.sports/Smart+watch` |
| `product_price` | `NUMERIC` | `12.2` | `CHECK >= 0` | Giá niêm yết hoặc giá chuẩn trong danh mục sản phẩm. | `327.75` |
| `product_status` | `INTEGER` | `—` | `NOT NULL ; categorical` | Trạng thái sản phẩm được mã hóa bằng số. Dataset mẫu chủ yếu sử dụng 0; cần kiểm tra tập giá trị trước khi diễn giải. |  |
