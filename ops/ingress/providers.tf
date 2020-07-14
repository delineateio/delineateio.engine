# This is an entrypoint
terraform {
  required_providers {
    google     = "3.28"
    kubernetes = "1.11.3"
    cloudflare = "2.8.0"
  }
  backend "gcs" {
    prefix = "terraform/ingress"
  }
}

# Google provider is setup by env variables
# TODO: Change ENV variables to be GOOGLE_ <- impacts Ansible, CircleCI
provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

# Sets up the provider specifically for this cluster
# https://www.terraform.io/docs/providers/google/guides/using_gke_with_terraform.html
provider "kubernetes" {
  load_config_file = false
  host             = "https://${data.google_container_cluster.app_cluster.endpoint}"
  token            = data.google_client_config.runner.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.app_cluster.master_auth[0].cluster_ca_certificate,
  )
}

# Cloudflare provider is setup by env variables
provider "cloudflare" {}
