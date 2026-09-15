# Admin separado del usuario de Datastream (sql/03_create_datastream_login.sql).

resource "random_password" "sqlserver_root_password" {
  length           = 24
  special          = true
  override_special = "!#$%^&*()-_=+[]{}"
}

resource "random_password" "datastream_user_password" {
  length           = 24
  special          = true
  override_special = "!#$%^&*()-_=+[]{}"
}

resource "google_secret_manager_secret" "sqlserver_root_password" {
  secret_id = "${var.db_instance_name}-root-password"
  project   = var.project_id

  replication {
    auto {}
  }

  labels = var.labels

  depends_on = [google_project_service.required]
}

resource "google_secret_manager_secret_version" "sqlserver_root_password" {
  secret      = google_secret_manager_secret.sqlserver_root_password.id
  secret_data = random_password.sqlserver_root_password.result
}

resource "google_secret_manager_secret" "datastream_user_password" {
  secret_id = "${var.db_instance_name}-${var.datastream_db_user}-password"
  project   = var.project_id

  replication {
    auto {}
  }

  labels = var.labels

  depends_on = [google_project_service.required]
}

resource "google_secret_manager_secret_version" "datastream_user_password" {
  secret      = google_secret_manager_secret.datastream_user_password.id
  secret_data = random_password.datastream_user_password.result
}

resource "google_secret_manager_secret_iam_member" "root_accessors" {
  for_each = toset(var.secret_accessors)

  project   = var.project_id
  secret_id = google_secret_manager_secret.sqlserver_root_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = each.value
}

resource "google_secret_manager_secret_iam_member" "datastream_user_accessors" {
  for_each = toset(var.secret_accessors)

  project   = var.project_id
  secret_id = google_secret_manager_secret.datastream_user_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = each.value
}
