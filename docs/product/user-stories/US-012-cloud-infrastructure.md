# US-012: Cloud Infrastructure Setup

**As a** developer  
**I want** production cloud infrastructure provisioned and configured  
**So that** the application can be deployed and accessed by users

## Acceptance Criteria

- [ ] DNS migration to Cloudflare completed (preserving existing sites)
- [ ] Neon PostgreSQL database provisioned and accessible
- [ ] Google Cloud Run service configured for API deployment
- [ ] Cloudflare R2 bucket created for image storage
- [ ] Upstash Redis instance ready for caching (future use)
- [ ] Custom domains configured and SSL certificates working
- [ ] Environment variables and secrets properly configured
- [ ] Monitoring and logging basic setup

## DNS & Domain Setup

- [ ] Cloudflare DNS management active
- [ ] `api.tracktory.tonyneuhold.com` pointing to Cloud Run
- [ ] `tracktory.tonyneuhold.com` reserved for frontend
- [ ] `cdn.tracktory.tonyneuhold.com` for image CDN
- [ ] SSL certificates auto-renewing

## Service Configuration

### Google Cloud Run

- [ ] Service account with minimal required permissions
- [ ] Environment variables for database and secrets
- [ ] Automatic scaling configuration
- [ ] Health check endpoints configured

### Database (Neon)

- [ ] Production database with connection pooling
- [ ] Backup and recovery configuration
- [ ] Performance monitoring enabled

### Object Storage (Cloudflare R2)

- [ ] Bucket with proper access policies
- [ ] CDN integration for image delivery
- [ ] API keys for programmatic access

## Security Configuration

- [ ] CORS policies configured for frontend integration
- [ ] Service-to-service authentication
- [ ] Network security rules
- [ ] Secret management best practices

## Technical Implementation

- **Deployment Guide**: Step-by-step process in [deployment guide](../../infrastructure/deployment-guide.md)
- **Infrastructure Blueprint**: Architecture in [cloud infrastructure blueprint](../../infrastructure/architecture.md)
- **Image Storage**: R2 setup per [ADR-002: Image Storage](../../architecture/technical-decisions/adr-002-image-storage.md)

## Status & Metadata

- **Status**: Ready
- **Priority**: Medium (can be done in parallel with development)
- **Estimate**: 8 points
- **Dependencies**: None (infrastructure work)
- **Deliverable**: Full production infrastructure ready for deployment
