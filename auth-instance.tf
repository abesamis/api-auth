terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "peppy-strategy-450006-a7"
  region  = "us-west1"
}

# Cloud Build Trigger
resource "google_cloudbuild_trigger" "deploy_trigger" {
  name     = "cloud-run-deploy-trigger"
  location = "us-west1"

  service_account = "projects/peppy-strategy-450006-a7/serviceAccounts/cloud-build-service-account@peppy-strategy-450006-a7.iam.gserviceaccount.com"

  repository_event_config {
    repository = "projects/peppy-strategy-450006-a7/locations/us-west1/connections/Github/repositories/abesamis-api-auth"
    push {
      branch = "^main$"
    }
  }

  git_file_source {
    path       = "cloudbuild.yaml"  
    repository = "projects/peppy-strategy-450006-a7/locations/us-west1/connections/Github/repositories/abesamis-api-auth"
    revision   = "main"
    repo_type  = "GITHUB"
  }

}
