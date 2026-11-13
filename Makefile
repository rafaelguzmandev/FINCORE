SHELL := /bin/bash

# On Windows GNU make executes recipes through Git Bash; on POSIX systems
# plain bash is used.
ifeq ($(OS),Windows_NT)
BASH ?= C:/Program Files/Git/bin/bash.exe
endif
BASH ?= bash

.PHONY: migrate-all migrate-status

## Apply every pending migration, in service order. Stops on the first failure.
migrate-all:
	@"$(BASH)" scripts/migrate-all.sh

## Show the migration history of each service.
migrate-status:
	@"$(BASH)" scripts/migrate-status.sh
