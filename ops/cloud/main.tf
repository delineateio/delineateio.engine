# This is an entrypoint
terraform {
  required_providers {
    google     = "3.28"
    kubernetes = "1.11.3"
  }
  backend "gcs" {
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}
