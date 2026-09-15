-- Genera insert/update/delete para comparar merge vs append en BigQuery una vez los streams
-- estén RUNNING. merge: solo estado final. append: cada evento como fila separada.
USE retail_db;
GO

-- INSERT: cliente y pedido nuevos
INSERT INTO dbo.customers (customer_id, full_name, email, country)
VALUES (6, N'Fernanda López', N'fernanda.lopez@example.com', N'CO');

INSERT INTO dbo.orders (order_id, customer_id, order_status, total_amount)
VALUES (106, 6, N'PENDING', 220.00);
GO

-- UPDATE: cambia estado y timestamp de un pedido existente
UPDATE dbo.orders
SET order_status = N'DELIVERED',
    updated_at    = SYSUTCDATETIME()
WHERE order_id = 101;
GO

-- DELETE: elimina un pedido existente
DELETE FROM dbo.orders
WHERE order_id = 103;
GO
