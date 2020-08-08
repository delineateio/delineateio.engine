# This is an entrypoint
terraform {
  required_providers {
    google = "3.32.0"
  }
  backend "gcs" {
    prefix = "terraform/jobs"
  }
}

# Google provider is setup by env variables
provider "google" {}

# Enables access to provider details
# https://www.terraform.io/docs/providers/google/d/datasource_client_config.html
data "google_client_config" "context" {}
