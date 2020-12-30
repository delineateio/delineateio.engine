# This is an entrypoint
terraform {
  required_version = "=0.13.4"
  required_providers {
    random     = "2.3.0"
    google     = "3.32.0"
    kubernetes = "1.11.3"
  }
  backend "gcs" {
    prefix = "terraform/db/databases"
  }
}

# Google provider is setup by env variables
provider "google" {}

# Enables access to the service account token
# https://www.terraform.io/docs/providers/google/d/datasource_client_config.html
data "google_client_config" "context" {}

# Gets a reference to the cluster
# https://www.terraform.io/docs/providers/google/d/container_cluster.html
data "google_container_cluster" "app_cluster" {
  name     = var.cluster_name
  location = data.google_client_config.context.zone
}

# Sets up the provider specifically for this cluster
# https://www.terraform.io/docs/providers/google/guides/using_gke_with_terraform.html
provider "kubernetes" {
  load_config_file = false
  host             = "https://${data.google_container_cluster.app_cluster.endpoint}"
  token            = data.google_client_config.context.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.app_cluster.master_auth[0].cluster_ca_certificate,
  )
}
