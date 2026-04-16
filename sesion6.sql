-- Johann Cortés Farias
-- Topicos Avanzados De Datos

--Ejercicio 1
DECLARE
    -- Declaración del cursor explícito
    CURSOR c_productos IS
        SELECT Nombre, Precio
        FROM Productos
        ORDER BY Precio DESC;
  
    v_nombre Productos.Nombre%TYPE;
    v_precio Productos.Precio%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Listado de Productos Ordenados por Precio');
    
    OPEN c_productos;
    LOOP
        FETCH c_productos INTO v_nombre, v_precio;
        EXIT WHEN c_productos%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Producto: ' || v_nombre || ' | Precio: $' || v_precio);
    END LOOP;
    CLOSE c_productos;
END;
/

--Ejercicio 2
DECLARE
    CURSOR c_pedidos_cliente(p_cliente_id NUMBER) IS
        SELECT PedidoID, Total
        FROM Pedidos
        WHERE ClienteID = p_cliente_id
        FOR UPDATE OF Total;

    v_nuevo_total Pedidos.Total%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Actualización de Totales (Aumento del 10%)');
    FOR r_pedido IN c_pedidos_cliente(1) LOOP
        -- Calculamos el nuevo total
        v_nuevo_total := r_pedido.Total * 1.10;

        DBMS_OUTPUT.PUT_LINE('Pedido ID: ' || r_pedido.PedidoID || 
                             ' | Total Original: $' || r_pedido.Total || 
                             ' | Nuevo Total: $' || v_nuevo_total);
        UPDATE Pedidos
        SET Total = v_nuevo_total
        WHERE CURRENT OF c_pedidos_cliente;
    END LOOP;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Actualización completada y guardada.');
END;
/