USE [MiniMart_DataWarehouse]
GO

CREATE DATABASE AUDIT SPECIFICATION [MiniMart_DB_AuditSpec]
FOR SERVER AUDIT [MiniMart_Audit]
ADD (DELETE ON OBJECT::[dbo].[Dim_Customer] BY [public]),
ADD (INSERT ON OBJECT::[dbo].[Dim_Customer] BY [public]),
ADD (SELECT ON OBJECT::[dbo].[Dim_Customer] BY [public]),
ADD (UPDATE ON OBJECT::[dbo].[Dim_Customer] BY [public]),
ADD (DELETE ON OBJECT::[dbo].[Fact_Sales] BY [public]),
ADD (INSERT ON OBJECT::[dbo].[Fact_Sales] BY [public]),
ADD (SELECT ON OBJECT::[dbo].[Fact_Sales] BY [public]),
ADD (UPDATE ON OBJECT::[dbo].[Fact_Sales] BY [public])
WITH (STATE = ON)
GO

