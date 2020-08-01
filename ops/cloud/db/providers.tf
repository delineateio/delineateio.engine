# This is an entrypoint
terraform {
  required_providers {
    random      = "2.3.0"
    google      = "3.32.0"
    google-beta = "3.32.0"
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
