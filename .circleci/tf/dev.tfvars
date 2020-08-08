domain="delineate.dev"
gcp_registry="eu.gcr.io"
app_cidr_range="10.2.0.0/16"

# Cluster
cluster_version_prefix="1.16."
cluster_machine_type="n1-standard-1"
cluster_min_node_count=1
cluster_max_node_count=1
cluster_max_surge=1
cluster_max_unavailable=1
cluster_deployment_versions=3

# DB
db_machine_type="db-f1-micro"

# Jobs
job_region="europe-west4" # Netherlands
