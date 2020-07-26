# GCP default registry
variable "gcp_registry" {
  type = string
}

# GCP Cluster CIDR range
variable "app_cidr_range" {
  type = string
}

variable "machine_type" {
  type = string
}

variable "min_node_count" {
  type = number
}

variable "max_node_count" {
  type = number
}

variable "max_surge" {
  type = number
}
