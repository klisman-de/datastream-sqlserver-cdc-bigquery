# Schema verificado contra hashicorp/google 6.50.0 (`terraform providers schema -json`).
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/datastream_stream

resource "google_datastream_connection_profile" "sqlserver_source" {
  project               = var.project_id
  location              = var.region
  connection_profile_id = "${var.db_instance_name}-source"
  display_name          = "Cloud SQL SQL Server (source)"

  sql_server_profile {
    hostname = google_sql_database_instance.sqlserver.public_ip_address
    port     = 1433
    username = google_sql_user.datastream_user.name
    password = random_password.datastream_user_password.result
    database = var.db_name
  }

  depends_on = [google_sql_database.retail]
}

resource "google_datastream_connection_profile" "bigquery_dest" {
  project               = var.project_id
  location              = var.region
  connection_profile_id = "${var.db_instance_name}-bigquery"
  display_name          = "BigQuery (destination)"

  bigquery_profile {}

  depends_on = [google_project_service.required]
}

# MERGE: BigQuery refleja el estado actual del origen (upsert por PK).
resource "google_datastream_stream" "merge" {
  project       = var.project_id
  location      = var.region
  stream_id     = "${var.db_instance_name}-merge"
  display_name  = "SQL Server to BigQuery (merge)"
  desired_state = "RUNNING"

  source_config {
    source_connection_profile = google_datastream_connection_profile.sqlserver_source.id

    sql_server_source_config {
      # CDC vía change tables nativas, no transaction log: evita el requisito de log
      # truncation safeguard de Datastream.
      change_tables {}

      include_objects {
        schemas {
          schema = "dbo"
          tables {
            table = "customers"
          }
          tables {
            table = "orders"
          }
        }
      }
    }
  }

  destination_config {
    destination_connection_profile = google_datastream_connection_profile.bigquery_dest.id

    bigquery_destination_config {
      data_freshness = "300s"

      single_target_dataset {
        dataset_id = "${var.project_id}:${google_bigquery_dataset.merge.dataset_id}"
      }

      merge {}
    }
  }

  backfill_all {}
}

# APPEND-ONLY: cada evento de cambio es una fila nueva.
resource "google_datastream_stream" "append" {
  project       = var.project_id
  location      = var.region
  stream_id     = "${var.db_instance_name}-append"
  display_name  = "SQL Server to BigQuery (append-only)"
  desired_state = "RUNNING"

  source_config {
    source_connection_profile = google_datastream_connection_profile.sqlserver_source.id

    sql_server_source_config {
      # CDC vía change tables nativas, no transaction log: evita el requisito de log
      # truncation safeguard de Datastream.
      change_tables {}

      include_objects {
        schemas {
          schema = "dbo"
          tables {
            table = "customers"
          }
          tables {
            table = "orders"
          }
        }
      }
    }
  }

  destination_config {
    destination_connection_profile = google_datastream_connection_profile.bigquery_dest.id

    bigquery_destination_config {
      data_freshness = "300s"

      single_target_dataset {
        dataset_id = "${var.project_id}:${google_bigquery_dataset.append.dataset_id}"
      }

      append_only {}
    }
  }

  backfill_all {}
}
