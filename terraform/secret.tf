data "google_secret_manager_secret_version" "db_user" {
  secret  = var.db_user_secret_name
  project = var.project_id
}

data "google_secret_manager_secret_version" "db_password" {
  secret  = var.db_password_secret_name
  project = var.project_id
}

data "google_secret_manager_secret_version" "google_client_id" {
  secret  = var.google_client_id_secret_name
  project = var.project_id
}

data "google_secret_manager_secret_version" "google_client_secret" {
  secret  = var.google_client_secret_name
  project = var.project_id
}

data "google_secret_manager_secret_version" "terraform_webhook_secret" {
  secret  = var.terraform_webhook_secret_name
  project = var.project_id
}

data "google_secret_manager_secret_version" "terraform_webhook_key" {
  secret  = var.terraform_webhook_key_secret_name
  project = var.project_id
}


# Decode secret value
locals {
  google_client_id       = data.google_secret_manager_secret_version.google_client_id.secret_data
  google_client_secret   = data.google_secret_manager_secret_version.google_client_secret.secret_data
  terraform_webhook_secret   = data.google_secret_manager_secret_version.terraform_webhook_secret.secret_data
  terraform_webhook_key   = data.google_secret_manager_secret_version.terraform_webhook_key.secret_data

  db_user       = data.google_secret_manager_secret_version.db_user.secret_data
  db_password   = data.google_secret_manager_secret_version.db_password.secret_data
  db_host       = google_sql_database_instance.postgres_instance.private_ip_address

  database_url = "postgresql://${local.db_user}:${local.db_password}@${local.db_host}:${var.db_port}/${var.db_name}?schema=public"
}