/* Kiểm kê các đối tượng cần xuất từ database đang chạy
Kết nối SSMS: Windows Authentication có quyền quản trị trên máy demo.
Chỉ chạy trên MiniMart_DataWarehouse hiện có. Đây là file demo/kiểm tra,
không tạo lại database, cấp quyền hoặc sửa dữ liệu nghiệp vụ.
Có thể phát sinh thêm nhật ký do cơ chế Audit đang bật.
*/
USE MiniMart_DataWarehouse;
GO
SET NOCOUNT ON;
SELECT @@SERVERNAME AS MaySQLServer, DB_NAME() AS DatabaseName,
       ORIGINAL_LOGIN() AS SQLLogin, USER_NAME() AS DatabaseUser;
SELECT v.DoiTuong, v.LoaiDuKien, o.type_desc AS LoaiThucTe,
       CASE WHEN o.object_id IS NULL THEN N'CHƯA THẤY - kiểm tra quyền metadata/tên thực tế'
            ELSE N'CÓ TRONG DATABASE' END AS TrangThai
FROM (VALUES
(N'dbo.Dim_Date', N'U'),
(N'dbo.Dim_Store', N'U'),
(N'dbo.Dim_Product', N'U'),
(N'dbo.Dim_Customer', N'U'),
(N'dbo.Fact_Sales', N'U'),
(N'Security.UserStoreAccess', N'U'),
(N'Security.AuditLog', N'U'),
(N'Security.AuthLog', N'U'),
(N'Security.UserMFA', N'U'),
(N'Security.LoginAttempt', N'U'),
(N'Security.AccountLog', N'U'),
(N'Security.StoreAccessChangeLog', N'U'),
(N'Security.usp_GetManagerStoreAccess', N'P'),
(N'Security.usp_SetManagerStoreAccess', N'P'),
(N'Security.usp_GetBusinessRoleAssignments', N'P'),
(N'Security.usp_PortalTransferBusinessRole', N'P'),
(N'Security.usp_PortalGetDecryptedCustomers', N'P'),
(N'dbo.usp_MiniMartPortalWriteAudit', N'P'),
(N'Security.fn_FilterSalesByStore', N'IF')
) v(DoiTuong, LoaiDuKien)
LEFT JOIN sys.objects o ON o.object_id = OBJECT_ID(v.DoiTuong)
ORDER BY v.LoaiDuKien, v.DoiTuong;

SELECT r.name AS VaiTro, u.name AS ThanhVien
FROM sys.database_principals r
LEFT JOIN sys.database_role_members m ON m.role_principal_id = r.principal_id
LEFT JOIN sys.database_principals u ON u.principal_id = m.member_principal_id
WHERE r.name IN (N'StoreManagerRole',N'CustomerStaffRole',N'AuditAdminRole',N'PortalAdminRole',N'PortalServiceRole')
ORDER BY r.name,u.name;

SELECT p.name AS PolicyName, p.is_enabled, pr.predicate_type_desc,
       OBJECT_SCHEMA_NAME(pr.target_object_id) AS TargetSchema,
       OBJECT_NAME(pr.target_object_id) AS TargetTable, pr.predicate_definition
FROM sys.security_policies p
JOIN sys.security_predicates pr ON pr.object_id = p.object_id;

SELECT name AS SymmetricKeyName, algorithm_desc
FROM sys.symmetric_keys WHERE name <> N'##MS_DatabaseMasterKey##';
SELECT name AS CertificateName, expiry_date
FROM sys.certificates WHERE name = N'Cert_MiniMart_Encryption';
-- Chỉ tên/cấu hình; không xuất key material, password hash, secret hoặc dữ liệu MFA.
SELECT name AS AuditName,is_state_enabled,type_desc FROM sys.server_audits WHERE name=N'MiniMart_Audit';
SELECT name AS AuditSpec,is_state_enabled FROM sys.database_audit_specifications WHERE name=N'MiniMart_DB_AuditSpec';
GO
