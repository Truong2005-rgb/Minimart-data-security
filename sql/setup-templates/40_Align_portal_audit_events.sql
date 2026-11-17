/* Additive logging correction for a separately rebuilt/test database.
Derived from the exported procedure; preserves existing action names and adds
four action names emitted by the current Flask code. Not applied to your demo DB.
This changes a procedure definition. Review and test before applying anywhere.
*/
USE [MiniMart_DataWarehouse];
GO
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
CREATE OR ALTER PROCEDURE [dbo].[usp_MiniMartPortalWriteAudit]
    @DatabaseUser SYSNAME,
    @ActionName NVARCHAR(100),
    @ActionStatus NVARCHAR(30),
    @ObjectName NVARCHAR(200) = NULL,
    @Details NVARCHAR(500) = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    -- Không chấp nhận tên người dùng trống
    IF NULLIF(LTRIM(RTRIM(@DatabaseUser)), N'') IS NULL
        THROW 51001, 'DatabaseUser khong hop le', 1;

    -- Chỉ cho phép những sự kiện đã định nghĩa
    IF @ActionName IS NULL
       OR @ActionName NOT IN (
           N'VIEW_DASHBOARD',
           N'VIEW_TRANSACTIONS',
           N'VIEW_REVENUE',
           N'VIEW_PRODUCTS',
           N'VIEW_CUSTOMERS',
           N'VIEW_AUDIT',
           N'VIEW_ADMIN',
           N'ACCESS_DENIED',
           N'LOGIN_SUCCESS',
           N'LOGIN_FAILED',
           N'MFA_SUCCESS',
           N'SESSION_EXPIRED',
           N'RBAC_ROLE_TRANSFER',
           N'STORE_ACCESS_GRANT',
           N'STORE_ACCESS_REVOKE',
           N'STORE_ACCESS_FAILED'
       )
        THROW 51002, 'ActionName khong hop le', 1;

    IF @ActionStatus IS NULL
       OR @ActionStatus NOT IN (
           N'SUCCESS', N'FAILED', N'DENIED'
       )
        THROW 51003, 'ActionStatus khong hop le', 1;

    -- Ghi nhật ký, thời gian và AuditID tự sinh
    INSERT INTO Security.AuditLog
        (DatabaseUser, ActionName, ObjectName,
         ActionStatus, Details)
    VALUES
        (@DatabaseUser, @ActionName, @ObjectName,
         @ActionStatus, @Details);
END;
GO
