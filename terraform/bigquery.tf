resource "google_bigquery_dataset" "merge" {
  dataset_id  = var.bq_merge_dataset_id
  project     = var.project_id
  location    = var.region
  description = "Destino del stream de Datastream en modo MERGE: refleja el estado actual de las tablas de origen (upsert por PK)."

  labels = var.labels

  depends_on = [google_project_service.required]
}

resource "google_bigquery_dataset" "append" {
  dataset_id  = var.bq_append_dataset_id
  project     = var.project_id
  location    = var.region
  description = "Destino del stream de Datastream en modo APPEND-ONLY: log histórico de todos los eventos de cambio (CDC crudo)."

  labels = var.labels

  depends_on = [google_project_service.required]
}
