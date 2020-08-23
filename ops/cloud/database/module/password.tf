# Creates the ramdom default password
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
resource "random_password" "db_password" {
  length  = 20
  special = false
}

locals {
  password = random_password.db_password.result
}

# Creates secret to store and enable access if required
# https://www.terraform.io/docs/providers/google/r/secret_manager_secret.html
resource "google_secret_manager_secret" "db_password_secret" {
  secret_id = "db-${var.service_name}-pw"
  replication {
    automatic = true
  }
}

# Writes the root password to a secret for retrieval
# https://www.terraform.io/docs/providers/google/r/secret_manager_secret_version.html
resource "google_secret_manager_secret_version" "db_password_secret_version" {
  secret      = google_secret_manager_secret.db_password_secret.id
  secret_data = local.password
}
