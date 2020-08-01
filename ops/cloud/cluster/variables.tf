variable "domain" {
  type = string
}

variable "gcp_registry" {
  type = string
}

variable "cluster_version_prefix" {
  type = string
}

variable "cluster_machine_type" {
  type = string
}

variable "cluster_min_node_count" {
  type = number
}

variable "cluster_max_node_count" {
  type = number
}

variable "cluster_max_surge" {
  type = number
}

variable "cluster_max_unavailable" {
  type = number
}

variable "cluster_deployment_versions" {
  type = number
}
