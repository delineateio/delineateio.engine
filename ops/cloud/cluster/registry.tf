# Creates the service account to use when pulling images
# https://www.terraform.io/docs/providers/google/r/google_service_account.html
resource "google_service_account" "registry_service_account" {
  account_id   = "registry"
  display_name = "Registry image pull service account"
  description  = "Service account for pulling images from GCR to GKE"
}

resource "google_project_iam_member" "project" {
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.registry_service_account.email}"
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
