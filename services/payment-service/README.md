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
