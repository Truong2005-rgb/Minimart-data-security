/* Tổng quan dữ liệu - đối chiếu mục 2.2 báo cáo
Kết nối SSMS: Windows Authentication có quyền quản trị trên máy demo.
Chỉ chạy trên MiniMart_DataWarehouse hiện có. Đây là file demo/kiểm tra,
không tạo lại database, cấp quyền hoặc sửa dữ liệu nghiệp vụ.
Có thể phát sinh thêm nhật ký do cơ chế Audit đang bật.
*/
USE MiniMart_DataWarehouse;
GO
SET NOCOUNT ON;
IF OBJECT_ID(N'dbo.Dim_Store') IS NULL
    THROW 51001, N'Không thấy dbo.Dim_Store; kiểm tra database và quyền xem metadata.', 1;
IF OBJECT_ID(N'dbo.Dim_Customer') IS NULL
    THROW 51001, N'Không thấy dbo.Dim_Customer; kiểm tra database và quyền xem metadata.', 1;
IF OBJECT_ID(N'dbo.Dim_Product') IS NULL
    THROW 51001, N'Không thấy dbo.Dim_Product; kiểm tra database và quyền xem metadata.', 1;
IF OBJECT_ID(N'dbo.Dim_Date') IS NULL
    THROW 51001, N'Không thấy dbo.Dim_Date; kiểm tra database và quyền xem metadata.', 1;
IF OBJECT_ID(N'dbo.Fact_Sales') IS NULL
    THROW 51001, N'Không thấy dbo.Fact_Sales; kiểm tra database và quyền xem metadata.', 1;
SELECT
  (SELECT COUNT(*) FROM dbo.Dim_Store)    AS CuaHang,
  (SELECT COUNT(*) FROM dbo.Dim_Customer) AS KhachHang,
  (SELECT COUNT(*) FROM dbo.Dim_Product)  AS SanPham,
  (SELECT COUNT(*) FROM dbo.Dim_Date)     AS Ngay,
  COUNT(*) AS GiaoDich,
  FORMAT(SUM(TotalAmount), 'N0') AS DoanhThu
FROM dbo.Fact_Sales;
GO
