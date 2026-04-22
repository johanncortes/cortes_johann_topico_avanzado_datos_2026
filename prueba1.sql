-- Johann Cortés Farias RUT: 21.644.439-6
-- Topicos Avanzados de Datos
--Parte teorica a continuacion:
--Pregunta 1:
/*
Relación Muchos a Muchos (10 pts): Explica qué es una relación muchos a muchos y cómo se implementa en una base de datos relacional. Usa un ejemplo basado en las tablas del esquema creado para la prueba.
Respuesta: La relación muchos a muchos ocurre cuando múltiples registros en una tabla pueden estar relacionados con múltiples 
registros en otra tabla. 
Para implementar esta relación en una base de datos relacional, se utiliza una tabla intermedia (también conocida como tabla de unión o tabla de asociación) ==>
que contiene claves foráneas que hacen referencia a las tablas principales.
Tabla creada:
CREATE TABLE Asignaciones (
    AsignacionID NUMBER PRIMARY KEY,
    AgenteID NUMBER,     -- Clave foránea referenciando a Agentes
    IncidenteID NUMBER,  -- Clave foránea referenciando a Incidentes
    Horas NUMBER,        -- Atributo de la relación
    Rol VARCHAR2(30),    -- Atributo de la relación
    CONSTRAINT fk_asignacion_agente FOREIGN KEY (AgenteID) REFERENCES Agentes(AgenteID),
    CONSTRAINT fk_asignacion_incidente FOREIGN KEY (IncidenteID) REFERENCES Incidentes(IncidenteID)
)
--Pregunta 2:
Vistas (10 pts): Describe qué es una vista y cómo la usarías para mostrar el total de horas dedicadas por incidente, 
incluyendo la descripción del incidente y su severidad. Escribe la consulta SQL para crear la vista (no es necesario ejecutarla).
Respuesta: Una vista es una tabla virtual que se basa en el resultado de una consulta SQL. No almacena datos por sí misma, sino que muestra datos almacenados en otras tablas. 
Las vistas se utilizan para simplificar consultas complejas, mejorar la seguridad al restringir el acceso a ciertos datos, y proporcionar una capa de abstracción.
Vista Creada: 
CREATE VIEW vista_totales_horas_incidente AS
SELECT 
    i.IncidenteID,
    i.Descripcion,
    i.Severidad,
    SUM(a.Horas) AS Total_Horas
FROM 
    Incidentes i
JOIN 
    Asignaciones a ON i.IncidenteID = a.IncidenteID
GROUP BY 
    i.IncidenteID,
    i.Descripcion,
    i.Severidad;

--Pregunta 3
Excepciones Predefinidas (10 pts): ¿Qué es una excepción predefinida en PL/SQL y cómo se maneja? 
Da un ejemplo de cómo manejarías la excepción NO_DATA_FOUND en un bloque PL/SQL.
Respuesta: Una excepción predefinida en PL/SQL es una excepción que ya está definida por el sistema
y se activa automáticamente cuando ocurre un error específico durante la ejecución de un bloque PL/SQL.

--Pregunta 4:
Cursores Explícitos (10 pts): Explica qué es un cursor explícito y cómo se usa en PL/SQL. Menciona al menos dos atributos de cursor (como %NOTFOUND) y su propósito.
Respuesta: Un cursor explícito en PL/SQL es un cursor que el programador define y controla manualmente. 
Se utiliza para manejar consultas que devuelven múltiples filas, permitiendo procesar cada fila individualmente.

*/
-- Ahora parte practica de codigo en SQL:
/* EJERCICIO 1 
Escribe un bloque PL/SQL con un cursor explícito que liste las especialidades de agentes cuyo promedio de horas asignadas a incidentes sea mayor a 30, 
mostrando la especialidad y el promedio de horas. Usa un JOIN entre Agentes y Asignaciones.
*/
DECLARE
    -- Declaración del cursor explícito con el JOIN
    CURSOR c_especialidades_promedio IS
        SELECT ag.Especialidad, AVG(asi.Horas) AS Promedio_Horas
        FROM Agentes ag
        JOIN Asignaciones asi ON ag.AgenteID = asi.AgenteID
        GROUP BY ag.Especialidad
        HAVING AVG(asi.Horas) > 30;

    -- Variables para almacenar los datos obtenidos por el cursor
    v_especialidad Agentes.Especialidad%TYPE;
    v_promedio_horas NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('-Especialidades con promedio de horas > 30-');
    
    -- Abrir el cursor
    OPEN c_especialidades_promedio;
    
    -- Bucle para recorrer los resultados del cursor
    LOOP
        FETCH c_especialidades_promedio INTO v_especialidad, v_promedio_horas;
        
        -- Condición de salida cuando no queden más registros
        EXIT WHEN c_especialidades_promedio%NOTFOUND;
        
        -- Mostrar la información procesada
        DBMS_OUTPUT.PUT_LINE('- Especialidad: ' || v_especialidad || 
                             ' | Promedio de Horas: ' || ROUND(v_promedio_horas, 2));
    END LOOP;
    
    -- Se cierra el cursor
    CLOSE c_especialidades_promedio;
END;
/

--EJERCICIO 2:
/* Escribe un bloque PL/SQL con un cursor explícito que aumente en 10 las horas de todas las asignaciones asociadas a incidentes con severidad 'Critical'. 
Usa FOR UPDATE y maneja excepciones.
*/
DECLARE
    -- Declarar el cursor explícito con FOR UPDATE
    CURSOR c_asignaciones_criticas IS
        SELECT a.AsignacionID, a.Horas
        FROM Asignaciones a
        JOIN Incidentes i ON a.IncidenteID = i.IncidenteID
        WHERE i.Severidad = 'Critical'
        FOR UPDATE OF a.Horas;

    v_asignacion_id Asignaciones.AsignacionID%TYPE;
    v_horas Asignaciones.Horas%TYPE;
BEGIN
    -- Abrir el cursor
    OPEN c_asignaciones_criticas;
    
    -- Recorrer el cursor
    LOOP
        FETCH c_asignaciones_criticas INTO v_asignacion_id, v_horas;
        EXIT WHEN c_asignaciones_criticas%NOTFOUND;
        
        -- Actualizar el registro actual en el que se encuentra el cursor
        UPDATE Asignaciones
        SET Horas = Horas + 10
        WHERE CURRENT OF c_asignaciones_criticas;
        
    END LOOP;
    
    -- Cerrar el cursor una vez terminada la iteración
    CLOSE c_asignaciones_criticas;
    
    -- Confirmar los cambios
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Se aumentaron con éxito 10 horas a los incidentes con severidad Critical.');

EXCEPTION
    WHEN OTHERS THEN
        IF c_asignaciones_criticas%ISOPEN THEN
            CLOSE c_asignaciones_criticas;
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Ha ocurrido un error durante la actualización: ' || SQLERRM);
END;
/

-- Ejercicio 3:
/*
Tipo de Objeto (20 pts) Crea un tipo de objeto incidente_obj con atributos incidente_id, descripcion, y un método get_reporte. 
Luego, crea una tabla basada en ese tipo y transfiere los datos de Incidentes a esa tabla. 
Finalmente, escribe un cursor explícito que liste la información de los incidentes usando el método get_reporte.
*/
-- 1. Crear la especificación del tipo de objeto
CREATE OR REPLACE TYPE incidente_obj AS OBJECT (
    incidente_id NUMBER,
    descripcion VARCHAR2(100),
    MEMBER FUNCTION get_reporte RETURN VARCHAR2
);
/

-- 2. Crear el cuerpo del tipo de objeto (implementación del método)
CREATE OR REPLACE TYPE BODY incidente_obj AS
    MEMBER FUNCTION get_reporte RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Reporte -> ID Incidente: ' || self.incidente_id || ' | Descripción: ' || self.descripcion;
    END;
END;
/

-- 3. Crear la tabla basada en el tipo de objeto (tabla de objetos)
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE tabla_incidentes_obj';
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END;
/

CREATE TABLE tabla_incidentes_obj OF incidente_obj;

-- 4. Transferir los datos desde la tabla relacional 'Incidentes' a la tabla de objetos
INSERT INTO tabla_incidentes_obj
SELECT incidente_obj(IncidenteID, Descripcion)
FROM Incidentes;

COMMIT;

-- 5. Bloque PL/SQL con cursor explícito que consume la tabla de objetos y su método
DECLARE
    -- Se declara el cursor
    CURSOR c_incidentes IS
        SELECT VALUE(t) AS obj
        FROM tabla_incidentes_obj t;
        
    v_incidente incidente_obj;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Lista de Incidentes usando get_reporte() ---');
    
    -- Abrir cursor
    OPEN c_incidentes;
    
    LOOP
        FETCH c_incidentes INTO v_incidente;
        EXIT WHEN c_incidentes%NOTFOUND;
        
        -- Ejecutar el método get_reporte() del objeto y mostrarlo
        DBMS_OUTPUT.PUT_LINE(v_incidente.get_reporte());
    END LOOP;
    
    -- Cerrar cursor
    CLOSE c_incidentes;
END;
/