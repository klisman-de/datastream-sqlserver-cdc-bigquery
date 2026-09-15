-- Ejecutar como admin sqlserver, no datastream_user.
-- sys.sp_cdc_enable_db bloqueado en Cloud SQL ("Sysadmin privileges required"); usa
-- msdb.dbo.gcloudsql_cdc_enable_db (https://cloud.google.com/sql/docs/sqlserver/replication/enable-cdc).
USE retail_db;
GO

IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = DB_NAME() AND is_cdc_enabled = 1)
BEGIN
    EXEC msdb.dbo.gcloudsql_cdc_enable_db 'retail_db';
END
GO

-- role_name = NULL: sin restricción de rol.
IF NOT EXISTS (
    SELECT 1 FROM cdc.change_tables ct
    JOIN sys.tables t ON t.object_id = ct.source_object_id
    WHERE t.name = 'customers'
)
BEGIN
    EXEC sys.sp_cdc_enable_table
        @source_schema = N'dbo',
        @source_name   = N'customers',
        @role_name     = NULL,
        @supports_net_changes = 1;
END
GO

IF NOT EXISTS (
    SELECT 1 FROM cdc.change_tables ct
    JOIN sys.tables t ON t.object_id = ct.source_object_id
    WHERE t.name = 'orders'
)
BEGIN
    EXEC sys.sp_cdc_enable_table
        @source_schema = N'dbo',
        @source_name   = N'orders',
        @role_name     = NULL,
        @supports_net_changes = 1;
END
GO

-- Default 5s: sp_cdc_change_job no hace falta.

-- Verificación
SELECT name, is_cdc_enabled FROM sys.databases WHERE name = DB_NAME();
SELECT s.name AS schema_name, t.name AS table_name, is_tracked_by_cdc
FROM sys.tables t
JOIN sys.schemas s ON s.schema_id = t.schema_id
WHERE t.name IN ('customers', 'orders');
GO
