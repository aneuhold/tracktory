# Development Plan: Backend First Approach

## Sprint 1: Foundation (Week 1-2)

**Goal**: Get basic backend API running with authentication

### Phase 1A: Project Setup & Database

1. **Initialize Go API project**

   - `go mod init`, basic project structure
   - Docker setup for local development
   - Database migrations with schema from specs

2. **Database Setup**

   - PostgreSQL with initial schema
   - Seed default categories
   - Row Level Security policies

3. **Basic CI/CD Pipeline**
   - GitHub Actions for testing and building
   - Temporary DB for CI (GitHub Actions PostgreSQL service)

**Deliverables**:

- Go API skeleton running locally
- Database schema implemented
- Basic CI/CD pipeline
- Health check endpoint working

### Phase 1B: Authentication

4. **Implement US-001: User Authentication**
   - JWT validation middleware
   - OAuth callback endpoint for frontend integration
   - User creation/lookup from OAuth data

**Deliverables**:

- `/auth/user` endpoint working
- JWT middleware protecting routes
- User table properly seeded

## Sprint 2: Core Item Management (Week 3-4)

**Goal**: Complete create item workflow (US-002 priority)

### Phase 2A: Item CRUD

5. **Implement US-003: Categories endpoint**

   - `GET /categories` with seeded data

6. **Implement US-002: Create New Item**

   - `POST /items` endpoint
   - Request validation
   - Database insertion with proper user isolation

7. **Implement US-004 & US-005: Item Retrieval**
   - `GET /items` with pagination
   - `GET /items/{id}` for details

**Deliverables**:

- Full item CRUD working via API
- Categories endpoint functional
- Proper error handling and validation

### Phase 2B: Image Upload

8. **Image Processing Pipeline**
   - Basic image upload to temporary storage
   - Image validation and processing
   - Multiple resolution generation

**Deliverables**:

- `POST /items/{id}/images` working
- Basic image storage (local/temp for MVP)

## Sprint 3: Search & Polish (Week 5-6)

**Goal**: Complete core backend functionality

9. **Implement US-006: Basic Search**

   - PostgreSQL full-text search
   - `GET /search` endpoint

10. **Production Deployment Setup**
    - Cloud infrastructure setup (following deployment guide)
    - Production database migration
    - Image storage migration to cloud

**Deliverables**:

- Search functionality working
- Backend deployed to production
- Ready for frontend integration

## Parallel Infrastructure Work

### Cloud Setup (can be done alongside Sprint 1-2)

Following the deployment guide sequence:

1. **DNS Migration to Cloudflare** (preserve existing sites)
2. **Provision Core Services** (Neon, Upstash, Cloudflare R2)
3. **Cloud Run Deployment Setup**
4. **CI/CD Pipeline for Cloud Run**

### Database Strategy

- **Local Development**: Docker PostgreSQL
- **CI/CD**: GitHub Actions PostgreSQL service
- **Production**: Neon PostgreSQL (free tier)

## Success Criteria for Backend Complete

✅ **API Functional**:

- All US-001 through US-006 endpoints working
- Proper authentication and authorization
- Input validation and error handling

✅ **Infrastructure Ready**:

- Production deployment working
- CI/CD pipeline deploying successfully
- Database migrations running in all environments

✅ **Frontend Ready**:

- API documented and available
- CORS configured for frontend development
- OAuth integration points ready

## Next Phase: Frontend Development

Once backend is complete, frontend development can begin with working API endpoints to integrate against.

---

**Questions to Confirm**:

1. Should we use Docker for local PostgreSQL, or would you prefer a local install?
2. For temporary image storage during development, filesystem vs cloud storage first?
3. Any preference for Go framework? (Current docs suggest Gin)
