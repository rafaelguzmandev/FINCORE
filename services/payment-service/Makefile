SHELL := /bin/sh

# goose is executed through the Go toolchain so no global install is required.
# Latest stable v3 release compatible with this module's Go version (go 1.24.1);
# newer releases (v3.27+) require Go 1.25.7 or newer.
GOOSE_VERSION ?= v3.26.0
GOOSE := go run github.com/pressly/goose/v3/cmd/goose@$(GOOSE_VERSION)

ENV_FILE ?= ../../.env
MIGRATIONS_DIR := migrations

# Load the service environment from the repository root. `tr` strips CR so the
# file can be authored on Windows without breaking the shell.
ENV_LOAD = set -a && eval "$$(tr -d '\r' < $(ENV_FILE))" && set +a

# Built from the PAYMENT_DB_* variables at recipe time.
DATABASE_URL ?= postgres://$${PAYMENT_DB_USER}:$${PAYMENT_DB_PASSWORD}@$${POSTGRES_HOST:-localhost}:$${POSTGRES_PORT:-5432}/$${PAYMENT_DB_NAME}?sslmode=disable

.PHONY: help migrate-up migrate-down migrate-status migrate-new

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "  migrate-up                   Apply all pending migrations"
	@echo "  migrate-down                 Revert the last applied migration"
	@echo "  migrate-status               Show the status of every migration"
	@echo "  migrate-new name=<nombre>    Create the next sequential migration"

migrate-up:
	$(ENV_LOAD) && $(GOOSE) -dir $(MIGRATIONS_DIR) postgres "$(DATABASE_URL)" up

migrate-down:
	$(ENV_LOAD) && $(GOOSE) -dir $(MIGRATIONS_DIR) postgres "$(DATABASE_URL)" down

migrate-status:
	$(ENV_LOAD) && $(GOOSE) -dir $(MIGRATIONS_DIR) postgres "$(DATABASE_URL)" status

migrate-new:
	@test -n "$(name)" || (echo "usage: make migrate-new name=<snake_case_description>" && exit 1)
	$(GOOSE) -s -dir $(MIGRATIONS_DIR) create $(name) sql
