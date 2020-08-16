# Gets a reference to the infrastructure service account
# https://www.terraform.io/docs/providers/google/d/service_account.html
data "google_service_account" "infrastructure" {
  account_id = "infrastructure"
}

# A customer role is required for creating AppEngine Apps
# https://www.terraform.io/docs/providers/google/r/google_project_iam_custom_role.html
resource "google_project_iam_custom_role" "app_engine_creator" {
  role_id     = "appengine.creator"
  title       = "AppEngine Creator"
  description = "Custom role to enable AppEngine creation without 'owner' role"
  permissions = ["appengine.applications.create"]
}

# Associates the role to the add user
resource "google_project_iam_member" "infrastructure_app_engine_creator" {
  role   = google_project_iam_custom_role.app_engine_creator.id
  member = "serviceAccount:${data.google_service_account.infrastructure.email}"
}

# This is REQUIRED to create a container app for the scheduler
# https://www.terraform.io/docs/providers/google/r/app_engine_application.html
resource "google_app_engine_application" "scheduler_app" {
  location_id = local.region
}

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
