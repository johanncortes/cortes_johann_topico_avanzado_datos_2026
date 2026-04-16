--Johann Cortés Farias
--Topicos Avanzados de Datos

--Ejercicio 1
CREATE OR REPLACE PROCEDURE aumentar_precio_producto (
    p_producto_id IN NUMBER,
    p_porcentaje_aumento IN NUMBER
)
IS
    e_producto_no_existe EXCEPTION;
BEGIN
    UPDATE Productos
    SET Precio = Precio * (1 + (p_porcentaje_aumento / 100))
    WHERE ProductoID = p_producto_id;

    IF SQL%NOTFOUND THEN
        RAISE e_producto_no_existe;
    END IF;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Éxito: Precio actualizado para el ProductoID ' || p_producto_id);
EXCEPTION
    WHEN e_producto_no_existe THEN
        DBMS_OUTPUT.PUT_LINE('Error: El producto con ID ' || p_producto_id || ' no existe en la base de datos.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
        ROLLBACK;
END;
/

--Ejercicio 2
CREATE OR REPLACE PROCEDURE contar_pedidos_cliente (
    p_cliente_id IN NUMBER,
    p_cantidad_pedidos OUT NUMBER
)
IS
BEGIN
    SELECT COUNT(PedidoID)
    INTO p_cantidad_pedidos
    FROM Pedidos
    WHERE ClienteID = p_cliente_id;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
        p_cantidad_pedidos := -1;
END;
/