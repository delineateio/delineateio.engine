# This is an entrypoint
terraform {
  required_version = "=0.13.4"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.32.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "1.2.0"
    }
  }
  backend "gcs" {
    prefix = "terraform/network"
  }
}

# Google provider is setup by env variables
provider "google" {}

# Enables access to provider details
# https://www.terraform.io/docs/providers/google/d/datasource_client_config.html
data "google_client_config" "context" {}
