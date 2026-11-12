@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0.."

:: Cargar variables de entorno desde .env (tolerando CRLF y comentarios)
for /f "usebackq tokens=1,* delims==" %%a in (".env") do (
    set "line=%%a"
    if not "!line:~0,1!"=="#" if not "!line!"=="" (
        for /f "tokens=1,* delims==" %%k in ("!line!") do (
            if not "%%k"=="" (
                set "%%k=%%l"
            )
        )
    )
)

:: Fallback JAVA_HOME si no se propagó a través de make
if not defined JAVA_HOME (
    set JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-21.0.13.9-hotspot
)

echo ==> Migrating identity-service...
cd /d services\identity-service
mvn -B flyway:migrate

echo ==> Migrating core-banking-service...
cd /d ..\core-banking-service
mvn -B flyway:migrate

echo ==> Migrating payment-service...
cd /d ..\payment-service
:: Recargar .env desde la raíz
for /f "usebackq tokens=1,* delims==" %%a in ("..\..\.env") do (
    set "line=%%a"
    if not "!line:~0,1!"=="#" if not "!line!"=="" (
        for /f "tokens=1,* delims==" %%k in ("!line!") do (
            if not "%%k"=="" (
                set "%%k=%%l"
            )
        )
    )
)
set DATABASE_URL=postgres://%PAYMENT_DB_USER%:%PAYMENT_DB_PASSWORD%@%POSTGRES_HOST%:%POSTGRES_PORT%/%PAYMENT_DB_NAME%?sslmode=disable
go run github.com/pressly/goose/v3/cmd/goose@v3.26.0 -dir migrations postgres "%DATABASE_URL%" up

echo ==> All migrations applied.
endlocal
