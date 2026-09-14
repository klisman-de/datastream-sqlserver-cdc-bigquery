# project_id/region sin default: completar los valores en terraform.tfvars.

variable "project_id" {
  description = "Project ID de GCP donde se crean todos los recursos."
  type        = string

  validation {
    condition     = length(var.project_id) > 0
    error_message = "project_id no puede quedar vacío. Complétalo en terraform.tfvars."
  }
}

variable "region" {
  description = "Región de GCP para Cloud SQL, BigQuery y Datastream (ej: us-central1, southamerica-west1)."
  type        = string

  validation {
    condition     = length(var.region) > 0
    error_message = "region no puede quedar vacío. Complétalo en terraform.tfvars."
  }
}

variable "authorized_networks" {
  description = <<-EOT
    CIDRs autorizados a la IP pública de Cloud SQL: tu IP + egress de Datastream para la
    región (https://cloud.google.com/datastream/docs/ip-allowlists-and-regions).
    Formato: { name = string, cidr = string }.
  EOT
  type = list(object({
    name = string
    cidr = string
  }))
  default = [] # TODO: agregar las IPs de Datastream para tu región + tu IP de administración
}

variable "db_instance_name" {
  description = "Nombre de la instancia de Cloud SQL for SQL Server."
  type        = string
  default     = "sqlserver-to-bq"
}

variable "db_tier" {
  description = "Tier de máquina de la instancia Cloud SQL. Mínimo soportado para SQL Server."
  type        = string
  default     = "db-custom-2-8192"
}

variable "db_version" {
  description = "Versión/edición de SQL Server. Standard soporta CDC desde SQL Server 2016 SP1+."
  type        = string
  default     = "SQLSERVER_2019_STANDARD"
}

variable "db_name" {
  description = "Nombre de la base de datos dentro de la instancia."
  type        = string
  default     = "retail_db"
}

variable "db_disk_size_gb" {
  description = "Tamaño de disco (GB) de la instancia Cloud SQL."
  type        = number
  default     = 20
}

variable "datastream_db_user" {
  description = "Usuario SQL Server dedicado para la conexión de Datastream (no admin)."
  type        = string
  default     = "datastream_user"
}

variable "deletion_protection" {
  description = "Protección contra borrado accidental de la instancia Cloud SQL."
  type        = bool
  default     = false
}

variable "bq_merge_dataset_id" {
  description = "Dataset de BigQuery destino para el stream en modo merge (estado actual)."
  type        = string
  default     = "sqlserver_to_bq_merge"
}

variable "bq_append_dataset_id" {
  description = "Dataset de BigQuery destino para el stream en modo append-only (histórico de cambios)."
  type        = string
  default     = "sqlserver_to_bq_append"
}

variable "secret_accessors" {
  description = <<-EOT
    Miembros IAM (user:/group:/serviceAccount:) con roles/secretmanager.secretAccessor
    sobre el secreto de la password. Requerido para correr sql/ localmente.
  EOT
  type        = list(string)
  default     = [] # TODO: ej. ["user: usuario@dominio.com"]
}

variable "labels" {
  description = "Labels comunes aplicados a los recursos que lo soportan."
  type        = map(string)
  default = {
    project = "sqlserver-to-bq"
  }
}
