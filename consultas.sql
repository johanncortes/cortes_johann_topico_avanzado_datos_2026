--Johann Cortes Farias 
--Topicos Avanzado de datos

--Realice 2 sentencias SELECT simples
-- Consulta 1: Obtener el nombre y ciudad de los clientes que viven en 'Santiago'
SELECT Nombre, Ciudad 
FROM Clientes 
WHERE Ciudad = 'Santiago';

-- Consulta 2: Obtener los productos que cuestan más de 100
SELECT Nombre, Precio 
FROM Productos 
WHERE Precio > 100;

--Realice 2 sentencias SELECT utilizando funciones agregadas sobre su base de datos.
-- Consulta 1: Calcular el gasto total de cada cliente en sus pedidos
SELECT ClienteID, SUM(Total) AS Gasto_Total 
FROM Pedidos 
GROUP BY ClienteID;

-- Consulta 2: Contar cuántos clientes hay registrados por ciudad
SELECT Ciudad, COUNT(ClienteID) AS Numero_De_Clientes 
FROM Clientes 
GROUP BY Ciudad;

--Realice 2 sentencias SELECT utilizando expresiones regulares
-- Consulta 1: Buscar clientes cuyo nombre comience con la letra 'J' o 'A'
SELECT ClienteID, Nombre 
FROM Clientes 
WHERE REGEXP_LIKE(Nombre, '^(J|A)');

-- Consulta 2: Buscar productos cuyo nombre termine con la letra 'p' o 'e'
SELECT ProductoID, Nombre 
FROM Productos 
WHERE REGEXP_LIKE(Nombre, '(p|e)$');

--Crear dos vistas
-- Vista 1: Vista simple de clientes que viven en Santiago
CREATE OR REPLACE VIEW v_clientes_santiago AS
SELECT ClienteID, Nombre, FechaNacimiento
FROM Clientes
WHERE Ciudad = 'Santiago';

-- Vista 2: Vista que une Pedidos y Clientes para ver el nombre del cliente junto a su pedido
CREATE OR REPLACE VIEW v_resumen_pedidos AS
SELECT p.PedidoID, c.Nombre AS Nombre_Cliente, p.Total, p.FechaPedido
FROM Pedidos p
JOIN Clientes c ON p.ClienteID = c.ClienteID;

COMMIT;