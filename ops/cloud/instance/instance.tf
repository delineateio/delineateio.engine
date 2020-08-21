# Creates the ramdom default password
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
resource "random_password" "default_password" {
  length  = 20
  special = false
}

# Creates secret to store and enable access if required
# https://www.terraform.io/docs/providers/google/r/secret_manager_secret.html
resource "google_secret_manager_secret" "db_password_secret" {
  secret_id = var.db_postgres_pw_secret
  replication {
    automatic = true
  }
}

# Writes the root password to a secret for retrieval
# https://www.terraform.io/docs/providers/google/r/secret_manager_secret_version.html
resource "google_secret_manager_secret_version" "db_password_secret_version" {
  secret      = google_secret_manager_secret.db_password_secret.id
  secret_data = random_password.default_password.result
}

# Gets a reference to the network
# https://www.terraform.io/docs/providers/google/d/compute_network.html
data "google_compute_network" "app_network" {
  name = var.network_name
}

# Creates a private IP address for VPC networking
# https://www.terraform.io/docs/providers/google/r/compute_global_address.html
resource "google_compute_global_address" "private_db_ip" {
  provider      = google-beta
  name          = "private-db-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.google_compute_network.app_network.id
}

# Creates the private VPC network connection
# https://www.terraform.io/docs/providers/google/r/service_networking_connection.html
resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = google-beta
  network                 = data.google_compute_network.app_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_db_ip.name]
}

# Creates a suffix for the db this is the workaround/convetion for Cloud SQL
# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id
resource "random_id" "db_suffix" {
  byte_length = 4
}

# Create the database instance so that it can be attached to GKE
# https://www.terraform.io/docs/providers/google/r/sql_database_instance.html
resource "google_sql_database_instance" "app_db" {
  name             = "app-db-${random_id.db_suffix.hex}"
  database_version = "POSTGRES_11"

  settings {
    tier = var.db_machine_type
    ip_configuration {
      # TODO: Still enabled as not able to connect over PRIVATE
      ipv4_enabled    = true
      private_network = data.google_compute_network.app_network.id
    }
  }
}

# Creates the the default user in the db
# https://www.terraform.io/docs/providers/google/r/sql_user.html
resource "google_sql_user" "default_user" {
  instance = google_sql_database_instance.app_db.name
  name     = "postgres"
  password = random_password.default_password.result
}

# Creates secret to store and enable access if required
# https://www.terraform.io/docs/providers/google/r/secret_manager_secret.html
resource "google_secret_manager_secret" "db_instance_secret" {
  secret_id = var.db_instance_connection_secret
  replication {
    automatic = true
  }
}

# Writes the db instance to a secret
# https://www.terraform.io/docs/providers/google/r/secret_manager_secret_version.html
resource "google_secret_manager_secret_version" "db_instance_secret_version" {
  secret      = google_secret_manager_secret.db_instance_secret.id
  secret_data = google_sql_database_instance.app_db.connection_name
}

# Creates secret to store and enable access if required
# https://www.terraform.io/docs/providers/google/r/secret_manager_secret.html
resource "google_secret_manager_secret" "db_name_secret" {
  secret_id = var.db_instance_name_secret
  replication {
    automatic = true
  }
}

# Writes the db name to a secret
# https://www.terraform.io/docs/providers/google/r/secret_manager_secret_version.html
resource "google_secret_manager_secret_version" "db_name_secret_version" {
  secret      = google_secret_manager_secret.db_name_secret.id
  secret_data = google_sql_database_instance.app_db.name
}
