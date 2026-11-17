USE [master]
GO
/****** Object:  Database [MiniMart_DataWarehouse]    Script Date: 11/17/2026 10:07:02 AM ******/
CREATE DATABASE [MiniMart_DataWarehouse]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'MiniMart_DataWarehouse', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\MiniMart_DataWarehouse.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'MiniMart_DataWarehouse_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA\MiniMart_DataWarehouse_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [MiniMart_DataWarehouse].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET ARITHABORT OFF 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET  ENABLE_BROKER 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET  MULTI_USER 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET DB_CHAINING OFF 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET QUERY_STORE = ON
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [MiniMart_DataWarehouse]
GO
/****** Object:  User [Staff_V6]    Script Date: 11/17/2026 10:07:03 AM ******/
CREATE USER [Staff_V6] FOR LOGIN [Staff_V6] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [Staff_Temp3]    Script Date: 11/17/2026 10:07:03 AM ******/
CREATE USER [Staff_Temp3] FOR LOGIN [Staff_Temp3] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [Staff_Temp2]    Script Date: 11/17/2026 10:07:03 AM ******/
CREATE USER [Staff_Temp2] FOR LOGIN [Staff_Temp2] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [Staff_Temp]    Script Date: 11/17/2026 10:07:03 AM ******/
CREATE USER [Staff_Temp] FOR LOGIN [Staff_Temp] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [Staff_Customer]    Script Date: 11/17/2026 10:07:03 AM ******/
CREATE USER [Staff_Customer] FOR LOGIN [Staff_Customer] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [RBAC_Test_01]    Script Date: 11/17/2026 10:07:03 AM ******/
CREATE USER [RBAC_Test_01] FOR LOGIN [RBAC_Test_01] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [Portal_Service]    Script Date: 11/17/2026 10:07:03 AM ******/
CREATE USER [Portal_Service] FOR LOGIN [Portal_Service] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [Portal_Admin]    Script Date: 11/17/2026 10:07:03 AM ******/
CREATE USER [Portal_Admin] FOR LOGIN [Portal_Admin] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [Manager_ThanhHoa]    Script Date: 11/17/2026 10:07:03 AM ******/
CREATE USER [Manager_ThanhHoa] FOR LOGIN [Manager_ThanhHoa] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [Manager_NgheAn]    Script Date: 11/17/2026 10:07:03 AM ******/
CREATE USER [Manager_NgheAn] FOR LOGIN [Manager_NgheAn] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [Manager_HaTinh]    Script Date: 11/17/2026 10:07:03 AM ******/
CREATE USER [Manager_HaTinh] FOR LOGIN [Manager_HaTinh] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [Demo_MaskedViewer]    Script Date: 11/17/2026 10:07:03 AM ******/
CREATE USER [Demo_MaskedViewer] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [Audit_Admin]    Script Date: 11/17/2026 10:07:03 AM ******/
CREATE USER [Audit_Admin] FOR LOGIN [Audit_Admin] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  DatabaseRole [StoreManagerRole]    Script Date: 11/17/2026 10:07:03 AM ******/
CREATE ROLE [StoreManagerRole]
GO
/****** Object:  DatabaseRole [PortalServiceRole]    Script Date: 11/17/2026 10:07:03 AM ******/
CREATE ROLE [PortalServiceRole]
GO
/****** Object:  DatabaseRole [PortalAdminRole]    Script Date: 11/17/2026 10:07:03 AM ******/
CREATE ROLE [PortalAdminRole]
GO
/****** Object:  DatabaseRole [CustomerStaffRole]    Script Date: 11/17/2026 10:07:03 AM ******/
CREATE ROLE [CustomerStaffRole]
GO
/****** Object:  DatabaseRole [AuditAdminRole]    Script Date: 11/17/2026 10:07:03 AM ******/
CREATE ROLE [AuditAdminRole]
GO
ALTER ROLE [CustomerStaffRole] ADD MEMBER [Staff_Customer]
GO
ALTER ROLE [CustomerStaffRole] ADD MEMBER [RBAC_Test_01]
GO
ALTER ROLE [PortalServiceRole] ADD MEMBER [Portal_Service]
GO
ALTER ROLE [PortalAdminRole] ADD MEMBER [Portal_Admin]
GO
ALTER ROLE [StoreManagerRole] ADD MEMBER [Manager_ThanhHoa]
GO
ALTER ROLE [StoreManagerRole] ADD MEMBER [Manager_NgheAn]
GO
ALTER ROLE [StoreManagerRole] ADD MEMBER [Manager_HaTinh]
GO
ALTER ROLE [AuditAdminRole] ADD MEMBER [Audit_Admin]
GO
GRANT CONNECT TO [Audit_Admin] AS [dbo]
GO
GRANT CONNECT TO [Demo_MaskedViewer] AS [dbo]
GO
GRANT CONNECT TO [Manager_HaTinh] AS [dbo]
GO
GRANT CONNECT TO [Manager_NgheAn] AS [dbo]
GO
GRANT CONNECT TO [Manager_ThanhHoa] AS [dbo]
GO
GRANT CONNECT TO [Portal_Admin] AS [dbo]
GO
GRANT CONNECT TO [Portal_Service] AS [dbo]
GO
GRANT VIEW ANY COLUMN ENCRYPTION KEY DEFINITION TO [public] AS [dbo]
GO
GRANT VIEW ANY COLUMN MASTER KEY DEFINITION TO [public] AS [dbo]
GO
GRANT CONNECT TO [RBAC_Test_01] AS [dbo]
GO
GRANT CONNECT TO [Staff_Customer] AS [dbo]
GO
GRANT CONNECT TO [Staff_Temp] AS [dbo]
GO
GRANT CONNECT TO [Staff_Temp2] AS [dbo]
GO
GRANT CONNECT TO [Staff_Temp3] AS [dbo]
GO
GRANT CONNECT TO [Staff_V6] AS [dbo]
GO
/****** Object:  Schema [HR]    Script Date: 11/17/2026 10:07:03 AM ******/
CREATE SCHEMA [HR]
GO
DENY DELETE ON SCHEMA::[HR] TO [AuditAdminRole] AS [dbo]
GO
DENY EXECUTE ON SCHEMA::[HR] TO [AuditAdminRole] AS [dbo]
GO
DENY INSERT ON SCHEMA::[HR] TO [AuditAdminRole] AS [dbo]
GO
DENY SELECT ON SCHEMA::[HR] TO [AuditAdminRole] AS [dbo]
GO
DENY UPDATE ON SCHEMA::[HR] TO [AuditAdminRole] AS [dbo]
GO
DENY DELETE ON SCHEMA::[HR] TO [CustomerStaffRole] AS [dbo]
GO
DENY EXECUTE ON SCHEMA::[HR] TO [CustomerStaffRole] AS [dbo]
GO
DENY INSERT ON SCHEMA::[HR] TO [CustomerStaffRole] AS [dbo]
GO
DENY SELECT ON SCHEMA::[HR] TO [CustomerStaffRole] AS [dbo]
GO
DENY UPDATE ON SCHEMA::[HR] TO [CustomerStaffRole] AS [dbo]
GO
DENY DELETE ON SCHEMA::[HR] TO [PortalServiceRole] AS [dbo]
GO
DENY EXECUTE ON SCHEMA::[HR] TO [PortalServiceRole] AS [dbo]
GO
DENY INSERT ON SCHEMA::[HR] TO [PortalServiceRole] AS [dbo]
GO
DENY SELECT ON SCHEMA::[HR] TO [PortalServiceRole] AS [dbo]
GO
DENY UPDATE ON SCHEMA::[HR] TO [PortalServiceRole] AS [dbo]
GO
DENY DELETE ON SCHEMA::[HR] TO [StoreManagerRole] AS [dbo]
GO
DENY EXECUTE ON SCHEMA::[HR] TO [StoreManagerRole] AS [dbo]
GO
DENY INSERT ON SCHEMA::[HR] TO [StoreManagerRole] AS [dbo]
GO
DENY SELECT ON SCHEMA::[HR] TO [StoreManagerRole] AS [dbo]
GO
DENY UPDATE ON SCHEMA::[HR] TO [StoreManagerRole] AS [dbo]
GO
/****** Object:  Schema [Security]    Script Date: 11/17/2026 10:07:04 AM ******/
CREATE SCHEMA [Security]
GO
DENY DELETE ON SCHEMA::[Security] TO [AuditAdminRole] AS [dbo]
GO
DENY INSERT ON SCHEMA::[Security] TO [AuditAdminRole] AS [dbo]
GO
DENY UPDATE ON SCHEMA::[Security] TO [AuditAdminRole] AS [dbo]
GO
/****** Object:  Table [HR].[Employee]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HR].[Employee](
	[EmployeeCode] [varchar](10) NOT NULL,
	[FullName] [nvarchar](100) NOT NULL,
	[DbUserName] [sysname] NULL,
	[Status] [varchar](10) NOT NULL,
	[StartDate] [date] NOT NULL,
	[ContractEndDate] [date] NULL,
	[ResignedDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[EmployeeCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [HR].[vw_EmployeeAccountState]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Khung nhìn đối chiếu: trạng thái nhân sự cạnh trạng thái quyền thực tế của tài khoản
CREATE   VIEW [HR].[vw_EmployeeAccountState] AS
SELECT e.EmployeeCode AS [Mã NV], e.FullName AS [Họ tên], e.DbUserName AS [Tài khoản],
       e.Status AS [Trạng thái nhân sự], e.ContractEndDate AS [Hết hạn hợp đồng],
       CASE WHEN dp.principal_id IS NULL THEN NULL
            ELSE (SELECT COUNT(*) FROM sys.database_role_members rm WHERE rm.member_principal_id = dp.principal_id) END AS [Số vai trò còn lại],
       CASE WHEN dp.principal_id IS NULL THEN NULL WHEN sp.is_disabled = 1 THEN 1 ELSE 0 END AS [Login bị vô hiệu hóa (1 = có)]
FROM HR.Employee e
LEFT JOIN sys.database_principals dp ON dp.name = e.DbUserName
LEFT JOIN sys.server_principals sp ON sp.sid = dp.sid;
GO
/****** Object:  Table [Security].[UserStoreAccess]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[UserStoreAccess](
	[DatabaseUserName] [sysname] NOT NULL,
	[StoreKey] [int] NOT NULL,
 CONSTRAINT [PK_UserStoreAccess_UserStore] PRIMARY KEY CLUSTERED 
(
	[DatabaseUserName] ASC,
	[StoreKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [Security].[fn_FilterSalesByStore]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- 2. Sua ham: admin/dbo thay tat ca, manager chi thay cua hang cua minh
CREATE FUNCTION [Security].[fn_FilterSalesByStore]
(
    @StoreKey INT
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
(
    SELECT 1 AS AccessAllowed
    WHERE IS_MEMBER(N'db_owner') = 1
       OR USER_NAME() = N'dbo'
       OR EXISTS
          (
              SELECT 1
              FROM Security.UserStoreAccess AS usa
              WHERE usa.DatabaseUserName = USER_NAME()
                AND usa.StoreKey = @StoreKey
          )
);
GO
/****** Object:  Table [dbo].[Dim_Customer]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_Customer](
	[CustomerKey] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [varchar](10) NOT NULL,
	[CustomerName] [nvarchar](100) NOT NULL,
	[Phone] [varchar](15) MASKED WITH (FUNCTION = 'partial(2, "XXXXXXX", 2)') NULL,
	[Email] [varchar](100) MASKED WITH (FUNCTION = 'email()') NULL,
	[Address] [nvarchar](200) NULL,
	[Phone_Encrypted] [varbinary](256) NULL,
	[Email_Encrypted] [varbinary](256) NULL,
PRIMARY KEY CLUSTERED 
(
	[CustomerKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
GRANT SELECT ON [dbo].[Dim_Customer] ([CustomerKey]) TO [CustomerStaffRole] AS [dbo]
GO
GRANT SELECT ON [dbo].[Dim_Customer] ([CustomerKey]) TO [PortalAdminRole] AS [dbo]
GO
GRANT SELECT ON [dbo].[Dim_Customer] ([CustomerID]) TO [CustomerStaffRole] AS [dbo]
GO
GRANT SELECT ON [dbo].[Dim_Customer] ([CustomerID]) TO [PortalAdminRole] AS [dbo]
GO
GRANT SELECT ON [dbo].[Dim_Customer] ([CustomerName]) TO [CustomerStaffRole] AS [dbo]
GO
GRANT SELECT ON [dbo].[Dim_Customer] ([CustomerName]) TO [Demo_MaskedViewer] AS [dbo]
GO
GRANT SELECT ON [dbo].[Dim_Customer] ([CustomerName]) TO [PortalAdminRole] AS [dbo]
GO
GRANT SELECT ON [dbo].[Dim_Customer] ([Phone]) TO [Demo_MaskedViewer] AS [dbo]
GO
GRANT SELECT ON [dbo].[Dim_Customer] ([Phone]) TO [PortalAdminRole] AS [dbo]
GO
GRANT UNMASK ON [dbo].[Dim_Customer] ([Phone]) TO [PortalAdminRole] AS [dbo]
GO
GRANT SELECT ON [dbo].[Dim_Customer] ([Email]) TO [Demo_MaskedViewer] AS [dbo]
GO
GRANT SELECT ON [dbo].[Dim_Customer] ([Email]) TO [PortalAdminRole] AS [dbo]
GO
GRANT UNMASK ON [dbo].[Dim_Customer] ([Email]) TO [PortalAdminRole] AS [dbo]
GO
GRANT SELECT ON [dbo].[Dim_Customer] ([Address]) TO [CustomerStaffRole] AS [dbo]
GO
GRANT SELECT ON [dbo].[Dim_Customer] ([Address]) TO [PortalAdminRole] AS [dbo]
GO
/****** Object:  Table [dbo].[Dim_Date]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_Date](
	[DateKey] [int] NOT NULL,
	[FullDate] [date] NOT NULL,
	[DayOfWeek] [nvarchar](20) NULL,
	[Month] [int] NULL,
	[Quarter] [int] NULL,
	[Year] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[DateKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[FullDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
GRANT SELECT ON [dbo].[Dim_Date] TO [StoreManagerRole] AS [dbo]
GO
/****** Object:  Table [dbo].[Dim_Product]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_Product](
	[ProductKey] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [varchar](10) NOT NULL,
	[ProductName] [nvarchar](150) NOT NULL,
	[Category] [nvarchar](50) NULL,
	[UnitPrice] [decimal](18, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
GRANT SELECT ON [dbo].[Dim_Product] TO [StoreManagerRole] AS [dbo]
GO
/****** Object:  Table [dbo].[Dim_Store]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dim_Store](
	[StoreKey] [int] IDENTITY(1,1) NOT NULL,
	[StoreID] [varchar](10) NOT NULL,
	[StoreName] [nvarchar](100) NOT NULL,
	[City] [nvarchar](50) NOT NULL,
	[ManagerName] [nvarchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[StoreKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[StoreID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
GRANT SELECT ON [dbo].[Dim_Store] TO [StoreManagerRole] AS [dbo]
GO
/****** Object:  Table [dbo].[Fact_Sales]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Fact_Sales](
	[SalesKey] [bigint] IDENTITY(1,1) NOT NULL,
	[DateKey] [int] NOT NULL,
	[StoreKey] [int] NOT NULL,
	[ProductKey] [int] NOT NULL,
	[CustomerKey] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[TotalAmount] [decimal](18, 2) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
GRANT SELECT ON [dbo].[Fact_Sales] TO [PortalAdminRole] AS [dbo]
GO
GRANT SELECT ON [dbo].[Fact_Sales] TO [StoreManagerRole] AS [dbo]
GO
/****** Object:  Table [Security].[AccountLog]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[AccountLog](
	[LogID] [bigint] IDENTITY(1,1) NOT NULL,
	[LogTimeUtc] [datetime2](3) NOT NULL,
	[ActionType] [nvarchar](20) NOT NULL,
	[TargetUser] [sysname] NOT NULL,
	[OldRole] [nvarchar](400) NULL,
	[NewRole] [nvarchar](400) NULL,
	[PerformedBy] [sysname] NOT NULL,
	[Detail] [nvarchar](400) NULL,
PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
GRANT SELECT ON [Security].[AccountLog] TO [AuditAdminRole] AS [dbo]
GO
DENY DELETE ON [Security].[AccountLog] TO [CustomerStaffRole] AS [dbo]
GO
DENY INSERT ON [Security].[AccountLog] TO [CustomerStaffRole] AS [dbo]
GO
DENY SELECT ON [Security].[AccountLog] TO [CustomerStaffRole] AS [dbo]
GO
DENY UPDATE ON [Security].[AccountLog] TO [CustomerStaffRole] AS [dbo]
GO
DENY DELETE ON [Security].[AccountLog] TO [PortalServiceRole] AS [dbo]
GO
DENY INSERT ON [Security].[AccountLog] TO [PortalServiceRole] AS [dbo]
GO
DENY SELECT ON [Security].[AccountLog] TO [PortalServiceRole] AS [dbo]
GO
DENY UPDATE ON [Security].[AccountLog] TO [PortalServiceRole] AS [dbo]
GO
DENY DELETE ON [Security].[AccountLog] TO [StoreManagerRole] AS [dbo]
GO
DENY INSERT ON [Security].[AccountLog] TO [StoreManagerRole] AS [dbo]
GO
DENY SELECT ON [Security].[AccountLog] TO [StoreManagerRole] AS [dbo]
GO
DENY UPDATE ON [Security].[AccountLog] TO [StoreManagerRole] AS [dbo]
GO
/****** Object:  Table [Security].[AuditLog]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[AuditLog](
	[AuditID] [bigint] IDENTITY(1,1) NOT NULL,
	[EventTime] [datetime2](7) NOT NULL,
	[DatabaseUser] [sysname] NOT NULL,
	[ActionName] [nvarchar](100) NOT NULL,
	[ObjectName] [nvarchar](200) NULL,
	[ActionStatus] [nvarchar](30) NOT NULL,
	[Details] [nvarchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[AuditID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
GRANT INSERT ON [Security].[AuditLog] TO [AuditAdminRole] AS [dbo]
GO
GRANT SELECT ON [Security].[AuditLog] TO [AuditAdminRole] AS [dbo]
GO
DENY DELETE ON [Security].[AuditLog] TO [CustomerStaffRole] AS [dbo]
GO
DENY INSERT ON [Security].[AuditLog] TO [CustomerStaffRole] AS [dbo]
GO
DENY SELECT ON [Security].[AuditLog] TO [CustomerStaffRole] AS [dbo]
GO
DENY UPDATE ON [Security].[AuditLog] TO [CustomerStaffRole] AS [dbo]
GO
GRANT SELECT ON [Security].[AuditLog] TO [PortalAdminRole] AS [dbo]
GO
DENY DELETE ON [Security].[AuditLog] TO [StoreManagerRole] AS [dbo]
GO
DENY INSERT ON [Security].[AuditLog] TO [StoreManagerRole] AS [dbo]
GO
DENY SELECT ON [Security].[AuditLog] TO [StoreManagerRole] AS [dbo]
GO
DENY UPDATE ON [Security].[AuditLog] TO [StoreManagerRole] AS [dbo]
GO
/****** Object:  Table [Security].[AuthLog]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[AuthLog](
	[LogID] [bigint] IDENTITY(1,1) NOT NULL,
	[LogTimeUtc] [datetime2](7) NOT NULL,
	[UserName] [nvarchar](128) NULL,
	[EventType] [varchar](30) NOT NULL,
	[ClientIp] [varchar](45) NULL,
	[Detail] [nvarchar](200) NULL,
 CONSTRAINT [PK_AuthLog] PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
GRANT SELECT ON [Security].[AuthLog] TO [AuditAdminRole] AS [dbo]
GO
DENY DELETE ON [Security].[AuthLog] TO [CustomerStaffRole] AS [dbo]
GO
DENY INSERT ON [Security].[AuthLog] TO [CustomerStaffRole] AS [dbo]
GO
DENY SELECT ON [Security].[AuthLog] TO [CustomerStaffRole] AS [dbo]
GO
DENY UPDATE ON [Security].[AuthLog] TO [CustomerStaffRole] AS [dbo]
GO
DENY DELETE ON [Security].[AuthLog] TO [PortalServiceRole] AS [dbo]
GO
DENY UPDATE ON [Security].[AuthLog] TO [PortalServiceRole] AS [dbo]
GO
GRANT INSERT ON [Security].[AuthLog] TO [PortalServiceRole] AS [dbo]
GO
DENY DELETE ON [Security].[AuthLog] TO [StoreManagerRole] AS [dbo]
GO
DENY INSERT ON [Security].[AuthLog] TO [StoreManagerRole] AS [dbo]
GO
DENY SELECT ON [Security].[AuthLog] TO [StoreManagerRole] AS [dbo]
GO
DENY UPDATE ON [Security].[AuthLog] TO [StoreManagerRole] AS [dbo]
GO
/****** Object:  Table [Security].[LoginAttempt]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[LoginAttempt](
	[UserName] [nvarchar](128) NOT NULL,
	[FailedCount] [int] NOT NULL,
	[LockedUntilUtc] [datetime2](7) NULL,
	[LastFailUtc] [datetime2](7) NULL,
 CONSTRAINT [PK_LoginAttempt] PRIMARY KEY CLUSTERED 
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
GRANT SELECT ON [Security].[LoginAttempt] TO [AuditAdminRole] AS [dbo]
GO
DENY DELETE ON [Security].[LoginAttempt] TO [CustomerStaffRole] AS [dbo]
GO
DENY INSERT ON [Security].[LoginAttempt] TO [CustomerStaffRole] AS [dbo]
GO
DENY SELECT ON [Security].[LoginAttempt] TO [CustomerStaffRole] AS [dbo]
GO
DENY UPDATE ON [Security].[LoginAttempt] TO [CustomerStaffRole] AS [dbo]
GO
GRANT INSERT ON [Security].[LoginAttempt] TO [PortalServiceRole] AS [dbo]
GO
GRANT SELECT ON [Security].[LoginAttempt] TO [PortalServiceRole] AS [dbo]
GO
GRANT UPDATE ON [Security].[LoginAttempt] TO [PortalServiceRole] AS [dbo]
GO
DENY DELETE ON [Security].[LoginAttempt] TO [StoreManagerRole] AS [dbo]
GO
DENY INSERT ON [Security].[LoginAttempt] TO [StoreManagerRole] AS [dbo]
GO
DENY SELECT ON [Security].[LoginAttempt] TO [StoreManagerRole] AS [dbo]
GO
DENY UPDATE ON [Security].[LoginAttempt] TO [StoreManagerRole] AS [dbo]
GO
/****** Object:  Table [Security].[StoreAccessChangeLog]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[StoreAccessChangeLog](
	[ChangeID] [bigint] IDENTITY(1,1) NOT NULL,
	[ChangedAtUTC] [datetime2](3) NOT NULL,
	[ActorLogin] [sysname] NOT NULL,
	[TargetManager] [sysname] NOT NULL,
	[StoreKey] [int] NOT NULL,
	[ActionName] [varchar](6) NOT NULL,
	[DataChanged] [bit] NOT NULL,
 CONSTRAINT [PK_StoreAccessChangeLog] PRIMARY KEY CLUSTERED 
(
	[ChangeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Security].[UserMFA]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Security].[UserMFA](
	[UserName] [nvarchar](128) NOT NULL,
	[TotpSecretEnc] [varchar](400) NOT NULL,
	[IsEnrolled] [bit] NOT NULL,
	[LastUsedStep] [bigint] NOT NULL,
	[CreatedAtUtc] [datetime2](7) NOT NULL,
	[EnrolledAtUtc] [datetime2](7) NULL,
 CONSTRAINT [PK_UserMFA] PRIMARY KEY CLUSTERED 
(
	[UserName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
DENY DELETE ON [Security].[UserMFA] TO [CustomerStaffRole] AS [dbo]
GO
DENY INSERT ON [Security].[UserMFA] TO [CustomerStaffRole] AS [dbo]
GO
DENY SELECT ON [Security].[UserMFA] TO [CustomerStaffRole] AS [dbo]
GO
DENY UPDATE ON [Security].[UserMFA] TO [CustomerStaffRole] AS [dbo]
GO
GRANT INSERT ON [Security].[UserMFA] TO [PortalServiceRole] AS [dbo]
GO
GRANT SELECT ON [Security].[UserMFA] TO [PortalServiceRole] AS [dbo]
GO
GRANT UPDATE ON [Security].[UserMFA] TO [PortalServiceRole] AS [dbo]
GO
DENY DELETE ON [Security].[UserMFA] TO [StoreManagerRole] AS [dbo]
GO
DENY INSERT ON [Security].[UserMFA] TO [StoreManagerRole] AS [dbo]
GO
DENY SELECT ON [Security].[UserMFA] TO [StoreManagerRole] AS [dbo]
GO
DENY UPDATE ON [Security].[UserMFA] TO [StoreManagerRole] AS [dbo]
GO
GRANT SELECT ON [Security].[UserMFA] ([UserName]) TO [AuditAdminRole] AS [dbo]
GO
GRANT SELECT ON [Security].[UserMFA] ([IsEnrolled]) TO [AuditAdminRole] AS [dbo]
GO
GRANT SELECT ON [Security].[UserMFA] ([CreatedAtUtc]) TO [AuditAdminRole] AS [dbo]
GO
GRANT SELECT ON [Security].[UserMFA] ([EnrolledAtUtc]) TO [AuditAdminRole] AS [dbo]
GO
/****** Object:  SecurityPolicy [Security].[SalesStorePolicy]    Script Date: 11/17/2026 10:07:04 AM ******/
CREATE SECURITY POLICY [Security].[SalesStorePolicy] 
ADD FILTER PREDICATE [Security].[fn_FilterSalesByStore]([StoreKey]) ON [dbo].[Fact_Sales]
WITH (STATE = ON, SCHEMABINDING = ON)
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UX_HR_Employee_DbUser]    Script Date: 11/17/2026 10:07:04 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UX_HR_Employee_DbUser] ON [HR].[Employee]
(
	[DbUserName] ASC
)
WHERE ([DbUserName] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [HR].[Employee] ADD  CONSTRAINT [DF_HR_Employee_Status]  DEFAULT ('ACTIVE') FOR [Status]
GO
ALTER TABLE [HR].[Employee] ADD  CONSTRAINT [DF_HR_Employee_Start]  DEFAULT (CONVERT([date],sysdatetime())) FOR [StartDate]
GO
ALTER TABLE [Security].[AccountLog] ADD  DEFAULT (sysutcdatetime()) FOR [LogTimeUtc]
GO
ALTER TABLE [Security].[AccountLog] ADD  DEFAULT (suser_sname()) FOR [PerformedBy]
GO
ALTER TABLE [Security].[AuditLog] ADD  DEFAULT (sysdatetime()) FOR [EventTime]
GO
ALTER TABLE [Security].[AuthLog] ADD  CONSTRAINT [DF_AuthLog_Time]  DEFAULT (sysutcdatetime()) FOR [LogTimeUtc]
GO
ALTER TABLE [Security].[StoreAccessChangeLog] ADD  CONSTRAINT [DF_StoreAccessChangeLog_ChangedAtUTC]  DEFAULT (sysutcdatetime()) FOR [ChangedAtUTC]
GO
ALTER TABLE [Security].[UserMFA] ADD  CONSTRAINT [DF_UserMFA_Enrolled]  DEFAULT ((0)) FOR [IsEnrolled]
GO
ALTER TABLE [Security].[UserMFA] ADD  CONSTRAINT [DF_UserMFA_Step]  DEFAULT ((0)) FOR [LastUsedStep]
GO
ALTER TABLE [Security].[UserMFA] ADD  CONSTRAINT [DF_UserMFA_Created]  DEFAULT (sysutcdatetime()) FOR [CreatedAtUtc]
GO
ALTER TABLE [dbo].[Fact_Sales]  WITH CHECK ADD  CONSTRAINT [FK_FactSales_Customer] FOREIGN KEY([CustomerKey])
REFERENCES [dbo].[Dim_Customer] ([CustomerKey])
GO
ALTER TABLE [dbo].[Fact_Sales] CHECK CONSTRAINT [FK_FactSales_Customer]
GO
ALTER TABLE [dbo].[Fact_Sales]  WITH CHECK ADD  CONSTRAINT [FK_FactSales_Date] FOREIGN KEY([DateKey])
REFERENCES [dbo].[Dim_Date] ([DateKey])
GO
ALTER TABLE [dbo].[Fact_Sales] CHECK CONSTRAINT [FK_FactSales_Date]
GO
ALTER TABLE [dbo].[Fact_Sales]  WITH CHECK ADD  CONSTRAINT [FK_FactSales_Product] FOREIGN KEY([ProductKey])
REFERENCES [dbo].[Dim_Product] ([ProductKey])
GO
ALTER TABLE [dbo].[Fact_Sales] CHECK CONSTRAINT [FK_FactSales_Product]
GO
ALTER TABLE [dbo].[Fact_Sales]  WITH CHECK ADD  CONSTRAINT [FK_FactSales_Store] FOREIGN KEY([StoreKey])
REFERENCES [dbo].[Dim_Store] ([StoreKey])
GO
ALTER TABLE [dbo].[Fact_Sales] CHECK CONSTRAINT [FK_FactSales_Store]
GO
ALTER TABLE [Security].[UserStoreAccess]  WITH CHECK ADD  CONSTRAINT [FK_UserStoreAccess_DimStore] FOREIGN KEY([StoreKey])
REFERENCES [dbo].[Dim_Store] ([StoreKey])
GO
ALTER TABLE [Security].[UserStoreAccess] CHECK CONSTRAINT [FK_UserStoreAccess_DimStore]
GO
ALTER TABLE [dbo].[Dim_Product]  WITH CHECK ADD CHECK  (([UnitPrice]>=(0)))
GO
ALTER TABLE [dbo].[Fact_Sales]  WITH CHECK ADD CHECK  (([Quantity]>(0)))
GO
ALTER TABLE [dbo].[Fact_Sales]  WITH CHECK ADD CHECK  (([TotalAmount]>=(0)))
GO
ALTER TABLE [HR].[Employee]  WITH CHECK ADD  CONSTRAINT [CK_HR_Employee_Status] CHECK  (([Status]='RESIGNED' OR [Status]='ACTIVE'))
GO
ALTER TABLE [HR].[Employee] CHECK CONSTRAINT [CK_HR_Employee_Status]
GO
ALTER TABLE [Security].[StoreAccessChangeLog]  WITH CHECK ADD  CONSTRAINT [CK_StoreAccessChangeLog_Action] CHECK  (([ActionName]='REVOKE' OR [ActionName]='GRANT'))
GO
ALTER TABLE [Security].[StoreAccessChangeLog] CHECK CONSTRAINT [CK_StoreAccessChangeLog_Action]
GO
ALTER TABLE [Security].[StoreAccessChangeLog]  WITH CHECK ADD  CONSTRAINT [CK_StoreAccessChangeLog_Store] CHECK  (([StoreKey]=(3) OR [StoreKey]=(2) OR [StoreKey]=(1)))
GO
ALTER TABLE [Security].[StoreAccessChangeLog] CHECK CONSTRAINT [CK_StoreAccessChangeLog_Store]
GO
/****** Object:  StoredProcedure [dbo].[usp_MiniMartPortalWriteAudit]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_MiniMartPortalWriteAudit]
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
           N'SESSION_EXPIRED'
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
GRANT EXECUTE ON [dbo].[usp_MiniMartPortalWriteAudit] TO [PortalServiceRole] AS [dbo]
GO
/****** Object:  StoredProcedure [HR].[usp_MarkResigned]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
/* ---------- A3. LỚP 1 - TỨC THÌ: nhân sự báo nghỉ việc, thu hồi ngay trong cùng thao tác ----------
   Trạng thái được cập nhật trước và được lưu ngay. Nếu bước thu hồi lỗi, trạng thái "đã nghỉ" vẫn còn
   và lớp 2 (đồng bộ) sẽ thu hồi nốt ở lần chạy sau. */
CREATE   PROCEDURE [HR].[usp_MarkResigned]
    @EmployeeCode varchar(10), @ResignedDate date = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @u sysname, @status varchar(10), @reason nvarchar(300);
    SELECT @u = DbUserName, @status = Status FROM HR.Employee WHERE EmployeeCode = @EmployeeCode;
    IF @@ROWCOUNT = 0 THROW 50020, N'Không có nhân viên với mã này.', 1;
    IF @status = 'RESIGNED' THROW 50021, N'Nhân viên đã được ghi nhận nghỉ việc trước đó.', 1;
 
    UPDATE HR.Employee
    SET Status = 'RESIGNED', ResignedDate = ISNULL(@ResignedDate, CAST(SYSDATETIME() AS date))
    WHERE EmployeeCode = @EmployeeCode;
 
    IF @u IS NOT NULL AND DATABASE_PRINCIPAL_ID(@u) IS NOT NULL
    BEGIN
        SET @reason = N'Tức thì: nhân sự báo nghỉ việc (mã ' + @EmployeeCode + N')';
        EXEC Security.usp_OffboardUser @UserName = @u, @Reason = @reason;
    END
END;
GO
/****** Object:  StoredProcedure [Security].[usp_CheckAccess]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
-- B4. Kiểm tra quyền thực tế của một tài khoản theo hồ sơ dự kiến
--     @Profile: STAFF (như nhân viên khách hàng), AUDIT (như kiểm toán viên), NONE (không còn quyền nào)
CREATE   PROCEDURE [Security].[usp_CheckAccess]
    @UserName sysname, @Profile nvarchar(10)
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT OFF;
    DECLARE @t TABLE (Id int, MoTa nvarchar(200), Lenh nvarchar(max), ExpStaff nvarchar(20), ExpAudit nvarchar(20), ExpNone nvarchar(20));
    INSERT @t VALUES
     (1, N'Đọc cột khách hàng được cấp (CustomerKey)', N'DECLARE @x int; SELECT TOP 1 @x = 1 FROM dbo.Dim_Customer WHERE CustomerKey IS NOT NULL;', N'ĐƯỢC PHÉP', N'BỊ CHẶN', N'BỊ CHẶN'),
     (2, N'Đọc cột Email của khách hàng',                 N'DECLARE @x int; SELECT TOP 1 @x = 1 FROM dbo.Dim_Customer WHERE Email IS NOT NULL;', N'BỊ CHẶN', N'BỊ CHẶN', N'BỊ CHẶN'),
     (3, N'Đọc dữ liệu bán hàng (Fact_Sales)',            N'DECLARE @x int; SELECT TOP 1 @x = 1 FROM dbo.Fact_Sales;', N'BỊ CHẶN', N'BỊ CHẶN', N'BỊ CHẶN'),
     (4, N'Đọc nhật ký đăng nhập (AuthLog)',              N'DECLARE @x int; SELECT TOP 1 @x = 1 FROM Security.AuthLog;', N'BỊ CHẶN', N'ĐƯỢC PHÉP', N'BỊ CHẶN'),
     (5, N'Xóa nhật ký đăng nhập (AuthLog)',              N'DELETE FROM Security.AuthLog WHERE 1 = 0;', N'BỊ CHẶN', N'BỊ CHẶN', N'BỊ CHẶN');
 
    DECLARE @r TABLE (Id int, KetQua nvarchar(20), MaLoi int NULL);
    DECLARE @id int, @cmd nvarchar(max), @sql nvarchar(max);
    DECLARE ct CURSOR LOCAL FAST_FORWARD FOR SELECT Id, Lenh FROM @t ORDER BY Id;
    OPEN ct; FETCH NEXT FROM ct INTO @id, @cmd;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            SET @sql = N'EXECUTE AS USER = ' + QUOTENAME(@UserName, '''') + N'; ' + @cmd + N' REVERT;';
            EXEC (@sql);
            INSERT @r VALUES (@id, N'ĐƯỢC PHÉP', NULL);
        END TRY
        BEGIN CATCH
            REVERT;
            INSERT @r VALUES (@id, N'BỊ CHẶN', ERROR_NUMBER());
        END CATCH
        FETCH NEXT FROM ct INTO @id, @cmd;
    END
    CLOSE ct; DEALLOCATE ct;
    REVERT;
 
    SELECT @UserName AS [Tài khoản], @Profile AS [Hồ sơ quyền], t.Id AS [STT], t.MoTa AS [Thao tác],
           CASE @Profile WHEN N'STAFF' THEN t.ExpStaff WHEN N'AUDIT' THEN t.ExpAudit ELSE t.ExpNone END AS [Dự kiến],
           r.KetQua AS [Thực tế], r.MaLoi AS [Mã lỗi],
           CASE WHEN r.KetQua <> CASE @Profile WHEN N'STAFF' THEN t.ExpStaff WHEN N'AUDIT' THEN t.ExpAudit ELSE t.ExpNone END THEN N'LỖI'
                WHEN r.KetQua = N'BỊ CHẶN' AND r.MaLoi NOT IN (229, 230) THEN N'LỖI: không phải lỗi quyền'
                ELSE N'Đạt' END AS [Đánh giá]
    FROM @t t JOIN @r r ON r.Id = t.Id ORDER BY t.Id;
END;
GO
DENY EXECUTE ON [Security].[usp_CheckAccess] TO [AuditAdminRole] AS [dbo]
GO
DENY EXECUTE ON [Security].[usp_CheckAccess] TO [CustomerStaffRole] AS [dbo]
GO
DENY EXECUTE ON [Security].[usp_CheckAccess] TO [PortalServiceRole] AS [dbo]
GO
DENY EXECUTE ON [Security].[usp_CheckAccess] TO [StoreManagerRole] AS [dbo]
GO
/****** Object:  StoredProcedure [Security].[usp_GetBusinessRoleAssignments]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [Security].[usp_GetBusinessRoleAssignments]
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    IF ORIGINAL_LOGIN() <> N'Portal_Admin'
       OR NOT EXISTS
       (
           SELECT 1
           FROM sys.database_principals AS u
           JOIN sys.database_role_members AS rm
             ON rm.member_principal_id = u.principal_id
           JOIN sys.database_principals AS r
             ON r.principal_id = rm.role_principal_id
           WHERE u.name = N'Portal_Admin'
             AND r.name = N'PortalAdminRole'
       )
        THROW 51410, N'Chi Portal_Admin co quyen xem danh sach vai tro nghiep vu.', 1;

    -- Chi tra tai khoan SQL thuoc dung mot vai tro nghiep vu va
    -- khong thuoc vai tro quan tri/cac fixed database roles.
    ;WITH business_roles AS
    (
        SELECT u.principal_id,
               u.name AS UserName,
               MAX(r.name) AS RoleName,
               COUNT(*) AS RoleCount
        FROM sys.database_principals AS u
        JOIN sys.database_role_members AS rm
          ON rm.member_principal_id = u.principal_id
        JOIN sys.database_principals AS r
          ON r.principal_id = rm.role_principal_id
        WHERE u.type = 'S'
          AND u.name NOT IN (N'Portal_Admin', N'Portal_Service', N'dbo', N'guest')
          AND r.name IN (N'StoreManagerRole', N'CustomerStaffRole', N'AuditAdminRole')
        GROUP BY u.principal_id, u.name
    )
    SELECT b.UserName, b.RoleName
    FROM business_roles AS b
    WHERE b.RoleCount = 1
      AND NOT EXISTS
      (
          SELECT 1
          FROM sys.database_role_members AS rm
          JOIN sys.database_principals AS r
            ON r.principal_id = rm.role_principal_id
          WHERE rm.member_principal_id = b.principal_id
            AND (r.is_fixed_role = 1 OR
                 r.name IN (N'PortalAdminRole', N'PortalServiceRole'))
      )
    ORDER BY b.UserName;
END;

GO
GRANT EXECUTE ON [Security].[usp_GetBusinessRoleAssignments] TO [PortalAdminRole] AS [dbo]
GO
/****** Object:  StoredProcedure [Security].[usp_GetManagerStoreAccess]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [Security].[usp_GetManagerStoreAccess]
AS
BEGIN
    SET NOCOUNT ON;

    IF ORIGINAL_LOGIN() <> N'Portal_Admin'
       OR ISNULL(IS_ROLEMEMBER(N'PortalAdminRole'), 0) <> 1
        THROW 51210, 'Chi Portal_Admin co quyen xem phan cong Manager.', 1;

    SELECT m.ManagerUsername,
           s.StoreKey,
           s.StoreName,
           CAST(CASE WHEN a.DatabaseUserName IS NULL THEN 0 ELSE 1 END AS BIT) AS HasAccess
    FROM (VALUES
        (N'Manager_ThanhHoa'), (N'Manager_NgheAn'), (N'Manager_HaTinh')
    ) AS m(ManagerUsername)
    CROSS JOIN (VALUES
        (1, N'Thanh Hóa'), (2, N'Nghệ An'), (3, N'Hà Tĩnh')
    ) AS s(StoreKey, StoreName)
    LEFT JOIN [Security].[UserStoreAccess] AS a
       ON a.DatabaseUserName = m.ManagerUsername
      AND a.StoreKey = s.StoreKey
    ORDER BY m.ManagerUsername, s.StoreKey;
END;

GO
GRANT EXECUTE ON [Security].[usp_GetManagerStoreAccess] TO [PortalAdminRole] AS [dbo]
GO
/****** Object:  StoredProcedure [Security].[usp_OffboardUser]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
/* ---------- A2. Nâng cấp usp_OffboardUser: thêm lý do để ghi vào nhật ký (các lệnh gọi cũ vẫn chạy) ---------- */
CREATE   PROCEDURE [Security].[usp_OffboardUser]
    @UserName sysname, @Reason nvarchar(300) = NULL
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    IF DATABASE_PRINCIPAL_ID(@UserName) IS NULL
        THROW 50010, N'Người dùng không tồn tại trong database.', 1;
    IF @UserName IN (N'dbo', N'guest', N'Portal_Service')
       OR EXISTS (SELECT 1 FROM sys.database_role_members rm
                  JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id AND r.name = N'PortalServiceRole'
                  JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id AND m.name = @UserName)
        THROW 50002, N'Tài khoản thuộc nhóm được bảo vệ.', 1;
 
    DECLARE @old nvarchar(400), @sql nvarchar(max), @login sysname, @kill nvarchar(max);
    SELECT @old = STRING_AGG(r.name, N', ')
    FROM sys.database_role_members rm
    JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
    JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
    WHERE m.name = @UserName;
    SELECT @login = sp.name
    FROM sys.database_principals dp JOIN sys.server_principals sp ON sp.sid = dp.sid
    WHERE dp.name = @UserName;
 
    BEGIN TRY
        BEGIN TRAN;
        SELECT @sql = STRING_AGG(CONVERT(nvarchar(max), N'ALTER ROLE ' + QUOTENAME(r.name) + N' DROP MEMBER ' + QUOTENAME(@UserName) + N';'), N' ')
        FROM sys.database_role_members rm
        JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
        JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
        WHERE m.name = @UserName;
        IF @sql IS NOT NULL EXEC (@sql);
        IF @login IS NOT NULL
        BEGIN
            SET @sql = N'ALTER LOGIN ' + QUOTENAME(@login) + N' DISABLE;';
            EXEC (@sql);
        END
        INSERT Security.AccountLog (ActionType, TargetUser, OldRole, Detail)
        VALUES (N'OFFBOARD', @UserName, @old, ISNULL(@Reason, N'Gỡ mọi vai trò, vô hiệu hóa login, ngắt phiên đang mở'));
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
 
    IF @login IS NOT NULL
    BEGIN
        SELECT @kill = STRING_AGG(CONVERT(nvarchar(max), N'KILL ' + CONVERT(nvarchar(10), session_id) + N';'), N' ')
        FROM sys.dm_exec_sessions
        WHERE login_name = @login AND is_user_process = 1 AND session_id <> @@SPID;
        IF @kill IS NOT NULL EXEC (@kill);
    END
END;
GO
DENY EXECUTE ON [Security].[usp_OffboardUser] TO [AuditAdminRole] AS [dbo]
GO
DENY EXECUTE ON [Security].[usp_OffboardUser] TO [CustomerStaffRole] AS [dbo]
GO
DENY EXECUTE ON [Security].[usp_OffboardUser] TO [PortalServiceRole] AS [dbo]
GO
DENY EXECUTE ON [Security].[usp_OffboardUser] TO [StoreManagerRole] AS [dbo]
GO
/****** Object:  StoredProcedure [Security].[usp_OnboardUser]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/* ---------- B. Ba thủ tục của quy trình và một thủ tục kiểm tra quyền ---------- */
 
-- B1. Vào làm: tạo login, tạo user, gán vào MỘT vai trò nghiệp vụ
CREATE   PROCEDURE [Security].[usp_OnboardUser]
    @UserName sysname, @Password nvarchar(128), @RoleName sysname
AS
BEGIN
    SET NOCOUNT ON; SET XACT_ABORT ON;
    IF @RoleName NOT IN (N'StoreManagerRole', N'CustomerStaffRole', N'AuditAdminRole')
        THROW 50001, N'Vai trò không được phép cấp qua thủ tục này.', 1;
    IF @UserName IS NULL OR LEN(@UserName) = 0 OR @UserName LIKE N'%[^A-Za-z0-9_]%'
       OR @UserName IN (N'dbo', N'guest', N'sa', N'Portal_Service')
        THROW 50002, N'Tên tài khoản không hợp lệ hoặc thuộc nhóm được bảo vệ.', 1;
    IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @UserName) OR DATABASE_PRINCIPAL_ID(@UserName) IS NOT NULL
        THROW 50003, N'Tên tài khoản đã tồn tại.', 1;
 
    DECLARE @sql nvarchar(max);
    BEGIN TRY
        BEGIN TRAN;
        SET @sql = N'CREATE LOGIN ' + QUOTENAME(@UserName) + N' WITH PASSWORD = N''' + REPLACE(@Password, '''', '''''')
                 + N''', CHECK_POLICY = ON, CHECK_EXPIRATION = ON, DEFAULT_DATABASE = MiniMart_DataWarehouse;';
        EXEC (@sql);
        SET @sql = N'CREATE USER ' + QUOTENAME(@UserName) + N' FOR LOGIN ' + QUOTENAME(@UserName) + N';';
        EXEC (@sql);
        SET @sql = N'ALTER ROLE ' + QUOTENAME(@RoleName) + N' ADD MEMBER ' + QUOTENAME(@UserName) + N';';
        EXEC (@sql);
        INSERT Security.AccountLog (ActionType, TargetUser, NewRole, Detail)
        VALUES (N'ONBOARD', @UserName, @RoleName, N'Tạo login và user, gán vai trò');
        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO
DENY EXECUTE ON [Security].[usp_OnboardUser] TO [AuditAdminRole] AS [dbo]
GO
DENY EXECUTE ON [Security].[usp_OnboardUser] TO [CustomerStaffRole] AS [dbo]
GO
DENY EXECUTE ON [Security].[usp_OnboardUser] TO [PortalServiceRole] AS [dbo]
GO
DENY EXECUTE ON [Security].[usp_OnboardUser] TO [StoreManagerRole] AS [dbo]
GO
/****** Object:  StoredProcedure [Security].[usp_PortalGetDecryptedCustomers]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Security].[usp_PortalGetDecryptedCustomers]
    @MaxRows INT = 200,
    @SearchPattern NVARCHAR(220) = NULL
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;

    -- Defense-in-depth: Only the actual SQL login Portal_Admin can invoke.
    -- Under EXECUTE AS OWNER, USER_NAME() is dbo; use ORIGINAL_LOGIN().
    IF ORIGINAL_LOGIN() COLLATE Latin1_General_100_CI_AS <> N'Portal_Admin'
        THROW 54001, N'Forbidden: actual Portal_Admin login required.', 1;
    IF @MaxRows IS NULL OR @MaxRows < 1 OR @MaxRows > 200
        THROW 54002, N'Invalid max rows.', 1;
    IF @SearchPattern IS NOT NULL AND LEN(@SearchPattern) > 220
        THROW 54003, N'Invalid search pattern.', 1;

    BEGIN TRY
        OPEN SYMMETRIC KEY Key_MiniMart_Customer
            DECRYPTION BY CERTIFICATE Cert_MiniMart_Encryption;

        -- Fail closed if ciphertext exists but the authorized key cannot recover it.
        IF EXISTS
        (
            SELECT 1 FROM dbo.Dim_Customer
            WHERE Phone_Encrypted IS NULL
               OR Email_Encrypted IS NULL
               OR DECRYPTBYKEY(Phone_Encrypted) IS NULL
               OR DECRYPTBYKEY(Email_Encrypted) IS NULL
        )
            THROW 54004, N'Encrypted customer data is missing or cannot be decrypted.', 1;

        SELECT TOP (@MaxRows)
            CustomerKey, CustomerID, CustomerName, Address,
            CONVERT(NVARCHAR(20), DECRYPTBYKEY(Phone_Encrypted)) AS Phone,
            CONVERT(NVARCHAR(150), DECRYPTBYKEY(Email_Encrypted)) AS Email
        FROM dbo.Dim_Customer
        WHERE @SearchPattern IS NULL
           OR REPLACE(REPLACE(CustomerName, N'Đ', N'D'), N'đ', N'd')
                COLLATE Latin1_General_100_CI_AI LIKE @SearchPattern ESCAPE N'~'
           OR CustomerID COLLATE Latin1_General_100_CI_AI
                LIKE @SearchPattern ESCAPE N'~'
        ORDER BY CustomerKey;

        CLOSE SYMMETRIC KEY Key_MiniMart_Customer;
    END TRY
    BEGIN CATCH
        IF EXISTS (SELECT 1 FROM sys.openkeys
                   WHERE key_name = N'Key_MiniMart_Customer')
            CLOSE SYMMETRIC KEY Key_MiniMart_Customer;
        THROW;
    END CATCH;
END;

GO
GRANT EXECUTE ON [Security].[usp_PortalGetDecryptedCustomers] TO [Portal_Admin] AS [dbo]
GO
/****** Object:  StoredProcedure [Security].[usp_PortalTransferBusinessRole]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [Security].[usp_PortalTransferBusinessRole]
    @TargetUser SYSNAME,
    @ExpectedOldRole SYSNAME,
    @NewRole SYSNAME
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF ORIGINAL_LOGIN() <> N'Portal_Admin'
        THROW 53710, N'Chi SQL Login Portal_Admin duoc goi.', 1;
    IF @TargetUser IS NULL OR @TargetUser <> N'RBAC_Test_01'
        THROW 53711, N'Chi duoc chuyen tai khoan thu nghiem RBAC_Test_01.', 1;
    IF @ExpectedOldRole IS NULL OR @NewRole IS NULL
       OR @ExpectedOldRole NOT IN (N'CustomerStaffRole', N'AuditAdminRole')
       OR @NewRole NOT IN (N'CustomerStaffRole', N'AuditAdminRole')
       OR @ExpectedOldRole = @NewRole
        THROW 53712, N'Chi ho tro chuyen Staff/Audit.', 1;
    IF NOT EXISTS (SELECT 1 FROM sys.database_principals u
                   WHERE u.name=@TargetUser AND u.type='S' AND u.authentication_type=1)
        THROW 53713, N'Tai khoan phai la SQL user hop le.', 1;
    -- Validate mapped server Login identity using SID resolution.
    -- EXECUTE AS OWNER may not see sys.server_principals metadata.
    IF NOT EXISTS (
        SELECT 1
        FROM sys.database_principals AS u
        WHERE u.name = @TargetUser
          AND SUSER_SNAME(u.sid) = @TargetUser
    )
        THROW 53716, N'SQL User test khong map dung SQL Login cung ten.', 1;
    -- Additional immutable guard for all 5 demo users plus system identities.
    IF EXISTS (
        SELECT 1 FROM sys.database_principals AS target
        JOIN sys.database_principals AS protected ON protected.sid = target.sid
        WHERE target.name = @TargetUser
          AND protected.name IN (
              N'Manager_ThanhHoa', N'Manager_NgheAn', N'Manager_HaTinh',
              N'Staff_Customer', N'Audit_Admin',
              N'Portal_Admin', N'Portal_Service'
          )
    )
        THROW 53720, N'SID thuoc danh tinh demo/he thong duoc bao ve.', 1;
    IF EXISTS (SELECT 1 FROM Security.UserStoreAccess WHERE DatabaseUserName=@TargetUser)
        THROW 53717, N'Tai khoan test co phan cong chi nhanh: dung va kiem tra.', 1;
    -- Khong chuyen cac user co GRANT/DENY rieng, ngoai CONNECT co ban.
    IF EXISTS (SELECT 1 FROM sys.database_permissions p
               JOIN sys.database_principals u ON u.principal_id=p.grantee_principal_id
               WHERE u.name=@TargetUser
                 AND NOT (p.class=0 AND p.permission_name=N'CONNECT' AND p.state='G'))
        THROW 53718, N'Tai khoan test co quyen rieng: dung va kiem tra.', 1;
    -- Serialise all requests through this wrapper for the same target.
    DECLARE @lock_result int;
    EXEC @lock_result = sys.sp_getapplock
        @Resource=N'MiniMart.RoleTransfer.Test', @LockMode=N'Exclusive',
        @LockOwner=N'Session', @LockTimeout=5000;
    IF @lock_result < 0 THROW 53719, N'Khong the khoa chuyen vai tro: thu lai.', 1;
    BEGIN TRY
        IF (SELECT COUNT_BIG(*) FROM sys.database_role_members rm
            JOIN sys.database_principals u ON u.principal_id=rm.member_principal_id
            WHERE u.name=@TargetUser) <> 1
            THROW 53714, N'Tai khoan co vai tro khac: dung va kiem tra.', 1;
        IF NOT EXISTS (SELECT 1 FROM sys.database_role_members rm
            JOIN sys.database_principals u ON u.principal_id=rm.member_principal_id
            JOIN sys.database_principals r ON r.principal_id=rm.role_principal_id
            WHERE u.name=@TargetUser AND r.name=@ExpectedOldRole)
            THROW 53715, N'Vai tro da thay doi: tai lai danh sach.', 1;
        EXEC Security.usp_TransferUser @UserName=@TargetUser, @NewRole=@NewRole;
        EXEC sys.sp_releaseapplock @Resource=N'MiniMart.RoleTransfer.Test', @LockOwner=N'Session';
    END TRY
    BEGIN CATCH
        EXEC sys.sp_releaseapplock @Resource=N'MiniMart.RoleTransfer.Test', @LockOwner=N'Session';
        THROW;
    END CATCH;
END;

GO
GRANT EXECUTE ON [Security].[usp_PortalTransferBusinessRole] TO [PortalAdminRole] AS [dbo]
GO
/****** Object:  StoredProcedure [Security].[usp_ReviewDormantAccounts]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
/* ---------- A5. LỚP 3 - RÀ SOÁT: chỉ liệt kê tài khoản lâu không đăng nhập qua cổng, KHÔNG tự thu hồi ---------- */
CREATE   PROCEDURE [Security].[usp_ReviewDormantAccounts]
    @Days int = 30
AS
BEGIN
    SET NOCOUNT ON;
    SELECT m.name AS [Tài khoản],
           STRING_AGG(r.name, N', ') AS [Vai trò],
           MAX(DATEADD(HOUR, 7, l.LogTimeUtc)) AS [Lần đăng nhập cổng gần nhất (giờ VN)],
           CASE WHEN MAX(l.LogTimeUtc) IS NULL THEN NULL ELSE DATEDIFF(DAY, MAX(l.LogTimeUtc), SYSUTCDATETIME()) END AS [Số ngày không đăng nhập],
           CASE WHEN MAX(l.LogTimeUtc) IS NULL THEN N'Chưa từng đăng nhập qua cổng'
                ELSE N'Quá ' + CONVERT(nvarchar(10), @Days) + N' ngày không đăng nhập' END AS [Dấu hiệu],
           N'Chỉ để người duyệt xem xét, không tự thu hồi' AS [Ghi chú]
    FROM sys.database_role_members rm
    JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
         AND r.name IN (N'StoreManagerRole', N'CustomerStaffRole', N'AuditAdminRole')
    JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
    LEFT JOIN Security.AuthLog l ON l.UserName = m.name AND l.EventType = N'LOGIN_OK'
    GROUP BY m.name
    HAVING MAX(l.LogTimeUtc) IS NULL OR MAX(l.LogTimeUtc) < DATEADD(DAY, -@Days, SYSUTCDATETIME())
    ORDER BY m.name;
END;
GO
DENY EXECUTE ON [Security].[usp_ReviewDormantAccounts] TO [AuditAdminRole] AS [dbo]
GO
DENY EXECUTE ON [Security].[usp_ReviewDormantAccounts] TO [CustomerStaffRole] AS [dbo]
GO
DENY EXECUTE ON [Security].[usp_ReviewDormantAccounts] TO [PortalServiceRole] AS [dbo]
GO
DENY EXECUTE ON [Security].[usp_ReviewDormantAccounts] TO [StoreManagerRole] AS [dbo]
GO
/****** Object:  StoredProcedure [Security].[usp_SetManagerStoreAccess]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [Security].[usp_SetManagerStoreAccess]
    @ManagerUsername SYSNAME,
    @StoreKey INT,
    @Action VARCHAR(6)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Khong chap nhan dich vu Portal_Service hoac tai khoan Manager goi truc tiep.
    -- Website phai ket noi SQL bang dung SQL Login cua Portal_Admin khi goi thu tuc.
    IF ORIGINAL_LOGIN() <> N'Portal_Admin'
       OR ISNULL(IS_ROLEMEMBER(N'PortalAdminRole'), 0) <> 1
        THROW 51010, 'Chi Portal_Admin co quyen thay doi phan cong chi nhanh.', 1;

    IF @ManagerUsername IS NULL OR @ManagerUsername NOT IN
        (N'Manager_ThanhHoa', N'Manager_NgheAn', N'Manager_HaTinh')
        THROW 51011, 'Chi duoc thao tac 3 tai khoan Manager duoc phep.', 1;

    IF DATABASE_PRINCIPAL_ID(@ManagerUsername) IS NULL
        THROW 51012, 'Tai khoan Manager khong ton tai trong database.', 1;

    IF @StoreKey IS NULL OR @StoreKey NOT IN (1, 2, 3)
        THROW 51013, 'Ma chi nhanh khong hop le.', 1;

    IF @Action IS NULL OR @Action NOT IN ('GRANT','REVOKE')
        THROW 51014, 'Thao tac phai la GRANT hoac REVOKE.', 1;

    DECLARE @DataChanged BIT = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @Action = 'GRANT'
        BEGIN
            -- Khoa pham vi hang de tranh cap trung neu co nhieu yeu cau dong thoi.
            IF NOT EXISTS
            (
                SELECT 1
                FROM [Security].[UserStoreAccess] WITH (UPDLOCK, HOLDLOCK)
                WHERE DatabaseUserName = @ManagerUsername
                  AND StoreKey = @StoreKey
            )
            BEGIN
                INSERT INTO [Security].[UserStoreAccess]
                    (DatabaseUserName, StoreKey)
                VALUES (@ManagerUsername, @StoreKey);
                SET @DataChanged = 1;
            END;
        END
        ELSE
        BEGIN
            DELETE FROM [Security].[UserStoreAccess]
            WHERE DatabaseUserName = @ManagerUsername
              AND StoreKey = @StoreKey;
            IF @@ROWCOUNT > 0 SET @DataChanged = 1;
        END;

        -- Lich su duoc ghi trong CUNG transaction voi thay doi phan quyen.
        INSERT INTO [Security].[StoreAccessChangeLog]
            (ActorLogin, TargetManager, StoreKey, ActionName, DataChanged)
        VALUES
            (ORIGINAL_LOGIN(), @ManagerUsername, @StoreKey, @Action, @DataChanged);

        COMMIT TRANSACTION;

        SELECT
            @ManagerUsername AS TaiKhoan,
            @StoreKey AS ChiNhanh,
            @Action AS ThaoTac,
            @DataChanged AS CoThayDoi;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;

GO
GRANT EXECUTE ON [Security].[usp_SetManagerStoreAccess] TO [PortalAdminRole] AS [dbo]
GO
/****** Object:  StoredProcedure [Security].[usp_SyncOffboarding]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
/* ---------- A4. LỚP 2 - DỰ PHÒNG: đối chiếu bảng nhân sự với tài khoản và thu hồi các trường hợp bị sót ----------
   @WhatIf = 1 (mặc định): chỉ LIỆT KÊ tài khoản lệch, chưa làm gì.  @WhatIf = 0: thu hồi các tài khoản đó. */
CREATE   PROCEDURE [Security].[usp_SyncOffboarding]
    @WhatIf bit = 1, @AsOfDate date = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET @AsOfDate = ISNULL(@AsOfDate, CAST(SYSDATETIME() AS date));
    DECLARE @c TABLE (EmployeeCode varchar(10), FullName nvarchar(100), UserName sysname, LyDo nvarchar(200), KetQua nvarchar(400) NULL);
 
    INSERT @c (EmployeeCode, FullName, UserName, LyDo)
    SELECT e.EmployeeCode, e.FullName, e.DbUserName,
           CASE WHEN e.Status = 'RESIGNED' THEN N'Nhân sự báo đã nghỉ nhưng tài khoản còn quyền'
                ELSE N'Hợp đồng hết hạn ' + CONVERT(nvarchar(10), e.ContractEndDate, 23) + N' nhưng tài khoản còn quyền' END
    FROM HR.Employee e
    JOIN sys.database_principals dp ON dp.name = e.DbUserName
    LEFT JOIN sys.server_principals sp ON sp.sid = dp.sid
    WHERE (e.Status = 'RESIGNED' OR e.ContractEndDate < @AsOfDate)
      AND (EXISTS (SELECT 1 FROM sys.database_role_members rm WHERE rm.member_principal_id = dp.principal_id)
           OR ISNULL(sp.is_disabled, 0) = 0);
 
    IF @WhatIf = 0
    BEGIN
        DECLARE @u sysname, @reason nvarchar(300);
        DECLARE cs CURSOR LOCAL STATIC FOR SELECT UserName, LyDo FROM @c;
        OPEN cs; FETCH NEXT FROM cs INTO @u, @reason;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            BEGIN TRY
                SET @reason = N'Tự động (đồng bộ): ' + @reason;
                EXEC Security.usp_OffboardUser @UserName = @u, @Reason = @reason;
                UPDATE @c SET KetQua = N'Đã thu hồi' WHERE UserName = @u;
            END TRY
            BEGIN CATCH
                UPDATE @c SET KetQua = N'LỖI: ' + LEFT(ERROR_MESSAGE(), 300) WHERE UserName = @u;
            END CATCH
            FETCH NEXT FROM cs INTO @u, @reason;
        END
        CLOSE cs; DEALLOCATE cs;
    END
 
    SELECT EmployeeCode AS [Mã NV], FullName AS [Họ tên], UserName AS [Tài khoản], LyDo AS [Lệch phát hiện],
           CASE WHEN @WhatIf = 1 THEN N'Chưa xử lý (chế độ xem trước)' ELSE KetQua END AS [Kết quả]
    FROM @c ORDER BY EmployeeCode;
END;
GO
DENY EXECUTE ON [Security].[usp_SyncOffboarding] TO [AuditAdminRole] AS [dbo]
GO
DENY EXECUTE ON [Security].[usp_SyncOffboarding] TO [CustomerStaffRole] AS [dbo]
GO
DENY EXECUTE ON [Security].[usp_SyncOffboarding] TO [PortalServiceRole] AS [dbo]
GO
DENY EXECUTE ON [Security].[usp_SyncOffboarding] TO [StoreManagerRole] AS [dbo]
GO
/****** Object:  StoredProcedure [Security].[usp_TransferUser]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [Security].[usp_TransferUser]
    @UserName SYSNAME,
    @NewRole  SYSNAME
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Quyen thay doi role duoc kiem tra tai CHINH SQL Server,
    -- khong chi dua vao menu hoac session Flask.
    IF ORIGINAL_LOGIN() <> N'Portal_Admin'
       OR NOT EXISTS
       (
            SELECT 1
            FROM sys.database_principals AS u
            JOIN sys.database_role_members AS rm
                ON rm.member_principal_id = u.principal_id
            JOIN sys.database_principals AS r
                ON r.principal_id = rm.role_principal_id
            WHERE u.name = N'Portal_Admin'
              AND r.name = N'PortalAdminRole'
       )
        THROW 51310, N'Chi SQL login Portal_Admin co quyen chuyen vai tro nghiep vu.', 1;

    IF @NewRole IS NULL
       OR @NewRole NOT IN (N'StoreManagerRole', N'CustomerStaffRole', N'AuditAdminRole')
        THROW 51311, N'Vai tro dich khong duoc phep.', 1;

    IF @UserName IS NULL OR @UserName IN
       (N'dbo', N'guest', N'Portal_Service', N'Portal_Admin')
        THROW 51312, N'Tai khoan thuoc nhom duoc bao ve.', 1;

    -- Chi thao tac tai khoan SQL User da ton tai, khong nhan role/nhom/nguoi dung he thong.
    IF NOT EXISTS
       (SELECT 1 FROM sys.database_principals
        WHERE name = @UserName AND type = 'S')
        THROW 51313, N'Tai khoan nghiep vu khong ton tai hoac khong hop le.', 1;

    -- Chan moi tai khoan co role quan tri hoac role co dinh quyen cao.
    IF EXISTS
    (
        SELECT 1
        FROM sys.database_role_members AS rm
        JOIN sys.database_principals AS r
             ON r.principal_id = rm.role_principal_id
        JOIN sys.database_principals AS u
             ON u.principal_id = rm.member_principal_id
        WHERE u.name = @UserName
          AND (r.name IN (N'PortalAdminRole', N'PortalServiceRole')
               OR r.is_fixed_role = 1)
    )
        THROW 51314, N'Khong duoc doi role cua tai khoan quyen cao.', 1;

    DECLARE @OldRole SYSNAME;
    DECLARE @BusinessRoleCount INT;
    SELECT @OldRole = MAX(r.name),
           @BusinessRoleCount = COUNT(*)
    FROM sys.database_role_members AS rm
    JOIN sys.database_principals AS r
         ON r.principal_id = rm.role_principal_id
    JOIN sys.database_principals AS u
         ON u.principal_id = rm.member_principal_id
    WHERE u.name = @UserName
      AND r.name IN (N'StoreManagerRole', N'CustomerStaffRole', N'AuditAdminRole');

    IF ISNULL(@BusinessRoleCount, 0) <> 1
        THROW 51315, N'Tai khoan phai thuoc dung mot vai tro nghiep vu hien tai.', 1;
    IF @OldRole = @NewRole
        THROW 51316, N'Tai khoan da thuoc vai tro nay.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @sql NVARCHAR(MAX);
        SET @sql = N'ALTER ROLE ' + QUOTENAME(@OldRole)
                 + N' DROP MEMBER ' + QUOTENAME(@UserName) + N';';
        EXEC sys.sp_executesql @sql;

        SET @sql = N'ALTER ROLE ' + QUOTENAME(@NewRole)
                 + N' ADD MEMBER ' + QUOTENAME(@UserName) + N';';
        EXEC sys.sp_executesql @sql;

        -- Neu roi role Manager, thu hoi phan cong chi nhanh cu de khong de lai quyen an.
        -- Log tung thu hoi trong cung transaction voi chuyen role.
        IF @OldRole = N'StoreManagerRole' AND @NewRole <> N'StoreManagerRole'
        BEGIN
            DECLARE @RemovedStores TABLE (StoreKey INT NOT NULL);

            DELETE FROM [Security].[UserStoreAccess]
                OUTPUT DELETED.StoreKey INTO @RemovedStores(StoreKey)
            WHERE DatabaseUserName = @UserName;

            INSERT INTO [Security].[StoreAccessChangeLog]
                (ActorLogin, TargetManager, StoreKey, ActionName, DataChanged)
            SELECT ORIGINAL_LOGIN(), @UserName, StoreKey, 'REVOKE', 1
            FROM @RemovedStores;
        END;

        -- Giu co che nhat ky AccountLog dang co cua BTL.
        INSERT INTO [Security].[AccountLog]
            (ActionType, TargetUser, OldRole, NewRole, Detail)
        VALUES
            (N'TRANSFER', @UserName, @OldRole, @NewRole,
             N'Chuyen vai tro; thu hoi chi nhanh cu neu roi Manager');

        COMMIT TRANSACTION;

        SELECT @UserName AS TaiKhoan,
               @OldRole AS VaiTroCu,
               @NewRole AS VaiTroMoi;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;

GO
DENY EXECUTE ON [Security].[usp_TransferUser] TO [AuditAdminRole] AS [dbo]
GO
DENY EXECUTE ON [Security].[usp_TransferUser] TO [CustomerStaffRole] AS [dbo]
GO
GRANT EXECUTE ON [Security].[usp_TransferUser] TO [PortalAdminRole] AS [dbo]
GO
DENY EXECUTE ON [Security].[usp_TransferUser] TO [PortalServiceRole] AS [dbo]
GO
DENY EXECUTE ON [Security].[usp_TransferUser] TO [StoreManagerRole] AS [dbo]
GO
/****** Object:  StoredProcedure [Security].[usp_WriteAuditLog]    Script Date: 11/17/2026 10:07:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   PROCEDURE [Security].[usp_WriteAuditLog]
    @ActionName NVARCHAR(100),
    @ObjectName NVARCHAR(200) = NULL,
    @ActionStatus NVARCHAR(30),
    @Details NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Security.AuditLog
    (
        DatabaseUser,
        ActionName,
        ObjectName,
        ActionStatus,
        Details
    )
    VALUES
    (
        USER_NAME(),
        @ActionName,
        @ObjectName,
        @ActionStatus,
        @Details
    );
END;
GO
GRANT EXECUTE ON [Security].[usp_WriteAuditLog] TO [AuditAdminRole] AS [dbo]
GO
USE [master]
GO
ALTER DATABASE [MiniMart_DataWarehouse] SET  READ_WRITE 
GO
