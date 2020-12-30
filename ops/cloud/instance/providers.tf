# This is an entrypoint
terraform {
  required_version = "=0.13.4"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.32.0"
    }
    google-beta = {
      source  = "hashicorp/google"
      version = "3.32.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "2.3.0"
    }
  }
  backend "gcs" {
    prefix = "terraform/db"
  }
}

# Google provider is setup by env variables
provider "google" {}

# Enables access to the service account token
# https://www.terraform.io/docs/providers/google/d/datasource_client_config.html
data "google_client_config" "context" {}
