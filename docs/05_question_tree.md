# Cây câu hỏi phân tích

## 1. Quyết định cần hỗ trợ

Người dùng giả định là **quản lý Kinh doanh và Vận hành**. Câu hỏi trung tâm:

> Với nguồn lực có hạn, nên điều tra và theo dõi sản phẩm, nhóm khách hàng hay khâu giao hàng nào trước?

Đây là bối cảnh giả định của bài tập danh mục dự án cá nhân. Kết quả cuối là danh sách ưu tiên có căn cứ; project chưa đo tác động của giải pháp kinh doanh.

## 2. Từ câu hỏi lớn đến phép phân tích

| Nhánh | Câu hỏi cần trả lời | Chỉ số và phép so sánh | Dữ liệu | Quyết định có thể hỗ trợ |
|---|---|---|---|---|
| Quy mô | Doanh thu thay đổi do số đơn hay giá trị mỗi đơn? | Doanh thu = số đơn × AOV; so sánh tháng | Bảng đơn | Chọn kiểm tra lượng đơn, giá trị giỏ hàng hay cơ cấu sản phẩm |
| Sản phẩm | Nhóm nào đóng góp nhiều doanh thu và lợi nhuận? | Tỷ trọng doanh thu, lợi nhuận, biên | Bảng dòng | Ưu tiên theo dõi nhóm đóng góp lớn |
| Ngoại lệ | Sản phẩm nào bị lỗ? Khoản lỗ lớn đến đâu? | Lợi nhuận âm, số đơn, tỷ trọng doanh thu, quy mô lỗ | Sản phẩm/tháng | Chọn trường hợp kiểm tra giá và chi phí |
| Khách | Doanh thu đến từ nhiều khách hay vài người? | Tỷ trọng của 10 khách và 10% khách đứng đầu | Tổng hợp khách | Đánh giá mức phụ thuộc vào từng khách |
| Mua lặp lại | Nhóm từ hai đơn đóng góp bao nhiêu? | Tỷ lệ khách, tỷ trọng doanh thu, số đơn/khách | Tổng hợp khách | Đặt câu hỏi cho phân tích theo thời điểm xuất hiện |
| Giao hàng | Nhóm nào có nhiều đơn trễ và tỷ lệ trễ cao? | Số đơn trễ, mẫu số, tỷ lệ, ngày thực tế/dự kiến | Bảng đơn | Chọn tổ hợp khu vực × phương thức để điều tra |
| Chất lượng | Định nghĩa nguồn có làm đổi kết luận? | A so với B, số đơn, tiền và mẫu số giao hàng | Hai phạm vi | Chọn phạm vi báo cáo nhất quán |

AOV là doanh thu thuần trung bình mỗi đơn. Bảng đơn và bảng dòng lần lượt là `vw_order_analysis_non_canceled` và `vw_order_item_analysis_non_canceled`. Phạm vi B loại `CANCELED` và `SUSPECTED_FRAUD`.

## 3. Trình tự đào sâu

Với mỗi nhánh:

1. Chốt đối tượng, thời gian, chỉ số và mẫu số.
2. Tính tổng quan để có mốc so sánh.
3. Chia theo tháng, sản phẩm, khu vực hoặc phương thức.
4. Kiểm tra đồng thời tỷ lệ, số lượng và giá trị liên quan.
5. Tìm cách giải thích khác và dữ liệu còn thiếu.
6. Viết hành động điều tra, người phụ trách đề xuất và chỉ số theo dõi.

Ví dụ: 57.31% đơn trễ tổng thể → First Class 100% trên 9,602 đơn → thực tế 2 ngày so với dự kiến 1 ngày → kiểm tra định nghĩa thời gian và sự kiện vận chuyển. Tỷ lệ cao giúp khoanh vùng, chưa xác định nguyên nhân.

## 4. Những câu hỏi chưa thể kết luận

| Câu hỏi | Điều còn thiếu | Bước tiếp theo |
|---|---|---|
| Giảm giá có gây lỗ? | Cơ cấu sản phẩm, chi phí, mục đích khuyến mãi | Tạo nhóm so sánh và bổ sung chi phí |
| Giao trễ có làm khách rời bỏ? | Thứ tự giao dịch và thời gian theo dõi tương đương | Phân tích lần mua tiếp theo sau trải nghiệm giao hàng |
| Có nên mở rộng danh mục biên cao nhất? | Nhu cầu, tồn kho, năng lực đáp ứng | Kiểm tra khả năng tăng quy mô |
| Có nên chuyển toàn bộ First Class sang Standard Class? | Chi phí, cam kết dịch vụ và kỳ vọng khách | So sánh trong cùng bối cảnh, thử nghiệm có theo dõi |
| Doanh thu giảm cuối kỳ có do mất khách? | Phạm vi trích xuất và cơ cấu sản phẩm | Kiểm tra thay đổi số dòng/đơn và số lượng/đơn |

## 5. Tiêu chuẩn viết kết luận

Mỗi kết luận cần trả lời: **số liệu gì, so với đâu, đáng chú ý vì sao, nên làm gì và còn chưa biết gì**.

Truy vấn hỗ trợ: [doanh thu và sản phẩm](../sql/06_business_analysis_sales_product.sql), [khách hàng và giao hàng](../sql/07_business_analysis_customer_market_delivery.sql), [chẩn đoán bổ sung](../sql/08_deeper_diagnostics.sql). Cách luyện tập: [hướng dẫn phân tích và trình bày](12_analysis_and_presentation_guide.md).
