/* Encryption - Staff bị từ chối EXECUTE thủ tục giải mã
Kết nối SSMS: Windows Authentication có quyền quản trị trên máy demo.
Chỉ chạy trên MiniMart_DataWarehouse hiện có. Đây là file demo/kiểm tra,
không tạo lại database, cấp quyền hoặc sửa dữ liệu nghiệp vụ.
Có thể phát sinh thêm nhật ký do cơ chế Audit đang bật.
*/
USE MiniMart_DataWarehouse;
GO
SET NOCOUNT ON;
IF OBJECT_ID(N'Security.usp_PortalGetDecryptedCustomers') IS NULL
    THROW 51001, N'Không thấy Security.usp_PortalGetDecryptedCustomers; kiểm tra database và quyền xem metadata.', 1;
IF DATABASE_PRINCIPAL_ID(N'Staff_Customer') IS NULL
    THROW 51002, N'Không thấy database user Staff_Customer.', 1;
DECLARE @DaDoiNguCanh bit = 0;
BEGIN TRY
    EXECUTE AS USER = N'Staff_Customer';
    SET @DaDoiNguCanh = 1;
    DECLARE @MaLoi int = 0, @ThongBao nvarchar(4000) = NULL;
    BEGIN TRY
        -- Chạy ở tầng thấp hơn để bắt được lỗi biên dịch/phân quyền của truy vấn.
        EXEC sys.sp_executesql N'EXEC Security.usp_PortalGetDecryptedCustomers @MaxRows=5, @SearchPattern=NULL;';
    END TRY
    BEGIN CATCH
        SELECT @MaLoi = ERROR_NUMBER(), @ThongBao = ERROR_MESSAGE();
    END CATCH;

    -- Trả ngữ cảnh trước khi kết luận hoặc phát lại lỗi.
    REVERT;
    SET @DaDoiNguCanh = 0;

    SELECT N'Staff_Customer' AS TaiKhoanThu, @MaLoi AS MaLoi,
           @ThongBao AS ThongBao,
           CASE WHEN @MaLoi IN (229)
                THEN N'ĐẠT - SQL từ chối đúng lỗi quyền mong đợi'
                WHEN @MaLoi = 0 THEN N'KHÔNG ĐẠT - Thao tác được phép'
                ELSE N'CHƯA KẾT LUẬN - Lỗi khác, cần kiểm tra' END AS KetQua;
    IF @MaLoi = 0
        THROW 51010, N'Thử nghiệm không đạt: tài khoản thực hiện được thao tác cần bị chặn.', 1;
    IF @MaLoi NOT IN (229)
        THROW 51011, N'Gặp lỗi khác lỗi quyền mong đợi; không được coi đây là kết quả đạt.', 1;
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
