# Makes the service available
# https://www.terraform.io/docs/providers/google/r/cloud_run_service_iam.html
resource "google_cloud_run_service_iam_policy" "destroy_policy" {
  location    = google_cloud_run_service.destroy_job.location
  project     = google_cloud_run_service.destroy_job.project
  service     = google_cloud_run_service.destroy_job.name
  policy_data = data.google_iam_policy.schedule_policy.policy_data
  depends_on  = [google_cloud_run_service.destroy_job]
}

# Gets the reference to the destroy image
# https://www.terraform.io/docs/providers/google/d/container_registry_image.html
data "google_container_registry_image" "destroy_image" {
  name   = "destroy"
  region = "eu"
}

# Creates the Cloud Run job for destroying the infrastructure
# https://www.terraform.io/docs/providers/google/r/cloud_run_service.html
resource "google_cloud_run_service" "destroy_job" {
  name     = "destroy-job"
  location = var.job_region
  template {
    spec {
      containers {
        image = "${data.google_container_registry_image.destroy_image.image_url}:latest"
        env {
          name  = "GOOGLE_PROJECT"
          value = local.project
        }
        env {
          name  = "GOOGLE_REGION"
          value = local.region
        }
        env {
          name  = "GOOGLE_ZONE"
          value = local.zone
        }
        resources {
          limits = {
            "cpu"    = "2000m"
            "memory" = "2048Mi"
          }
          requests = {}
        }
      }
      service_account_name = data.google_service_account.infrastructure.email
    }

    metadata {
      annotations = {
        "run.googleapis.com/client-name"   = "renew-${uuid()}" # This forces new revision
        "autoscaling.knative.dev/maxScale" = "10"
      }
    }
  }
}

# Creates the top for the destroy job
# https://www.terraform.io/docs/providers/google/r/pubsub_topic.html
resource "google_pubsub_topic" "destroy_job_topic" {
  name = "destroy-job-topic"
  message_storage_policy {
    allowed_persistence_regions = [
      var.job_region,
    ]
  }
}

# Creates the subscription to push to destroy job
# https://www.terraform.io/docs/providers/google/r/pubsub_subscription.html
resource "google_pubsub_subscription" "destroy_job_subscription" {
  name  = "destroy-job-subscription"
  topic = google_pubsub_topic.destroy_job_topic.name

  ack_deadline_seconds = 20

  push_config {
    push_endpoint = "${google_cloud_run_service.destroy_job.status[0].url}/pubsub"
    oidc_token {
      service_account_email = google_service_account.schedules_service_account.email
    }
  }
}

# Creates the scheduler job for the requirement
# https://www.terraform.io/docs/providers/google/r/cloud_scheduler_job.html
resource "google_cloud_scheduler_job" "destroy_job" {

  name        = "destroy-job"
  description = "Job that destroys expensive infrastructure"
  time_zone   = var.schedule_time_zone
  schedule    = var.destroy_schedule

  pubsub_target {
    topic_name = google_pubsub_topic.destroy_job_topic.id
    data       = base64encode(templatefile("${path.module}/destroy/config.json", { env = var.env }))
  }

  depends_on = [google_project_iam_member.infrastructure_app_engine_creator]
}

# Outputs the url of the service
# https://www.terraform.io/docs/configuration/outputs.html
output "destroy_job_image_url" {
  value       = data.google_container_registry_image.destroy_image.image_url
  description = "The url of the destroy job"
}

# Outputs the url of the service
# https://www.terraform.io/docs/configuration/outputs.html
output "destroy_job_url" {
  value       = google_cloud_run_service.destroy_job.status[0].url
  description = "The url of the destroy job"
}
