-- SESIÓN 14: Tipos de objetos y herencia
-- Autor: Johann Cortés Farias
-- Topicos Avanzados de Datos

-- Supertipo Vehiculo con atributos Marca y Anio (anio del vehículo)
-- y un método obtener_antiguedad que calcula la antigüedad en años.
CREATE OR REPLACE TYPE Vehiculo AS OBJECT (
    Marca VARCHAR2(50),
    Anio NUMBER,
    MEMBER FUNCTION obtener_antiguedad RETURN NUMBER
) NOT FINAL;
/

-- Implementación del método obtener_antiguedad
CREATE OR REPLACE TYPE BODY Vehiculo AS
    MEMBER FUNCTION obtener_antiguedad RETURN NUMBER IS
    BEGIN
        -- Calcula la diferencia entre el año actual y el año del vehículo
        RETURN EXTRACT(YEAR FROM SYSDATE) - Anio;
    END;
END;
/

-- Subtipo Automovil que hereda de Vehiculo
-- Agrega el atributo NumeroPuertas y un método descripcion
-- que devuelve una cadena con los detalles del automóvil.
CREATE OR REPLACE TYPE Automovil UNDER Vehiculo (
    NumeroPuertas NUMBER,
    MEMBER FUNCTION descripcion RETURN VARCHAR2
);
/

-- Implementación del método descripcion
CREATE OR REPLACE TYPE BODY Automovil AS
    MEMBER FUNCTION descripcion RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Marca: ' || Marca ||
               ', Anio: ' || Anio ||
               ', Puertas: ' || NumeroPuertas ||
               ', Antiguedad: ' || obtener_antiguedad || ' anios';
    END;
END;
/
