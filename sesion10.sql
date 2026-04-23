-- ============================================================================
-- SESIÓN 10: Procedimientos Almacenados en PL/SQL
-- Autor: Johann Cortés
-- ============================================================================

-- ============================================================================
-- EJERCICIO 1: PROCEDIMIENTO actualizar_total_pedidos
-- ============================================================================
-- DESCRIPCIÓN GENERAL:
-- Este procedimiento actualiza el total de todos los pedidos de un cliente
-- específico, aplicando un porcentaje de aumento a cada uno. Utiliza un cursor
-- para iterar sobre los pedidos del cliente y aplicar el cambio de forma
-- individual, mostrando el resultado de cada actualización.

-- PARÁMETROS DE ENTRADA (IN):
-- - p_cliente_id: Número que identifica al cliente cuyo pedidos se actualizarán
-- - p_porcentaje: Porcentaje de aumento a aplicar (valor por defecto: 10%)

-- LÓGICA DEL PROCEDIMIENTO:
-- 1. Define un cursor que obtiene todos los pedidos del cliente
-- 2. Usa un bucle FOR para recorrer cada pedido
-- 3. Calcula el nuevo total: Total anterior * (1 + porcentaje / 100)
-- 4. Actualiza el registro en la base de datos
-- 5. Imprime un mensaje con el resultado
-- 6. Verifica si se actualizaron registros
-- 7. Si hay cambios, confirma la transacción (COMMIT)
-- 8. Si ocurre un error, deshace los cambios (ROLLBACK)

-- ============================================================================

CREATE OR REPLACE PROCEDURE actualizar_total_pedidos(
    -- Parámetro de entrada: ID del cliente cuyos pedidos se actualizarán
    p_cliente_id IN NUMBER,
    -- Parámetro de entrada: Porcentaje de aumento (por defecto 10%)
    p_porcentaje IN NUMBER DEFAULT 10
) AS
    -- SECCIÓN DE DECLARACIÓN DE VARIABLES Y CURSORES
    
    -- Definición de un cursor que obtiene los pedidos del cliente específico
    -- FOR UPDATE: Bloquea los registros para asegurar que no se modifiquen durante el proceso
    -- Este bloqueo evita conflictos de concurrencia en una base de datos multiusuario
    CURSOR pedido_cursor IS
        SELECT PedidoID, Total           -- Selecciona el ID y total del pedido
        FROM Pedidos                      -- De la tabla Pedidos
        WHERE ClienteID = p_cliente_id   -- Donde el cliente coincida con el parámetro
        FOR UPDATE;                       -- Bloquea los registros para actualización
        
BEGIN
    -- SECCIÓN DE EJECUCIÓN DEL PROCEDIMIENTO
    
    -- Inicia un bucle FOR que itera sobre cada fila del cursor
    -- La variable 'pedido' contiene los datos de cada fila en cada iteración
    FOR pedido IN pedido_cursor LOOP
        
        -- Actualiza el total del pedido actual
        -- Multiplica el total anterior por (1 + porcentaje/100)
        -- Ejemplo: Si Total=100 y porcentaje=10%, el nuevo total será: 100 * (1 + 10/100) = 100 * 1.1 = 110
        UPDATE Pedidos
            SET Total = pedido.Total * (1 + p_porcentaje / 100)
            -- WHERE CURRENT OF: Actualiza solo el registro actual del cursor
            -- Esto es más eficiente que usar la clave primaria
            WHERE CURRENT OF pedido_cursor;
        
        -- Imprime un mensaje mostrando el resultado de la actualización
        -- || es el operador de concatenación en SQL/PL-SQL
        -- Concatena texto, números y variables en una sola línea
        DBMS_OUTPUT.PUT_LINE(
            'Pedido ' || pedido.PedidoID ||           -- Imprime "Pedido X"
            ': Nuevo total: ' ||                      -- Imprime ": Nuevo total: "
            (pedido.Total * (1 + p_porcentaje / 100)) -- Calcula e imprime el nuevo total
        );
        
    -- Fin del bucle FOR: continúa con el siguiente pedido
    END LOOP;
    
    -- Verifica cuántas filas fueron afectadas por la última operación
    -- SQL%ROWCOUNT: Contador especial de PL/SQL que cuenta los registros modificados
    -- Si es 0, significa que no se actualizó ningún registro
    IF SQL%ROWCOUNT = 0 THEN
        -- Si el cliente no tiene pedidos, muestra un mensaje informativo
        DBMS_OUTPUT.PUT_LINE('Cliente ' || p_cliente_id || ' no tiene pedidos.');
    ELSE
        -- Si se actualizó al menos un registro:
        -- COMMIT: Confirma permanentemente todos los cambios en la base de datos
        -- Sin COMMIT, los cambios serían reversibles
        COMMIT;
    END IF;
    
-- SECCIÓN DE MANEJO DE EXCEPCIONES (Errores)
EXCEPTION
    -- WHEN OTHERS captura CUALQUIER tipo de error que ocurra
    -- OTHERS es un comodín que atrapa todas las excepciones no capturadas específicamente
    WHEN OTHERS THEN
        -- SQLERRM: Función que devuelve el mensaje de error de Oracle
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        
        -- ROLLBACK: Deshace todos los cambios realizados en caso de error
        -- Esto garantiza que la base de datos permanece consistente
        -- Si hay error, ninguno de los cambios se guarda
        ROLLBACK;
        
-- Fin del procedimiento
END actualizar_total_pedidos;
/

-- Prueba del procedimiento: ejecuta el procedimiento con el cliente 1
-- Aumenta un 10% (valor por defecto) los totales de los pedidos del cliente 1
EXEC actualizar_total_pedidos(1);

-- ============================================================================
-- EJERCICIO 2: PROCEDIMIENTO calcular_costo_detalle
-- ============================================================================
-- DESCRIPCIÓN GENERAL:
-- Este procedimiento calcula el costo total de un detalle de pedido.
-- El costo se obtiene multiplicando: Precio del Producto * Cantidad
-- Los datos se obtienen de las tablas DetallesPedidos y Productos.
-- El resultado se devuelve en un parámetro IN OUT (parámetro de entrada y salida).

-- PARÁMETROS:
-- - p_detalle_id (IN): ID del detalle a calcular (solo entrada)
-- - p_costo_total (IN OUT): Variable que recibirá el costo calculado (entrada y salida)

-- LÓGICA DEL PROCEDIMIENTO:
-- 1. Busca el detalle en la tabla DetallesPedidos
-- 2. Obtiene el ProductoID y la Cantidad
-- 3. Busca el precio del producto en la tabla Productos
-- 4. Calcula: Costo = Precio * Cantidad
-- 5. Asigna el resultado al parámetro p_costo_total
-- 6. Imprime información del cálculo
-- 7. Captura errores si el detalle o producto no existen

-- ============================================================================

CREATE OR REPLACE PROCEDURE calcular_costo_detalle (
    -- Parámetro de entrada: ID del detalle a consultar
    p_detalle_id IN NUMBER,
    -- Parámetro de entrada/salida: Variable que recibirá el costo calculado
    -- IN OUT significa que recibe un valor y devuelve otro
    p_costo_total IN OUT NUMBER
) AS
    -- SECCIÓN DE DECLARACIÓN DE VARIABLES
    
    -- Variable para almacenar el ID del producto del detalle
    v_producto_id NUMBER;
    
    -- Variable para almacenar la cantidad del producto en el detalle
    v_cantidad NUMBER;
    
    -- Variable para almacenar el precio del producto
    v_precio NUMBER;
    
    -- Variable bandera para saber si se encontró el detalle
    -- TRUE si se encontró, FALSE si no existe
    v_detalle_encontrado BOOLEAN := FALSE;
    
BEGIN
    -- SECCIÓN DE EJECUCIÓN
    
    -- Imprime un encabezado para identificar el inicio del procedimiento
    DBMS_OUTPUT.PUT_LINE('=== Calculando costo del detalle ===');
    DBMS_OUTPUT.PUT_LINE('Detalle ID: ' || p_detalle_id);
    
    -- BLOQUE 1: Obtener datos del detalle
    -- Este es un bloque BEGIN...END anidado para manejar excepciones localmente
    BEGIN
        -- Consulta SELECT... INTO: obtiene una fila y la asigna a variables
        -- Esta consulta busca el detalle en la tabla DetallesPedidos
        SELECT dp.ProductoID, dp.Cantidad  -- Qué columnas obtener
        INTO v_producto_id, v_cantidad      -- Dónde guardarlas (variables locales)
        FROM DetallesPedidos dp             -- De qué tabla
        WHERE dp.DetalleID = p_detalle_id;  -- Condición: el detalle específico
        
        -- Si la consulta fue exitosa, marca que se encontró el detalle
        v_detalle_encontrado := TRUE;
        
    -- Manejo de excepciones para este bloque específico
    EXCEPTION
        -- Si NO_DATA_FOUND: la consulta no devolvió resultados
        -- Significa que el detalle con ese ID no existe en la base de datos
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Error: El detalle con ID ' || p_detalle_id || ' no existe.');
            -- Asigna 0 al resultado
            p_costo_total := 0;
            -- RETURN: Sale del procedimiento sin continuar
            RETURN;
        
        -- Si TOO_MANY_ROWS: la consulta devolvió más de una fila
        -- Esto indicaría un error en la integridad de la base de datos
        -- (las claves primarias deberían asegurar una sola fila)
        WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE('Error: Se encontraron múltiples detalles (error de integridad).');
            p_costo_total := 0;
            RETURN;
    END;
    
    -- BLOQUE 2: Verificar si se encontró el detalle y obtener el precio
    -- IF: Sentencia condicional
    IF v_detalle_encontrado THEN
        -- Este bloque se ejecuta solo si se encontró el detalle
        
        -- Sub-bloque: Obtener el precio del producto
        BEGIN
            -- Consulta SELECT... INTO que obtiene el precio del producto
            SELECT Precio           -- Qué columna obtener
            INTO v_precio           -- Dónde guardarla
            FROM Productos          -- De qué tabla
            WHERE ProductoID = v_producto_id;  -- Condición: el producto específico
            
        -- Manejo de excepciones para la consulta del producto
        EXCEPTION
            -- Si el producto no existe (también un error de integridad)
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.PUT_LINE('Error: El producto con ID ' || v_producto_id || ' no existe.');
                p_costo_total := 0;
                RETURN;
            
            -- Si hay múltiples productos con el mismo ID (error de integridad)
            WHEN TOO_MANY_ROWS THEN
                DBMS_OUTPUT.PUT_LINE('Error: Se encontraron múltiples productos (error de integridad).');
                p_costo_total := 0;
                RETURN;
        END;
        
        -- BLOQUE 3: Calcular el costo total
        -- Fórmula: Costo = Precio * Cantidad
        -- Ejemplo: Si Precio = 100 y Cantidad = 5, entonces Costo = 500
        p_costo_total := v_precio * v_cantidad;
        
        -- Imprime la información detallada del cálculo
        DBMS_OUTPUT.PUT_LINE('Producto ID: ' || v_producto_id);
        DBMS_OUTPUT.PUT_LINE('Cantidad: ' || v_cantidad);
        DBMS_OUTPUT.PUT_LINE('Precio unitario: ' || v_precio);
        DBMS_OUTPUT.PUT_LINE('Costo total: ' || ROUND(p_costo_total, 2));
        -- ROUND: Redondea el número a 2 decimales (para dinero)
        DBMS_OUTPUT.PUT_LINE('=== Cálculo finalizado exitosamente ===');
        
    END IF;  -- Fin del IF
    
-- Manejo de excepciones generales del procedimiento completo
EXCEPTION
    -- Captura cualquier otra excepción no manejada anteriormente
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado en el procedimiento: ' || SQLERRM);
        -- Asigna 0 si hay un error inesperado
        p_costo_total := 0;
        -- RAISE: Lanza la excepción nuevamente (re-lanza el error)
        RAISE;
        
-- Fin del procedimiento
END calcular_costo_detalle;
/

-- ============================================================================
-- EJEMPLOS DE USO DE LOS PROCEDIMIENTOS
-- ============================================================================

-- Habilitar la salida de mensajes DBMS_OUTPUT en la sesión
SET SERVEROUTPUT ON;

-- Ejemplo 1: Calcular costo del detalle ID 1
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('--- Ejemplo 1: Calcular costo del detalle ID 1 ---');
DECLARE
    -- Declara una variable local para almacenar el costo
    v_costo NUMBER;
BEGIN
    -- Inicializa la variable en 0
    v_costo := 0;
    -- Llama al procedimiento pasando el detalle 1 y la variable para recibir el resultado
    calcular_costo_detalle(1, v_costo);
    -- Imprime el resultado con 2 decimales
    DBMS_OUTPUT.PUT_LINE('Resultado: Costo total = ' || ROUND(v_costo, 2));
END;
/

-- Ejemplo 2: Calcular costo del detalle ID 2
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('--- Ejemplo 2: Calcular costo del detalle ID 2 ---');
DECLARE
    v_costo NUMBER;
BEGIN
    v_costo := 0;
    calcular_costo_detalle(2, v_costo);
    DBMS_OUTPUT.PUT_LINE('Resultado: Costo total = ' || ROUND(v_costo, 2));
END;
/

-- Ejemplo 3: Intentar calcular costo de un detalle que NO existe (ID 999)
-- Este ejemplo demuestra el manejo de excepciones
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('--- Ejemplo 3: Detalle inexistente (ID 999) - Prueba de excepciones ---');
DECLARE
    v_costo NUMBER;
BEGIN
    v_costo := 0;
    calcular_costo_detalle(999, v_costo);
    DBMS_OUTPUT.PUT_LINE('Resultado: Costo total = ' || ROUND(v_costo, 2));
END;
/

-- Verificar datos de referencia de las tablas usadas
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('=== Referencia: DetallesPedidos ===');
SELECT * FROM DetallesPedidos;

DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('=== Referencia: Productos ===');
SELECT * FROM Productos;

