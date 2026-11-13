# Conventions

Project-wide conventions for FINCORE. See the service READMEs and
`docs/specs/` for feature-specific details.

## Code formatting

- Go is formatted with `gofmt` and enforced in CI (`.github/workflows/ci.yml`).
- Java has no standard formatting tool in the toolchain. CI deliberately does
  not enforce a Java formatter; if the team adopts one (e.g. Spotless), the
  check must be added to CI in the same change.

## Database migrations

Each service owns its schema and its migration history. Migrations live
inside the service directory; there is no shared migration folder. A service
never migrates another service's database and uses only its own credentials.

| Service | Tool | Location | History table |
|---|---|---|---|
| Identity Service | Flyway | `services/identity-service/src/main/resources/db/migration` | `flyway_schema_history` |
| Core Banking Service | Flyway | `services/core-banking-service/src/main/resources/db/migration` | `flyway_schema_history` |
| Payment Service | goose | `services/payment-service/migrations` | `goose_db_version` |

All migrations are plain SQL. They are applied explicitly, never as a side
effect of starting a service.

### Naming

| Service | Pattern | Example |
|---|---|---|
| Java (Flyway) | `V{n}__{descripcion_snake_case}.sql` | `V2__create_customers.sql` |
| Go (goose) | `{nnnnn}_{descripcion_snake_case}.sql` | `00002_create_transfers.sql` |

Rules:

- Versions are sequential integers with no gaps (`V1`, `V2`, ... and
  `00001`, `00002`, ...). Timestamps are not used.
- The description is in English, snake_case, and starts with a verb:
  `create_`, `add_`, `alter_`, `drop_`.
- One migration = one logical change.
- Never edit a migration that has been applied or merged. Fix it with a new
  migration.

### Rollback

| Service | Support |
|---|---|
| Go / goose | Every migration declares `-- +goose Down` |
| Java / Flyway | No undo (Community). Roll-forward only: correct with a new migration |

Rules:

- Local environment: `docker compose down -v && docker compose up -d` resets
  all databases, then re-run the migrations.
- Destructive migrations (`DROP`, lossy type changes) must be marked as
  non-reversible in the pull request.
- For financial tables (ledger, postings, journal entries) rollback is unsafe
  by design: posted movements are immutable. Always roll forward.

### Adding a migration

Java services:

```bash
cd services/identity-service
# Create src/main/resources/db/migration/V2__create_customers.sql
./mvnw flyway:migrate
./mvnw flyway:info
```

Payment service:

```bash
cd services/payment-service
make migrate-new name=create_transfers   # creates the next sequential file
make migrate-up
make migrate-status
```

Cross-cutting commands from the repository root:

```bash
make migrate-all      # applies pending migrations in all three services
make migrate-status   # shows each service's migration history
```

`make` targets require a POSIX shell (Linux, macOS, WSL or Git Bash) and an
`.env` file at the repository root, created from `.env.example`.
