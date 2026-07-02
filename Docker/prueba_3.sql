-- Script para crear y poblar la base de datos para la Prueba 3
-- Ejecutar en Oracle SQL Developer en el esquema del estudiante

SET SERVEROUTPUT ON;

-- Eliminar tablas si ya existen
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Asignaciones CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Incidentes CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE Agentes CASCADE CONSTRAINTS'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- Crear tabla Agentes
CREATE TABLE Agentes (
    AgenteID     NUMBER PRIMARY KEY,
    Nombre       VARCHAR2(50),
    Especialidad VARCHAR2(50),
    FechaIngreso DATE
);

-- Crear tabla Incidentes
CREATE TABLE Incidentes (
    IncidenteID    NUMBER PRIMARY KEY,
    Descripcion    VARCHAR2(100),
    Severidad      VARCHAR2(20),
    Estado         VARCHAR2(20),
    FechaDeteccion DATE
);

-- Crear tabla Asignaciones
CREATE TABLE Asignaciones (
    AsignacionID NUMBER PRIMARY KEY,
    AgenteID     NUMBER,
    IncidenteID  NUMBER,
    Horas        NUMBER,
    Rol          VARCHAR2(30),
    CONSTRAINT fk_asig_agente    FOREIGN KEY (AgenteID)    REFERENCES Agentes(AgenteID),
    CONSTRAINT fk_asig_incidente FOREIGN KEY (IncidenteID) REFERENCES Incidentes(IncidenteID)
);

-- Insertar datos en Agentes
INSERT INTO Agentes VALUES (101, 'Camila Reyes',     'Pentester',       TO_DATE('2023-03-15','YYYY-MM-DD'));
INSERT INTO Agentes VALUES (102, 'Diego Muñoz',      'Analista SOC',    TO_DATE('2022-07-01','YYYY-MM-DD'));
INSERT INTO Agentes VALUES (103, 'Valentina Soto',   'Analista SOC',    TO_DATE('2024-01-10','YYYY-MM-DD'));
INSERT INTO Agentes VALUES (104, 'Matías Fernández', 'Forense Digital', TO_DATE('2021-11-20','YYYY-MM-DD'));
INSERT INTO Agentes VALUES (105, 'Francisca López',  'Pentester',       TO_DATE('2023-08-05','YYYY-MM-DD'));

-- Insertar datos en Incidentes
INSERT INTO Incidentes VALUES (201, 'Ransomware LockBit en servidor de archivos', 'Critical', 'Abierto',  TO_DATE('2026-03-01','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (202, 'Campaña de Phishing dirigida a RRHH',        'High',     'Abierto',  TO_DATE('2026-03-03','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (203, 'DDoS en portal web institucional',            'High',     'Cerrado',  TO_DATE('2026-03-20','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (204, 'SQL Injection en API de pagos',               'Critical', 'Abierto',  TO_DATE('2026-04-05','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (205, 'Exfiltración de datos via DNS tunneling',     'Medium',   'Cerrado',  TO_DATE('2026-04-10','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (206, 'Acceso no autorizado a base de datos',        'Critical', 'Abierto',  TO_DATE('2026-05-02','YYYY-MM-DD'));
INSERT INTO Incidentes VALUES (207, 'Malware en estaciones de trabajo',            'Medium',   'Cerrado',  TO_DATE('2026-05-15','YYYY-MM-DD'));

-- Insertar datos en Asignaciones
INSERT INTO Asignaciones VALUES (1,  101, 201, 40, 'Lider');
INSERT INTO Asignaciones VALUES (2,  102, 201, 35, 'Apoyo');
INSERT INTO Asignaciones VALUES (3,  102, 202, 20, 'Lider');
INSERT INTO Asignaciones VALUES (4,  103, 202, 25, 'Apoyo');
INSERT INTO Asignaciones VALUES (5,  103, 203, 30, 'Lider');
INSERT INTO Asignaciones VALUES (6,  104, 204, 45, 'Lider');
INSERT INTO Asignaciones VALUES (7,  101, 204, 35, 'Apoyo');
INSERT INTO Asignaciones VALUES (8,  105, 205, 25, 'Lider');
INSERT INTO Asignaciones VALUES (9,  104, 201, 20, 'Apoyo');
INSERT INTO Asignaciones VALUES (10, 102, 206, 50, 'Lider');
INSERT INTO Asignaciones VALUES (11, 105, 206, 30, 'Apoyo');
INSERT INTO Asignaciones VALUES (12, 103, 207, 15, 'Lider');

COMMIT;

SELECT 'Tablas creadas y datos insertados correctamente.' AS mensaje FROM dual;

SELECT * FROM Agentes;
SELECT * FROM Incidentes;
SELECT * FROM Asignaciones;

/*
================================================================================
PRUEBA 3 - TÓPICOS AVANZADOS DE BASES DE DATOS
================================================================================

INSTRUCCIONES GENERALES:
- Tiempo: 90 minutos
- Puntaje total: 100 puntos
- Parte 1 (teórica): 40 puntos | Parte 2 (práctica): 60 puntos
- Ejecute el script de datos antes de comenzar la parte práctica
- En la parte teórica, la lógica y el concepto son lo que se evalúa;
  errores menores de sintaxis no penalizan si la idea es correcta

================================================================================
PARTE 1 - PREGUNTAS TEÓRICAS (40 puntos, 10 puntos cada una)
================================================================================

PREGUNTA 1 (10 puntos)
Explica qué es una transacción en una base de datos y describe las propiedades
ACID. Luego, muestra a través de un ejemplo cómo usarías múltiples savepoints
para manejar errores parciales en un procedimiento que asigna un agente a un
incidente y actualiza simultáneamente el estado del incidente. ¿Qué ocurre si
falla solo la actualización del estado?

PREGUNTA 2 (10 puntos)
¿Qué es un Data Warehouse y cómo se diferencia de una base de datos
transaccional? Describe cómo diseñarías un modelo dimensional (tabla de hechos
y al menos dos dimensiones) para analizar las horas trabajadas por agente y
por severidad de incidente. ¿Qué ventajas tiene este modelo para consultas
analíticas versus consultar directamente las tablas transaccionales?

PREGUNTA 3 (10 puntos)
Explica cómo se implementa la herencia en Oracle usando tipos de objetos.
Da un ejemplo de una jerarquía de dos niveles: Agente → AgenteEspecialista →
AgentePentester, donde cada nivel agrega atributos y sobreescribe un método
calcular_costo(). ¿Qué implicancias tiene declarar un tipo como NOT
INSTANTIABLE?

PREGUNTA 4 (10 puntos)
Describe las ventajas y desventajas de usar índices y particiones en una base
de datos. ¿Cómo usarías un índice compuesto y una partición por rango para
mejorar el rendimiento de consultas en la tabla Incidentes filtradas por
Severidad y FechaDeteccion? Explica qué es el partition pruning y cómo
impacta en el plan de ejecución.

================================================================================
PARTE 2 - EJERCICIOS PRÁCTICOS (60 puntos)
================================================================================

EJERCICIO 1 (20 puntos)
Escribe un procedimiento registrar_asignacion que reciba un AgenteID,
IncidenteID, Horas y Rol (parámetros IN). El procedimiento debe:
  a) Insertar una nueva asignación en Asignaciones (usa el próximo
     AsignacionID disponible).
  b) Validar que el agente no supere 100 horas totales asignadas en
     incidentes con Estado 'Abierto'.
  c) Validar que el incidente no tenga ya 3 o más agentes asignados.
  d) Usar savepoints independientes para cada validación, de modo que un
     fallo en una no deshaga operaciones previas válidas.
  e) Manejar todas las excepciones con mensajes descriptivos.

EJERCICIO 2 (20 puntos)
Diseña las tablas Fact_Asignaciones, Dim_Agente y Dim_Incidente para un
Data Warehouse basado en la base de datos de la prueba. Luego, escribe una
consulta analítica sobre las tablas transaccionales que muestre, para cada
agente, el total de horas trabajadas y el número de incidentes atendidos,
ordenado de mayor a menor por total de horas.

EJERCICIO 3 (20 puntos)
Crea un índice compuesto en Incidentes para las columnas Severidad y
FechaDeteccion. Luego, crea la tabla Incidentes particionada por rango de
FechaDeteccion (trimestral para 2026). Escribe una consulta que muestre el
total de horas asignadas por incidente para incidentes 'Critical' detectados
en el primer trimestre de 2026. Finalmente, muestra el plan de ejecución
con EXPLAIN PLAN e indica qué ventaja aporta la partición para esta consulta.

================================================================================
*/
