Description

Create the initial runnable application skeleton for each FinCore service.

The objective is to establish a consistent starting point for development, with independent applications, configuration management and basic health endpoints.

Services

Identity Service

Java 21.

Spring Boot.

Independent application entry point.

Basic health endpoint.

Core Banking Service

Java 21.

Spring Boot.

Independent application entry point.

Basic health endpoint.

Payment Service

Go.

Independent application entry point.

Basic health endpoint.

Scope

Initialize each application.

Configure environment-based application settings.

Add a basic HTTP server.

Expose a health endpoint.

Configure database connection settings.

Add basic startup and shutdown behavior.

Ensure each service can be started independently.

Add minimal tests verifying application startup and health endpoint behavior.

Acceptance Criteria

All three services compile successfully.

Each service can start independently.

Each service exposes a health endpoint.

Configuration is loaded from environment variables.

Database connection settings are service-specific.

Basic startup and health tests pass.

No financial business logic is implemented.

Out of Scope

Authentication and authorization.

Customer registration.

Account creation.

Transfers.

Ledger operations.

Inter-service communication.

Definition of Done

All three applications are independently runnable and have a minimal, tested foundation for future development.