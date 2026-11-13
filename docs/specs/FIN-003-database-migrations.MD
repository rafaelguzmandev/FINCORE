SPEC — FIN-003: Database Migration Strategy

Campo	Valor
Estado	Propuesta para aprobación
Depende de	FIN-001 (monorepo), FIN-002 (Docker Compose + PostgreSQL)
Servicios afectados	identity-service, core-banking-service, payment-service
Tipo	Foundation / infraestructura. Sin lógica de negocio.
1. Contexto

FinCore es un monorepo con tres servicios desplegables. Cada uno es dueño de su base de datos lógica dentro de una misma instancia PostgreSQL local (Docker Compose):

Servicio	Tecnología	Base de datos	Usuario de BD
identity-service	Java 21 / Spring Boot	identity_db	identity_user
core-banking-service	Java 21 / Spring Boot	core_banking_db	core_banking_user
payment-service	Go	payment_db	payment_user

Estado heredado de FIN-001 y FIN-002:

Cada base tiene su propio rol, con CONNECT revocado a PUBLIC. Cada rol es owner solo de su base.
Las variables de entorno están en .env (gitignored) y se documentan en .env.example.
Variables por servicio: IDENTITY_DB_*, CORE_BANKING_DB_*, PAYMENT_DB_*, más POSTGRES_HOST y POSTGRES_PORT.
2. Objetivo

Establecer un mecanismo de migraciones versionado, ordenado, repetible y auditable para los tres servicios, de modo que el esquema nunca se modifique manualmente y cualquier entorno vacío pueda inicializarse con comandos documentados.

3. Principios no negociables
Cada servicio es dueño de su esquema y su historial de migraciones. Las migraciones viven dentro del directorio del servicio. No existe carpeta compartida de migraciones.
Ningún servicio modifica la base de otro. Cada servicio usa solo sus propias credenciales.
Migraciones en SQL plano en los tres servicios (formato compatible, distinta herramienta de ejecución).
Las migraciones se ejecutan de forma explícita, nunca como efecto secundario de arrancar el servicio.
Una migración ya aplicada o mergeada no se edita. Se corrige con una migración nueva.
4. Decisiones de diseño (ya tomadas, no re-decidir)
Tema	Decisión
Herramienta Java	Flyway (Community), en ambos servicios Java
Herramienta Go	goose (alternativa aceptable solo si hay bloqueo técnico: golang-migrate)
Liquibase	Descartado: no se quiere capa de abstracción sobre el SQL
Ejecución en Java	spring.flyway.enabled=false por defecto; se migra con ./mvnw flyway:migrate
Ejecución en Go	Solo por CLI/Makefile; nunca migrar dentro de main
Tests de integración Java	Pueden habilitar Flyway (Testcontainers) en su propio perfil
Rollback Java	No hay undo (es de pago). Estrategia roll-forward
Rollback Go	-- +goose Down en cada migración
Numeración	Enteros secuenciales, no timestamps
5. Alcance
Incluido
Configurar Flyway en identity-service y core-banking-service.
Configurar goose y un Makefile en payment-service.
Crear el directorio de migraciones y una migración baseline por servicio.
Definir y documentar la convención de nombres.
Soportar aplicar migraciones pendientes, consultar estado y (cuando sea seguro) revertir.
Agregar un Makefile raíz con un target migrate-all.
Documentar el uso local y las reglas de rollback.
Fuera de alcance
Crear tablas de clientes, cuentas, ledger, holds, idempotencia o pagos.
Constraints de negocio financieras (CHECK de montos, triggers de balance, etc.).
Operaciones entre bases de datos de distintos servicios.
Migraciones automáticas en producción, CI/CD de despliegue o infraestructura cloud.
Seeds de datos de negocio.
6. Estructura de archivos esperada
FINCORE/
├── Makefile                                   # nuevo: migrate-all
├── docs/
│   └── conventions.md                         # actualizar: sección de migraciones
├── services/
│   ├── identity-service/
│   │   ├── pom.xml                            # flyway-core, flyway-database-postgresql, flyway-maven-plugin
│   │   └── src/main/resources/
│   │       ├── application.yml                # spring.flyway.enabled=false
│   │       └── db/migration/V1__baseline.sql
│   ├── core-banking-service/
│   │   ├── pom.xml
│   │   └── src/main/resources/
│   │       ├── application.yml
│   │       └── db/migration/V1__baseline.sql
│   └── payment-service/
│       ├── Makefile                           # migrate-up / down / status / new
│       └── migrations/00001_baseline.sql
└── README.md                                  # actualizar: comandos de migración
7. Convención de nombres
Servicio	Patrón	Ejemplo
Java (Flyway)	V{n}__{descripcion_snake_case}.sql	V2__create_customers.sql
Go (goose)	{nnnnn}_{descripcion_snake_case}.sql	00002_create_transfers.sql

Reglas comunes:

Descripción en inglés, snake_case, iniciando con verbo: create_, add_, alter_, drop_.
Una migración = un cambio lógico.
Las versiones son consecutivas, sin saltos.
Nunca editar una migración aplicada o mergeada.
8. Contenido de las migraciones baseline

La V1 no crea tablas de negocio. Solo marca el inicio del historial.

Flyway (V1__baseline.sql):

sql
-- Marca el inicio del historial de migraciones de este servicio.
-- Sin tablas de negocio.
SELECT 1;

goose (00001_baseline.sql):

sql
-- +goose Up
SELECT 1;

-- +goose Down
SELECT 1;

El historial lo persisten las herramientas: flyway_schema_history (Java) y goose_db_version (Go).

9. Requisitos de configuración
Java (ambos servicios)
Dependencias: flyway-core y flyway-database-postgresql. Usar las versiones administradas por el BOM de Spring Boot; no fijar versiones a mano sin justificación.
Plugin flyway-maven-plugin con el driver de PostgreSQL como dependencia del plugin.
Conexión solo desde variables de entorno del propio servicio:
identity: IDENTITY_DB_NAME, IDENTITY_DB_USER, IDENTITY_DB_PASSWORD
core-banking: CORE_BANKING_DB_NAME, CORE_BANKING_DB_USER, CORE_BANKING_DB_PASSWORD
Host/puerto: POSTGRES_HOST, POSTGRES_PORT
locations apunta a filesystem:src/main/resources/db/migration.
Validación de checksum de Flyway activada (valor por defecto; no desactivar).
spring.flyway.enabled=false en el perfil por defecto.
Go (payment-service)
goose ejecutado vía go run github.com/pressly/goose/v3/cmd/goose@<version> o binario instalado. Verificar la última versión estable antes de fijarla.
Makefile que cargue ../../.env y construya la URL con PAYMENT_DB_*.
Targets: migrate-up, migrate-down, migrate-status, migrate-new name=<nombre>.
Directorio de migraciones: migrations/.
Raíz

Makefile con migrate-all que ejecute los tres servicios y falle si alguno falla.

10. Reglas de rollback
Servicio	Soporte
Go / goose	Down obligatorio en cada migración
Java / Flyway	Sin undo. Roll-forward: se corrige con una nueva migración

Reglas a documentar:

Local: se puede resetear todo con docker compose down -v y volver a migrar.
Las migraciones destructivas (DROP, cambios de tipo con pérdida) deben marcarse como no reversibles en el PR.
Para tablas financieras (ledger, postings, journal entries), el rollback no es seguro por diseño (los movimientos contabilizados son inmutables). Siempre roll-forward.
11. Criterios de aceptación
#	Criterio	Cómo se verifica
1	Cada servicio tiene estructura de migraciones independiente	Existen los tres directorios con su baseline
2	Migraciones versionadas en Git	Los archivos están commiteados; .env no
3	Orden determinista	Agregar temporalmente una V2 y confirmar que se aplica después de la V1 (luego eliminarla)
4	Historial persistido	SELECT * FROM flyway_schema_history; en identity y core-banking; SELECT * FROM goose_db_version; en payment
5	Entorno vacío inicializa las 3 BD	docker compose down -v && docker compose up -d, esperar healthy, make migrate-all
6	Re-ejecutar no reaplica	Segundo make migrate-all no aplica nada ("up to date" / sin cambios)
7	Cada servicio migra solo su BD	Intentar migrar identity con credenciales de payment debe fallar por permisos
8	Documentación	README y docs/conventions.md incluyen comandos, convención y reglas de rollback
9	Sin lógica de negocio	No existen tablas de dominio; solo las tablas de historial de las herramientas
12. Documentación a entregar
README raíz: sección "Database migrations" con los comandos de abajo.
docs/conventions.md: convención de nombres, regla de roll-forward, regla de no editar migraciones aplicadas.
Nota sobre el esquema public en PostgreSQL 15+: el rol funciona por ser owner de su base; confirmarlo en la verificación.

Comandos mínimos:

bash
cp .env.example .env              # primera vez
docker compose up -d              # esperar estado "healthy"
make migrate-all                  # migra los tres servicios

# Por servicio
cd services/identity-service     && set -a && . ../../.env && set +a && ./mvnw flyway:migrate
cd services/core-banking-service && set -a && . ../../.env && set +a && ./mvnw flyway:migrate
cd services/payment-service      && make migrate-up

# Inspección
./mvnw flyway:info               # Java
make migrate-status              # Go
13. Instrucciones para la IA

Debes:

Leer este spec completo antes de escribir código.
Mantenerte dentro del alcance. Si algo no está aquí, pregunta en lugar de inventar.
Usar solo las variables de entorno definidas en .env.example. Si necesitas una nueva, agrégala ahí con valor placeholder.
Verificar versiones vigentes de goose y del plugin de Flyway antes de fijarlas.
Ejecutar la verificación de la sección 11 y reportar el resultado real de cada punto.

No debes:

Crear tablas de negocio ni constraints financieros.
Escribir credenciales reales en archivos versionados.
Habilitar migraciones automáticas al arrancar los servicios.
Editar una migración existente para "arreglar" un fallo; crea otra.
Declarar un criterio como cumplido sin haberlo ejecutado.
Introducir librerías o carpetas compartidas entre servicios.
14. Orden de trabajo sugerido

Rama: feature/FIN-003-database-migrations

Flyway + V1__baseline.sql en identity-service.
Lo mismo en core-banking-service.
goose + Makefile + 00001_baseline.sql en payment-service.
Makefile raíz con migrate-all.
Verificación completa desde cero (sección 11).
Documentación en README y docs/conventions.md.

Commits en formato Conventional Commits, por ejemplo chore(identity): add flyway baseline migration.

15. Definition of Done
 Los 9 criterios de aceptación verificados con evidencia.
 Un desarrollador nuevo puede inicializar las tres BD desde un entorno vacío siguiendo solo el README.
 .env excluido de Git; ningún secreto en el diff.
 Sin lógica de negocio ni tablas de dominio.
 PR revisado por el desarrollador, que entiende cada cambio aceptado.
16. Supuestos y preguntas abiertas
Se asume Maven como build tool (decisión de FIN-001).
Se asume que el usuario de cada servicio puede crear objetos en el esquema public de su base. Si no, otorgar CREATE explícitamente en el script de init (cambio en infra/postgres/init/).
Pendiente: definir en CI (FIN-004) un job que corra las tres migraciones desde cero contra un PostgreSQL efímero.