#!/usr/bin/env bash
# Aplica las migraciones pendientes de los tres servicios (identity, core-banking, payment).
# Detiene en el primer fallo.
#
# Uso: bash scripts/migrate-all.sh
set -eo pipefail

cd "$(dirname "$0")/.."

# Derivar JAVA_HOME desde el java del PATH (mvnw lo necesita).
if [ -z "${JAVA_HOME:-}" ] && command -v java >/dev/null 2>&1; then
    export JAVA_HOME="$(cd "$(dirname "$(dirname "$(which java)")")" && pwd)"
fi

# Cargar variables de entorno del repositorio
eval "$(bash scripts/load_env.sh .env)"

echo "==> Migrating identity-service..."
cd services/identity-service
./mvnw -B flyway:migrate

echo "==> Migrating core-banking-service..."
cd ../core-banking-service
./mvnw -B flyway:migrate

echo "==> Migrating payment-service..."
cd ../payment-service
bash migrate.sh up

echo "==> All migrations applied."
