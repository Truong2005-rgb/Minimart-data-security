/* Encryption - Admin gọi thủ tục giải mã
Kết nối SSMS: SQL Login Portal_Admin trực tiếp, không dùng EXECUTE AS USER.
Chỉ chạy trên MiniMart_DataWarehouse hiện có. Đây là file demo/kiểm tra,
không tạo lại database, cấp quyền hoặc sửa dữ liệu nghiệp vụ.
Có thể phát sinh thêm nhật ký do cơ chế Audit đang bật.
*/
USE MiniMart_DataWarehouse;
GO
SET NOCOUNT ON;
SELECT ORIGINAL_LOGIN() AS SQLLoginGoc, SUSER_SNAME() AS SQLLoginHienTai,
       USER_NAME() AS DatabaseUser;
IF ORIGINAL_LOGIN() <> N'Portal_Admin'
    THROW 51020, N'Mở kết nối SSMS bằng SQL Authentication / Portal_Admin rồi chạy file này.', 1;
IF SUSER_SNAME() <> ORIGINAL_LOGIN() OR USER_NAME() <> N'Portal_Admin'
    THROW 51021, N'Ngữ cảnh đang bị giả lập; mở kết nối Portal_Admin trực tiếp để demo.', 1;
EXEC Security.usp_PortalGetDecryptedCustomers @MaxRows = 5, @SearchPattern = NULL;
GO
