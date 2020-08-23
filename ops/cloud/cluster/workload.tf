# TODO: Workload identity should ultimately be managed INSIDE the service
# this will enable least priviledge to be implemented for each pod.  At the
# moment all pods would share the same priviledges

# Creates the service account to use when pulling images
# https://www.terraform.io/docs/providers/google/r/google_service_account.html
resource "google_service_account" "workload_service" {
  account_id   = "workload"
  display_name = "Workload identity service account"
  description  = "Service account used for running workloads in the app cluster"
}

# Binds the roles to the workload GSA
# https://www.terraform.io/docs/providers/google/r/google_project_iam.html
resource "google_project_iam_member" "workload_iam_sql_client" {
  role   = "roles/cloudsql.client"
  member = "serviceAccount:${google_service_account.workload_service.email}"
}
resource "google_project_iam_member" "workload_iam_log_writer" {
  role   = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.workload_service.email}"
}
resource "google_project_iam_member" "workload_iam_metric_writer" {
  role   = "roles/monitoring.metricWriter"
  member = "serviceAccount:${google_service_account.workload_service.email}"
}
resource "google_project_iam_member" "workload_iam_monitoring_viewer" {
  role   = "roles/monitoring.viewer"
  member = "serviceAccount:${google_service_account.workload_service.email}"
}
resource "google_project_iam_member" "workload_identity_user" {
  role   = "roles/iam.workloadIdentityUser"
  member = "serviceAccount:${google_service_account.workload_service.email}"
}

# Binds the service account to workload account
# https://www.terraform.io/docs/providers/google/r/google_service_account_iam.html
resource "google_service_account_iam_member" "workload_iam_member" {
  service_account_id = google_service_account.workload_service.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project}.svc.id.goog[default/${google_service_account.workload_service.account_id}]"
}

# Creates the k8s service account
# https://www.terraform.io/docs/providers/kubernetes/r/service_account.html
resource "kubernetes_service_account" "workload_service" {
  metadata {
    name = "workload"
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.workload_service.email
    }
  }
}
