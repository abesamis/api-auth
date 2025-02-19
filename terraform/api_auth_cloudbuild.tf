resource "google_cloudbuild_trigger" "deploy_trigger" {
  name     = "cloud-run-deploy-trigger"
  location = var.region

  service_account = "projects/${var.project_id}/serviceAccounts/${var.account_id}@${var.project_id}.iam.gserviceaccount.com"

  repository_event_config {
    repository = "projects/${var.project_id}/locations/${var.region}/connections/github-${var.region}/repositories/abesamis-api-auth"
    push {
      branch = "^main$"
    }
  }

  git_file_source {
    path       = "cloudbuild.yaml"  
    repository = "projects/${var.project_id}/locations/${var.region}/connections/github-${var.region}/repositories/abesamis-api-auth"
    revision   = "main"
    repo_type  = "GITHUB"
  }

  substitutions = {
    _POSTGRES_INSTANCE_NAME = google_sql_database_instance.postgres_instance.name
    _POSTGRES_HOST          = google_sql_database_instance.postgres_instance.public_ip_address
    _POSTGRES_DB            = var.db_name
    _POSTGRES_PORT          = var.db_port
    _DATABASE_URL           = local.database_url
    _LOCATION               = var.region
  }

}