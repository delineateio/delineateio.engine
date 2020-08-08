locals {
  disable_dependent_services = true
  disable_on_destroy         = true
}

resource "google_project_service" "cloud_resource_manager" {
  service                    = "cloudresourcemanager.googleapis.com"
  disable_dependent_services = local.disable_dependent_services
  disable_on_destroy         = local.disable_on_destroy
}

resource "google_project_service" "container" {
  service                    = "container.googleapis.com"
  disable_dependent_services = local.disable_dependent_services
  disable_on_destroy         = local.disable_on_destroy
}

resource "google_project_service" "container_scanning" {
  service                    = "containerscanning.googleapis.com"
  disable_dependent_services = local.disable_dependent_services
  disable_on_destroy         = local.disable_on_destroy
}

resource "google_project_service" "sql_admin" {
  service                    = "sqladmin.googleapis.com"
  disable_dependent_services = local.disable_dependent_services
  disable_on_destroy         = local.disable_on_destroy
}

resource "google_project_service" "compute" {
  service                    = "compute.googleapis.com"
  disable_dependent_services = local.disable_dependent_services
  disable_on_destroy         = local.disable_on_destroy
}

resource "google_project_service" "secret_manager" {
  service                    = "secretmanager.googleapis.com"
  disable_dependent_services = local.disable_dependent_services
  disable_on_destroy         = local.disable_on_destroy
}

resource "google_project_service" "iam_credentials" {
  service                    = "iamcredentials.googleapis.com"
  disable_dependent_services = local.disable_dependent_services
  disable_on_destroy         = local.disable_on_destroy
}

resource "google_project_service" "service_networking" {
  service                    = "servicenetworking.googleapis.com"
  disable_dependent_services = local.disable_dependent_services
  disable_on_destroy         = local.disable_on_destroy
}

# Creates the service
# https://www.terraform.io/docs/providers/google/r/google_project_service.html
resource "google_project_service" "cloud" {
  service                    = "run.googleapis.com"
  disable_dependent_services = local.disable_dependent_services
  disable_on_destroy         = local.disable_on_destroy
}

# Enables Cloud Scheduler
# https://www.terraform.io/docs/providers/google/r/google_project_service.html
resource "google_project_service" "cloud_scheduler" {
  service                    = "cloudscheduler.googleapis.com"
  disable_dependent_services = local.disable_dependent_services
  disable_on_destroy         = local.disable_on_destroy
}
