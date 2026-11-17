/* Authentication - Kiểm tra cấu trúc MFA, không xuất TOTP secret
Kết nối SSMS: Windows Authentication có quyền quản trị trên máy demo.
Chỉ chạy trên MiniMart_DataWarehouse hiện có. Đây là file demo/kiểm tra,
không tạo lại database, cấp quyền hoặc sửa dữ liệu nghiệp vụ.
Có thể phát sinh thêm nhật ký do cơ chế Audit đang bật.
*/
USE MiniMart_DataWarehouse;
GO
SET NOCOUNT ON;
SELECT s.name AS SchemaName, t.name AS TableName, c.name AS ColumnName,
       TYPE_NAME(c.user_type_id) AS DataType
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
JOIN sys.columns c ON c.object_id = t.object_id
WHERE s.name = N'Security' AND t.name IN (N'UserMFA', N'LoginAttempt', N'AuthLog')
ORDER BY t.name, c.column_id;
-- Không SELECT dữ liệu TotpSecretEnc, không xuất QR/secret đăng ký.
-- Kiểm tra SQL Login + TOTP + khóa tạm + hết phiên thực hiện trên web.
-- Code config.py hiện tại: idle 600 giây (10 phút), absolute 28800 giây (8 giờ).
GO
