provider "cloudflare" {
  version = "~> 2.0"
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

provider "google" {
  credentials = file("../.env/gcloud.json")
  project     = "my-project-id"
  region      = "us-central1"
}
