# GCP project ID
variable "gcp_project" {
  type = string
}

# GCP default region
variable "gcp_region" {
  type = string
}

# GCP default zone
variable "gcp_zone" {
  type = string
}

# GCP default zone
variable "gcp_registry" {
  type = string
}

# GCP Cluster CIDR range
variable "app_cidr_range" {
  type = string
}

# Cloudflare domain
variable "cloudflare_domain" {
  type = string
}
