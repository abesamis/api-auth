data "google_secret_manager_secret_version" "db_user" {
  secret  = var.db_user_secret_name
  project = var.project_id
}

data "google_secret_manager_secret_version" "db_password" {
  secret  = var.db_password_secret_name
  project = var.project_id
}

# Decode secret value
locals {
  db_user       = data.google_secret_manager_secret_version.db_user.secret_data
  db_password   = data.google_secret_manager_secret_version.db_password.secret_data
  db_host       = google_sql_database_instance.postgres_instance.private_ip_address

  database_url = "postgresql://${local.db_user}:${local.db_password}@${local.db_host}:${var.db_port}/${var.db_name}?schema=public"
}