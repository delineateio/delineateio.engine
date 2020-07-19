# Select the available version for the cluster
# https://www.terraform.io/docs/providers/google/d/google_container_engine_versions.html
data "google_container_engine_versions" "app_cluster_version" {
  location       = data.google_client_config.context.zone
  version_prefix = "1.16."
}

# Cluster for hosting apps
# https://www.terraform.io/docs/providers/google/r/container_cluster.html
resource "google_container_cluster" "app_cluster" {

  name               = "app-cluster"
  description        = "Cluster for application hosting"
  location           = data.google_client_config.context.zone
  network            = google_compute_network.app_network.self_link
  subnetwork         = google_compute_subnetwork.app_subnet.self_link
  min_master_version = data.google_container_engine_versions.app_cluster_version.latest_node_version

  # Replaces with node pool after creation
  remove_default_node_pool = true
  initial_node_count       = 1

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

  name     = "app-cluster-node-pool"
  location = data.google_client_config.context.zone
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
    machine_type = var.machine_type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

# Creates the service account to use when pulling images
# https://www.terraform.io/docs/providers/google/r/google_service_account.html
resource "google_service_account" "registry_service_account" {
  account_id   = "registry"
  display_name = "registry"
}

resource "google_project_iam_binding" "registry_iam_binding" {
  role = "roles/storage.objectViewer"
  members = [
    "serviceAccount:${google_service_account.registry_service_account.email}"
  ]
}

# Gets a service account key
# https://www.terraform.io/docs/providers/google/r/google_service_account_key.html
resource "google_service_account_key" "registry_key" {
  service_account_id = google_service_account.registry_service_account.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

# Creates the required image pull Secret
# https://www.terraform.io/docs/providers/kubernetes/r/secret.html
resource "kubernetes_secret" "registry_secret" {
  metadata {
    name = google_service_account.registry_service_account.account_id
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      "auths" : {
        "https://${var.gcp_registry}/${data.google_client_config.context.project}" : {
          email    = google_service_account.registry_service_account.email
          username = "_json_key"
          password = trimspace(base64decode(google_service_account_key.registry_key.private_key))
          auth     = base64encode(join(":", ["_json_key", base64decode(google_service_account_key.registry_key.private_key)]))
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}

# Outputs the IP endpoint for the cluster
output "cluster_ip" {
  value = google_container_cluster.app_cluster.endpoint
}
