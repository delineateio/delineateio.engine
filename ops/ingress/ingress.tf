# Retrieves the cloudflare secrets
# https://www.terraform.io/docs/providers/google/d/secret_manager_secret_version.html
data "google_secret_manager_secret_version" "cloudflare_zone" {
  secret = "cloudflare-zone"
}
data "google_secret_manager_secret_version" "cloudflare_token" {
  secret = "cloudflare-token"
}
data "google_secret_manager_secret_version" "cloudflare_domain" {
  secret = "cloudflare-domain"
}

locals {
  cloudflare_zone    = data.google_secret_manager_secret_version.cloudflare_zone.secret_data
  cloudflare_token   = data.google_secret_manager_secret_version.cloudflare_token.secret_data
  cloudflare_domain  = data.google_secret_manager_secret_version.cloudflare_domain.secret_data
  cloudflare_fdomain = replace(data.google_secret_manager_secret_version.cloudflare_domain.secret_data, ".", "-")
}

# Gets access to the already created cluster
# https://www.terraform.io/docs/providers/google/d/container_cluster.html
data "google_container_cluster" "app_cluster" {
  name     = "app-cluster"
  location = data.google_client_config.context.zone
}

# Retrieves the cert from the secret store
# https://www.terraform.io/docs/providers/google/d/secret_manager_secret_version.html
data "google_secret_manager_secret_version" "domain_cert" {
  secret = "${local.cloudflare_fdomain}-cert"
}

# Retrieves the key from the secret store
# https://www.terraform.io/docs/providers/google/d/secret_manager_secret_version.html
data "google_secret_manager_secret_version" "domain_key" {
  secret = "${local.cloudflare_fdomain}-key"
}

# Adds the required k8s tls secrets from the secret store
# https://www.terraform.io/docs/providers/kubernetes/r/secret.html
resource "kubernetes_secret" "tls_secret" {

  metadata {
    name = "${local.cloudflare_fdomain}-tls"
  }

  data = {
    "tls.crt" = data.google_secret_manager_secret_version.domain_cert.secret_data
    "tls.key" = data.google_secret_manager_secret_version.domain_key.secret_data
  }

  type = "kubernetes.io/tls"
}

# Creates cluster ingress automatically
# https://www.terraform.io/docs/providers/kubernetes/r/ingress.html
resource "kubernetes_ingress" "app_ingress" {

  metadata {
    name = "app-ingress"
    annotations = {
      "kubernetes.io/ingress.class"                 = "gce"
      "kubernetes.io/ingress.global-static-ip-name" = google_compute_global_address.app_cluster_ip.name
      "kubernetes.io/ingress.allow-http"            = "false"
    }
  }

  spec {
    tls {
      secret_name = kubernetes_secret.tls_secret.metadata[0].name
    }
    rule {
      host = cloudflare_record.api_record.hostname
      http {
        path {
          path = "/*"
          backend {
            service_name = "customers"
            service_port = 80
          }
        }
      }
    }
  }

  wait_for_load_balancer = true
}

# Creates a static IP for the cluster addressing
# https://www.terraform.io/docs/providers/google/r/compute_global_address.html
resource "google_compute_global_address" "app_cluster_ip" {
  name = "app-cluster-ip"
}

# Creates a DNS entry
# https://www.terraform.io/docs/providers/cloudflare/r/record.html
resource "cloudflare_record" "api_record" {
  zone_id = local.cloudflare_zone
  name    = "api"
  value   = google_compute_global_address.app_cluster_ip.address
  type    = "A"
  proxied = true
}

# Sets up the config for the domain
# https://www.terraform.io/docs/providers/cloudflare/r/zone_settings_override.html
resource "cloudflare_zone_settings_override" "settings" {

  zone_id = local.cloudflare_zone
  settings {
    always_online            = "on"
    ssl                      = "strict"
    tls_1_3                  = "on"
    min_tls_version          = "1.2" //1.3 not supported by Httpie
    always_use_https         = "on"
    automatic_https_rewrites = "on"
    brotli                   = "on"
  }
}

# Accesses the published cloudflare
# https://registry.terraform.io/providers/hashicorp/http/latest/docs
data "http" "cloudflare_ip_ranges" {
  url = "https://www.cloudflare.com/ips-v4"
}

# Outputs the IP endpoint for the cluster
output "cluster_ip" {
  value = data.google_container_cluster.app_cluster.endpoint
}
