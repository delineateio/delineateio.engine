# GCP default registry
variable "gcp_registry" {
  type    = string
  default = "eu.gcr.io"
}

# GCP Cluster CIDR range
variable "app_cidr_range" {
  type    = string
  default = "10.2.0.0/16"
}

# Cloudflare domain
variable "cloudflare_domain" {
  type = string
}
