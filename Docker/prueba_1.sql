-- Script para crear y poblar la base de datos para la Prueba 1
-- Ejecutar en Oracle SQL en el esquema del estudiante (curso_topicos)

-- Habilitar salida de mensajes para PL/SQL
SET SERVEROUTPUT ON;

-- Eliminar tablas si ya existen (para evitar errores si el script se ejecuta más de una vez)
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Asignaciones CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('Tabla Asignaciones eliminada (si existía).');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Tabla Asignaciones no existía.');
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Incidentes CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('Tabla Incidentes eliminada (si existía).');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Tabla Incidentes no existía.');
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Agentes CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('Tabla Agentes eliminada (si existía).');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Tabla Agentes no existía.');
END;
/

-- Crear tabla Agentes
BEGIN
    DBMS_OUTPUT.PUT_LINE('Creando tabla Agentes...');
    EXECUTE IMMEDIATE 'CREATE TABLE Agentes (
        AgenteID NUMBER PRIMARY KEY,
        Nombre VARCHAR2(50),
        Especialidad VARCHAR2(50),
        FechaIngreso DATE
    )';
    DBMS_OUTPUT.PUT_LINE('Tabla Agentes creada.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al crear tabla Agentes: ' || SQLERRM);
        RAISE;
END;
/

-- Crear tabla Incidentes
BEGIN
    DBMS_OUTPUT.PUT_LINE('Creando tabla Incidentes...');
    EXECUTE IMMEDIATE 'CREATE TABLE Incidentes (
        IncidenteID NUMBER PRIMARY KEY,
        Descripcion VARCHAR2(100),
        Severidad VARCHAR2(20),
        Estado VARCHAR2(20),
        FechaDeteccion DATE
    )';
    DBMS_OUTPUT.PUT_LINE('Tabla Incidentes creada.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al crear tabla Incidentes: ' || SQLERRM);
        RAISE;
END;
/

-- Crear tabla Asignaciones (muchos a muchos entre Agentes e Incidentes)
BEGIN
    DBMS_OUTPUT.PUT_LINE('Creando tabla Asignaciones...');
    EXECUTE IMMEDIATE 'CREATE TABLE Asignaciones (
        AsignacionID NUMBER PRIMARY KEY,
        AgenteID NUMBER,
        IncidenteID NUMBER,
        Horas NUMBER,
        Rol VARCHAR2(30),
        CONSTRAINT fk_asignacion_agente FOREIGN KEY (AgenteID) REFERENCES Agentes(AgenteID),
        CONSTRAINT fk_asignacion_incidente FOREIGN KEY (IncidenteID) REFERENCES Incidentes(IncidenteID)
    )';
    DBMS_OUTPUT.PUT_LINE('Tabla Asignaciones creada.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al crear tabla Asignaciones: ' || SQLERRM);
        RAISE;
END;
/

-- Insertar datos en Agentes
BEGIN
    DBMS_OUTPUT.PUT_LINE('Insertando datos en Agentes...');
    INSERT INTO Agentes VALUES (101, 'Camila Reyes', 'Pentester', TO_DATE('2023-03-15', 'YYYY-MM-DD'));
    INSERT INTO Agentes VALUES (102, 'Diego Muñoz', 'Analista SOC', TO_DATE('2022-07-01', 'YYYY-MM-DD'));
    INSERT INTO Agentes VALUES (103, 'Valentina Soto', 'Analista SOC', TO_DATE('2024-01-10', 'YYYY-MM-DD'));
    INSERT INTO Agentes VALUES (104, 'Matías Fernández', 'Forense Digital', TO_DATE('2021-11-20', 'YYYY-MM-DD'));
    INSERT INTO Agentes VALUES (105, 'Francisca López', 'Pentester', TO_DATE('2023-08-05', 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('Datos insertados en Agentes.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al insertar datos en Agentes: ' || SQLERRM);
        RAISE;
END;
/

-- Insertar datos en Incidentes
BEGIN
    DBMS_OUTPUT.PUT_LINE('Insertando datos en Incidentes...');
    INSERT INTO Incidentes VALUES (201, 'Ransomware LockBit en servidor de archivos', 'Critical', 'Abierto', TO_DATE('2026-06-01', 'YYYY-MM-DD'));
    INSERT INTO Incidentes VALUES (202, 'Campaña de Phishing dirigida a RRHH', 'High', 'Abierto', TO_DATE('2026-06-03', 'YYYY-MM-DD'));
    INSERT INTO Incidentes VALUES (203, 'DDoS en portal web institucional', 'High', 'Cerrado', TO_DATE('2026-05-20', 'YYYY-MM-DD'));
    INSERT INTO Incidentes VALUES (204, 'SQL Injection en API de pagos', 'Critical', 'Abierto', TO_DATE('2026-06-05', 'YYYY-MM-DD'));
    INSERT INTO Incidentes VALUES (205, 'Exfiltracion de datos via DNS tunneling', 'Medium', 'Cerrado', TO_DATE('2026-05-10', 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('Datos insertados en Incidentes.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al insertar datos en Incidentes: ' || SQLERRM);
        RAISE;
END;
/

-- Insertar datos en Asignaciones
BEGIN
    DBMS_OUTPUT.PUT_LINE('Insertando datos en Asignaciones...');
    INSERT INTO Asignaciones VALUES (1, 101, 201, 40, 'Lider');
    INSERT INTO Asignaciones VALUES (2, 102, 201, 35, 'Apoyo');
    INSERT INTO Asignaciones VALUES (3, 102, 202, 20, 'Lider');
    INSERT INTO Asignaciones VALUES (4, 103, 202, 25, 'Apoyo');
    INSERT INTO Asignaciones VALUES (5, 103, 203, 30, 'Lider');
    INSERT INTO Asignaciones VALUES (6, 104, 204, 45, 'Lider');
    INSERT INTO Asignaciones VALUES (7, 101, 204, 35, 'Apoyo');
    INSERT INTO Asignaciones VALUES (8, 105, 205, 25, 'Lider');
    INSERT INTO Asignaciones VALUES (9, 104, 201, 20, 'Apoyo');
    DBMS_OUTPUT.PUT_LINE('Datos insertados en Asignaciones.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al insertar datos en Asignaciones: ' || SQLERRM);
        RAISE;
END;
/

-- Confirmar creación e inserción de datos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Tablas creadas y datos insertados correctamente.');
END;
/

-- Verificar datos
SELECT * FROM Agentes;
SELECT * FROM Incidentes;
SELECT * FROM Asignaciones;

-- Commit para asegurar los cambios
COMMIT;
