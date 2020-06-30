provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

output "instance_ip_addr" {
  value = "${path.module}"
}
