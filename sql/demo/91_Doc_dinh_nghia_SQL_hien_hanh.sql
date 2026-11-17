/* Đọc định nghĩa SQL hiện hành để đối chiếu, không chạy lại định nghĩa
Kết nối SSMS: Windows Authentication có quyền quản trị trên máy demo.
Chỉ chạy trên MiniMart_DataWarehouse hiện có. Đây là file demo/kiểm tra,
không tạo lại database, cấp quyền hoặc sửa dữ liệu nghiệp vụ.
Có thể phát sinh thêm nhật ký do cơ chế Audit đang bật.
*/
USE MiniMart_DataWarehouse;
GO
SET NOCOUNT ON;
-- Dùng Results to File của SSMS nếu nội dung dài. File kết quả là bản đối chiếu,
-- không phải migration SQL hoàn chỉnh. Có thể bị giới hạn độ dài ô kết quả của SSMS.
-- Ưu tiên Script as CREATE / Generate Scripts theo HUONG_DAN_XUAT_SQL.md để lấy bản đầy đủ.
SELECT s.name AS SchemaName, o.name AS ObjectName, o.type_desc AS ObjectType,
       sm.definition AS DinhNghiaHienHanh,
       CASE WHEN sm.definition IS NULL THEN N'KHÔNG ĐỌC ĐƯỢC: quyền VIEW DEFINITION hoặc module được mã hóa'
            ELSE N'CÓ ĐỊNH NGHĨA' END AS TrangThai
FROM sys.objects o
JOIN sys.schemas s ON s.schema_id=o.schema_id
LEFT JOIN sys.sql_modules sm ON sm.object_id=o.object_id
WHERE o.is_ms_shipped=0 AND o.type IN ('P','V','FN','IF','TF','TR')
ORDER BY s.name,o.type_desc,o.name;

-- Liệt kê các phụ thuộc SQL có khai báo; SQL động có thể không xuất hiện đầy đủ ở đây.
SELECT OBJECT_SCHEMA_NAME(d.referencing_id) AS ReferencingSchema,
       OBJECT_NAME(d.referencing_id) AS ReferencingObject,
       d.referenced_schema_name AS ReferencedSchema,
       d.referenced_entity_name AS ReferencedObject
FROM sys.sql_expression_dependencies d
WHERE OBJECTPROPERTY(d.referencing_id,'IsMSShipped')=0
ORDER BY ReferencingSchema,ReferencingObject,ReferencedObject;
GO
