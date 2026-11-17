/* CLS - Staff đọc 4 cột, bị chặn Phone/Email
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
IF DATABASE_PRINCIPAL_ID(N'Staff_Customer') IS NULL
    THROW 51002, N'Không thấy database user Staff_Customer.', 1;
IF COL_LENGTH(N'dbo.Dim_Customer', N'Phone') IS NULL
    OR COL_LENGTH(N'dbo.Dim_Customer', N'Email') IS NULL
    THROW 51003, N'Không thấy cột Phone/Email; kiểm tra schema trước khi thử CLS.', 1;
DECLARE @DaDoiNguCanh bit = 0;
BEGIN TRY
    EXECUTE AS USER = N'Staff_Customer';
    SET @DaDoiNguCanh = 1;
    EXEC sys.sp_executesql N'SELECT TOP (5) CustomerKey, CustomerID, CustomerName, Address
                            FROM dbo.Dim_Customer ORDER BY CustomerKey;';
    DECLARE @LoiPhone int = 0, @LoiEmail int = 0;
    DECLARE @TinPhone nvarchar(4000) = NULL, @TinEmail nvarchar(4000) = NULL;
    BEGIN TRY
        EXEC sys.sp_executesql N'SELECT TOP (1) Phone FROM dbo.Dim_Customer;';
    END TRY
    BEGIN CATCH
        SELECT @LoiPhone = ERROR_NUMBER(), @TinPhone = ERROR_MESSAGE();
    END CATCH;
    BEGIN TRY
        EXEC sys.sp_executesql N'SELECT TOP (1) Email FROM dbo.Dim_Customer;';
    END TRY
    BEGIN CATCH
        SELECT @LoiEmail = ERROR_NUMBER(), @TinEmail = ERROR_MESSAGE();
    END CATCH;
    REVERT;
    SET @DaDoiNguCanh = 0;
    SELECT N'Phone' AS Cot, @LoiPhone AS MaLoi, @TinPhone AS ThongBao,
           CASE WHEN @LoiPhone = 230 THEN N'ĐẠT - Từ chối quyền cột'
                WHEN @LoiPhone = 0 THEN N'KHÔNG ĐẠT - Đọc được'
                ELSE N'CHƯA KẾT LUẬN - Lỗi khác' END AS KetQua
    UNION ALL
    SELECT N'Email', @LoiEmail, @TinEmail,
           CASE WHEN @LoiEmail = 230 THEN N'ĐẠT - Từ chối quyền cột'
                WHEN @LoiEmail = 0 THEN N'KHÔNG ĐẠT - Đọc được'
                ELSE N'CHƯA KẾT LUẬN - Lỗi khác' END;
    IF @LoiPhone <> 230 OR @LoiEmail <> 230
        THROW 51012, N'Chưa xác nhận được CLS: cần cả Phone và Email bị từ chối quyền cột 230.', 1;
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
