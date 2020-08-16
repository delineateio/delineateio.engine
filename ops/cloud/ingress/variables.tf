variable "env" {
  type = string
}

variable "domain" {
  type = string
}

variable "registry" {
  type = string
}

variable "app_cidr_range" {
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

variable "db_machine_type" {
  type = string
}

variable "job_region" {
  type = string
}

variable "schedule_time_zone" {
  type = string
}

variable "destroy_schedule" {
  type = string
}

variable "clean_schedule" {
  type = string
}
