# Creates the database
# https://www.terraform.io/docs/providers/google/r/sql_database.html
resource "google_sql_database" "db" {
  name     = var.service_name
  instance = data.google_sql_database_instance.db_instance.name
}

# Creates the user db for the service
# https://www.terraform.io/docs/providers/google/r/sql_user.html
resource "google_sql_user" "db_user" {
  name     = var.service_name
  instance = data.google_sql_database_instance.db_instance.name
  password = local.password
}

# Creates the customers cert
# https://www.terraform.io/docs/providers/google/r/sql_ssl_cert.html
resource "google_sql_ssl_cert" "db_cert" {
  common_name = "${var.service_name}-cert"
  instance    = data.google_sql_database_instance.db_instance.name
}
