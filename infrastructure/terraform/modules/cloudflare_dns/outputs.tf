output "frontend_fqdn" {
  description = "Fully qualified domain name for the frontend."
  value       = cloudflare_record.frontend.hostname
}

output "api_fqdn" {
  description = "Fully qualified domain name for the API."
  value       = cloudflare_record.api.hostname
}
