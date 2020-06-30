# This is an entrypoint
terraform {
  required_providers {
    google = "3.28"
  }
  backend "gcs" {
    bucket = "io-delineate-staging"
    prefix = "terraform/state"
  }
}

variable "gcp_project" {
  type = string
}

variable "gcp_region" {
  type = string
}

variable "gcp_zone" {
  type = string
}
