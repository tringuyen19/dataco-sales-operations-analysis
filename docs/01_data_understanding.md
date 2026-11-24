# Hiểu dữ liệu và xác định đơn vị phân tích

## 1. Project đang phân tích điều gì?

Dữ liệu DataCo chứa giao dịch bán hàng, khách hàng, sản phẩm và thông tin vận chuyển. Project dùng dữ liệu này để hỗ trợ một quản lý Kinh doanh và Vận hành giả định khoanh vùng vấn đề cần điều tra. Chưa có doanh nghiệp giao chỉ tiêu, ngân sách hay mục tiêu chính thức.

Nguồn dữ liệu và cách nạp được mô tả trong [hướng dẫn dữ liệu](../data/README.md). Kết quả kiểm chứng của lần rà soát này nằm tại [biên bản kiểm chứng](11_project_review_validation.md).

## 2. Quy mô dữ liệu nguồn

| Chỉ số | Phạm vi A: toàn bộ nguồn |
|---|---:|
| Dòng dữ liệu | 180,519 |
| Đơn hàng khác nhau | 65,752 |
| Khách hàng khác nhau | 20,652 |
| Sản phẩm khác nhau | 118 |
| Số lượng sản phẩm bán ra | 384,079 |
| Khoảng ngày đặt hàng | 01/01/2015–31/01/2018 |
| Số tháng có giao dịch | 37 |

**Quy ước số:** tài liệu dùng dấu phẩy phân tách hàng nghìn và dấu chấm cho phần thập phân để dễ đối chiếu SQL. Ví dụ 1,234.56 là một nghìn hai trăm ba mươi bốn phẩy năm sáu. Đơn vị tiền tệ chưa được xác minh.

## 3. Một dòng dữ liệu đại diện cho cái gì?

Một dòng là **một dòng sản phẩm trong đơn hàng**. Khóa của dòng là `order_item_id`. Một `order_id` có thể có nhiều dòng; mỗi dòng có thể chứa nhiều đơn vị sản phẩm.

Ví dụ minh họa: đơn A có hai dòng, dòng thứ nhất mua 3 áo, dòng thứ hai mua 2 bóng. Khi đó có **1 đơn, 2 dòng sản phẩm, 5 đơn vị bán ra**.

| Số dòng trong một đơn | Số đơn |
|---|---:|
| 1 | 19,850 |
| 2 | 11,447 |
| 3 | 11,398 |
| 4 | 11,704 |
| 5 | 11,353 |
| Tổng | 65,752 |

Không xem `order_id` lặp là lỗi trùng dữ liệu. Có 180,519 mã dòng sản phẩm duy nhất và không thiếu mã này.

| Cần đo | Phép tính trên bảng dòng sản phẩm |
|---|---|
| Số đơn | `COUNT(DISTINCT order_id)` |
| Số dòng sản phẩm | `COUNT(*)` |
| Số đơn vị bán ra | `SUM(order_item_quantity)` |
| Số khách | `COUNT(DISTINCT customer_id)` |

## 4. Quan hệ và tính nhất quán

Một khách có thể có nhiều đơn; một đơn có nhiều dòng sản phẩm. Kiểm chứng dữ liệu hiện có không phát hiện đơn nào có nhiều giá trị khác nhau về khách, ngày đặt, trạng thái, phân khúc, thị trường, khu vực, quốc gia, phương thức vận chuyển, trạng thái giao hàng, cờ trễ hay số ngày thực tế/dự kiến.

Sau khi kiểm tra này đạt, có thể lấy một giá trị đại diện cho các thuộc tính cấp đơn bằng `MIN()` khi tổng hợp. `MIN()` không tự giải quyết mâu thuẫn nếu dữ liệu tương lai phát sinh lỗi.

## 5. Hai phạm vi báo cáo

| Phạm vi | Định nghĩa | Số đơn | Mục đích |
|---|---|---:|---|
| A | Giữ tất cả trạng thái | 65,752 | Hiểu nguồn, đối soát, phân tích trạng thái và độ nhạy |
| B | Loại `CANCELED`, `SUSPECTED_FRAUD` | 62,897 | Báo cáo kinh doanh và giao hàng chính |

Có 2,855 đơn bị loại, tương đương 4.34% số đơn A. Tất cả thuộc trạng thái giao hàng `Shipping canceled` và có cờ trễ bằng 0. Đưa chúng vào mẫu số giao hàng sẽ kéo tỷ lệ trễ xuống dù số đơn trễ không thay đổi.

B vẫn chứa `PENDING`, `PENDING_PAYMENT`, `PROCESSING`, `ON_HOLD` và `PAYMENT_REVIEW`. Vì vậy, gọi B là **phạm vi đã loại đơn hủy/nghi gian lận**, không gọi là “đơn đã hoàn tất”. Giá trị tài chính là số ghi trong nguồn, chưa được xác nhận là doanh thu kế toán đã ghi nhận.

## 6. Hai cấp phân tích

| Lớp | Một dòng đại diện cho | Dùng để trả lời |
|---|---|---|
| `vw_order_item_analysis_non_canceled` | Một dòng sản phẩm | Sản phẩm, danh mục, số lượng, giảm giá, lợi nhuận dòng |
| `vw_order_analysis_non_canceled` | Một đơn | Số đơn, AOV, khách, địa lý, giao hàng |

Hai view không có hậu tố `_non_canceled` là phạm vi A. Phân tích khách mua một lần/mua lặp lại phải tổng hợp lại từ các đơn thuộc đúng phạm vi; việc loại một đơn có thể làm khách đổi nhóm.

## 7. Giới hạn cần hiểu từ đầu

- Trường có tên “per order” hoặc “per customer” không bảo đảm dữ liệu ở cấp đó. Phải kiểm chứng thực tế.
- Ngày cuối là 31/01/2018. Có dữ liệu cả 31 ngày của tháng này nhưng chưa đủ bằng chứng xác nhận mọi giao dịch của doanh nghiệp đều được trích xuất.
- Mô tả nguồn gọi `shipping_date` là thời điểm vận chuyển. Chưa có sự kiện nhận hàng độc lập để kiểm chứng trải nghiệm giao hàng.
- Địa chỉ/tọa độ khách không nên tự coi là điểm đích giao hàng. Phân tích địa lý chính dùng `market`, `order_region`, `order_country`.

Tham khảo: [SQL kiểm tra cấp dữ liệu](../sql/01_profiling_and_grain.sql), [từ điển trường](data_dictionary.md), [cây câu hỏi](05_question_tree.md).
