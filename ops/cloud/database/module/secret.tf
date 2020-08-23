
# Adds the required database info
# https://www.terraform.io/docs/providers/kubernetes/r/secret.html
resource "kubernetes_secret" "cluster_secret" {

  metadata {
    name = "${var.service_name}-connection"
  }

  data = {
    "connection" = data.google_sql_database_instance.db_instance.connection_name
    "username"   = google_sql_user.db_user.name
    "password"   = local.password
    "dbname"     = google_sql_database.db.name
  }
}
