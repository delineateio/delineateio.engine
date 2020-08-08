# Makes the service available
# https://www.terraform.io/docs/providers/google/r/cloud_run_service_iam.html
resource "google_cloud_run_service_iam_policy" "destroy_policy" {
  location    = google_cloud_run_service.destroy_job.location
  project     = google_cloud_run_service.destroy_job.project
  service     = google_cloud_run_service.destroy_job.name
  policy_data = data.google_iam_policy.schedule_policy.policy_data
}

# Gets a reference to the infrastructure service account
# https://www.terraform.io/docs/providers/google/d/service_account.html
data "google_service_account" "infrastructure" {
  account_id = "infrastructure"
}

# Creates the Cloud Run job for destroying the infrastructure
# https://www.terraform.io/docs/providers/google/r/cloud_run_service.html
resource "google_cloud_run_service" "destroy_job" {
  name     = "destroy-job"
  location = var.job_region

  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello"
      }

      service_account_name = data.google_service_account.infrastructure.email
    }
  }
}

# Creates the scheduler job for the requirement
# https://www.terraform.io/docs/providers/google/r/cloud_scheduler_job.html
resource "google_cloud_scheduler_job" "destroy_job" {

  name             = "destroy-job"
  description      = "Job that destroys expensive infrastructure"
  schedule         = "0 2,7,17 * * *"
  time_zone        = "Europe/London"
  attempt_deadline = "360s"

  http_target {

    http_method = "POST"
    uri         = "${google_cloud_run_service.destroy_job.status[0].url}/http"
    body        = base64encode(file("${path.module}/destroy/config.json"))

    oidc_token {
      service_account_email = google_service_account.schedules_service_account.email
    }
  }
}

# Outputs the url of the service
# https://www.terraform.io/docs/configuration/outputs.html
output "destroy_job_url" {
  value       = google_cloud_run_service.destroy_job.status[0].url
  description = "The url of the destroy job"
}
