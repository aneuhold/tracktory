# Infrastructure as Code Strategy

Last Updated: 2025-09-03

Goal: Use Terraform for the core, keep it simple now, and remain portable. Start with Cloudflare DNS and Cloudflare R2. Add more later.

Tooling

- Terraform in this repo under infrastructure/terraform
- State: local for first run; migrate to a remote backend later (Terraform Cloud free tier or a small GCS bucket)
- Modules: small, focused (cloudflare_dns, cloudflare_r2)

Scope now (MVP)

- Cloudflare DNS: zone records for app and api, any TXT verifications
- Cloudflare R2: bucket and access credentials (or create bucket in UI and only manage DNS via Terraform initially)
- Outputs: values to paste into GitHub/Vercel/Cloud Run

Out of scope now

- Vercel project provisioning (use UI)
- Cloud Run service (deploy via GitHub Actions/gcloud)
- Neon/Upstash provisioning (use their UI for free tier)

Repository layout

infrastructure/
terraform/
modules/
cloudflare_dns/
cloudflare_r2/
envs/
prod/
main.tf
variables.tf
terraform.tfvars (gitignored)

Workflows

- Init: terraform init in envs/prod
- Plan/Apply: terraform plan and terraform apply for DNS and R2 only
- CI: optional GitHub Action to run terraform fmt, validate, and plan on PRs (no auto-apply initially)

Secrets management

- Terraform variables from a local tfvars file for tokens and keys (gitignored)
- Provider tokens stored locally for manual runs; store in GitHub Actions secrets for CI plans
- Cloudflare API token with least privilege (DNS edit and R2 access if managing R2)

Future additions

- Remote state backend
- Add Cloud Run service configuration via google provider (optional)
- Add Cloudflare Workers/Rules for CDN caching and signed URL helpers
- Staging environment under envs/staging

Quality

- Run terraform fmt and validate before committing
- Keep modules tiny with README in each module
