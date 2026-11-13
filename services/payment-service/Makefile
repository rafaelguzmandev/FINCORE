SHELL := /bin/bash

# On Windows GNU make executes recipes through Git Bash; on POSIX systems
# plain bash is used. The migration logic itself lives in migrate.sh.
ifeq ($(OS),Windows_NT)
BASH ?= C:/Program Files/Git/bin/bash.exe
endif
BASH ?= bash

MIGRATIONS_DIR := migrations

.PHONY: help migrate-up migrate-down migrate-status migrate-new

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "  migrate-up                   Apply all pending migrations"
	@echo "  migrate-down                 Revert the last applied migration"
	@echo "  migrate-status               Show the status of every migration"
	@echo "  migrate-new name=<nombre>    Create the next sequential migration"

migrate-up:
	@"$(BASH)" migrate.sh up

migrate-down:
	@"$(BASH)" migrate.sh down

migrate-status:
	@"$(BASH)" migrate.sh status

migrate-new:
	@test -n "$(name)" || (echo "usage: make migrate-new name=<snake_case_description>" && exit 1)
	@"$(BASH)" migrate.sh new $(name)
