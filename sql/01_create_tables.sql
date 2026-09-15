-- PK obligatoria en ambas tablas: la requiere el merge de Datastream/BigQuery por fila.
USE retail_db;
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'customers' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.customers (
        customer_id   INT             NOT NULL PRIMARY KEY,
        full_name     NVARCHAR(200)   NOT NULL,
        email         NVARCHAR(200)   NOT NULL,
        country       NVARCHAR(100)   NULL,
        created_at    DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at    DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'orders' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.orders (
        order_id      INT             NOT NULL PRIMARY KEY,
        customer_id   INT             NOT NULL REFERENCES dbo.customers(customer_id),
        order_status  NVARCHAR(50)    NOT NULL,
        total_amount  DECIMAL(12, 2)  NOT NULL,
        created_at    DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at    DATETIME2       NOT NULL DEFAULT SYSUTCDATETIME()
    );
END
GO
