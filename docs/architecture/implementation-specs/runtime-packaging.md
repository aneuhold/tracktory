# Runtime Packaging (Implementation Spec)

Last Updated: 2025-09-04

Scope: Authoritative, implementation-level details for building and packaging the Go API and Next.js frontend artifacts. Provider names are avoided; link infrastructure docs for environment-specific steps.

Related:

- [Cloud Infrastructure Blueprint](../../infrastructure/architecture.md)
- [Deployment Guide (Prod)](../../infrastructure/deployment-guide.md)

## Go API Container Image

- Base: Minimal, non-root image suitable for serverless container runtimes.
- Build: Static binary with CGO disabled; target linux/amd64 for widest compatibility.

Example (reference):

```dockerfile
FROM golang:1.22-alpine AS build
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags "-s -w" -o /out/api ./cmd/api

FROM gcr.io/distroless/base-debian12:nonroot
WORKDIR /
COPY --from=build /out/api /api
USER nonroot:nonroot
ENTRYPOINT ["/api"]
```

Notes:

- Prefer distroless (nonroot) or alpine+`USER` for smaller attack surface.
- Health endpoint: `/health` returns 200 OK quickly for startup/readiness checks.
- Env configuration via variables (examples): `DATABASE_URL`, `JWT_SECRET`, `R2_*`, `REDIS_URL`.

## Next.js Frontend Artifact

- Build on managed host or CI. Output is server-rendered app with global asset CDN.
- Required envs (examples): `NEXT_PUBLIC_API_BASE_URL`, `NEXT_PUBLIC_IMAGE_BASE`, `NEXTAUTH_URL`, `NEXTAUTH_SECRET`.
- Do not store secrets in `NEXT_PUBLIC_*`.

### PWA & Service Worker Strategy

- Choose: `next-pwa` plugin (simple) or custom SW; MVP may start with simple custom SW to control caching precisely
- Precache: app shell routes, offline.html, critical CSS/JS with revisioned filenames
- Runtime caching:
  - API GET: stale-while-revalidate with 5m max-age; bypass for POST/PUT/PATCH/DELETE
  - Images: cache-first with immutable URLs; respect `Cache-Control`
  - Fonts: cache-first with long max-age
- Versioning: bump cache name/version on deploy to avoid stale assets
- iOS caveat: Background sync unreliable; run sync on foreground

## Security & Secrets

- JWT signing (MVP): HS256 shared secret across frontend auth and API (`NEXTAUTH_SECRET` = `JWT_SECRET`).
- Future: JWKS-based asymmetric keys (RS256/ES256) with API-side verification.
- Rotate secrets annually or on suspicion.

## CORS & Networking

- Allowed Origins: `https://tracktory.tonyneuhold.com`, local dev (`http://localhost:3000`).
- Headers: Authorization, Content-Type. Methods: GET, POST, PUT, PATCH, DELETE, OPTIONS.
- Use Authorization: Bearer <token>; cookies not required.

## Image Pipeline Integration

- Uploads: Client gets presigned URL from API; uploads directly to object storage.
- Processing: Synchronous in Go API for MVP (resize/optimize); consider async workers later.
- Access: Derived images public via CDN; originals private with time-limited signed URLs.

## CI/CD Hooks (Abstract)

- On main: run tests and linters; build Next.js; build API image; deploy with health checks.
- Secrets live in environment/repo scopes; avoid hardcoding provider credentials.

## Operational Considerations

- Start with API DNS-only; enable proxy+caching for read endpoints manually later if needed.
- Cold starts: consider minimal warm instances for API or lean image footprint.
