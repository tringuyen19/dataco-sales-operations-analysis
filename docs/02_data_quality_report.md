# Data Quality Report

## Summary

| Area | Result | Severity | Decision |
|---|---|---|---|
| Primary keys | [Không thiếu/Không trùng hoặc mô tả lỗi] | High/Low | [Giữ/Xử lý] |
| Revenue fields | [đủ/thiếu x dòng] | High | [Giữ/Loại các dòng thiếu] |
| Product description | [thiếu x dòng] | Low | Không dùng trường này trong phân tích |
| Date fields | [hợp lệ/ghi nhận lỗi] | High | [Chuyển kiểu dữ liệu/Xem xét loại] |
| Duplicate rows | [x dòng] | High | [Giữ/Loại sau khi xác minh] |
| Invalid numeric values | [x dòng] | High | [Xử lý cụ thể] |
| Category labels | [nhất quán/không nhất quán] | Medium | Chuẩn hóa bằng `TRIM` và `LOWER/INITCAP` |

## Validations passed

- Không có `order_item_id` bị thiếu.
- Không có `order_item_id` bị trùng.
- Không có giá trị quantity nhỏ hơn hoặc bằng 0.
- Không phát hiện `discount_rate` nằm ngoài khoảng từ 0 đến 1.