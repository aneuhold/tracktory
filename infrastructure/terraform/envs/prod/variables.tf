variable "cloudflare_api_token" {
  description = "Cloudflare API token (optional if using env var)."
  type        = string
  default     = ""
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID (for R2 module if used)."
  type        = string
  default     = ""
}

variable "zone_name" {
  description = "Your DNS zone, e.g., example.com."
  type        = string
}

variable "frontend_record_name" {
  description = "Frontend subdomain or '@' for apex."
  type        = string
  default     = "@"
}

variable "frontend_target" {
  description = "Frontend CNAME target (Vercel DNS target)."
  type        = string
}

variable "frontend_proxied" {
  description = "Whether to proxy the frontend through Cloudflare."
  type        = bool
  default     = true
}

variable "api_record_name" {
  description = "API subdomain (e.g., 'api')."
  type        = string
  default     = "api"
}

variable "api_target" {
  description = "API CNAME target (Cloud Run *.run.app)."
  type        = string
}

variable "api_proxied" {
  description = "Whether to proxy the API through Cloudflare."
  type        = bool
  default     = false
}

variable "r2_bucket_name" {
  description = "Optional R2 bucket name if using the R2 module."
  type        = string
  default     = ""
}
