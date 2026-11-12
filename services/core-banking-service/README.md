# Core Banking Service

Responsible for core banking operations and account
management within FINCORE.

## Technology
- Java 21
- Spring Boot
- Maven

## Build
./mvnw clean package

## Test
./mvnw test

## Run

Prerequisites: PostgreSQL running (see root `README.md`, section "Running the Services").

```bash
cd services/core-banking-service
./mvnw spring-boot:run
```

Or build and run the jar:

```bash
./mvnw clean package
java -jar target/core-banking-service-0.0.1-SNAPSHOT.jar
```

Health endpoint: `http://localhost:8080/health`

Configuration is loaded from environment variables (`CORE_BANKING_DB_*`, `POSTGRES_HOST`, `POSTGRES_PORT`, `SERVER_PORT`). See `.env.example`.
