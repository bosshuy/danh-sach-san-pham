# Báo cáo Phân tích Lỗ hổng Dữ liệu (Gap Analysis) - Hệ thống HealthSync

Bản thiết kế cơ sở dữ liệu cũ (Legacy Schema) tồn tại 4 lỗ hổng nghiêm trọng khiến hệ thống không thể đáp ứng UML Activity Diagram:

1. **Sai lầm về Quản lý Trạng thái (Lifecycle Status):** Cột `is_active` dạng BOOLEAN chỉ hỗ trợ 2 trạng thái (Đúng/Sai). Điều này làm mất toàn bộ 5 trạng thái chuyển đổi của quy trình: `PENDING` -> `CONFIRMED` -> `CHECKED_IN` -> `COMPLETED` / `CANCELLED`.
2. **Thiếu Dữ liệu Quản lý Tài chính:** Không có các cột `deposit_amount` (Tiền cọc) và `penalty_fee` (Phí phạt). Hệ thống không thể ghi nhận khoản cọc ban đầu cũng như không thể tính toán số tiền phạt trừ vào tiền cọc khi bệnh nhân hủy lịch sau khi đã `CONFIRMED`.
3. **Thiếu Thông tin Vận hành & Đối soát:** Không có cột `cancel_reason` để lưu trữ lý do hủy lịch, gây ảnh hưởng đến việc chăm sóc khách hàng và đối soát tài chính.
4. **Vắng mặt Bảng Đơn thuốc (`Prescriptions`):** Bác sĩ không thể kê đơn khi lịch hẹn chuyển sang trạng thái `COMPLETED` do cơ sở dữ liệu hoàn toàn thiếu bảng lưu trữ thông tin đơn thuốc và liên kết khóa ngoại tới lịch hẹn.
