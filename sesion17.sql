-- Sesion 17: Seguridad y Roles
-- Johann Cortes Farias
-- Topicos Avanzados de Datos

/* Ejercicio 1: Crea un usuario user_analista y un rol rol_analista. 
El rol debe tener permisos para consultar (SELECT) todas las tablas de curso_topicos y para insertar (INSERT) en la tabla Pedidos. 
Asigna el rol al usuario y prueba los permisos. */
-- Crear usuario
CREATE USER user_analista IDENTIFIED BY analista123;
GRANT CONNECT TO user_analista;

-- Crear rol y asignar permisos
CREATE ROLE rol_analista;
GRANT SELECT ON Clientes TO rol_analista;
GRANT SELECT ON Pedidos TO rol_analista;
GRANT SELECT ON Productos TO rol_analista;
GRANT SELECT ON DetallesPedidos TO rol_analista;
GRANT INSERT ON Pedidos TO rol_analista;

-- Asignar rol al usuario
GRANT rol_analista TO user_analista;

-- Probar permisos
CONNECT user_analista/analista123;
SELECT * FROM Clientes; -- Debería funcionar
INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido)
VALUES (109, 1, 1500, TO_DATE('2025-06-01', 'YYYY-MM-DD')); -- Debería funcionar
UPDATE Clientes SET Nombre = 'Juan Pérez Modificado' WHERE ClienteID = 1; -- Debería fallar

-- Ejercicio 2: Configura auditoría para monitorear las acciones de user_analista al consultar la tabla Clientes y al insertar en la tabla Pedidos. 
-- Realiza algunas acciones y verifica los registros de auditoría.

-- Habilitar auditoría (requiere privilegios de administrador)
CONNECT sys AS sysdba;
AUDIT SELECT ON Clientes BY user_analista;
AUDIT INSERT ON Pedidos BY user_analista;

-- Realizar acciones como user_analista
CONNECT user_analista/analista123;
SELECT * FROM Clientes;
INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido)
VALUES (110, 2, 2000, TO_DATE('2025-06-02', 'YYYY-MM-DD'));

-- Ver registros de auditoría
CONNECT sys AS sysdba;
SELECT username, action_name, timestamp
FROM dba_audit_trail
WHERE username = 'USER_ANALISTA';