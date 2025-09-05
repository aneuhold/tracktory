variable "zone_name" {
  description = "The DNS zone (domain) to manage."
  type        = string
}

variable "frontend_record_name" {
  description = "Subdomain for the frontend (use '@' for apex)."
  type        = string
}

variable "frontend_target" {
  description = "CNAME target for the frontend (e.g., cname.vercel-dns.com)."
  type        = string
}

variable "frontend_proxied" {
  description = "Whether Cloudflare should proxy the frontend record."
  type        = bool
  default     = true
}

variable "api_record_name" {
  description = "Subdomain for the API (e.g., 'api')."
  type        = string
  default     = "api"
}

variable "api_target" {
  description = "CNAME target for the API (Cloud Run *.run.app hostname)."
  type        = string
}

variable "api_proxied" {
  description = "Whether Cloudflare should proxy the API record."
  type        = bool
  default     = false
}
