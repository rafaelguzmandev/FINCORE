SHELL := /bin/bash

.PHONY: migrate-all migrate-status

ifeq ($(OS),Windows_NT)
## Apply every pending migration, in service order. Stops on the first failure.
migrate-all:
	cmd //c "scripts\migrate-all.bat"

## Show the migration history of each service.
migrate-status:
	cmd //c "scripts\migrate-status.bat"
else
## Apply every pending migration, in service order. Stops on the first failure.
migrate-all:
	bash scripts/migrate-all.sh

## Show the migration history of each service.
migrate-status:
	bash scripts/migrate-status.sh
endif
