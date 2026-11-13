# Payment Service

Responsible for payment processing within FINCORE.

## Technology
- Go

## Build
go build ./...

## Test
go test ./...

## Static Analysis
go vet ./...

## Run

Prerequisites: PostgreSQL running (see root `README.md`, section "Running the Services").

```bash
cd services/payment-service
go run ./cmd/payment
```

Or build and run the binary:

```bash
go build -o payment-service.exe ./cmd/payment
.\payment-service.exe
```

Health endpoint: `http://localhost:8080/health`

Configuration is loaded from environment variables (`PAYMENT_DB_*`, `POSTGRES_HOST`, `POSTGRES_PORT`, `SERVER_PORT`). See `.env.example`.

## Migrations

Migrations live in `migrations/` and are applied with goose. The migration
logic (goose version, connection URL) lives in `migrate.sh`:

```bash
make migrate-up                        # apply pending migrations
make migrate-down                      # revert the last applied migration
make migrate-status                    # show the status of every migration
make migrate-new name=create_transfers # create the next sequential file
```

These targets operate only on this service's database. Use the repository
root `make migrate-all` to migrate the three services in order.
