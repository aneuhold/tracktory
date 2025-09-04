# Deployment Guide (Prod)

Last Updated: 2025-09-03

Goal: Bring up a production MVP using Vercel (frontend), Cloud Run (API), Neon (Postgres), Upstash (Redis), and Cloudflare (DNS and R2). Keep it simple and low cost.

Prerequisites

- GitHub repository connected
- Accounts: Vercel, Google Cloud, Neon, Upstash, Cloudflare
- Domain access: Ability to change nameservers at Squarespace (registrar)

Step 1 - Move DNS to Cloudflare (preserving existing Netlify sites)

**IMPORTANT**: This process preserves existing Netlify sites (like wiki.tonyneuhold.com) while transferring DNS management to Cloudflare.

1a. Inventory current DNS records

- Log into Netlify DNS settings and document all existing records:
  - A records (apex domain pointing to Netlify)
  - CNAME records (subdomains like wiki.tonyneuhold.com pointing to Netlify)
  - MX records (email)
  - TXT records (verification, SPF, DKIM)
  - Any other custom records

1b. Add domain to Cloudflare

- In Cloudflare, "Add a site" and enter your domain (tonyneuhold.com)
- Cloudflare automatically scans and imports most existing DNS records
- **Critical**: Verify that ALL your Netlify records are imported correctly
- If missing records, manually add them before changing nameservers

1c. Configure Netlify sites for external DNS

- In each Netlify site dashboard (tonyneuhold.com, wiki.tonyneuhold.com, etc.):
  - Go to Site settings > Domain management
  - Note the current custom domain and Netlify domain (\*.netlify.app)
  - You'll need to point DNS records to these Netlify targets after the switch

1d. Update DNS records in Cloudflare

- For existing Netlify sites, ensure records point to correct Netlify targets:
  - Apex domain (tonyneuhold.com): CNAME to your-site.netlify.app (or A records if using apex)
  - Subdomains (wiki.tonyneuhold.com): CNAME to wiki-site.netlify.app
- Set all existing site records to "DNS only" (gray cloud) initially for safety
- Add placeholder records for new Tracktory services (will update targets later):
  - api.tonyneuhold.com: CNAME to placeholder.example.com (update after Cloud Run setup)

1e. Change nameservers at Squarespace

- Replace current nameservers with the two Cloudflare nameservers
- **Test immediately**: Check that existing sites (tonyneuhold.com, wiki.tonyneuhold.com) still load
- Wait for full propagation (usually 2-24 hours)

1f. Verify and troubleshoot

- Use `dig` or online DNS tools to verify records resolve correctly:
  ```bash
  dig tonyneuhold.com
  dig wiki.tonyneuhold.com
  ```
- If any existing site breaks, check the CNAME target in Cloudflare matches Netlify's expected target
- Netlify sites should continue working normally with external DNS

Step 2 - Provision core services

- Neon (Postgres): Create a free project and database. Note DATABASE_URL. Enable pooling if available
- Upstash (Redis): Create a free Redis. Note REST URL and token, or standard Redis URL
- Cloudflare R2: Create a bucket (for example, tracktory-images). Create an API token with R2 access (write, list, read). Note Account ID, Access Key ID, Secret Access Key, and bucket name

Step 3 - Frontend on Vercel

- Import the GitHub repo into Vercel and select the Next.js app
- Set environment variables (NEXT_PUBLIC_API_BASE_URL, NEXT_PUBLIC_IMAGE_BASE)
- First deploy creates a Vercel URL; map custom domain after DNS cutover

Step 4 - API on Cloud Run

- Containerize the Go API (minimal Dockerfile). Build and push via GitHub Actions or gcloud locally
- Create a Cloud Run service (region us-west1 recommended). Allow unauthenticated if this is a public API
- Capture the service URL (for example, https://api-xxxxx-uw.a.run.app)
- Optionally map custom domain (api.yourdomain.com) in Cloud Run, or create a CNAME in Cloudflare to the run.app hostname (DNS only to start)

Step 5 - Wire environment secrets

- GitHub repo or environments: DATABASE_URL (Neon), REDIS_URL or UPSTASH_REST_URL and UPSTASH_REST_TOKEN, R2 credentials, JWT secret
- Vercel project env vars: NEXT_PUBLIC_API_BASE_URL and any client needed values (do not put secrets in NEXT_PUBLIC unless intended)
- Cloud Run service: set container env vars for DB, Redis, R2, and JWT secret

Step 6 - Custom domains

- Frontend: Add your Tracktory domain in Vercel (could be app.yourdomain.com or a separate domain). Vercel provides DNS targets. Create these records in Cloudflare. Use proxied CNAME where supported
- API: In Cloudflare, create CNAME api.yourdomain.com -> Cloud Run hostname. Start as DNS only (gray cloud) for simplicity; you can proxy later
- R2 assets (optional): Create a custom domain (cdn.yourdomain.com) to expose public images via R2. Start with private plus signed URLs if preferred
- **Existing sites**: Your current Netlify sites (tonyneuhold.com, wiki.tonyneuhold.com) should continue working unchanged

**DNS Management Best Practices**:

- Keep existing Netlify sites on "DNS only" (gray cloud) until you're confident in the setup
- Use subdomains for new services (api., app., cdn.) to avoid conflicts
- Consider using a separate domain for Tracktory if you want to keep existing setup completely isolated

Step 7 - CI/CD

- Vercel: Auto-deploy on push to main
- GitHub Actions: Add a workflow to build and test backend and deploy to Cloud Run on main. Use repo or environment secrets for GCP auth. Start with a JSON key for a service account; later move to OIDC or Workload Identity Federation

Step 8 - Smoke test

- Visit https://yourdomain.com and basic app routes
- Call https://api.yourdomain.com/health
- Upload a small image; verify it lands in R2 and is retrievable via CDN or signed URL

Operations basics

- Backups: Neon offers branching and point in time features on some tiers; schedule logical backups monthly. Do not rely on Redis for durability
- Monitoring: Start with provider dashboards and a basic uptime check (for example, GitHub Actions schedule). Add OpenTelemetry later
- Secrets rotation: Rotate yearly for tokens and keys or immediately on suspicion

Env var checklist (sample)

- API (Cloud Run): DATABASE_URL, REDIS_URL or UPSTASH_REST_URL and UPSTASH_REST_TOKEN, R2_ACCOUNT_ID, R2_ACCESS_KEY_ID, R2_SECRET_ACCESS_KEY, R2_BUCKET, JWT_SECRET, BASE_URL
- Frontend (Vercel): NEXT_PUBLIC_API_BASE_URL, NEXT_PUBLIC_IMAGE_BASE

Notes

- Keep costs low by using free tiers and minimizing egress. R2 plus Cloudflare CDN reduces egress for images
- If cold starts are noticeable, consider Cloud Run min instances = 1 (small cost) or add Cloudflare cache rules
- **Netlify sites**: Continue to work normally with Cloudflare DNS. You can gradually enable Cloudflare proxy features (orange cloud) for performance benefits, but test carefully
- **Rollback plan**: If issues arise, you can quickly change nameservers back to Netlify DNS, though propagation takes time

## DNS Migration Troubleshooting

Common issues and solutions:

**Existing Netlify site not loading**:

- Check CNAME target in Cloudflare matches the \*.netlify.app domain for that site
- Ensure record is set to "DNS only" (gray cloud) initially
- Use `dig yourdomain.com` to verify DNS resolution

**Netlify says "DNS zone not managed by Netlify"**:

- This is expected after moving to external DNS
- Netlify sites will still work; you just manage DNS elsewhere
- Custom domains in Netlify should show the target domain to point your DNS to

**Gradual migration approach**:

- Move just the apex domain first, keep subdomains on Netlify DNS temporarily
- Use Cloudflare's partial setup if you want to manage only some records initially
- Test thoroughly before moving production subdomains
