data "google_project" "current" {}

locals {
  project_number  = data.google_project.current.number
  service_account = "projects/${var.project_id}/serviceAccounts/${var.account_id}@${var.project_id}.iam.gserviceaccount.com"
  repository      = "projects/${var.project_id}/locations/${var.region}/connections/github-${var.region}/repositories/${var.auth_repo_name}"
}

variable "auth_repo_name" {
  type = string
  default = "abesamis-api-auth"
}

variable "auth_service_name" {
  type = string
  default = "api-auth"
}

variable "frontend_service_name" {
  type = string
  default = "frontend-app"
}

variable "project_id" {
  type = string
  default = "peppy-strategy-450006-a7"
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "postgres_instance" {
  type    = string
  default = "postgresql-17"
}

variable "account_id" {
  type    = string
  default = "cloud-build-service-account"
}

variable "postgres_instance_name" {
  type    = string
  default = "postgresql-17"
}


variable "db_name" {
  type    = string
  default = "auth"
}

variable "db_port" {
  type    = number
  default = 5432
}

variable "db_password_secret_name" {
  type    = string
  default = "db_password"
}

variable "db_user_secret_name" {
  type    = string
  default = "db_user"
}

variable "google_client_secret_name" {
  type    = string
  default = "google_client_secret"
}

variable "google_client_id_secret_name" {
  type    = string
  default = "google_client_id"
}

variable "terraform_webhook_secret_name" {
  type    = string
  default = "terraform_webhook_secret"
}

variable "terraform_webhook_key_secret_name" {
  type    = string
  default = "terraform_webhook_key"
}