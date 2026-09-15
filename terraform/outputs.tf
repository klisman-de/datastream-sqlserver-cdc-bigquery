output "sqlserver_instance_connection_name" {
  description = "Connection name de la instancia Cloud SQL (para Cloud SQL Auth Proxy)."
  value       = google_sql_database_instance.sqlserver.connection_name
}

output "sqlserver_public_ip" {
  description = "IP pública de la instancia Cloud SQL SQL Server."
  value       = google_sql_database_instance.sqlserver.public_ip_address
}

output "db_name" {
  description = "Nombre de la base de datos."
  value       = google_sql_database.retail.name
}

output "datastream_db_user" {
  description = "Usuario SQL Server usado por Datastream."
  value       = google_sql_user.datastream_user.name
}

output "sqlserver_root_password_secret" {
  description = "Nombre del secreto en Secret Manager con la password del usuario admin (sqlserver)."
  value       = google_secret_manager_secret.sqlserver_root_password.secret_id
}

output "datastream_user_password_secret" {
  description = "Nombre del secreto en Secret Manager con la password del usuario de Datastream."
  value       = google_secret_manager_secret.datastream_user_password.secret_id
}

output "bq_merge_dataset" {
  description = "Dataset de BigQuery destino del stream merge."
  value       = google_bigquery_dataset.merge.dataset_id
}

output "bq_append_dataset" {
  description = "Dataset de BigQuery destino del stream append-only."
  value       = google_bigquery_dataset.append.dataset_id
}

output "datastream_merge_stream_id" {
  description = "ID del stream en modo merge."
  value       = google_datastream_stream.merge.stream_id
}

output "datastream_append_stream_id" {
  description = "ID del stream en modo append-only."
  value       = google_datastream_stream.append.stream_id
}
