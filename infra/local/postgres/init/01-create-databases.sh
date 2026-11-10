
#!/bin/bash

set -e

create_database() {
    local database="$1"
    local username="$2"
    local password="$3"

    echo "Creating database: ${database}"

    psql \
        --username "$POSTGRES_USER" \
        --dbname "$POSTGRES_DB" \
        --set=ON_ERROR_STOP=1 \
        --set=username="$username" \
        --set=password="$password" \
        --set=database="$database" <<'EOSQL'

SELECT format(
    'CREATE ROLE %I LOGIN PASSWORD %L',
    :'username',
    :'password'
) \gexec

SELECT format(
    'CREATE DATABASE %I OWNER %I',
    :'database',
    :'username'
) \gexec

EOSQL
}

create_database \
    "identity_db" \
    "$IDENTITY_DB_USER" \
    "$IDENTITY_DB_PASSWORD"

create_database \
    "core_banking_db" \
    "$CORE_BANKING_DB_USER" \
    "$CORE_BANKING_DB_PASSWORD"

create_database \
    "payment_db" \
    "$PAYMENT_DB_USER" \
    "$PAYMENT_DB_PASSWORD"

echo "FINCORE databases initialized successfully."
