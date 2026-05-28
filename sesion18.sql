-- Sesion 18: Paquetes y Variables Globales, Desarrollo de paquetes y excepciones
-- Johann Cortes Farias
-- Topicos Avanzados de Datos

--Ejercicio 1: Crea un paquete gestion_clientes con:
--Un procedimiento registrar_cliente que reciba ClienteID, Nombre, Ciudad y FechaNacimiento, y valide que la fecha de nacimiento sea anterior a la fecha actual.
--Una función obtener_edad que reciba un ClienteID y devuelva la edad del cliente.
--Usa una variable global para contar los clientes registrados.
-- Especificación
CREATE OR REPLACE PACKAGE gestion_clientes AS
	g_contador_clientes NUMBER := 0;
	PROCEDURE registrar_cliente(
    	p_cliente_id IN NUMBER,
    	p_nombre IN VARCHAR2,
    	p_ciudad IN VARCHAR2,
    	p_fecha_nacimiento IN DATE
	);
	FUNCTION obtener_edad(
    	p_cliente_id IN NUMBER
	) RETURN NUMBER;
END gestion_clientes;
/

-- Cuerpo
CREATE OR REPLACE PACKAGE BODY gestion_clientes AS
	PROCEDURE registrar_cliente(
    	p_cliente_id IN NUMBER,
    	p_nombre IN VARCHAR2,
    	p_ciudad IN VARCHAR2,
    	p_fecha_nacimiento IN DATE
	) IS
	BEGIN
    	IF p_fecha_nacimiento >= SYSDATE THEN
        	RAISE_APPLICATION_ERROR(-20001, 'La fecha de nacimiento debe ser anterior a la fecha actual.');
    	END IF;
   	 
    	INSERT INTO Clientes (ClienteID, Nombre, Ciudad, FechaNacimiento)
    	VALUES (p_cliente_id, p_nombre, p_ciudad, p_fecha_nacimiento);
        g_contador_clientes := g_contador_clientes + 1;
    	DBMS_OUTPUT.PUT_LINE('Cliente registrado. Total clientes: ' || g_contador_clientes);
	EXCEPTION
    	WHEN OTHERS THEN
        	DBMS_OUTPUT.PUT_LINE('Error al registrar cliente: ' || SQLERRM);
        	RAISE;
	END registrar_cliente;
    
	FUNCTION obtener_edad(
    	p_cliente_id IN NUMBER
	) RETURN NUMBER IS
    	v_fecha_nacimiento DATE;
    	v_edad NUMBER;
	BEGIN
    	SELECT FechaNacimiento INTO v_fecha_nacimiento
    	FROM Clientes
    	WHERE ClienteID = p_cliente_id;
   	 
    	v_edad := FLOOR(MONTHS_BETWEEN(SYSDATE, v_fecha_nacimiento) / 12);
    	RETURN v_edad;
	EXCEPTION
    	WHEN NO_DATA_FOUND THEN
        	RAISE_APPLICATION_ERROR(-20002, 'Cliente no encontrado.');
    	WHEN OTHERS THEN
        	DBMS_OUTPUT.PUT_LINE('Error al calcular edad: ' || SQLERRM);
        	RAISE;
	END obtener_edad;
END gestion_clientes;
/

-- Prueba
EXEC gestion_clientes.registrar_cliente(4, 'Carlos Díaz', 'Santiago', TO_DATE('1980-01-01', 'YYYY-MM-DD'));
DECLARE
	v_edad NUMBER;
BEGIN
	v_edad := gestion_clientes.obtener_edad(4);
	DBMS_OUTPUT.PUT_LINE('Edad del cliente 4: ' || v_edad);
END;
/

--Ejercicio 2: Modifica el paquete gestion_clientes para incluir una excepción personalizada
-- e_edad_invalida que se lance si el cliente tiene menos de 18 años al registrarlo. 
--Prueba el paquete con un cliente menor de edad.
-- Modificar el paquete para incluir la excepción personalizada
-- Especificación
CREATE OR REPLACE PACKAGE gestion_clientes AS
	e_edad_invalida EXCEPTION;
	g_contador_clientes NUMBER := 0;
	PROCEDURE registrar_cliente(
    	p_cliente_id IN NUMBER,
    	p_nombre IN VARCHAR2,
    	p_ciudad IN VARCHAR2,
    	p_fecha_nacimiento IN DATE
	);
	FUNCTION obtener_edad(
    	p_cliente_id IN NUMBER
	) RETURN NUMBER;
END gestion_clientes;
/

-- Cuerpo
CREATE OR REPLACE PACKAGE BODY gestion_clientes AS
	PROCEDURE registrar_cliente(
    	p_cliente_id IN NUMBER,
    	p_nombre IN VARCHAR2,
    	p_ciudad IN VARCHAR2,
    	p_fecha_nacimiento IN DATE
	) IS
    	v_edad NUMBER;
	BEGIN
    	IF p_fecha_nacimiento >= SYSDATE THEN
        	RAISE_APPLICATION_ERROR(-20001, 'La fecha de nacimiento debe ser anterior a la fecha actual.');
    	END IF;
   	 
    	v_edad := FLOOR(MONTHS_BETWEEN(SYSDATE, p_fecha_nacimiento) / 12);
    	IF v_edad < 18 THEN
        	RAISE e_edad_invalida;
     END IF;
   	 
    	INSERT INTO Clientes (ClienteID, Nombre, Ciudad, FechaNacimiento)
    	VALUES (p_cliente_id, p_nombre, p_ciudad, p_fecha_nacimiento);
   	 
    	g_contador_clientes := g_contador_clientes + 1;
    	DBMS_OUTPUT.PUT_LINE('Cliente registrado. Total clientes: ' || g_contador_clientes);
	EXCEPTION
    	WHEN e_edad_invalida THEN
        	DBMS_OUTPUT.PUT_LINE('Error: El cliente debe tener al menos 18 años.');
        	RAISE;
    	WHEN OTHERS THEN
        	DBMS_OUTPUT.PUT_LINE('Error al registrar cliente: ' || SQLERRM);
        	RAISE;
	END registrar_cliente;
    
	FUNCTION obtener_edad(
    	p_cliente_id IN NUMBER
	) RETURN NUMBER IS
    	v_fecha_nacimiento DATE;
    	v_edad NUMBER;
	BEGIN
    	SELECT FechaNacimiento INTO v_fecha_nacimiento
    	FROM Clientes
    	WHERE ClienteID = p_cliente_id;
   	 
    	v_edad := FLOOR(MONTHS_BETWEEN(SYSDATE, v_fecha_nacimiento) / 12);
    	RETURN v_edad;
	EXCEPTION
    	WHEN NO_DATA_FOUND THEN
        	RAISE_APPLICATION_ERROR(-20002, 'Cliente no encontrado.');
    	WHEN OTHERS THEN
        	DBMS_OUTPUT.PUT_LINE('Error al calcular edad: ' || SQLERRM);
        	RAISE;
	END obtener_edad;
END gestion_clientes;
/

-- Prueba con un cliente menor de edad
EXEC gestion_clientes.registrar_cliente(5, 'Ana Menor', 'Santiago', TO_DATE('2010-01-01', 'YYYY-MM-DD'));

