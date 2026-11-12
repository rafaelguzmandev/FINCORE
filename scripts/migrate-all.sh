#!/usr/bin/env bash
# Aplica las migraciones pendientes de los tres servicios (identity, core-banking, payment).
# Detiene en el primer fallo.
#
# Uso: bash scripts/migrate-all.sh
set -eo pipefail

cd "$(dirname "$0")/.."

# En Windows, cuando make invoca a Bash, JAVA_HOME y el PATH de Java a menudo
# no se propagan. Si falta JAVA_HOME, lo derivamos de `java` en el PATH o de
# ubicaciones conocidas del JDK en Windows.
if [ -z "${JAVA_HOME:-}" ]; then
    if command -v java >/dev/null 2>&1; then
        export JAVA_HOME="$(cd "$(dirname "$(dirname "$(which java)")")" && pwd)"
    elif [ -d "/c/Program Files/Eclipse Adoptium/jdk-21.0.13.9-hotspot" ]; then
        export JAVA_HOME="/c/Program Files/Eclipse Adoptium/jdk-21.0.13.9-hotspot"
    elif [ -d "C:/Program Files/Eclipse Adoptium/jdk-21.0.13.9-hotspot" ]; then
        export JAVA_HOME="C:/Program Files/Eclipse Adoptium/jdk-21.0.13.9-hotspot"
    elif [ -d "/c/Program Files/Java/jdk-21" ]; then
        export JAVA_HOME="/c/Program Files/Java/jdk-21"
    fi
fi

# Cargar variables de entorno del repositorio
eval "$(bash scripts/load_env.sh .env)"

echo "==> Migrating identity-service..."
cd services/identity-service
if command -v mvn >/dev/null 2>&1; then
    mvn -B flyway:migrate
else
    ./mvnw flyway:migrate
fi

echo "==> Migrating core-banking-service..."
cd ../core-banking-service
if command -v mvn >/dev/null 2>&1; then
    mvn -B flyway:migrate
else
    ./mvnw flyway:migrate
fi

echo "==> Migrating payment-service..."
cd ../payment-service
eval "$(bash ../../scripts/load_env.sh ../../.env)"
DATABASE_URL="postgres://${PAYMENT_DB_USER}:${PAYMENT_DB_PASSWORD}@${POSTGRES_HOST:-localhost}:${POSTGRES_PORT:-5432}/${PAYMENT_DB_NAME}?sslmode=disable"
go run github.com/pressly/goose/v3/cmd/goose@v3.26.0 -dir migrations postgres "$DATABASE_URL" up

echo "==> All migrations applied."
