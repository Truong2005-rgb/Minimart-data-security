/* Encryption - Quan sát và đếm các cột bản mã
Kết nối SSMS: Windows Authentication có quyền quản trị trên máy demo.
Chỉ chạy trên MiniMart_DataWarehouse hiện có. Đây là file demo/kiểm tra,
không tạo lại database, cấp quyền hoặc sửa dữ liệu nghiệp vụ.
Có thể phát sinh thêm nhật ký do cơ chế Audit đang bật.
*/
USE MiniMart_DataWarehouse;
GO
SET NOCOUNT ON;
IF OBJECT_ID(N'dbo.Dim_Customer') IS NULL
    THROW 51001, N'Không thấy dbo.Dim_Customer; kiểm tra database và quyền xem metadata.', 1;
-- COUNT bản mã khác NULL không tự chứng minh giải mã được hoặc đã xóa bản rõ.
-- Đối chiếu file 09 để kiểm tra đường giải mã của Admin.



SELECT TOP (5)
    CustomerID,
    Phone_Encrypted,
    Email_Encrypted
FROM dbo.Dim_Customer
ORDER BY CustomerKey;

SELECT
    COUNT(*) AS TongKhachHang,
    COUNT(Phone_Encrypted) AS PhoneDaMaHoa,
    COUNT(Email_Encrypted) AS EmailDaMaHoa
FROM dbo.Dim_Customer;
GO
