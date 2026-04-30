-- SESIÓN 13: Gestión de Inventario con Savepoints
-- Autor: Johann Cortés Farias
--Topicos Avanzados de Datos
SET SERVEROUTPUT ON;

-- Crear tabla Inventario
CREATE TABLE Inventario (
	ProductoID NUMBER PRIMARY KEY,
	Cantidad NUMBER
);
INSERT INTO Inventario VALUES (1, 10);
INSERT INTO Inventario VALUES (2, 20);

-- Procedimiento
CREATE OR REPLACE PROCEDURE actualizar_inventario_pedido(p_pedido_id IN NUMBER) AS
	CURSOR detalle_cursor IS
    	SELECT ProductoID, Cantidad
    	FROM DetallesPedidos
    	WHERE PedidoID = p_pedido_id;
	v_cantidad_actual NUMBER;
BEGIN
	FOR detalle IN detalle_cursor LOOP
    	-- Verificar cantidad disponible
    	SELECT Cantidad INTO v_cantidad_actual
    	FROM Inventario
    	WHERE ProductoID = detalle.ProductoID;
   	 
    	SAVEPOINT antes_reducir;
   	 
    	IF v_cantidad_actual < detalle.Cantidad THEN
        	RAISE_APPLICATION_ERROR(-20001, 'No hay suficiente inventario para el producto ' || detalle.ProductoID);
    	END IF;
   	 
    	UPDATE Inventario
    	SET Cantidad = Cantidad - detalle.Cantidad
    	WHERE ProductoID = detalle.ProductoID;
   	 
    	DBMS_OUTPUT.PUT_LINE('Inventario actualizado para producto ' || detalle.ProductoID);
	END LOOP;
	COMMIT;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
    	DBMS_OUTPUT.PUT_LINE('Error: Producto no encontrado en inventario.');
    	ROLLBACK;
	WHEN OTHERS THEN
    	DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    	ROLLBACK TO antes_reducir;
    	COMMIT;
END;
/
-- Prueba
EXEC actualizar_inventario_pedido(108);

--Ejercicio 2: Diseña una tabla de hechos Fact_Pedidos y una dimensión Dim_Ciudad para un Data Warehouse basado en curso_topicos. Escribe una consulta analítica que muestre el total de ventas por ciudad y año.
-- Dimensión Ciudad
CREATE TABLE Dim_Ciudad (
	CiudadID NUMBER PRIMARY KEY,
	Ciudad VARCHAR2(50)
);
INSERT INTO Dim_Ciudad (CiudadID, Ciudad)
SELECT ROWNUM, Ciudad
FROM (SELECT DISTINCT Ciudad FROM Clientes);

-- Tabla de hechos (usando las dimensiones ya creadas)
CREATE TABLE Fact_Pedidos (
	PedidoID NUMBER,
	ClienteID NUMBER,
	CiudadID NUMBER,
	FechaID NUMBER,
	Total NUMBER,
	CONSTRAINT fk_pedido_cliente FOREIGN KEY (ClienteID) REFERENCES Dim_Cliente(ClienteID),
	CONSTRAINT fk_pedido_ciudad FOREIGN KEY (CiudadID) REFERENCES Dim_Ciudad(CiudadID),
	CONSTRAINT fk_pedido_tiempo FOREIGN KEY (FechaID) REFERENCES Dim_Tiempo(FechaID)
);
INSERT INTO Fact_Pedidos (PedidoID, ClienteID, CiudadID, FechaID, Total)
SELECT p.PedidoID, p.ClienteID, dc.CiudadID, dt.FechaID, p.Total
FROM Pedidos p
JOIN Clientes c ON p.ClienteID = c.ClienteID
JOIN Dim_Ciudad dc ON c.Ciudad = dc.Ciudad
JOIN Dim_Tiempo dt ON p.FechaPedido = dt.Fecha;

-- Consulta analítica
SELECT dc.Ciudad, dt.Año, SUM(fp.Total) AS TotalVentas
FROM Fact_Pedidos fp
JOIN Dim_Ciudad dc ON fp.CiudadID = dc.CiudadID
JOIN Dim_Tiempo dt ON fp.FechaID = dt.FechaID
GROUP BY dc.Ciudad, dt.Año;

