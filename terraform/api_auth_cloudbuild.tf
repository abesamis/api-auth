resource "google_cloudbuild_trigger" "deploy_trigger" {
  name     = "cloud-run-deploy-trigger"
  location = var.region

  service_account = local.service_account

  repository_event_config {
    repository = local.repository
    push {
      branch = "^main$"
    }
  }

  git_file_source {
    path       = "cloudbuild.yaml"  
    repository = local.repository
    revision   = "main"
    repo_type  = "GITHUB"
  }

  substitutions = {
    _POSTGRES_INSTANCE_NAME = google_sql_database_instance.postgres_instance.name
    _POSTGRES_HOST          = google_sql_database_instance.postgres_instance.private_ip_address
    _POSTGRES_DB            = var.db_name
    _POSTGRES_PORT          = var.db_port
    _DATABASE_URL           = local.database_url
    _LOCATION               = var.region
    _SERVICE_ACCOUNT        = local.service_account
    _SERVICE_NAME           = var.service_name
  }

}