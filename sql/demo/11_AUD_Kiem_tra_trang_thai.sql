/* Audit - Xem đúng cấu hình MiniMart trong báo cáo
Kết nối SSMS: Windows Authentication có quyền quản trị trên máy demo.
Chỉ chạy trên MiniMart_DataWarehouse hiện có. Đây là file demo/kiểm tra,
không tạo lại database, cấp quyền hoặc sửa dữ liệu nghiệp vụ.
Có thể phát sinh thêm nhật ký do cơ chế Audit đang bật.
*/
USE MiniMart_DataWarehouse;
GO
SET NOCOUNT ON;
SELECT name AS TenAudit, is_state_enabled AS DangBat, type_desc AS KieuLuu
FROM sys.server_audits WHERE name = N'MiniMart_Audit';
SELECT name AS TenAuditSpecification, is_state_enabled AS DangBat
FROM sys.database_audit_specifications WHERE name = N'MiniMart_DB_AuditSpec';
-- Nếu bảng kết quả trống: kiểm tra quyền xem metadata hoặc tên cấu hình thực tế.
-- Không tự tạo/bật lại Audit chỉ vì truy vấn này không thấy cấu hình.
GO
