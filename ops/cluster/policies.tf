# TODO: Dynamically read from URL
# https://www.cloudflare.com/ips-v4

# List of the Cloudflare Source IP Addresses
locals {
  cloudflare_ips = ["173.245.48.0/20",
    "103.21.244.0/22",
    "103.22.200.0/22",
    "103.31.4.0/22",
    "141.101.64.0/18",
    "108.162.192.0/18",
    "190.93.240.0/20",
    "188.114.96.0/20",
    "197.234.240.0/22",
    "198.41.128.0/17",
    "162.158.0.0/15",
    "104.16.0.0/12",
    "172.64.0.0/13",
  "131.0.72.0/22"]
}

# Creates a policy
# https://www.terraform.io/docs/providers/google/r/compute_security_policy.html
resource "google_compute_security_policy" "backend_policy" {

  name = "backend-policy"

  dynamic "rule" {

    for_each = chunklist(local.cloudflare_ips, 4)

    content {
      action   = "allow"
      priority = rule.key + 1

      match {
        versioned_expr = "SRC_IPS_V1"

        config {
          src_ip_ranges = rule.value
        }
      }
    }
  }

  rule {
    action   = "deny(403)"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule"
  }
}
