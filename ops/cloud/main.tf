# This is an entrypoint
terraform {
  required_providers {
    google = "3.28"
  }
  backend "gcs" {
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

variable "gcp_registry" {
  type = string
}
