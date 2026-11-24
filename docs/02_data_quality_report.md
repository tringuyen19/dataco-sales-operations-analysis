# Báo cáo chất lượng dữ liệu

## 1. Phạm vi và cách kiểm tra

Kiểm tra toàn bộ phạm vi A: 180,519 dòng sản phẩm, 65,752 đơn. Không loại trạng thái trước khi hiểu dữ liệu nguồn. Kết quả dưới đây đã được đối chiếu bằng [chương trình Python](../scripts/verify_analysis.py) và các truy vấn PostgreSQL được liệt kê trong [biên bản kiểm chứng](11_project_review_validation.md).

“Đạt kiểm tra” chỉ nói về quy tắc cụ thể được kiểm tra, không có nghĩa dữ liệu phản ánh đầy đủ hoạt động doanh nghiệp.

## 2. Kết quả chính

| Kiểm tra | Kết quả | Quyết định |
|---|---:|---|
| Thiếu `order_item_id` | 0 dòng | Dùng làm khóa cấp dòng |
| Trùng `order_item_id` | 0 dòng | Không cần loại trùng |
| Thiếu các trường trọng yếu được kiểm tra trong SQL 02 | 0 dòng | Có thể tính chỉ số chính |
| Ngày vận chuyển trước ngày đặt | 0 dòng | Giữ lại |
| Số lượng ≤ 0 | 0 dòng | Giữ lại |
| Tỷ lệ giảm giá ngoài [0,1] | 0 dòng | Giữ lại |
| Cờ giao trễ ngoài {0,1} | 0 dòng | Dùng {0,1} làm tập đủ điều kiện |
| Sai cặp mã khách, mã sản phẩm hoặc mã danh mục tương ứng | 0 dòng mỗi cặp | Các cặp mã khớp trong nguồn hiện có |
| Thuộc tính cấp đơn không nhất quán | 0 đơn | Cho phép tổng hợp bảng đơn |
| Biến thể nhãn do viết hoa/khoảng trắng tạo trùng sau chuẩn hóa | 0 nhóm trong các trường đã rà soát | Không gộp nhãn nghiệp vụ tùy ý |
| Nhãn danh mục/sản phẩm có khoảng trắng ngoài | 4 giá trị khác nhau mỗi trường | Dùng `BTRIM()` ở view |
| Đơn hủy/nghi gian lận | 2,855 đơn | Giữ ở A, loại khỏi B |

Những trường trọng yếu gồm khóa, ngày đặt/vận chuyển, trạng thái, phân khúc, thị trường, khu vực, phương thức, cờ trễ, số lượng, đơn giá, doanh thu thuần và lợi nhuận. Tài chính được kiểm chứng riêng tại [tài liệu 03](03_financial_field_validation.md).

## 3. Dữ liệu thiếu có thật nhưng không nằm ở chỉ số chính

| Trường | Dòng thiếu | Cách xử lý trong project |
|---|---:|---|
| `product_description` | 180,519 | Không dùng để phân tích sản phẩm |
| `order_zipcode` | 155,679 | Không phân tích theo mã bưu chính giao hàng |
| `customer_last_name` | 8 | Không cần cho tổng hợp theo mã khách |
| `customer_zipcode` | 3 | Không dùng để suy ra vị trí giao hàng |

Không viết “dữ liệu không có giá trị thiếu” cho toàn bộ bảng. Kết luận đúng là **không thiếu các trường trọng yếu đã kiểm tra**, trong khi một số trường phụ bị thiếu nhiều.

## 4. Ngoại lệ trạng thái giao hàng

Có 1,650 đơn hủy/nghi gian lận ghi số ngày thực tế lớn hơn dự kiến nhưng cờ trễ vẫn bằng 0. Tất cả thuộc `Shipping canceled`.

Đây là khác biệt về cách áp dụng nhãn cho đơn bị hủy. Các giá trị thời gian không chứng minh đơn đã được giao cho khách. Không sửa cờ 0 thành 1 và không đưa nhóm này vào nhóm “không trễ” của báo cáo B.

Tỷ lệ trễ thay đổi từ 54.82% ở A thành 57.31% ở B do mẫu số giảm từ 65,752 xuống 62,897; số đơn trễ vẫn là 36,048. Đây là **thay đổi định nghĩa tập báo cáo**, không phải vận hành xấu đi theo thời gian.

## 5. Các vấn đề ảnh hưởng cách đọc kết quả

| Vấn đề | Hệ quả | Cách xử lý |
|---|---|---|
| Tên cột tài chính dễ gây hiểu nhầm | Có thể cộng sai doanh thu/lợi nhuận | Kiểm chứng công thức và cấp dữ liệu |
| Số thập phân trong CSV có phần dư | Kết quả cộng trực tiếp khác staging | Công bố quy tắc làm tròn từng dòng về 2 chữ số |
| Cấu trúc giỏ hàng thay đổi cuối 2017 | Doanh thu giảm chưa đủ để kết luận mất khách | Xem số đơn, số lượng và AOV theo tháng |
| Thiếu sự kiện giao/nhận thực tế | Chưa kiểm chứng được nguyên nhân giao trễ | Bổ sung dữ liệu đơn vị vận chuyển và sự kiện |
| Không có mục tiêu chính thức | Không thể chấm đạt/không đạt KPI | Dùng mốc quan sát và so sánh tương đối |

## 6. Quy tắc làm sạch đã áp dụng

Giữ nguyên CSV và phạm vi A. View phân tích bỏ khoảng trắng đầu/cuối, chuyển chuỗi rỗng thành `NULL`, tạo cột thời gian và đổi tên trường. Phạm vi B được tạo bằng view có điều kiện lọc, không xóa giao dịch khỏi nguồn.

SQL: [kiểm tra chất lượng](../sql/02_data_quality_checks.sql), [kiểm tra trước biến đổi](../sql/04_cleaning_transformation.sql), [tạo view](../sql/05_create_analysis_views.sql).
