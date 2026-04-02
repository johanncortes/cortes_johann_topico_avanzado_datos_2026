--Johann Cortes Farias
--Topicos Avanzados de datos 2026

SET SERVEROUTPUT ON;
DECLARE
    -- Variables para almacenar los datos
    v_cliente_id NUMBER := 1; 
    v_nombre_cliente VARCHAR2(50);
    v_total_gastado NUMBER := 0;
    v_categoria VARCHAR2(20);
    
BEGIN
    -- 1. Buscamos en curso_topicos.Clientes
    SELECT Nombre INTO v_nombre_cliente
    FROM curso_topicos.Clientes
    WHERE ClienteID = v_cliente_id;

    -- 2. Buscamos en curso_topicos.Pedidos
    SELECT NVL(SUM(Total), 0) INTO v_total_gastado
    FROM curso_topicos.Pedidos
    WHERE ClienteID = v_cliente_id;

    -- 3. Clasificar el total gastado
    IF v_total_gastado < 400 THEN
        v_categoria := 'BAJO';
    ELSIF v_total_gastado <= 800 THEN
        v_categoria := 'MEDIO';
    ELSE
        v_categoria := 'ALTO';
    END IF;

    -- 4. Mostrar los resultados por pantalla
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    DBMS_OUTPUT.PUT_LINE('REPORTE DE CLASIFICACIÓN DE CLIENTES');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Cliente: ' || v_nombre_cliente || ' (ID: ' || v_cliente_id || ')');
    DBMS_OUTPUT.PUT_LINE('Total Histórico Gastado: $' || v_total_gastado);
    DBMS_OUTPUT.PUT_LINE('Categoría del Cliente: ' || v_categoria);
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: El cliente con ID ' || v_cliente_id || ' no existe en la base de datos.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR INESPERADO: ' || SQLERRM);
END;
/