# Check if the service account already exists
data "google_service_account" "existing_cloud_run_sa" {
  account_id = var.account_id
}

# Create the service account only if it doesn’t exist
resource "google_service_account" "cloud_run_sa" {
  count        = length(data.google_service_account.existing_cloud_run_sa.email) > 0 ? 0 : 1
  account_id   = var.account_id
  display_name = "Cloud Run Auth Service Account"
}

# Use the existing or newly created service account dynamically
locals {
  cloud_run_sa_email = try(data.google_service_account.existing_cloud_run_sa.email, google_service_account.cloud_run_sa[0].email)
}

# Grant Cloud Run access to Cloud SQL
resource "google_project_iam_member" "cloudsql_client_role" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${local.cloud_run_sa_email}"
}

# Grant Cloud Run access to Secret Manager
resource "google_project_iam_member" "secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${local.cloud_run_sa_email}"
}

# Cloud SQL Instance (PostgreSQL)
resource "google_sql_database_instance" "postgres_instance" {
  name             = var.postgres_instance_name
  database_version = "POSTGRES_17"
  region           = var.region

  settings {
    edition           = "ENTERPRISE"
    tier              = "db-f1-micro"
    disk_size         = 20
    availability_type = "REGIONAL"

    ip_configuration {
      ipv4_enabled    = true
      private_network = "projects/${var.project_id}/global/networks/default"
    }

    backup_configuration {
      enabled    = true
      start_time = "19:00"
      location   = var.region
    }
  }
}

resource "google_sql_user" "db_user" {
  name     = local.db_user
  instance = google_sql_database_instance.postgres_instance.name
  password = local.db_password
}

# Database Creation
resource "google_sql_database" "default" {
  name     = var.db_name
  instance = google_sql_database_instance.postgres_instance.name
}