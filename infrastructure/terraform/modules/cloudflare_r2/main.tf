# Optional module. Requires Cloudflare provider supporting cloudflare_r2_bucket.
# Create R2 bucket to store images.

resource "cloudflare_r2_bucket" "this" {
  account_id = var.account_id
  name       = var.bucket_name
  # location can be omitted for auto. Uncomment if needed:
  # location   = "auto"
}
