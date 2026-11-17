# Đăng bộ Mini-Mart lên GitHub

## Bộ này dùng để làm gì?

Đây là bản mã nguồn và minh chứng đã sắp xếp để đăng GitHub. Nó gồm web Flask hiện hành, cấu trúc database, dữ liệu mẫu, hai cấu hình Audit, các file demo và tài liệu.

Bản này không chứa `.venv`, backup cũ, hai file khóa đang dùng, dữ liệu bảng MFA, mật khẩu thật hay log truy cập. Các file tạo Login/khóa là mẫu cho môi trường mới; chưa được chạy thử trên một SQL Server mới tại nơi đóng gói.

**Bạn không cần chạy bất kỳ script cài đặt nào để đăng GitHub. Giữ thư mục demo gốc và SQL Server đang dùng như hiện tại.** Nếu chạy bản GitHub với database cũ, khóa Fernet mới sẽ không đọc được seed MFA đã mã hóa bằng khóa gốc; vì vậy chỉ dùng bản này để xem mã nguồn hoặc dựng một môi trường riêng theo tài liệu.

## Tự đăng qua trình duyệt

1. Giải nén ZIP vào một thư mục riêng. Mở thư mục `minimart-data-security` bên trong.
2. Mở https://github.com/new, chọn tài khoản `Truong2005-rgb`.
3. Tên repository: `minimart-data-security`.
4. Description có thể dùng: `SQL Server data warehouse security with Flask, TOTP, RBAC, RLS, column permissions, encryption and auditing.`
5. Chọn Public nếu muốn người tuyển dụng mở xem. Tắt Add README và không tạo sẵn .gitignore/license.
6. Create repository → uploading an existing file.
7. Kéo toàn bộ nội dung bên trong thư mục đã giải nén, gồm `templates`, `static`, `sql`, `tests`, `docs`. Không chỉ kéo các file lẻ bằng hộp chọn file nếu nó bỏ sót thư mục con.
8. Nhập commit message `Add Mini-Mart data warehouse security project` → Commit changes.
9. Kiểm tra README, hai ảnh và các thư mục con mở được.

Không tự đặt repo ở đường dẫn GitHub đã có và không trộn vào repository thời tiết. Nếu tên đã tồn tại, kiểm tra nội dung trước khi đăng thêm.

Link dự kiến sau khi BẠN tạo và đăng xong:
https://github.com/Truong2005-rgb/minimart-data-security

## Những điểm cần biết khi giới thiệu

- Bộ dữ liệu có 10.091 giao dịch, 200 khách hàng, 50 sản phẩm, 3 chi nhánh và 91 ngày.
- 7 dòng ánh xạ hiện hành cho Manager Thanh Hóa xem thêm Nghệ An; đây là cấu hình đang được cấp, không phải lỗi RLS.
- Code đang đặt idle timeout 10 phút, tối đa 8 giờ.
- Schema vẫn có định nghĩa Data Masking và HR cũ; phần báo cáo/CV tập trung sáu cơ chế đã chọn.
- Có bản sửa riêng cho danh sách sự kiện ghi Audit, chưa áp dụng lên máy demo của bạn.
- Không tuyên bố “cài một lần chạy ngay” hay “bảo mật hoàn toàn”: đọc `docs/SETUP.md` và `docs/KNOWN_LIMITATIONS.md`.

Các file CSV/SQL do bạn cung cấp được dùng như dữ liệu giả lập của BTL theo báo cáo. Kiểm tra lại nếu bạn từng thay dữ liệu giả lập bằng dữ liệu thật trước khi công khai.
