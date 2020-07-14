# Creates a network specifically for apps
# https://www.terraform.io/docs/providers/google/r/compute_network.html
resource "google_compute_network" "app_network" {
  name                            = "app-network"
  description                     = "Network for managing application"
  project                         = var.gcp_project
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
}

# Creates a subnetwork specifically for apps
# https://www.terraform.io/docs/providers/google/r/compute_subnetwork.html
resource "google_compute_subnetwork" "app_subnet" {
  name          = "app-subnet-${var.gcp_region}"
  ip_cidr_range = var.app_cidr_range
  region        = var.gcp_region
  network       = google_compute_network.app_network.id
}
