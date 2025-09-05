terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  # Prefer environment variable CLOUDFLARE_API_TOKEN; fall back to var token
  api_token = var.cloudflare_api_token != "" ? var.cloudflare_api_token : null
}

module "dns" {
  source = "../../modules/cloudflare_dns"

  zone_name             = var.zone_name
  frontend_record_name  = var.frontend_record_name
  frontend_target       = var.frontend_target
  frontend_proxied      = var.frontend_proxied
  api_record_name       = var.api_record_name
  api_target            = var.api_target
  api_proxied           = var.api_proxied
}

# Optional: manage R2 bucket via Terraform. Uncomment when ready.
# module "r2" {
#   source     = "../../modules/cloudflare_r2"
#   account_id = var.cloudflare_account_id
#   bucket_name = var.r2_bucket_name
# }

output "frontend_fqdn" {
  value = module.dns.frontend_fqdn
}

output "api_fqdn" {
  value = module.dns.api_fqdn
}
