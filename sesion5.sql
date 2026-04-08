--Johann Cortes Farias
--Topicos Avanzados de Datos

--1
DECLARE
    CURSOR c_productos IS
        SELECT Nombre, Precio
        FROM Productos
        ORDER BY Precio DESC;
    v_nombre Productos.Nombre%TYPE;
    v_precio Productos.Precio%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- LISTA DE PRODUCTOS ---');
    
    OPEN c_productos;
    
    LOOP
        FETCH c_productos INTO v_nombre, v_precio;
        
        EXIT WHEN c_productos%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Producto: ' || v_nombre || ' - Precio: $' || v_precio);
    END LOOP;
    CLOSE c_productos;
END;
/

--2
DECLARE
    CURSOR c_pedidos_cliente(p_cliente_id NUMBER) IS
        SELECT PedidoID, Total
        FROM Pedidos
        WHERE ClienteID = p_cliente_id
        FOR UPDATE OF Total;
        
    v_pedido_id Pedidos.PedidoID%TYPE;
    v_total_original Pedidos.Total%TYPE;
    v_total_nuevo Pedidos.Total%TYPE;
    v_cliente_objetivo NUMBER := 1; 
BEGIN
    DBMS_OUTPUT.PUT_LINE('Actualizando pedidos del Cliente ID: ' || v_cliente_objetivo);
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
    
    OPEN c_pedidos_cliente(v_cliente_objetivo);
    
    LOOP
        FETCH c_pedidos_cliente INTO v_pedido_id, v_total_original;
        EXIT WHEN c_pedidos_cliente%NOTFOUND;
        
        v_total_nuevo := v_total_original * 1.10;
        UPDATE Pedidos
        SET Total = v_total_nuevo
        WHERE CURRENT OF c_pedidos_cliente;
        
        DBMS_OUTPUT.PUT_LINE('Pedido N° ' || v_pedido_id || 
                             ' | Total Anterior: $' || v_total_original || 
                             ' | Nuevo Total (+10%): $' || v_total_nuevo);
    END LOOP;
    
    CLOSE c_pedidos_cliente;
    COMMIT; 
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Actualización completada y guardada.');
END;
/

