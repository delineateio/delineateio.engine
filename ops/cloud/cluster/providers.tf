# This is an entrypoint

terraform {
  required_version = "=0.13.4"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.39.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "1.11.3"
    }
  }
  backend "gcs" {
    prefix = "terraform/cluster"
  }
}

# Google provider is setup by env variables
provider "google" {}

# Enables access to provider details
# https://www.terraform.io/docs/providers/google/d/datasource_client_config.html
data "google_client_config" "context" {}

# Sets up the provider specifically for this cluster
# https://www.terraform.io/docs/providers/google/guides/using_gke_with_terraform.html
provider "kubernetes" {
  load_config_file = false
  host             = "https://${google_container_cluster.app_cluster.endpoint}"
  token            = data.google_client_config.context.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.app_cluster.master_auth[0].cluster_ca_certificate,
  )
}
