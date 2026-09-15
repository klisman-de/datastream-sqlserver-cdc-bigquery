#!/usr/bin/env bash
# Corre sql/05_simulate_changes.sql. Requiere ambos streams de Datastream en RUNNING.
# Uso: ./simulate-changes.sh -p <project_id> -s <server_ip> -r <root_password_secret> [-d db] [-u user]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./get-db-password.sh
source "$SCRIPT_DIR/get-db-password.sh"

db_name="retail_db"
admin_user="sqlserver"

usage() {
  echo "Uso: $0 -p <project_id> -s <server_ip> -r <root_password_secret_name> [-d <db_name>] [-u <admin_user>]" >&2
  exit 1
}

while getopts "p:s:r:d:u:" opt; do
  case "$opt" in
    p) project_id="$OPTARG" ;;
    s) server_ip="$OPTARG" ;;
    r) secret_name="$OPTARG" ;;
    d) db_name="$OPTARG" ;;
    u) admin_user="$OPTARG" ;;
    *) usage ;;
  esac
done

if [[ -z "${project_id:-}" || -z "${server_ip:-}" || -z "${secret_name:-}" ]]; then
  usage
fi

if ! command -v sqlcmd >/dev/null 2>&1; then
  echo "sqlcmd no está en el PATH." >&2
  exit 1
fi

password="$(get_secret_value "$project_id" "$secret_name")"
trap 'unset password' EXIT

echo "==> Ejecutando 05_simulate_changes.sql ..."
# -b: exit code != 0 en error SQL (default de sqlcmd: 0).
sqlcmd -S "${server_ip},1433" -U "$admin_user" -P "$password" -d "$db_name" -C -N -b -i "$SCRIPT_DIR/../sql/05_simulate_changes.sql"

echo "Cambios simulados. Revisa sqlserver_to_bq_merge vs sqlserver_to_bq_append en BigQuery en unos minutos."
