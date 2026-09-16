#!/usr/bin/env bash
# Corre sql/01..04: tablas, CDC, usuario de Datastream, seed. Requiere sqlcmd en PATH,
# terraform apply ya aplicado, e IP propia en authorized_networks.
# Uso: ./run-sql-setup.sh -p <project_id> -s <server_ip> -r <root_password_secret> [-d db] [-u user]

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

sql_dir="$SCRIPT_DIR/../sql"
sql_files=(01_create_tables.sql 02_enable_cdc.sql 03_create_datastream_login.sql 04_seed_data.sql)

for file in "${sql_files[@]}"; do
  echo "==> Ejecutando $file ..."
  sql_path="$sql_dir/$file"
  # cygpath -w: la conversión automática de MSYS a sqlcmd.exe rompe rutas con "..".
  command -v cygpath >/dev/null 2>&1 && sql_path="$(cygpath -w "$sql_path")"
  # -C: cert TLS de Cloud SQL. -b: exit code != 0 en error SQL (default de sqlcmd: 0).
  sqlcmd -S "${server_ip},1433" -U "$admin_user" -P "$password" -d "$db_name" -C -N -b -i "$sql_path"
done

echo "Setup SQL completado."
