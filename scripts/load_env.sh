#!/usr/bin/env bash
# Exporta las variables de un archivo .env en el shell que lo invoca.
# Soporta CRLF (Windows) y ignora comentarios/líneas vacías.
# Uso: eval "$(bash scripts/load_env.sh .env)"
set -eo pipefail

ENV_FILE="${1:-.env}"

if [ ! -f "$ENV_FILE" ]; then
    echo "ERROR: archivo de entorno no encontrado: $ENV_FILE" >&2
    exit 1
fi

while IFS= read -r line || [ -n "$line" ]; do
    # Eliminar CR final (archivos CRLF de Windows)
    line="${line%$'\r'}"
    # Ignorar líneas vacías y comentarios
    case "$line" in
        ''|\#*) continue ;;
    esac
    # Dividir en clave y valor en el primer '='
    k="${line%%=*}"
    v="${line#*=}"
    # Ignorar líneas sin clave
    [ -z "$k" ] && continue
    printf 'export %s=%s\n' "$k" "$v"
done < "$ENV_FILE"
