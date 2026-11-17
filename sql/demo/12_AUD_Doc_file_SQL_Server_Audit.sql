/* Audit - Đọc bản ghi từ file .sqlaudit của MiniMart
Kết nối SSMS: Windows Authentication có quyền quản trị trên máy demo.
Chỉ chạy trên MiniMart_DataWarehouse hiện có. Đây là file demo/kiểm tra,
không tạo lại database, cấp quyền hoặc sửa dữ liệu nghiệp vụ.
Có thể phát sinh thêm nhật ký do cơ chế Audit đang bật.
*/
USE MiniMart_DataWarehouse;
GO
SET NOCOUNT ON;

DECLARE @AuditPath nvarchar(260), @Pattern nvarchar(260), @AuditGuid uniqueidentifier;
SELECT @AuditPath = log_file_path, @AuditGuid = audit_guid
FROM sys.server_file_audits
WHERE name = N'MiniMart_Audit';
IF @AuditPath IS NULL OR @AuditGuid IS NULL
    THROW 51030, N'Không thấy file audit MiniMart_Audit; kiểm tra quyền xem cấu hình và kiểu lưu FILE.', 1;
IF RIGHT(@AuditPath, 1) NOT IN (N'\', N'/')
    SET @AuditPath += N'\';
-- Dùng tên + GUID để giới hạn đúng tập file audit, kể cả khi cùng thư mục có audit khác.
IF LEN(@AuditPath) + LEN(N'MiniMart_Audit_') + 36 + LEN(N'*.sqlaudit') > 260
    THROW 51031, N'Đường dẫn file audit vượt 260 ký tự; kiểm tra đường dẫn thực tế.', 1;
SET @Pattern = @AuditPath + N'MiniMart_Audit_' + CONVERT(nvarchar(36), @AuditGuid) + N'*.sqlaudit';

-- Tùy chọn: nhập khoảng thời gian UTC để thu hẹp kết quả trên máy có nhiều log.
DECLARE @TuUTC datetime2 = NULL, @DenUTC datetime2 = NULL;
IF @TuUTC IS NOT NULL AND @DenUTC IS NOT NULL AND @TuUTC > @DenUTC
    THROW 51032, N'Khoảng thời gian UTC không hợp lệ.', 1;

BEGIN TRY
    SELECT COUNT_BIG(*) AS TongBanGhiSQLAudit
    FROM sys.fn_get_audit_file(@Pattern, DEFAULT, DEFAULT)
    WHERE database_name = N'MiniMart_DataWarehouse'
      AND (@TuUTC IS NULL OR event_time >= @TuUTC)
      AND (@DenUTC IS NULL OR event_time <= @DenUTC);

    SELECT TOP (20)
           event_time AS ThoiGianUTC,
           DATEADD(HOUR, 7, event_time) AS ThoiGianVietNam,
           session_server_principal_name AS TaiKhoanKetNoi,
           database_principal_name AS DatabaseUser,
           action_id AS HanhDong,
           schema_name AS SchemaName,
           object_name AS DoiTuong,
           succeeded AS KiemTraQuyenThanhCong
    FROM sys.fn_get_audit_file(@Pattern, DEFAULT, DEFAULT)
    WHERE database_name = N'MiniMart_DataWarehouse'
      AND (@TuUTC IS NULL OR event_time >= @TuUTC)
      AND (@DenUTC IS NULL OR event_time <= @DenUTC)
    ORDER BY event_time DESC, sequence_number DESC;
END TRY
BEGIN CATCH
    SELECT ERROR_NUMBER() AS MaLoi, ERROR_MESSAGE() AS ThongBao,
           N'Kiểm tra quyền đọc Audit, file thực tế và thư mục trên máy SQL Server. Không kết luận Audit đạt.' AS HuongXuLy;
    THROW;
END CATCH;
-- TOP (20) là số dòng hiển thị, không phải tổng số log.
-- succeeded của sự kiện ngoài đăng nhập phản ánh kết quả kiểm tra quyền,
-- không bảo đảm toàn bộ câu lệnh/nghiệp vụ đã chạy thành công.
-- Nhật ký web Security.AuditLog là nguồn khác; không cần có cùng số dòng.
GO
