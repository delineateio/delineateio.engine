# Select the available version for the cluster
# https://www.terraform.io/docs/providers/google/d/google_container_engine_versions.html
data "google_container_engine_versions" "app_cluster_version" {
  location       = var.gcp_zone
  version_prefix = "1.16."
}

# Cluster for hosting apps
# https://www.terraform.io/docs/providers/google/r/container_cluster.html
resource "google_container_cluster" "app_cluster" {

  name               = "app-cluster"
  description        = "Cluster for application hosting"
  project            = var.gcp_project
  location           = var.gcp_zone
  min_master_version = data.google_container_engine_versions.app_cluster_version.latest_node_version

  # Replaces with node pool after creation
  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }
}

resource "google_container_node_pool" "app_cluster_nodes" {

  name     = "app-cluster-node-pool"
  project  = var.gcp_project
  location = var.gcp_zone
  cluster  = google_container_cluster.app_cluster.name

  initial_node_count = 1
  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge       = 3
    max_unavailable = 1
  }

  node_config {
    preemptible  = true
    machine_type = "n1-standard-1"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
