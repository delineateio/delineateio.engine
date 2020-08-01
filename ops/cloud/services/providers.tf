# This is an entrypoint
terraform {
  required_providers {
    google = "3.32.0"
  }
  backend "gcs" {
    prefix = "terraform/services"
  }
}

# Google provider is setup by env variables
provider "google" {}
