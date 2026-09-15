#!/usr/bin/env bash
# Lee un secreto de Secret Manager por stdout, no va a logs. Uso:
#   source ./get-db-password.sh
#   password="$(get_secret_value "$PROJECT_ID" "$SECRET_NAME")"
# Requiere roles/secretmanager.secretAccessor (ver terraform.tfvars -> secret_accessors).

get_secret_value() {
  local project_id="$1"
  local secret_name="$2"
  local version="${3:-latest}"

  if [[ -z "$project_id" || -z "$secret_name" ]]; then
    echo "get_secret_value: se requieren project_id y secret_name" >&2
    return 1
  fi

  local value
  # gcloud ya decodifica el payload; sale en texto plano por stdout.
  if ! value="$(gcloud secrets versions access "$version" \
      --secret="$secret_name" \
      --project="$project_id" 2>/dev/null)"; then
    echo "No se pudo leer el secreto '$secret_name' (proyecto '$project_id'): nombre, proyecto o roles/secretmanager.secretAccessor." >&2
    return 1
  fi

  if [[ -z "$value" ]]; then
    echo "El secreto '$secret_name' está vacío o no existe." >&2
    return 1
  fi

  printf '%s' "$value"
}
