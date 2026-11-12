SHELL := /bin/bash

# goose is executed through the Go toolchain so no global install is required.
# Latest stable v3 release compatible with this module's Go version (go 1.24.1);
# newer releases (v3.27+) require Go 1.25.7 or newer.
GOOSE_VERSION ?= v3.26.0
GOOSE := go run github.com/pressly/goose/v3/cmd/goose@$(GOOSE_VERSION)

MIGRATIONS_DIR := migrations

.PHONY: help migrate-up migrate-down migrate-status migrate-new

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "  migrate-up                   Apply all pending migrations"
	@echo "  migrate-down                 Revert the last applied migration"
	@echo "  migrate-status               Show the status of every migration"
	@echo "  migrate-new name=<nombre>    Create the next sequential migration"

ifeq ($(OS),Windows_NT)
migrate-up:
	cmd //c "..\..\scripts\migrate-all.bat"

migrate-down:
	cmd //c "..\..\scripts\migrate-status.bat"

migrate-status:
	cmd //c "..\..\scripts\migrate-status.bat"
else
migrate-up:
	bash ../../scripts/migrate-all.sh

migrate-down:
	bash ../../scripts/migrate-status.sh

migrate-status:
	bash ../../scripts/migrate-status.sh
endif

migrate-new:
	@test -n "$(name)" || (echo "usage: make migrate-new name=<snake_case_description>" && exit 1)
	$(GOOSE) -s -dir $(MIGRATIONS_DIR) create $(name) sql
