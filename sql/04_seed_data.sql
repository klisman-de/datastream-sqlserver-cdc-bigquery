-- Seed inicial, cargado antes del backfill_all de los streams.
USE retail_db;
GO

MERGE dbo.customers AS target
USING (VALUES
    (1, N'Ana Torres',    N'ana.torres@example.com',    N'PE'),
    (2, N'Bruno Silva',   N'bruno.silva@example.com',   N'BR'),
    (3, N'Carla Gómez',   N'carla.gomez@example.com',   N'CL'),
    (4, N'Diego Ramírez', N'diego.ramirez@example.com', N'PE'),
    (5, N'Elena Vargas',  N'elena.vargas@example.com',  N'MX')
) AS src (customer_id, full_name, email, country)
ON target.customer_id = src.customer_id
WHEN NOT MATCHED THEN
    INSERT (customer_id, full_name, email, country)
    VALUES (src.customer_id, src.full_name, src.email, src.country);
GO

MERGE dbo.orders AS target
USING (VALUES
    (100, 1, N'PENDING',  150.00),
    (101, 1, N'SHIPPED',   89.90),
    (102, 2, N'PENDING',  340.50),
    (103, 3, N'DELIVERED', 25.00),
    (104, 4, N'PENDING',  510.00),
    (105, 5, N'CANCELLED', 75.25)
) AS src (order_id, customer_id, order_status, total_amount)
ON target.order_id = src.order_id
WHEN NOT MATCHED THEN
    INSERT (order_id, customer_id, order_status, total_amount)
    VALUES (src.order_id, src.customer_id, src.order_status, src.total_amount);
GO
