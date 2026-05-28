-- Johann Eduardo Cortes Farias
-- RUT: 21.644.439-6
-- Topicos Avanzados de Datos
-- PARTE 1: PREGUNTAS TEORICAS

/* Pregunta 1: Explica la diferencia entre un procedimiento almacenado y una función almacenada en PL/SQL. 
Da un ejemplo de cuándo usarías cada uno en el contexto de la base de datos de la prueba.
PROCEDIMIENTO vs FUNCIÓN EN PL/SQL

PROCEDIMIENTO: No retorna valor directo. Se usa para EJECUTAR ACCIONES 
(INSERT, UPDATE, DELETE). Parámetros OUT para retornar valores.
Ejemplo: AsignarAgenteAIncidente - Crear asignaciones e insertar en la base de datos.

FUNCIÓN: Siempre retorna UN valor. Se usa para CALCULAR Y DEVOLVER datos.
Se puede usar en sentencias SQL (SELECT, WHERE).
Ejemplo: ObtenerHorasAgente - Calcular suma de horas de un agente, Procedimiento = "Hacer cosas" y la Función = "Calcular cosas"

Pregunta 2: Describe cómo usarías un parámetro IN OUT en un procedimiento almacenado. Escribe un ejemplo de un procedimiento que use un parámetro IN OUT para actualizar y devolver las horas de una asignación después de un ajuste.
Un parámetro IN OUT en un procedimiento almacenado se utiliza para pasar un valor al procedimiento, permitir que el procedimiento lo modifique y luego devolver el valor actualizado al llamador. Esto es útil cuando deseas que el procedimiento realice una operación sobre un valor existente y luego devuelva el resultado modificado.


EJEMPLO: Procedimiento que incrementa horas de asignación y retorna el nuevo valor

CREATE PROCEDURE AjustarHorasAsignacion (
    p_asignacionID IN NUMBER,
    p_horasAjuste IN OUT NUMBER
)AS
    v_horasActuales NUMBER;
 BEGIN
    SELECT Horas INTO v_horasActuales 
    FROM Asignaciones 
    WHERE AsignacionID = p_asignacionID;
     
    p_horasAjuste := v_horasActuales + p_horasAjuste;     
        UPDATE Asignaciones 
    SET Horas = p_horasAjuste 
    WHERE AsignacionID = p_asignacionID;
     
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        p_horasAjuste := -1;
        ROLLBACK;
END;
USO: 
DECLARE v_horas NUMBER := 10;
BEGIN
    AjustarHorasAsignacion(1, v_horas);  -- Entrada: 10 horas a agregar
        DBMS_OUTPUT.PUT_LINE('Nuevas horas: ' || v_horas);  -- Salida: 50 (40+10)
END;

Pregunta 3: ¿Cómo se puede usar una función almacenada dentro de una consulta SQL? Escribe un ejemplo de una función que calcule el total de horas asignadas a un incidente y úsala en una consulta para listar los incidentes con su total de horas.
Una función almacenada se usa dentro de una consulta SQL cuando necesitas calcular o transformar valores como parte de la consulta. La función se llama directamente en la cláusula SELECT o WHERE, recibiendo parámetros de las columnas de la tabla.
En este caso, crear una función que sume las horas asignadas a cada incidente permite obtener un total sin necesidad de hacer JOINs complejos o subconsultas. La función realiza el cálculo internamente y devuelve el resultado que se integra automáticamente en la consulta.

-- Crear función para calcular total de horas por incidente
CREATE FUNCTION ObtenerTotalHorasIncidente (
    p_incidenteID IN NUMBER
) RETURN NUMBER AS
    v_totalHoras NUMBER;
BEGIN
    SELECT SUM(Horas) INTO v_totalHoras
    FROM Asignaciones
    WHERE IncidenteID = p_incidenteID;
    
    RETURN NVL(v_totalHoras, 0);
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END;
/

-- Usar la función en una consulta para listar incidentes con total de horas
SELECT 
    IncidenteID,
    Descripcion,
    Severidad,
    Estado,
    ObtenerTotalHorasIncidente(IncidenteID) AS TotalHoras
FROM Incidentes
ORDER BY TotalHoras DESC;

Pregunta 4: Explica qué es un trigger y menciona dos tipos de eventos que pueden dispararlo. Da un ejemplo de un trigger que se dispare después de insertar una asignación en la tabla Asignaciones y actualice el estado del incidente a 'En Proceso' si estaba en 'Abierto'.
Un trigger es un objeto de base de datos que se ejecuta automáticamente en respuesta a eventos específicos en una tabla. 
Es un bloque de código PL/SQL que se activa sin intervención del usuario cuando ocurre una acción determinada. Los triggers son útiles para mantener la integridad de los datos, aplicar reglas de negocio y realizar auditorías. Dos tipos de eventos que pueden disparar un trigger son: INSERT (cuando se inserta una nueva fila) y UPDATE (cuando se modifica una fila existente). También existen triggers para DELETE. En el contexto de la base de datos de la prueba, un trigger puede dispararse después de insertar una nueva asignación para cambiar automáticamente el estado del incidente de "Abierto" a "En Proceso",
garantizando que cuando se asignen agentes a un incidente, el estado se actualice sin intervención manual.
-- Crear trigger que se dispara después de insertar una asignación
CREATE OR REPLACE TRIGGER ActualizarEstadoIncidente
AFTER INSERT ON Asignaciones
FOR EACH ROW
BEGIN
    UPDATE Incidentes
    SET Estado = 'En Proceso'
    WHERE IncidenteID = :NEW.IncidenteID
    AND Estado = 'Abierto';
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END ActualizarEstadoIncidente;
/

-- Prueba del trigger: insertar una nueva asignación
-- Esto disparará automáticamente el trigger y cambiará el estado del incidente
INSERT INTO Asignaciones VALUES (10, 101, 205, 15, 'Lider');

-- Verificar que el estado del incidente fue actualizado
SELECT IncidenteID, Estado FROM Incidentes WHERE IncidenteID = 205;
*/

-- PARTE 2: PREGUNTAS PRACTICAS

-- Parte 2 Ejercicio 1:
-- Procedimiento para registrar una asignación
CREATE OR REPLACE PROCEDURE registrar_asignacion (
    p_agenteID IN NUMBER,
    p_incidenteID IN NUMBER,
    p_horas IN NUMBER,
    p_rol IN VARCHAR2
) AS
    v_nuevoID NUMBER;
    v_existe NUMBER;
BEGIN
    -- Verificar que el agente existe
    SELECT COUNT(*) INTO v_existe FROM Agentes WHERE AgenteID = p_agenteID;
    IF v_existe = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Agente no existe');
    END IF;
    
    -- Verificar que el incidente existe
    SELECT COUNT(*) INTO v_existe FROM Incidentes WHERE IncidenteID = p_incidenteID;
    IF v_existe = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Incidente no existe');
    END IF;
    
    -- Verificar que el agente no está ya asignado al incidente
    SELECT COUNT(*) INTO v_existe FROM Asignaciones 
    WHERE AgenteID = p_agenteID AND IncidenteID = p_incidenteID;
    IF v_existe > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Agente ya está asignado a este incidente');
    END IF;
    
    -- Obtener el siguiente ID
    SELECT MAX(AsignacionID) + 1 INTO v_nuevoID FROM Asignaciones;
    IF v_nuevoID IS NULL THEN v_nuevoID := 1; END IF;
    
    -- Insertar la asignación
    INSERT INTO Asignaciones VALUES (v_nuevoID, p_agenteID, p_incidenteID, p_horas, p_rol);
    
    -- Cambiar estado del incidente
    UPDATE Incidentes SET Estado = 'En Proceso' 
    WHERE IncidenteID = p_incidenteID AND Estado = 'Abierto';
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Asignacion creada con ID: ' || v_nuevoID);

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END registrar_asignacion;
/

-- Ejemplo de ejecución:
-- EXEC registrar_asignacion(101, 205, 15, 'Lider');


-- Parte 2 Ejercicio 2:
-- Función para calcular total de horas de un agente
CREATE OR REPLACE FUNCTION calcular_horas_agente (
    p_agenteID IN NUMBER
) RETURN NUMBER AS
    v_totalHoras NUMBER;
BEGIN
    SELECT SUM(Horas) INTO v_totalHoras
    FROM Asignaciones
    WHERE AgenteID = p_agenteID;
    
    RETURN NVL(v_totalHoras, 0);
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END calcular_horas_agente;
/

-- Procedimiento para mostrar carga de trabajo de todos los agentes
CREATE OR REPLACE PROCEDURE mostrar_carga_agentes AS
    CURSOR c_agentes IS SELECT AgenteID, Nombre, Especialidad FROM Agentes;
    v_horasTotal NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('====== CARGA DE TRABAJO POR AGENTE ======');
    DBMS_OUTPUT.PUT_LINE('Nombre                    | Especialidad         | Horas');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------');
    
    FOR reg_agente IN c_agentes LOOP
        v_horasTotal := calcular_horas_agente(reg_agente.AgenteID);
        DBMS_OUTPUT.PUT_LINE(RPAD(reg_agente.Nombre, 25) || ' | ' || 
                            RPAD(reg_agente.Especialidad, 20) || ' | ' || v_horasTotal);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------');
END mostrar_carga_agentes;
/

-- Ejemplo de ejecución:
-- EXEC mostrar_carga_agentes;

-- Parte 2 Ejercicio 3:
-- Crear tabla de auditoría
CREATE TABLE AuditoriaAsignaciones (
    AuditoriaID NUMBER PRIMARY KEY,
    AsignacionID NUMBER,
    AgenteID NUMBER,
    IncidenteID NUMBER,
    Horas NUMBER,
    Accion VARCHAR2(10),
    FechaRegistro DATE
);

-- Crear secuencia para AuditoriaID
CREATE SEQUENCE auditoria_seq START WITH 1 INCREMENT BY 1;

-- Crear trigger para auditar inserciones y eliminaciones
CREATE OR REPLACE TRIGGER auditar_asignaciones
AFTER INSERT OR DELETE ON Asignaciones
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO AuditoriaAsignaciones VALUES (
            auditoria_seq.NEXTVAL,
            :NEW.AsignacionID,
            :NEW.AgenteID,
            :NEW.IncidenteID,
            :NEW.Horas,
            'INSERT',
            SYSDATE
        );
    ELSIF DELETING THEN
        INSERT INTO AuditoriaAsignaciones VALUES (
            auditoria_seq.NEXTVAL,
            :OLD.AsignacionID,
            :OLD.AgenteID,
            :OLD.IncidenteID,
            :OLD.Horas,
            'DELETE',
            SYSDATE
        );
    END IF;
    COMMIT;
END auditar_asignaciones;
/

-- Verificar la auditoría:
-- SELECT * FROM AuditoriaAsignaciones;
