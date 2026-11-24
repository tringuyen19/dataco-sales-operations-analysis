# Từ điển chỉ số

## 1. Phạm vi, đơn vị và cách đọc

Mặc định dùng **B**: loại `CANCELED` và `SUSPECTED_FRAUD`. **A** giữ toàn bộ trạng thái để đối soát. B chưa phải tập đơn đã hoàn tất. Thời gian quan sát: 01/01/2015–31/01/2018.

Các nhãn tiếng Anh trong ngoặc tương ứng với nhãn trên Power BI. Tiền dùng đơn vị nguồn chưa xác minh; không gắn ký hiệu tiền tệ. Số tham chiếu áp dụng toàn kỳ, không thêm bộ lọc, sau làm tròn tiền từng dòng về 2 chữ số.

## 2. Chỉ số kinh doanh chính

| Chỉ số | Ý nghĩa và công thức | Nguồn B | Mốc toàn kỳ |
|---|---|---|---:|
| Số đơn (Total Orders) | `COUNT(*)` trên bảng một dòng/đơn | Bảng đơn | 62,897 |
| Số khách (Total Customers) | `COUNT(DISTINCT customer_id)` | Bảng đơn | 20,261 |
| Số dòng sản phẩm | `COUNT(*)` trên bảng một dòng/sản phẩm trong đơn | Bảng dòng | 172,765 |
| Số lượng bán (Units Sold) | `SUM(quantity)` | Bảng dòng | 367,591 |
| Doanh thu trước giảm giá (Gross Sales) | `SUM(gross_sales)` | Bảng dòng | 35,214,428.98 |
| Tiền giảm giá (Total Discount) | `SUM(discount_amount)` | Bảng dòng | 3,569,808.32 |
| Doanh thu thuần (Net Sales) | `SUM(net_sales)` | Bảng đơn hoặc bảng dòng | 31,644,664.75 |
| Lợi nhuận (Total Profit) | `SUM(order_profit)` hoặc `SUM(line_profit)` theo cấp dữ liệu | Bảng đơn hoặc bảng dòng | 3,806,420.63 |
| Biên lợi nhuận (Profit Margin) | Tổng lợi nhuận / tổng doanh thu thuần | Cùng phạm vi và bộ lọc | 12.03% |
| Giá trị trung bình mỗi đơn (AOV) | Tổng doanh thu thuần / số đơn | Bảng đơn | 503.12 |
| Tỷ lệ giảm giá (Discount Rate) | Tổng tiền giảm giá / tổng doanh thu trước giảm giá | Bảng dòng | 10.14% |

“Bảng đơn” là `vw_order_analysis_non_canceled`; “bảng dòng” là `vw_order_item_analysis_non_canceled`. Khi tính số đơn trên bảng dòng, dùng `COUNT(DISTINCT order_id)`.

Đơn hàng có thể chứa nhiều danh mục. Do đó **không cộng số đơn từng danh mục để suy ra tổng số đơn**. Doanh thu và lợi nhuận theo các danh mục không chồng lặp có thể cộng về tổng.

## 3. Chỉ số giao hàng

| Chỉ số | Công thức trên bảng đơn B | Mốc toàn kỳ |
|---|---|---:|
| Đơn trễ (Late Orders) | Số đơn có `late_delivery_risk = 1` | 36,048 |
| Đơn đủ điều kiện đánh giá (Evaluable Orders) | Số đơn có `late_delivery_risk IN (0,1)` | 62,897 |
| Tỷ lệ trễ (Late Delivery Rate) | Đơn trễ / đơn đủ điều kiện | 57.31% |
| Số ngày thực tế trung bình | `AVG(actual_shipping_days)` | 3.50 |
| Số ngày dự kiến trung bình | `AVG(scheduled_shipping_days)` | 2.94 |
| Chênh lệch ngày trung bình | `AVG(actual_shipping_days - scheduled_shipping_days)` | 0.57 |

Phân biệt ba mẫu số: tỷ lệ trễ **trong phương thức** chia cho số đơn của phương thức; tỷ trọng phương thức **trong nhóm trễ** chia cho toàn bộ đơn trễ; tỷ trọng khách mua lặp lại chia cho số khách. Chúng trả lời các câu hỏi khác nhau.

Chênh lệch ngày trung bình có thể âm vì giao sớm bù trừ giao trễ. Không dùng chỉ số này một mình để đánh giá dịch vụ. Chỉ dùng các dòng có đủ hai trường ngày khi tính chênh lệch. Các giá trị hiển thị được làm tròn riêng nên 3.50 − 2.94 có thể khác 0.57.

## 4. Chỉ số khách hàng và mức tập trung

Khách mua lặp lại là khách có từ hai đơn B trở lên **trong khoảng quan sát đang xét**. Phải tổng hợp một dòng/khách trước khi đếm.

| Chỉ số | Công thức | Mốc toàn kỳ |
|---|---|---:|
| Khách mua lặp lại (Repeat Customers) | Số khách có ít nhất 2 đơn | 11,644 |
| Tỷ lệ khách mua lặp lại | Khách mua lặp lại / toàn bộ khách | 57.47% |
| Tỷ trọng doanh thu nhóm mua lặp lại | Doanh thu nhóm này / tổng doanh thu | 92.21% |
| Doanh thu/khách mua lặp lại | Doanh thu nhóm / số khách trong nhóm | 2,505.85 |
| Doanh thu/khách mua một lần | Doanh thu nhóm / số khách trong nhóm | 286.25 |
| Tỷ trọng 10 khách lớn nhất | Doanh thu 10 khách đứng đầu / tổng doanh thu | 0.26% |
| Tỷ trọng 10% khách lớn nhất | Doanh thu 2,027 khách đứng đầu / tổng doanh thu | 29.08% |
| Tỷ trọng 10 sản phẩm lớn nhất | Doanh thu 10 sản phẩm đứng đầu / tổng doanh thu | 89.99% |

Số khách thuộc 10% đầu được làm tròn lên: `CEIL(0.10 × 20,261) = 2,027`. Xếp hạng khách theo doanh thu giảm dần, mã khách tăng dần để xử lý trường hợp bằng nhau.

**Quy ước bộ lọc đề xuất:** khi chọn một khoảng thời gian/thị trường/phân khúc, tính lại số đơn của mỗi khách trong tập đang chọn rồi xác định nhóm mua lặp lại. Nếu cần phân loại khách theo toàn bộ lịch sử nhưng chỉ hiển thị doanh thu kỳ đang chọn, phải đặt tên chỉ số khác. Chưa xác minh được hành vi này bằng thao tác trực tiếp trong PBIX.

## 5. Chỉ số đối soát A

| Chỉ số | Mốc A |
|---|---:|
| Số đơn | 65,752 |
| Doanh thu thuần | 33,054,402.04 |
| Lợi nhuận | 3,966,902.97 |
| Biên lợi nhuận | 12.00% |
| Tỷ lệ đơn bị loại khỏi B | 2,855 / 65,752 = 4.34% |

“Tỷ lệ đơn bị loại” gồm cả nghi gian lận, nên không tự đặt tên là tỷ lệ hủy thuần túy nếu chưa giải thích định nghĩa.

## 6. Quy tắc tránh sai số

- Chia bằng `NULLIF(mẫu_số, 0)`; trả về trống khi không có cơ sở tính tỷ lệ.
- Tính tỷ lệ từ tổng tử số và tổng mẫu số. Không lấy `AVG()` biên lợi nhuận hoặc tỷ lệ giảm giá dòng.
- Dùng số tiền giảm giá thực tế; tỷ lệ giảm giá nguồn đã làm tròn.
- Không cộng chỉ số cấp đơn sau khi nối vào nhiều dòng sản phẩm.
- Không gán `Shipping canceled` thành “không trễ”.
- Tên “mua lặp lại” không đồng nghĩa với giữ chân, trung thành hay giá trị vòng đời khách hàng.

Project chưa có chỉ tiêu doanh nghiệp chính thức. Trung vị và tỷ lệ tổng thể là mốc so sánh nội bộ, không phải chuẩn đạt/không đạt.

Nguồn: [SQL tạo view](../sql/05_create_analysis_views.sql), [SQL 06](../sql/06_business_analysis_sales_product.sql), [SQL 07](../sql/07_business_analysis_customer_market_delivery.sql).
