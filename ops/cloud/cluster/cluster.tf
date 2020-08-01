# Loads into locals for less typing :)
# https://www.terraform.io/docs/configuration/locals.html
locals {
  project = data.google_client_config.context.project
  region  = data.google_client_config.context.region
  zone    = data.google_client_config.context.zone
}

# Gets a reference to the network
# https://www.terraform.io/docs/providers/google/d/compute_network.html
data "google_compute_network" "app_network" {
  name = "app-network"
}

# Gets a referenece to the subnetwork
# https://www.terraform.io/docs/providers/google/d/compute_subnetwork.html
data "google_compute_subnetwork" "app_subnet" {
  name = "app-subnet-${local.region}"
}

# Select the available version for the cluster
# https://www.terraform.io/docs/providers/google/d/google_container_engine_versions.html
data "google_container_engine_versions" "app_cluster_version" {
  location       = local.zone
  version_prefix = var.cluster_version_prefix
}

# Cluster for hosting apps
# https://www.terraform.io/docs/providers/google/r/container_cluster.html
resource "google_container_cluster" "app_cluster" {

  name               = "app-cluster"
  description        = "Cluster for application hosting"
  location           = local.zone
  network            = data.google_compute_network.app_network.self_link
  subnetwork         = data.google_compute_subnetwork.app_subnet.self_link
  min_master_version = data.google_container_engine_versions.app_cluster_version.latest_node_version

  # Replaces with node pool after creation
  remove_default_node_pool = true
  initial_node_count       = 1

  # Enable Workload Identity
  workload_identity_config {
    identity_namespace = "${local.project}.svc.id.goog"
  }

  master_auth {

    client_certificate_config {
      issue_client_certificate = true
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

  # TODO: To remove once workload_metadata_config available in 'google' provider
  provider = google-beta
  name     = "app-cluster-node-pool"
  location = local.zone
  cluster  = google_container_cluster.app_cluster.name

  initial_node_count = 1
  autoscaling {
    min_node_count = var.cluster_min_node_count
    max_node_count = var.cluster_max_node_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge       = var.cluster_max_surge
    max_unavailable = var.cluster_max_unavailable
  }

  node_config {
    preemptible  = true
    machine_type = var.cluster_machine_type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    workload_metadata_config {
      node_metadata = "GKE_METADATA_SERVER"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

# Outputs the IP endpoint for the cluster
output "cluster_ip" {
  value = google_container_cluster.app_cluster.endpoint
}
