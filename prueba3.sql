/* Sesión 29: Prueba Parcial N°3 Topicos Avanzados de Datos
Johann Cortés Farias

-----PARTE TEORICA DE EJERCICIOS-----
Pregunta 1: 
Explica qué es una transacción en una base de datos y describe las propiedades
ACID. Luego, muestra a través de un ejemplo cómo usarías múltiples savepoints
para manejar errores parciales en un procedimiento que asigna un agente a un
incidente y actualiza simultáneamente el estado del incidente. ¿Qué ocurre si
falla solo la actualización del estado?

Respuesta: Una transacción es una unidad de trabajo que agrupa una o más operaciones 
sobre la base de datos para que se ejecuten como un todo.
Las propiedades ACID son:
- Atomicidad: La transacción se ejecuta completamente o se revierte completa.
- Consistencia: La base de datos pasa de un estado valido a otro estado valido, respetando reglas e integridad.
- Aislamiento: Cada transaccion se ejecuta sin interferir con otras transacciones concurrentes:
- Durabilidad: Una vez que la transaccion se confirma, los cambios quedan persistidos aunque falle el sistema despues.
Ejemplo de uso de savepoints: 
DECLARE
  v_id_asignacion NUMBER;
BEGIN
  SELECT NVL(MAX(AsignacionID), 0) + 1
  INTO v_id_asignacion
  FROM Asignaciones;

  SAVEPOINT sp_inicio;

  INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol)
  VALUES (v_id_asignacion, 101, 201, 40, 'Lider');

  SAVEPOINT sp_despues_asignacion;

  BEGIN
    UPDATE Incidentes
    SET Estado = 'En Proceso'
    WHERE IncidenteID = 201;

    SAVEPOINT sp_despues_estado;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO sp_despues_asignacion;
      DBMS_OUTPUT.PUT_LINE('Falló la actualización del estado. Se conserva la asignación.');
  END;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO sp_inicio;
    DBMS_OUTPUT.PUT_LINE('Falló la transacción completa.');
    END;
/
Si falla solo la actualización del estado, se hace rollback al savepoint después de la asignación, conservando la asignación pero sin actualizar el estado del incidente.

Pregunta 2: 
¿Qué es un Data Warehouse y cómo se diferencia de una base de datos
transaccional? Describe cómo diseñarías un modelo dimensional (tabla de hechos
y al menos dos dimensiones) para analizar las horas trabajadas por agente y
por severidad de incidente. ¿Qué ventajas tiene este modelo para consultas
analíticas versus consultar directamente las tablas transaccionales?

Respuesta: Un Data Warehouse es un repositorio orintado al analisis, integrado, historico y optimizado para consultas de lectura.
A diferencia de una base de datos transaccional, que esta diseñada para registrar operaciones del dia a ddia con alta concurrencia,
consistencia inmediata y muchas inserciones y actualizaciones, el data warehouse consolida
informacion de varias fuentes para facilitar reportes, tendencias y analisis gerenciales.
Modelo dimensional:
Fact_Asignaciones: AgenteID, IncidenteID, HorasAsignadas.
Dim_Agente: AgenteID, Nombre, Especialidad, FechaIngreso.
Dim_Incidente: IncidenteID, Descripcion, Severidad, Estado, FechaDeteccion.
La tabla de hechos almacena la métrica principal, que en este caso son las horas trabajadas. 
Las dimensiones permiten analizar esas horas por agente y por severidad del incidente.
La ventaja de eeste modelo frente a consultar directamente las tablas transaccionales
es que las consultas analiticas son mas simples, mas rapidas y mas faciles de mantener.
Reduce la complejidad de los joins, mejora el rendimiento en agregaciones y permite
explorar los datos por categorias de negocio de forma mas clara.

Pregunta 3: 
Explica cómo se implementa la herencia en Oracle usando tipos de objetos.
Da un ejemplo de una jerarquía de dos niveles: Agente → AgenteEspecialista →
AgentePentester, donde cada nivel agrega atributos y sobreescribe un método
calcular_costo(). ¿Qué implicancias tiene declarar un tipo como NOT
INSTANTIABLE?

Respuesta: En Oracle, la herencia con tipos de objetos se implementa usando tipos objeto
y la clausula UNDER. Esto permite definir un tipo padre con atributos y metodos comunes,
y luego crear subtipos que agregan nuevos atributos o redefinen metodos.
Ejemplo de jerarquía:
CREATE OR REPLACE TYPE Agente AS OBJECT (
  agente_id NUMBER,
  nombre VARCHAR2(50),
  especialidad VARCHAR2(50),
  MEMBER FUNCTION calcular_costo RETURN NUMBER
) NOT FINAL NOT INSTANTIABLE;
/

CREATE OR REPLACE TYPE BODY Agente AS
  MEMBER FUNCTION calcular_costo RETURN NUMBER IS
  BEGIN
    RETURN 0;
  END;
END;
/

CREATE OR REPLACE TYPE AgenteEspecialista UNDER Agente (
  nivel_certificacion VARCHAR2(30),
  OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY AgenteEspecialista AS
  OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER IS
  BEGIN
    RETURN 1000;
  END;
END;
/

CREATE OR REPLACE TYPE AgentePentester UNDER AgenteEspecialista (
  herramientas VARCHAR2(100),
  OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY AgentePentester AS
  OVERRIDING MEMBER FUNCTION calcular_costo RETURN NUMBER IS
  BEGIN
    RETURN 2000;
  END;
END;
/
En el ejemplo anterior, Agente contiene los atributos base
AgenteEspecialista agrega nivel_certificacion y AgentePentester agrega herramientas.
Cada subtipo sobreescribe calcular_costo() para calcular un valor distinto segun su nivel.
Declara un tipo coomo NON INSTANTIABLE significa que no se pueden crear objetos directamente de ese tipo.
Se usa como un tipo abstracto o base, util para definir estructura comun que solo sera instanciada
a traves de sus subtipos. Esto obliga a que la logica concreta este en los tipos derivados y evita usar directamente una clase base incompleta.

Pregunta 4:
Describe las ventajas y desventajas de usar índices y particiones en una base
de datos. ¿Cómo usarías un índice compuesto y una partición por rango para
mejorar el rendimiento de consultas en la tabla Incidentes filtradas por
Severidad y FechaDeteccion? Explica qué es el partition pruning y cómo
impacta en el plan de ejecución.

Respuesta: Los indices aceleran busquedas y filtros, pero ocupan espacio y vuelven mas lentas las inserciones y actualizaciones.
Las particiones dividen la tabla en bloques mas pequeños, lo que mejora consultas por rango y mantenimiento,
aunque aumentan la complejidad.
Para incidentes, usaria un indice compuesto sobre Severidad y FechaDeteccion, y particionaria por rango de FechaDeteccion,
por ejemplo, por trimste de 2026, asi una consulta de incidentes critical del primer trimestre solo revisa la particion necesaria.

Partition pruning es cuando Oracle ignora las particiones que no necesita. 
Esto reduce I/0 y mejora el tiempo de respuesta para que el plan de ejecucion sea mas eficiente.
*/

------ PARTE 2: EJERCICIOS PRACTICOS ------
-- Ejercicio 1:
CREATE OR REPLACE PROCEDURE registrar_asignacion (
    p_agenteid    IN NUMBER,
    p_incidenteid IN NUMBER,
    p_horas       IN NUMBER,
    p_rol         IN VARCHAR2
    ) IS
    v_asignacion_id   NUMBER;
    v_total_horas     NUMBER;
    v_cantidad_agente NUMBER;
BEGIN
    -- Validación básica de entrada
    IF p_horas <= 0 THEN
        RAISE_APPLICATION_ERROR(-20000, 'Las horas deben ser mayores que cero.');
    END IF;

    -- Obtener el siguiente identificador disponible
    SELECT NVL(MAX(AsignacionID), 0) + 1
    INTO v_asignacion_id
    FROM Asignaciones;

    SAVEPOINT sp_inicio;

    -- 1) Insertar primero la asignación
    INSERT INTO Asignaciones (AsignacionID, AgenteID, IncidenteID, Horas, Rol)
    VALUES (v_asignacion_id, p_agenteid, p_incidenteid, p_horas, p_rol);

    SAVEPOINT sp_insertado;

    -- 2) Validar que el agente no supere 100 horas en incidentes abiertos
    SAVEPOINT sp_valida_horas;
    BEGIN
      SELECT NVL(SUM(a.Horas), 0)
      INTO v_total_horas
      FROM Asignaciones a
      JOIN Incidentes i ON i.IncidenteID = a.IncidenteID
      WHERE a.AgenteID = p_agenteid
        AND i.Estado = 'Abierto';

      IF v_total_horas > 100 THEN
        ROLLBACK TO sp_valida_horas;
        DBMS_OUTPUT.PUT_LINE('El agente supera las 100 horas en incidentes abiertos.');
      ELSE
        DBMS_OUTPUT.PUT_LINE('Validación de horas aprobada.');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO sp_valida_horas;
        DBMS_OUTPUT.PUT_LINE('Error al validar horas del agente: ' || SQLERRM);
    END;

    -- 3) Validar que el incidente no tenga 3 o más agentes asignados
    SAVEPOINT sp_valida_incidente;
    BEGIN
      SELECT COUNT(*)
      INTO v_cantidad_agente
      FROM Asignaciones
      WHERE IncidenteID = p_incidenteid;

      IF v_cantidad_agente >= 3 THEN
        ROLLBACK TO sp_valida_incidente;
        DBMS_OUTPUT.PUT_LINE('El incidente ya tiene 3 o más agentes asignados.');
      ELSE
        DBMS_OUTPUT.PUT_LINE('Validación de incidente aprobada.');
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO sp_valida_incidente;
        DBMS_OUTPUT.PUT_LINE('Error al validar el incidente: ' || SQLERRM);
    END;

    -- Confirmar cambios si todo fue correcto
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Asignación registrada correctamente.');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK TO sp_inicio;
        DBMS_OUTPUT.PUT_LINE('Error al registrar asignación: ' || SQLERRM);
END;
/


--Ejercicio 2:
--Data warehouse para analizar horas trabajadas por agente y severidad de incidente
CREATE TABLE Dim_Agente (
    AgenteKey      NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    AgenteID       NUMBER NOT NULL,
    Nombre         VARCHAR2(50),
    Especialidad   VARCHAR2(50),
    FechaIngreso   DATE
);

CREATE TABLE Dim_Incidente (
    IncidenteKey    NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    IncidenteID     NUMBER NOT NULL,
    Descripcion     VARCHAR2(100),
    Severidad       VARCHAR2(20),
    Estado          VARCHAR2(20),
    FechaDeteccion  DATE
);

CREATE TABLE Fact_Asignaciones (
    FactKey         NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    AgenteKey       NUMBER NOT NULL,
    IncidenteKey    NUMBER NOT NULL,
    HorasAsignadas  NUMBER NOT NULL,
    CONSTRAINT fk_fact_agente
        FOREIGN KEY (AgenteKey) REFERENCES Dim_Agente(AgenteKey),
    CONSTRAINT fk_fact_incidente
        FOREIGN KEY (IncidenteKey) REFERENCES Dim_Incidente(IncidenteKey)
);

SELECT
  a.AgenteID,
  a.Nombre,
  SUM(asg.Horas) AS TotalHoras,
  COUNT(DISTINCT asg.IncidenteID) AS IncidentesAtendidos
FROM Agentes a
JOIN Asignaciones asg ON asg.AgenteID = a.AgenteID
GROUP BY a.AgenteID, a.Nombre
ORDER BY TotalHoras DESC;

--Ejercicio 3:
-- Tabla particionada por rango trimestral para 2026
-- Si ya existe, primero elimínala antes de ejecutar este bloque.
CREATE TABLE Incidentes_Part (
    IncidenteID    NUMBER PRIMARY KEY,
    Descripcion    VARCHAR2(100),
    Severidad      VARCHAR2(20),
    Estado         VARCHAR2(20),
    FechaDeteccion DATE
)
PARTITION BY RANGE (FechaDeteccion) (
    PARTITION p_2026_q1 VALUES LESS THAN (TO_DATE('2026-04-01','YYYY-MM-DD')),
    PARTITION p_2026_q2 VALUES LESS THAN (TO_DATE('2026-07-01','YYYY-MM-DD')),
    PARTITION p_2026_q3 VALUES LESS THAN (TO_DATE('2026-10-01','YYYY-MM-DD')),
    PARTITION p_2026_q4 VALUES LESS THAN (TO_DATE('2027-01-01','YYYY-MM-DD'))
);

  CREATE INDEX idx_incidentes_sev_fecha
  ON Incidentes_Part (Severidad, FechaDeteccion);

-- Consulta: total de horas por incidente para incidentes Critical del 1er trimestre de 2026
SELECT
    i.IncidenteID,
    i.Descripcion,
    SUM(a.Horas) AS TotalHoras
FROM Incidentes_Part i
JOIN Asignaciones a
    ON a.IncidenteID = i.IncidenteID
WHERE i.Severidad = 'Critical'
  AND i.FechaDeteccion >= TO_DATE('2026-01-01','YYYY-MM-DD')
  AND i.FechaDeteccion <  TO_DATE('2026-04-01','YYYY-MM-DD')
GROUP BY i.IncidenteID, i.Descripcion
ORDER BY i.IncidenteID;

-- Plan de ejecución
EXPLAIN PLAN FOR
SELECT
    i.IncidenteID,
    i.Descripcion,
    SUM(a.Horas) AS TotalHoras
FROM Incidentes_Part i
JOIN Asignaciones a
    ON a.IncidenteID = i.IncidenteID
WHERE i.Severidad = 'Critical'
  AND i.FechaDeteccion >= TO_DATE('2026-01-01','YYYY-MM-DD')
  AND i.FechaDeteccion <  TO_DATE('2026-04-01','YYYY-MM-DD')
GROUP BY i.IncidenteID, i.Descripcion;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
/* La ventaja de la particion es que Oracle puede hacer partition pruning
y leer solo la particion del primer trimestre de 2026, reduciento I/O y mejorando
el tiempo de respuesta. */

