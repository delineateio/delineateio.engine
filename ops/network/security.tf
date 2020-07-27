# Accesses the published cloudflare IPv4 addresses
# https://registry.terraform.io/providers/hashicorp/http/latest/docs
data "http" "cloudflare_ip_ranges" {
  url = "https://www.cloudflare.com/ips-v4"
}

# Creates a policy
# https://www.terraform.io/docs/providers/google/r/compute_security_policy.html
resource "google_compute_security_policy" "backend_policy" {

  name = "backend-policy"

  dynamic "rule" {

    # trims the last newline, splits into list, chunklist of 4
    for_each = chunklist(split("\n", trimsuffix(data.http.cloudflare_ip_ranges.body, "\n")), 4)

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
