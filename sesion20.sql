--Sesion 20: Repaso para la prueba N°2
-- Johann Cortes Farias
-- Topicos Avanzados de Datos
-- Ejercicio 1: Crea un procedimiento actualizar_precios_por_categoria que reciba un porcentaje de aumento (parámetro IN) y aplique el aumento solo a productos cuyo precio promedio por pedido (calculado con una función) sea mayor a 500. 
-- Usa un cursor para iterar sobre los productos.

-- Función para calcular el precio promedio por pedido
CREATE OR REPLACE FUNCTION precio_promedio_por_pedido(p_producto_id IN NUMBER) RETURN NUMBER AS
	v_promedio NUMBER;
BEGIN
	SELECT AVG(p.Precio * d.Cantidad) INTO v_promedio
	FROM DetallesPedidos d JOIN Productos p ON d.ProductoID = p.ProductoID
	WHERE d.ProductoID = p_producto_id;
	RETURN NVL(v_promedio, 0);
END;
/
-- Procedimiento
CREATE OR REPLACE PROCEDURE actualizar_precios_por_categoria(p_porcentaje IN NUMBER) AS
	CURSOR producto_cursor IS
    	SELECT ProductoID, Precio
    	FROM Productos;
BEGIN
	FOR producto IN producto_cursor LOOP
    	IF precio_promedio_por_pedido(producto.ProductoID) > 500 THEN
        	UPDATE Productos
        	SET Precio = producto.Precio * (1 + p_porcentaje / 100)
        	WHERE ProductoID = producto.ProductoID;
        	DBMS_OUTPUT.PUT_LINE('Producto ' || producto.ProductoID || ' actualizado.');
    	END IF;
	END LOOP;
	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
    	DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    	ROLLBACK;
END;
/
-- Prueba
EXEC actualizar_precios_por_categoria(10);

-- Ejercicio 2: Crea un trigger auditar_eliminacion_pedido que se dispare después de eliminar un pedido y registre el PedidoID, 
-- ClienteID, Total y la fecha de eliminación en una tabla de auditoría AuditoriaPedidos.
-- Crear tabla de auditoría
CREATE TABLE AuditoriaPedidos (
	AuditoriaID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	PedidoID NUMBER,
	ClienteID NUMBER,
	Total NUMBER,
	FechaEliminacion DATE
);
-- Crear trigger
CREATE OR REPLACE TRIGGER auditar_eliminacion_pedido
AFTER DELETE ON Pedidos
FOR EACH ROW
BEGIN
	INSERT INTO AuditoriaPedidos (PedidoID, ClienteID, Total, FechaEliminacion)
	VALUES (:OLD.PedidoID, :OLD.ClienteID, :OLD.Total, SYSDATE);
END;
/
-- Prueba
DELETE FROM Pedidos WHERE PedidoID = 102;
SELECT * FROM AuditoriaPedidos;