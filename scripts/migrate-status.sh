#!/usr/bin/env bash
# Muestra el estado de las migraciones de los tres servicios.
#
# Uso: bash scripts/migrate-status.sh
set -eo pipefail

cd "$(dirname "$0")/.."

# Derivar JAVA_HOME desde el java del PATH (mvnw lo necesita).
if [ -z "${JAVA_HOME:-}" ] && command -v java >/dev/null 2>&1; then
    export JAVA_HOME="$(cd "$(dirname "$(dirname "$(which java)")")" && pwd)"
fi

eval "$(bash scripts/load_env.sh .env)"

echo "==> identity-service"
cd services/identity-service
./mvnw -B flyway:info

echo "==> core-banking-service"
cd ../core-banking-service
./mvnw -B flyway:info

echo "==> payment-service"
cd ../payment-service
bash migrate.sh status
