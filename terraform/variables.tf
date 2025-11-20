variable "project" {
  description = "ID du projet GCP"
  default     = "gentle-brace-477910-h1"  # remplace si ton projet a un autre ID
}

variable "region" {
  description = "Région GCP"
  default     = "europe-west4"
}

variable "worker_count" {
  description = "Nombre de workers Spark"
  default     = 2
}
