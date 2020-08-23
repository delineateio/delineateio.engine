env="pub"
domain="delineate.pub"
registry="eu.gcr.io"

# Network
network_name="app-network"
app_cidr_range="10.2.0.0/16"

# Cluster
cluster_name="app-cluster"
cluster_version_prefix="1.16."
cluster_machine_type="n1-standard-1"
cluster_min_node_count=1
cluster_max_node_count=1
cluster_max_surge=1
cluster_max_unavailable=1
cluster_deployment_versions=3

# DB
db_instance_name_secret="db-instance-name"
db_instance_connection_secret="db-instance-connection"
db_postgres_pw_secret="db-postgres-pw"
db_machine_type="db-f1-micro"

# Jobs
job_region="europe-west4" # Netherlands
schedule_time_zone="Europe/London"
destroy_schedule="0 2,7,17 * * *"
clean_schedule="0 */3 * * *"
