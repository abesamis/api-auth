resource "google_cloudbuild_trigger" "deploy_trigger" {
  name     = "${var.auth_service_name}-build-trigger"
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
    _SERVICE_NAME           = var.auth_service_name
  }

}

resource "null_resource" "api_auth_force_build" {
  provisioner "local-exec" {
    command = <<EOT
      # Trigger the build and capture the build ID
      echo "Triggering Cloud Build..."
      BUILD_ID=$(gcloud builds triggers run ${google_cloudbuild_trigger.deploy_trigger.name} \
      --project="${var.project_id}" \
      --region="${var.region}" \
      --format="value(metadata.build.id)")

      if [ -z "$BUILD_ID" ]; then
        echo "Error: Could not get build ID."
        exit 1
      fi

      echo "Build ID: $BUILD_ID"

      # Wait for the build to finish using build ID
      echo "Waiting for Cloud Build to finish..."
      end=$((SECONDS+600))  # Timeout after 10 minutes
      while [ $SECONDS -lt $end ]; do
        STATUS=$(gcloud builds describe $BUILD_ID \
          --project="${var.project_id}" \
          --region="${var.region}" \
          --format="value(status)")

        echo "Current status: $STATUS"
        if [[ "$STATUS" == "SUCCESS" ]]; then
          echo "Build finished successfully!"
          exit 0
        elif [[ "$STATUS" == "FAILURE" || "$STATUS" == "CANCELLED" ]]; then
          echo "Build failed or was cancelled."
          exit 1
        fi

        sleep 10
      done

      echo "Build timed out after 10 minutes."
      exit 1
    EOT

    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [google_cloudbuild_trigger.deploy_trigger]

}