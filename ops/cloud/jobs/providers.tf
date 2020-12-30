# This is an entrypoint
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.32.0"
    }
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

# Loads into locals for less typing :)
# https://www.terraform.io/docs/configuration/locals.html
locals {
  project = data.google_client_config.context.project
  region  = data.google_client_config.context.region
  zone    = data.google_client_config.context.zone
}
