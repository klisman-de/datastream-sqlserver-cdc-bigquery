-- LOGIN datastream_user creado por Terraform (terraform/cloudsql.tf).
-- Ejecutar como admin sqlserver, no datastream_user.
USE retail_db;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'datastream_user')
BEGIN
    CREATE USER [datastream_user] FOR LOGIN [datastream_user];
END
GO

-- db_owner: requerido para leer metadata/cdc.*. db_denydatawriter: deniega escritura
-- (mínimo privilegio).
-- https://cloud.google.com/datastream/docs/configure-your-source-sql-server-database
EXEC sp_addrolemember 'db_owner', 'datastream_user';
EXEC sp_addrolemember 'db_denydatawriter', 'datastream_user';
GO

-- Verificación
SELECT dp.name AS user_name, r.name AS role_name
FROM sys.database_role_members drm
JOIN sys.database_principals dp ON dp.principal_id = drm.member_principal_id
JOIN sys.database_principals r  ON r.principal_id  = drm.role_principal_id
WHERE dp.name = 'datastream_user';
GO
