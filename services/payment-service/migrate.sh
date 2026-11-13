#!/usr/bin/env bash
# Payment-service migration runner (goose). Single source of truth for the
# goose version, the connection URL and the available actions.
#
# Usage: bash migrate.sh <up|down|status|new> [name]
#
# The migration directory is always ./migrations (owned by this service).
set -eo pipefail

cd "$(dirname "$0")"

GOOSE_VERSION="${GOOSE_VERSION:-v3.26.0}"
GOOSE=(go run "github.com/pressly/goose/v3/cmd/goose@${GOOSE_VERSION}")

# Load the repository environment variables (.env at the repo root).
eval "$(bash ../../scripts/load_env.sh ../../.env)"

DATABASE_URL="postgres://${PAYMENT_DB_USER}:${PAYMENT_DB_PASSWORD}@${POSTGRES_HOST:-localhost}:${POSTGRES_PORT:-5432}/${PAYMENT_DB_NAME}?sslmode=disable"

action="${1:-}"
shift || true

case "$action" in
    up)
        "${GOOSE[@]}" -dir migrations postgres "$DATABASE_URL" up
        ;;
    down)
        # Reverts the most recently applied migration.
        "${GOOSE[@]}" -dir migrations postgres "$DATABASE_URL" down
        ;;
    status)
        "${GOOSE[@]}" -dir migrations postgres "$DATABASE_URL" status
        ;;
    new)
        name="${1:-}"
        if [ -z "$name" ]; then
            echo "usage: bash migrate.sh new <snake_case_description>" >&2
            exit 1
        fi
        "${GOOSE[@]}" -s -dir migrations create "$name" sql
        ;;
    *)
        echo "usage: bash migrate.sh <up|down|status|new> [name]" >&2
        exit 1
        ;;
esac
