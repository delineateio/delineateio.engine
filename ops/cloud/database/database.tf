module "database" {
  source                  = "./module"
  service_name            = var.service_name
  db_instance_name_secret = var.db_instance_name_secret
}
