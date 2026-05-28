-- Sesion 16: Optimización de Consultas y analisis de planes de ejecución
-- Johann Cortes Farias
-- Topicos Avanzados de Datos

-- Ejercicio 1: Analiza el plan de ejecución de la siguiente consulta y optimízala 
-- para que use índices y particiones.
SELECT c.Nombre, COUNT(p.PedidoID) AS TotalPedidos
FROM Clientes c, Pedidos p
WHERE c.ClienteID = p.ClienteID
AND c.Ciudad = 'Santiago'
AND p.FechaPedido >= TO_DATE('2025-03-01', 'YYYY-MM-DD')
GROUP BY c.Nombre;

-- Plan de ejecución inicial
EXPLAIN PLAN FOR
SELECT c.Nombre, COUNT(p.PedidoID) AS TotalPedidos
FROM Clientes c, Pedidos p
WHERE c.ClienteID = p.ClienteID
AND c.Ciudad = 'Santiago'
AND p.FechaPedido >= TO_DATE('2025-03-01', 'YYYY-MM-DD')
GROUP BY c.Nombre;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Optimizar: Asegurarse de que existan índices
CREATE INDEX idx_clientes_ciudad ON Clientes(Ciudad);

-- Consulta optimizada
EXPLAIN PLAN FOR
SELECT /*+ INDEX(c idx_clientes_ciudad) INDEX(p idx_pedidos_clienteid) */
   	c.Nombre, COUNT(p.PedidoID) AS TotalPedidos
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID
WHERE c.Ciudad = 'Santiago'
AND p.FechaPedido >= TO_DATE('2025-03-01', 'YYYY-MM-DD')
GROUP BY c.Nombre;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Ejecutar consulta
SELECT c.Nombre, COUNT(p.PedidoID) AS TotalPedidos
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID
WHERE c.Ciudad = 'Santiago'
AND p.FechaPedido >= TO_DATE('2025-03-01', 'YYYY-MM-DD')
GROUP BY c.Nombre;


-- Ejercicio 2: Optimiza la siguiente consulta para evitar un FULL TABLE SCAN 
-- en DetallesPedidos y analiza el plan de ejecución antes y 
-- después de la optimización.

SELECT p.Nombre, SUM(dp.Cantidad * p.Precio) AS TotalVentas
FROM Productos p, DetallesPedidos dp
WHERE p.ProductoID = dp.ProductoID
GROUP BY p.Nombre;

-- Plan de ejecución inicial
EXPLAIN PLAN FOR
SELECT p.Nombre, SUM(dp.Cantidad * p.Precio) AS TotalVentas
FROM Productos p, DetallesPedidos dp
WHERE p.ProductoID = dp.ProductoID
GROUP BY p.Nombre;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Optimizar: Usar índice existente o crear uno nuevo
-- (idx_detalles_productoid ya fue creado en el ejemplo práctico)
EXPLAIN PLAN FOR
SELECT /*+ INDEX(dp idx_detalles_productoid) */
   	p.Nombre, SUM(dp.Cantidad * p.Precio) AS TotalVentas
FROM Productos p
JOIN DetallesPedidos dp ON p.ProductoID = dp.ProductoID
GROUP BY p.Nombre;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Ejecutar consulta
SELECT p.Nombre, SUM(dp.Cantidad * p.Precio) AS TotalVentas
FROM Productos p
JOIN DetallesPedidos dp ON p.ProductoID = dp.ProductoID
GROUP BY p.Nombre;
