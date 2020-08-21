# Dynamically retrieves connection name
# https://www.terraform.io/docs/providers/google/d/secret_manager_secret_version.html
data "google_secret_manager_secret_version" "db_name_secret" {
  secret = var.db_instance_name_secret
}

# Gets a reference to the the database instance
# https://www.terraform.io/docs/providers/google/d/sql_database_instance.html
data "google_sql_database_instance" "db_instance" {
  name = data.google_secret_manager_secret_version.db_name_secret.secret_data
}
