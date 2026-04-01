# Contenedor Oracle SQL

Este repositorio tiene fines educacionales.
A continuacion revisaremos como correr el contenedor en nuestros computadores, y como correr el script `sesion1.sql` el cual se encuentra disponible en el directorio.

## Verificando funcionamiento de Docker

```
docker --version
docker-compose --version
```
Con esto deberiamos obtener como output la version de docker y la version de docker-compose respectivamente.

Si es que no tenemos docker instalado, primero debemos procurar instalarlo desde su pagina oficial -> https://www.docker.com/products/docker-desktop/

### Cuenta en Oracle Container Registry

Para poder descargar la imagen de Oracle, debemos estar logeados con nuestra cuenta de Oracle, asi que debemos:

1. Ir a [https://container-registry.oracle.com/](https://container-registry.oracle.com/).
2. Crea una cuenta gratuita o iniciar sesión si ya tienes una.
3. Una vez creada la cuenta nos logeamos desde nuestra linea de comandos.
4. Ingresar en la linea de comandos `docker login container-registry.oracle.com`
5. Si el login es exitoso veras: *Login Succeeded*

### Construir y levantar el Contenedor

Desde la carpeta raiz, ejecutar:

`docker-compose up --build`

Esto construye el contenedor y lo ejecuta.

*La primera vez que ejecutes este comando, Docker descargará la imagen de Oracle Database (container-registry.oracle.com/database/express:21.3.0-xe), que es grande (varios GB). Esto puede tomar varios minutos dependiendo de tu conexión a internet.
Una vez que la imagen se descargue, el contenedor se iniciará. Verás logs en la terminal. Espera hasta que veas un mensaje como
`DATABASE IS READY TO USE!`*


### Conéctate a la Base de Datos

Abre una nueva terminal (no cierres la terminal donde ejecutaste docker-compose up).
Accede al contenedor:
`docker-compose exec oracle-db bash`

*El nombre del container (oracle-db) deberia coincidir con el nombre del servicio en ocker-compose.yml. Si nombraste el servicio con otro nombre, debe modificar este comando.*

Una vez dentro deberiamos ver: `bash-4.2$ ` junto con el cursor para poder ingresar comandos al servidor Oracle.

Ahora, conectemonos a la base de datos usando `sqlplus`

`sqlplus sys/oracle@//localhost:1521/XE as sysdba`

Aqui utilizamos:
* Username: `sys`
* Password: `oracle` (o lo que hayamos configurado en la variable de entorno `ORACLE_PWD` de docker-compose.yml)
* SID: `XE`

Si la conexion es exitosa, veremos el prompt de SQL:

`SQL> `

Intenta correr una query simple para testear:

`SELECT * FROM PRODUCTOS;`

### Wrap up

Al hacer build del proyecto, en Dockerfile especificamos que debemos copiar el archivo sesion1.sql en la carpeta startup de oracle la cual contien el script que corre en la inicializacion de la base de datos.

```
COPY sesion1.sql /opt/oracle/scripts/startup/
```
*Se ha modificado sesion1.sql agregando la creacion de la tabla DetallesPedidos y creando bloque PL/SQL para la creacion de las tablas*

Para poder usar esta configuracion, desde nuestro docker-compose especificamos que utilizaremos el Dockerfile para construir nuestra imagen, por lo que ahora especificamos en Dockerfile la imagen que vamos a utilizar.

```
#En dockerfile
FROM container-registry.oracle.com/database/express:21.3.0-xe

```

```
#En docker-compose
  oracle-db:
    build:
      context: .
      dockerfile: Dockerfile
      ...
```
Ahora, cada vez que levantemos el contenedor, vamos a intentar correr script1.sql.
La primera vez correra bien, pero las siguientes veces intentará crear tuplas con ids que ya existen asi que fallará al insertar tuplas.


### Problemas Comunes:

## Error KeyError: 'ContainerConfig'

Este error puede ocurrir por multiples razones:

* Incompatibilidad entre versiones de Docker Compose y Docker Engine
* Corrupción de Metadatos del Contenedor o Imagen
* Corrupción de Metadatos del Contenedor o Imagen
* Reconstrucción Innecesaria con --build

Una de las formas de solucionarlos es eliminando las imagenes, contenedores, redes y volumenes que no estan siendo usados con `docker system prune`. Esto incluye la imagen base container-registry.oracle.com/database/express:21.3.0-xe, que es grande y tarda mucho en descargarse. Si hacemos el `prune`, al intentar levantar el servidor nuevamente, tendremos que descargar la imagen nuevamente.

Podemos intentar:
* Levantar el entorno sin eliminar la imagen ni reconstruir: `docker-compose up`. Deberiamos reconstruir (`--build`) **solo si modificamos dockerfile o docker-compose**
* Limpiar el entorno sin eliminar la imagen: `docker-compose down -v`

## ERROR: An HTTP request took too long to complete.

Este error ocurre si una operación con Docker toma demasiado tiempo (por ejemplo, debido a una red lenta o recursos insuficientes). Para solucionarlo aumenta el tiempo de espera de Docker Compose:

```
export COMPOSE_HTTP_TIMEOUT=120
docker-compose up
```

Si el problema persiste, verifica si un firewall o antivirus está interfiriendo. Desactiva temporalmente el firewall:

```
sudo ufw disable
docker-compose up
```

Si funciona, ajusta las reglas del firewall y vuelve a habilitarlo:

```
sudo ufw allow 2375/tcp
sudo ufw allow 2376/tcp
sudo ufw enable
```

## Tras conectarnos, pareciera ser que no se han creado las tablas.

Si nos conectamos a la bd mediante el script entregado anteriormente: `sqlplus sys/oracle@//localhost:1521/XE as sysdba`, nos estaremos conectando por defecto a la base de datos Root de Oracle. Por otro lado, si nos fijamos en nuestro script ejecutado al iniciar el container, estamos:

```
-- Cambiandonos a la base de datos (PDB) XEPDB1 de Oracle
ALTER SESSION SET CONTAINER = XEPDB1;

-- Creando un nuevo usuario (esquema) para el curso.
CREATE USER curso_topicos IDENTIFIED BY curso2025;

```

Para poder acceder a nuestras tablas, estando conectados con el script facilitado anteriormente, podemos cambiarnos de base de datos con un:

`ALTER SESSION SET CONTAINER = XEPDB1;`

y luego, para acceder a los datos, anteponiendo el nombre del esquema: `CURSO_TOPICOS`:

```
SQL> ALTER SESSION SET CONTAINER = XEPDB1;

Session altered.

SQL> SELECT * from CURSO_TOPICOS.Clientes;

 CLIENTEID NOMBRE
---------- --------------------------------------------------
CIUDAD                                             FECHANACI
-------------------------------------------------- ---------
         1 Juan Perez
Santiago                                           15-MAY-90

         2 Mar??a Gomez
Valparaiso                                         20-OCT-85

         3 Ana Lopez
Santiago                                           10-MAR-95

```

o directamente cambiandonos de esquema:

```
ALTER SESSION SET CURRENT_SCHEMA = curso_topicos;
```

### Alternativas

1. Podemos conectarnos utilizando el usuario y contraseña creado en nuestro script: (User: curso_topicos, Pass: curso2025).

`sqlplus curso_topicos/curso2025@//localhost:1521/XEPDB1`

2. Podemos seguir conectandonos con el user y pass creado en el docker-compose, pero debemos cambiar de schema:

```
bash-4.2$ sqlplus sys/oracle@//localhost:1521/XEPDB1 as sysdba

SQL*Plus: Release 21.0.0.0.0 - Production on Wed Apr 16 20:15:08 2025
Version 21.3.0.0.0

Copyright (c) 1982, 2021, Oracle.  All rights reserved.


Connected to:
Oracle Database 21c Express Edition Release 21.0.0.0.0 - Production
Version 21.3.0.0.0

SQL> ALTER SESSION SET CURRENT_SCHEMA = curso_topicos;        

Session altered.

SQL> select * from Clientes;

 CLIENTEID NOMBRE
---------- --------------------------------------------------
CIUDAD                                             FECHANACI
-------------------------------------------------- ---------
         1 Juan Perez
Santiago                                           15-MAY-90

         2 Mar??a Gomez
Valparaiso                                         20-OCT-85

         3 Ana Lopez
Santiago                                           10-MAR-95


SQL> 
```



