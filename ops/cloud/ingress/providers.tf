# This is an entrypoint
terraform {
  required_version = "=0.13.4"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.32.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "1.11.3"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "2.9.0"
    }
  }
  backend "gcs" {
    prefix = "terraform/ingress"
  }
}

# Google provider is setup by env variables
provider "google" {}

# Enables access to the service account token
# https://www.terraform.io/docs/providers/google/d/datasource_client_config.html
data "google_client_config" "context" {}

# Sets up the provider specifically for this cluster
# https://www.terraform.io/docs/providers/google/guides/using_gke_with_terraform.html
provider "kubernetes" {
  load_config_file = false
  host             = "https://${data.google_container_cluster.app_cluster.endpoint}"
  token            = data.google_client_config.context.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.app_cluster.master_auth[0].cluster_ca_certificate,
  )
}

# Cloudflare provider is setup by env variables
# https://www.terraform.io/docs/providers/cloudflare/guides/version-2-upgrade.html
provider "cloudflare" {
  api_token  = local.cloudflare_token
  account_id = local.cloudflare_zone
}

output "cloudflare_api_token" {
  value = local.cloudflare_token
}

output "cloudflare_account_id" {
  value = local.cloudflare_zone
}
