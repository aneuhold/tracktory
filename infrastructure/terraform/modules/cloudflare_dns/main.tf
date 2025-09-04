data "cloudflare_zone" "zone" {
  name = var.zone_name
}

resource "cloudflare_record" "frontend" {
  zone_id = data.cloudflare_zone.zone.id
  name    = var.frontend_record_name
  type    = "CNAME"
  value   = var.frontend_target
  proxied = var.frontend_proxied
}

resource "cloudflare_record" "api" {
  zone_id = data.cloudflare_zone.zone.id
  name    = var.api_record_name
  type    = "CNAME"
  value   = var.api_target
  proxied = var.api_proxied
}
