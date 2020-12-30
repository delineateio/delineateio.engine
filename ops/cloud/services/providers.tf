# This is an entrypoint
terraform {
  required_version = "=0.13.4"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.32.0"
    }
  }
  backend "gcs" {
    prefix = "terraform/services"
  }
}

# Google provider is setup by env variables
provider "google" {}
