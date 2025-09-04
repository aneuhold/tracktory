# Deployment Guide (Prod)

Last Updated: 2025-09-03

Goal: Bring up a production MVP using Vercel (frontend), Cloud Run (API), Neon (Postgres), Upstash (Redis), and Cloudflare (DNS and R2). Keep it simple and low cost.

Prerequisites

- GitHub repository connected
- Accounts: Vercel, Google Cloud, Neon, Upstash, Cloudflare
- Domain access: Ability to change nameservers at Squarespace (registrar)

Step 1 - Move DNS to Cloudflare

- In Cloudflare, Add a site and enter your domain
- Cloudflare imports existing records; verify A and CNAME records
- Change nameservers at Squarespace to the two Cloudflare nameservers
- Wait for propagation (minutes to a few hours)

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

- Frontend: Add your domain in Vercel. Vercel suggests DNS records. Create them in Cloudflare. Use proxied CNAME where supported
- API: In Cloudflare, create CNAME api -> Cloud Run hostname. Start as DNS only (gray cloud) for simplicity; you can proxy later
- R2 assets (optional): Create a custom domain (cdn.yourdomain.com) to expose public images via R2. Start with private plus signed URLs if preferred

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
