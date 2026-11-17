/* Chỉ xem vai trò RBAC_Test_01 trước/sau thao tác trên web
Kết nối SSMS: Windows Authentication có quyền quản trị trên máy demo.
Chỉ chạy trên MiniMart_DataWarehouse hiện có. Đây là file demo/kiểm tra,
không tạo lại database, cấp quyền hoặc sửa dữ liệu nghiệp vụ.
Có thể phát sinh thêm nhật ký do cơ chế Audit đang bật.
*/
USE MiniMart_DataWarehouse;
GO
SET NOCOUNT ON;
-- File này không chuyển vai trò. Nếu demo chuyển vai trò, dùng tài khoản thử trên web,
-- chạy truy vấn này trước/sau rồi khôi phục vai trò ban đầu qua cùng giao diện.
IF DATABASE_PRINCIPAL_ID(N'RBAC_Test_01') IS NULL
    THROW 51002, N'Không thấy database user RBAC_Test_01.', 1;



SELECT
    u.name AS TaiKhoan,
    r.name AS VaiTro
FROM sys.database_role_members rm
JOIN sys.database_principals r
    ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals u
    ON rm.member_principal_id = u.principal_id
WHERE u.name = N'RBAC_Test_01';

GO
