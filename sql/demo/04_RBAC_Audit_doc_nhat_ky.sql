/* RBAC - Audit_Admin đọc nhật ký ứng dụng
Kết nối SSMS: Windows Authentication có quyền quản trị trên máy demo.
Chỉ chạy trên MiniMart_DataWarehouse hiện có. Đây là file demo/kiểm tra,
không tạo lại database, cấp quyền hoặc sửa dữ liệu nghiệp vụ.
Có thể phát sinh thêm nhật ký do cơ chế Audit đang bật.
*/
USE MiniMart_DataWarehouse;
GO
SET NOCOUNT ON;
IF OBJECT_ID(N'Security.AuditLog') IS NULL
    THROW 51001, N'Không thấy Security.AuditLog; kiểm tra database và quyền xem metadata.', 1;
IF DATABASE_PRINCIPAL_ID(N'Audit_Admin') IS NULL
    THROW 51002, N'Không thấy database user Audit_Admin.', 1;
DECLARE @DaDoiNguCanh bit = 0;
BEGIN TRY
    EXECUTE AS USER = N'Audit_Admin';
    SET @DaDoiNguCanh = 1;
    SELECT USER_NAME() AS TaiKhoanDangThu;
    EXEC sys.sp_executesql N'SELECT TOP (5) * FROM Security.AuditLog ORDER BY AuditID DESC;';
    REVERT;
    SET @DaDoiNguCanh = 0;
END TRY
BEGIN CATCH
    IF @DaDoiNguCanh = 1
    BEGIN
        REVERT;
        SET @DaDoiNguCanh = 0;
    END;
    THROW;
END CATCH;
GO
