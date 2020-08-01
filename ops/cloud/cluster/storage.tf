# Creates a bucket for the deployments
# https://www.terraform.io/docs/providers/google/r/storage_bucket.html
resource "google_storage_bucket" "deployments" {

  name          = "${data.google_client_config.context.project}-deployments"
  location      = data.google_client_config.context.region
  storage_class = "STANDARD"
  force_destroy = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      num_newer_versions = var.cluster_deployment_versions
    }
    action {
      type = "Delete"
    }
  }
}
