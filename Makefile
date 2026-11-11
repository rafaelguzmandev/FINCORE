SHELL := /bin/sh

ENV_FILE ?= .env

# Load the repository environment, tolerating CRLF line endings.
ENV_LOAD = set -a && eval "$$(tr -d '\r' < $(ENV_FILE))" && set +a

.PHONY: migrate-all migrate-status \
	migrate-identity migrate-core-banking migrate-payment \
	status-identity status-core-banking status-payment

## Apply every pending migration, in service order. Stops on the first failure.
migrate-all: migrate-identity migrate-core-banking migrate-payment

migrate-identity:
	$(ENV_LOAD) && cd services/identity-service && ./mvnw flyway:migrate

migrate-core-banking:
	$(ENV_LOAD) && cd services/core-banking-service && ./mvnw flyway:migrate

migrate-payment:
	$(MAKE) -C services/payment-service migrate-up

## Show the migration history of each service.
migrate-status: status-identity status-core-banking status-payment

status-identity:
	$(ENV_LOAD) && cd services/identity-service && ./mvnw flyway:info

status-core-banking:
	$(ENV_LOAD) && cd services/core-banking-service && ./mvnw flyway:info

status-payment:
	$(MAKE) -C services/payment-service migrate-status
