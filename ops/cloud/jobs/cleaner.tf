# Makes the service available
# https://www.terraform.io/docs/providers/google/r/cloud_run_service_iam.html
resource "google_cloud_run_service_iam_policy" "registry_policy" {
  location    = google_cloud_run_service.clean_job.location
  project     = google_cloud_run_service.clean_job.project
  service     = google_cloud_run_service.clean_job.name
  policy_data = data.google_iam_policy.schedule_policy.policy_data
}

# Creates the service account to use when pulling images
# https://www.terraform.io/docs/providers/google/r/google_service_account.html
resource "google_service_account" "clean_service_account" {
  account_id   = "cleaner"
  display_name = "Cleaner service account"
  description  = "Service account for cleaning up GCR"
}

resource "google_project_iam_member" "project" {
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.clean_service_account.email}"
}

# Creates the Cloud Run job for destroying the infrastructure
# https://www.terraform.io/docs/providers/google/r/cloud_run_service.html
resource "google_cloud_run_service" "clean_job" {
  name     = "clean-job"
  location = var.job_region

  template {
    spec {
      containers {
        image = "gcr.io/gcr-cleaner/gcr-cleaner:latest"
      }

      service_account_name = google_service_account.clean_service_account.email
    }
  }
}

# Creates the scheduler job for the requirement
# https://www.terraform.io/docs/providers/google/r/cloud_scheduler_job.html
resource "google_cloud_scheduler_job" "clean_job" {

  name             = "destroy-clean"
  description      = "Job that cleans up the destroy registry images"
  time_zone        = var.schedule_time_zone
  schedule         = var.clean_schedule
  attempt_deadline = "360s"

  http_target {
    http_method = "POST"
    uri         = "${google_cloud_run_service.clean_job.status[0].url}/http"
    body        = base64encode(templatefile("${path.module}/clean/config.json", { project = local.project, registry = var.registry }))

    oidc_token {
      audience              = "${google_cloud_run_service.clean_job.status[0].url}/http"
      service_account_email = google_service_account.schedules_service_account.email
    }
  }

  depends_on = [google_project_iam_member.infrastructure_app_engine_creator]
}

# Outputs the url of the service
# https://www.terraform.io/docs/configuration/outputs.html
output "clean_job_url" {
  value       = google_cloud_run_service.clean_job.status[0].url
  description = "The url of the registry clean job"
}
