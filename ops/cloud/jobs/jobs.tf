# Creates a service account for jobs
# https://www.terraform.io/docs/providers/google/r/google_service_account.html
resource "google_service_account" "schedules_service_account" {
  account_id   = "schedules"
  display_name = "Scheduled jobs service account"
  description  = "Service account for executing scheduled jobs"
}

# Creates a policy that enables the
# https://www.terraform.io/docs/providers/google/d/iam_policy.html
data "google_iam_policy" "schedule_policy" {
  binding {
    role = "roles/run.invoker"
    members = [
      "serviceAccount:${google_service_account.schedules_service_account.email}",
    ]
  }
}
