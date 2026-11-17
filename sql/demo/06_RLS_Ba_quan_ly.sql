/* RLS - Kiểm tra phạm vi hiện được cấp của ba quản lý
Kết nối SSMS: Windows Authentication có quyền quản trị trên máy demo.
Chỉ chạy trên MiniMart_DataWarehouse hiện có. Đây là file demo/kiểm tra,
không tạo lại database, cấp quyền hoặc sửa dữ liệu nghiệp vụ.
Có thể phát sinh thêm nhật ký do cơ chế Audit đang bật.
*/
USE MiniMart_DataWarehouse;
GO
SET NOCOUNT ON;
-- Baseline báo cáo: Thanh Hóa 3387, Nghệ An 3398, Hà Tĩnh 3306 giao dịch.
-- Admin có thể đã thay đổi ánh xạ StoreKey sau baseline; phải đối chiếu phạm vi
-- hiện được cấp, không kết luận RLS lỗi chỉ vì một quản lý được cấp thêm chi nhánh.
IF OBJECT_ID(N'dbo.Fact_Sales') IS NULL
    THROW 51001, N'Không thấy dbo.Fact_Sales; kiểm tra database và quyền xem metadata.', 1;
IF DATABASE_PRINCIPAL_ID(N'Manager_ThanhHoa') IS NULL
    THROW 51002, N'Không thấy database user Manager_ThanhHoa.', 1;
DECLARE @DaDoiNguCanh bit = 0;
BEGIN TRY
    EXECUTE AS USER = N'Manager_ThanhHoa';
    SET @DaDoiNguCanh = 1;
    EXEC sys.sp_executesql N'
        SELECT USER_NAME() AS TaiKhoan, StoreKey AS MaChiNhanh,
               COUNT_BIG(*) AS SoGiaoDich,
               FORMAT(SUM(TotalAmount), ''N0'', ''vi-VN'') + N'' VNĐ'' AS DoanhThu
        FROM dbo.Fact_Sales GROUP BY StoreKey ORDER BY StoreKey;';
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
IF OBJECT_ID(N'dbo.Fact_Sales') IS NULL
    THROW 51001, N'Không thấy dbo.Fact_Sales; kiểm tra database và quyền xem metadata.', 1;
IF DATABASE_PRINCIPAL_ID(N'Manager_NgheAn') IS NULL
    THROW 51002, N'Không thấy database user Manager_NgheAn.', 1;
DECLARE @DaDoiNguCanh bit = 0;
BEGIN TRY
    EXECUTE AS USER = N'Manager_NgheAn';
    SET @DaDoiNguCanh = 1;
    EXEC sys.sp_executesql N'
        SELECT USER_NAME() AS TaiKhoan, StoreKey AS MaChiNhanh,
               COUNT_BIG(*) AS SoGiaoDich,
               FORMAT(SUM(TotalAmount), ''N0'', ''vi-VN'') + N'' VNĐ'' AS DoanhThu
        FROM dbo.Fact_Sales GROUP BY StoreKey ORDER BY StoreKey;';
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
IF OBJECT_ID(N'dbo.Fact_Sales') IS NULL
    THROW 51001, N'Không thấy dbo.Fact_Sales; kiểm tra database và quyền xem metadata.', 1;
IF DATABASE_PRINCIPAL_ID(N'Manager_HaTinh') IS NULL
    THROW 51002, N'Không thấy database user Manager_HaTinh.', 1;
DECLARE @DaDoiNguCanh bit = 0;
BEGIN TRY
    EXECUTE AS USER = N'Manager_HaTinh';
    SET @DaDoiNguCanh = 1;
    EXEC sys.sp_executesql N'
        SELECT USER_NAME() AS TaiKhoan, StoreKey AS MaChiNhanh,
               COUNT_BIG(*) AS SoGiaoDich,
               FORMAT(SUM(TotalAmount), ''N0'', ''vi-VN'') + N'' VNĐ'' AS DoanhThu
        FROM dbo.Fact_Sales GROUP BY StoreKey ORDER BY StoreKey;';
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
