-- Sesion 22: Replicación y Alta Disponibilidad en bases de datos
-- Johann Cortés Farias
-- Topico Avanzado de Datos
-- Ejercicio 1:
-- Estrategia de Alta Disponibilidad para curso_topicos
-- - Nodos:
--   * Nodo principal: Santiago, Chile
--   * Nodo standby: Valparaíso, Chile
-- - Replicación: Asíncrona con Oracle Data Guard
--   * Motivo: Menor latencia en el nodo principal, aceptable para este sistema
-- - Uso del nodo standby:
--   * Consultas de solo lectura (reportes de ventas) usando Active Data Guard
-- - Failover:
--   * Configurar Fast-Start Failover para cambio automático al nodo standby
--   * MTTR objetivo: 5 minutos
-- - Consideraciones:
--   * Respaldo completo semanal y archivelogs diarios (integrado con la estrategia de Sesión 22)
--   * Monitoreo: Usar Oracle Enterprise Manager para alertas de fallos

-- Ejercicio 2:
-- Consulta de solo lectura para el nodo standby
-- Esta consulta obtiene el total de ventas por cliente en un período específico
SELECT c.ClienteID,          -- Identificador único del cliente
       c.Nombre,             -- Nombre del cliente
       SUM(p.Total) AS TotalVentas  -- Suma de todos los montos de pedidos para cada cliente
FROM Clientes c              -- Tabla de clientes (tabla base izquierda)
JOIN Pedidos p ON c.ClienteID = p.ClienteID  -- Une con tabla Pedidos usando el ClienteID común
-- Filtra los pedidos realizados entre el 1 de enero y el 30 de junio de 2025
WHERE p.FechaPedido BETWEEN TO_DATE('2025-01-01', 'YYYY-MM-DD') AND TO_DATE('2025-06-30', 'YYYY-MM-DD')
-- Agrupa los resultados por ClienteID y Nombre (requerido cuando usas funciones de agregación como SUM)
GROUP BY c.ClienteID, c.Nombre
-- Ordena los resultados en forma descendente para ver primero los clientes con mayores ventas
ORDER BY TotalVentas DESC;

-- Uso de Active Data Guard:
-- - El nodo standby está en modo de solo lectura mientras se sincroniza con el principal
-- - Esta consulta se ejecuta en el standby para no afectar el rendimiento del nodo principal
-- - Beneficio: Balanceo de carga, ya que las operaciones de escritura (INSERT, UPDATE) se realizan en el principal