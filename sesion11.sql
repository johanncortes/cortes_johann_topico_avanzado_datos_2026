--Johann Cortes Farias
--Topicos Avanzados de Datos
-- Sesión 11
-- Funciones en PL/SQL: Calcular Edad de Cliente

CREATE OR REPLACE FUNCTION calcular_edad_cliente (
    p_cliente_id IN NUMBER
) RETURN NUMBER AS
    -- Variables locales
    v_fecha_nacimiento  DATE;
    v_edad              NUMBER;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Calculando edad del cliente ===');
    DBMS_OUTPUT.PUT_LINE('Cliente ID: ' || p_cliente_id);
    
    -- Consultar la fecha de nacimiento del cliente
    BEGIN
        SELECT FechaNacimiento
        INTO v_fecha_nacimiento
        FROM Clientes
        WHERE ClienteID = p_cliente_id;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: El cliente con ID ' || p_cliente_id || ' no existe.');
            RETURN NULL;
        WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE('Error: Se encontraron múltiples clientes (error de integridad).');
            RETURN NULL;
    END;
    
    -- Calcular la edad en años
    -- Utilizamos TRUNC para obtener solo los años completos
    v_edad := TRUNC(MONTHS_BETWEEN(SYSDATE, v_fecha_nacimiento) / 12);
    
    -- Mostrar información
    DBMS_OUTPUT.PUT_LINE('Fecha de nacimiento: ' || TO_CHAR(v_fecha_nacimiento, 'DD/MM/YYYY'));
    DBMS_OUTPUT.PUT_LINE('Edad: ' || v_edad || ' años');
    DBMS_OUTPUT.PUT_LINE('=== Cálculo finalizado exitosamente ===');
    
    -- Devolver la edad
    RETURN v_edad;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado en la función: ' || SQLERRM);
        RETURN NULL;
END calcular_edad_cliente;
/

-- Habilitar salida de mensajes
SET SERVEROUTPUT ON;

--Ejercicio 2:
CREATE OR REPLACE FUNCTION obtener_precio_promedio RETURN NUMBER AS
	v_promedio NUMBER;
BEGIN
	SELECT AVG(Precio) INTO v_promedio
	FROM Productos;
	RETURN v_promedio;
END;
/
-- Consulta SQL
SELECT Nombre, Precio
FROM Productos
WHERE Precio > obtener_precio_promedio();

