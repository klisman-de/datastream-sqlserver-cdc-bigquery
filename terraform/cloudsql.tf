resource "google_sql_database_instance" "sqlserver" {
  name             = var.db_instance_name
  project          = var.project_id
  region           = var.region
  database_version = var.db_version
  root_password    = random_password.sqlserver_root_password.result

  deletion_protection = var.deletion_protection

  settings {
    tier      = var.db_tier
    disk_size = var.db_disk_size_gb
    disk_type = "PD_SSD"

    # IP pública + allowlist: método de conectividad de Datastream para SQL Server.
    ip_configuration {
      ipv4_enabled = true

      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.cidr
        }
      }
    }

    backup_configuration {
      enabled = true
    }

    user_labels = var.labels
  }

  depends_on = [google_project_service.required]
}

resource "google_sql_database" "retail" {
  name     = var.db_name
  project  = var.project_id
  instance = google_sql_database_instance.sqlserver.name
}

# Grants a nivel DB en sql/03_create_datastream_login.sql.
resource "google_sql_user" "datastream_user" {
  name     = var.datastream_db_user
  project  = var.project_id
  instance = google_sql_database_instance.sqlserver.name
  password = random_password.datastream_user_password.result
}
