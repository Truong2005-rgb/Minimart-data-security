USE [master]
GO

/****** Object:  Audit [MiniMart_Audit]    Script Date: 11/17/2026 7:33:49 PM ******/
CREATE SERVER AUDIT [MiniMart_Audit]
TO FILE 
(	FILEPATH = N'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\Log\'
	,MAXSIZE = 10 MB
	,MAX_ROLLOVER_FILES = 5
	,RESERVE_DISK_SPACE = OFF
) WITH (QUEUE_DELAY = 1000, ON_FAILURE = CONTINUE, AUDIT_GUID = 'c6b7e92a-2d6e-424d-b802-01f0c8082406')
ALTER SERVER AUDIT [MiniMart_Audit] WITH (STATE = ON)
GO

