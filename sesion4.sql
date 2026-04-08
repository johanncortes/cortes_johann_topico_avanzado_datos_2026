--Johann Cortes Farias
--Topicos Avanzados de Datos


--Bloque 1 PL/SQL
DECLARE
    e_monto_insuficiente EXCEPTION;
    v_total NUMBER; 
    v_pedido_id NUMBER := 102; 
    v_bias NUMBER := 500;
BEGIN
    -- Intentamos obtener el dato
    SELECT Total INTO v_total 
    FROM CURSO_TOPICOS.Pedidos
    WHERE PedidoID = v_pedido_id;

    IF v_total < v_bias THEN
        RAISE e_monto_insuficiente;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Pedido ' || v_pedido_id || ' correcto. Monto: ' || v_total);
    END IF;

EXCEPTION
    WHEN e_monto_insuficiente THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: El total (' || v_total || ') es menor al bias de ' || v_bias);
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ID de pedido no encontrado.');
END;
/

--Bloque 2 PL/SQL
DECLARE
    v_id_duplicado Productos.ProductoID%TYPE := 1; -- El ID 1 ya existe (Laptop)
BEGIN
    DBMS_OUTPUT.PUT_LINE('Intentando insertar un producto con ID duplicado: ' || v_id_duplicado);

    INSERT INTO Productos (ProductoID, Nombre, Precio)
    VALUES (v_id_duplicado, 'Teclado Mecánico', 45);
    COMMIT;
    
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Excepción capturada: DUP_VAL_ON_INDEX');
        DBMS_OUTPUT.PUT_LINE('Error: Ya existe un registro con el ID ' || v_id_duplicado || ' en la tabla Productos.');
        ROLLBACK;
        
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/