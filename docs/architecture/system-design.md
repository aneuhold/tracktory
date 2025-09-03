# Tracktory System Design

_Last Updated: September 3, 2025_

## System Overview

Tracktory is a mobile-first asset tracking platform built with Next.js frontend and Go backend, designed for sub-2-second load times and offline-first functionality. The architecture supports progressive enhancement from individual user MVP to multi-tenant household management.

## Architecture Principles

### Core Design Principles

1. **Mobile-First Performance**: All architectural decisions prioritize mobile device constraints
2. **Offline-First**: Core functionality works without internet connectivity
3. **Progressive Enhancement**: Features scale gracefully from basic to advanced usage
4. **User Data Sovereignty**: Architecture enables complete user control over data
5. **Horizontal Scalability**: System designed for community growth and multi-tenant usage

### Performance Constraints

- **Page Load**: < 2 seconds on 3G connections
- **API Response**: < 200ms average for core operations
- **Bundle Size**: < 200KB initial JavaScript bundle
- **Image Optimization**: Automatic compression and progressive loading

---

## High-Level System Architecture

```mermaid
graph TB
    subgraph "Client Layer"
        PWA[Next.js PWA]
        Mobile[Mobile Browser]
        Offline[Offline Storage]
    end

    subgraph "CDN & Edge"
        CDN[CloudFlare CDN]
        Edge[Edge Functions]
    end

    subgraph "Application Layer"
        API[Go API Server]
        AuthJS[Auth.js OAuth Handler]
        ImageProc[Image Processing]
    end

    subgraph "Data Layer"
        DB[(PostgreSQL)]
        Cache[(Redis Cache)]
        Storage[Object Storage]
    end

    subgraph "Infrastructure"
        LB[Load Balancer]
        Monitor[Monitoring]
        Backup[Backup System]
    end

    Mobile --> PWA
    PWA --> CDN
    CDN --> Edge
    Edge --> LB
    LB --> API
    API --> AuthJS
    API --> DB
    API --> Cache
    API --> ImageProc
    ImageProc --> Storage

    PWA -.-> Offline
    Storage --> CDN

    Monitor --> API
    Monitor --> DB
    Backup --> DB
    Backup --> Storage
```

---

## Component Architecture

### Frontend Architecture (Next.js PWA)

```mermaid
graph TB
    subgraph "Next.js App Router"
        Layout[Root Layout]
        Auth[Auth Pages]
        Dashboard[Dashboard]
        ItemDetail[Item Detail]
        Search[Search Interface]
    end

    subgraph "State Management"
        Store[Zustand Store]
        Cache[TanStack Query]
        Local[Local Storage]
    end

    subgraph "Core Components"
        Camera[Camera Component]
        ImageOpt[Image Optimizer]
        Search[Search Component]
        ItemForm[Item Form]
    end

    subgraph "PWA Features"
        SW[Service Worker]
        Manifest[App Manifest]
        Offline[Offline Queue]
    end

    Layout --> Dashboard
    Layout --> ItemDetail
    Layout --> Search

    Dashboard --> Store
    ItemDetail --> Cache
    Search --> Cache

    Camera --> ImageOpt
    ItemForm --> Store

    SW --> Offline
    SW --> Cache
    Offline --> Local
```

#### Key Frontend Components

**Next.js App Router Structure:**

```
app/
├── (auth)/
│   ├── login/
│   └── register/
├── dashboard/
│   ├── page.tsx          # Item grid view
│   ├── add/page.tsx      # Add item form
│   └── [id]/page.tsx     # Item detail
├── search/
│   └── page.tsx          # Search interface
└── layout.tsx            # Root layout with PWA manifest
```

**State Management Strategy:**

- **Zustand**: Global state for user data and app settings
- **TanStack Query**: Server state management with caching
- **Local Storage**: Offline data persistence and user preferences

**Performance Optimizations:**

- **Code Splitting**: Route-based and component-based splitting
- **Image Optimization**: Next.js Image component with custom loader
- **Lazy Loading**: Progressive component loading with Suspense
- **Service Worker**: Aggressive caching and offline functionality with sync queue
- **Offline Support**: IndexedDB with conflict resolution and background sync (see [Offline Support Spec](./implementation-specs/offline-support.md))

### Backend Architecture (Go API)

```mermaid
graph TB
    subgraph "API Layer"
        Router[Gin Router]
        Middleware[Auth Middleware]
        Handlers[Request Handlers]
    end

    subgraph "Business Logic"
        ItemService[Item Service]
        UserService[User Service]
        ImageService[Image Service]
        SearchService[Search Service]
    end

    subgraph "Data Access"
        ItemRepo[Item Repository]
        UserRepo[User Repository]
        ImageRepo[Image Repository]
    end

    subgraph "External Services"
        Storage[Object Storage]
        Email[Email Service]
        Analytics[Analytics]
    end

    Router --> Middleware
    Middleware --> Handlers
    Handlers --> ItemService
    Handlers --> UserService
    Handlers --> ImageService
    Handlers --> SearchService

    ItemService --> ItemRepo
    UserService --> UserRepo
    ImageService --> ImageRepo

    ImageService --> Storage
    UserService --> Email
    ItemService --> Analytics
```

#### Go Service Architecture

**Directory Structure:**

```
cmd/
├── api/
│   └── main.go           # API server entry point
├── migrate/
│   └── main.go           # Database migrations
internal/
├── handlers/             # HTTP request handlers
├── services/             # Business logic layer
├── repositories/         # Data access layer
├── models/              # Data models and DTOs
├── middleware/          # Authentication, logging, CORS
├── config/              # Configuration management
└── utils/               # Shared utilities
```

**Service Layer Design:**

- **Item Service**: CRUD operations, search, categorization
- **User Service**: Authentication, profile management, preferences
- **Image Service**: Upload, processing, optimization, CDN integration
- **Search Service**: Full-text search, filtering, ranking

---

## Data Architecture

### Database Schema Design

Note: This section presents a conceptual model. The authoritative, single-source schema (DDL, indexes, triggers, and RLS policies) lives in [database schema spec](./implementation-specs/database-schema.md). Update that file first; this diagram should be kept consistent with it.

```mermaid
erDiagram
    Users ||--o{ Items : owns
    Users ||--o{ Households : belongs_to
    Households ||--o{ Items : contains
    Items ||--o{ Images : has
    Items ||--o{ ItemHistory : tracks
    Categories ||--o{ Items : categorizes
    Locations ||--o{ Items : stores
```

#### Database Design Decisions

**PostgreSQL Features Utilized:**

- **UUID Primary Keys**: Distributed-friendly, privacy-focused identifiers
- **JSONB Columns**: Flexible metadata storage for preferences and settings
- **Full-Text Search**: tsvector with weighted ranking (A: name, B: description, C: category)
- **Trigram Similarity**: pg_trgm for fuzzy matching and typo tolerance
- **Partial Indexes**: Performance optimization for common queries
- **Row Level Security**: Multi-tenant data isolation

### Image Storage Architecture

```mermaid
graph LR
    subgraph "Upload Flow"
        Upload[Client Upload]
        Validate[Size/Type Validation]
        Process[Image Processing]
        Store[Object Storage]
    end

    subgraph "Processing Pipeline"
        Original[Original Image]
        Resize[Multi-Resolution]
        Compress[Compression]
        Format[Format Optimization]
    end

    subgraph "Delivery"
        CDN[CDN Distribution]
        Progressive[Progressive Loading]
        Responsive[Responsive Images]
    end

    Upload --> Validate
    Validate --> Process
    Process --> Store

    Process --> Original
    Process --> Resize
    Resize --> Compress
    Compress --> Format

    Store --> CDN
    CDN --> Progressive
    CDN --> Responsive
```

#### Image Optimization Strategy

**Upload Processing:**

- **Size Limits**: 10MB max upload, 2048px max dimension
- **Format Support**: JPEG, PNG, WebP input; WebP/AVIF output
- **Multiple Resolutions**: 150px (thumbnail), 800px (display), 1600px (detail)
- **Compression**: Automated quality optimization for file size

**Storage Organization:**

```
images/
├── originals/
│   └── {user_id}/{item_id}/{image_id}.{ext}
├── thumbnails/
│   └── {user_id}/{item_id}/{image_id}_thumb.webp
├── display/
│   └── {user_id}/{item_id}/{image_id}_800.webp
└── detail/
    └── {user_id}/{item_id}/{image_id}_1600.webp
```

---

## API Design

### RESTful API Structure

```mermaid
graph TB
    subgraph "Authentication"
        AuthAPI["/api/auth/*"]
    end

    subgraph "Core Resources"
        ItemsAPI["/api/items/*"]
        UsersAPI["/api/users/*"]
        SearchAPI["/api/search/*"]
    end

    subgraph "Supporting Resources"
        CategoriesAPI["/api/categories/*"]
        LocationsAPI["/api/locations/*"]
        ImagesAPI["/api/images/*"]
    end

    subgraph "Advanced Features"
        HouseholdsAPI["/api/households/*"]
        ExportAPI["/api/export/*"]
        AnalyticsAPI["/api/analytics/*"]
    end
```

For complete endpoint contracts, request/response bodies, and error codes, see the authoritative [API specification](./implementation-specs/api-specification.md).

#### API Response Standards

Standard success and error formats are defined in the [API specification](./implementation-specs/api-specification.md).

---

## Performance Architecture

### Caching Strategy

```mermaid
graph TB
    subgraph "Client-Side Caching"
        Browser[Browser Cache]
        SW[Service Worker Cache]
        LocalDB[IndexedDB]
    end

    subgraph "CDN Caching"
        Static[Static Assets]
        Images[Image Cache]
        API[API Cache]
    end

    subgraph "Server-Side Caching"
        Redis[Redis Cache]
        Query[Query Cache]
        Session[Session Store]
    end

    subgraph "Database"
        PG[(PostgreSQL)]
    end

    Browser --> SW
    SW --> LocalDB

    Static --> CDN
    Images --> CDN
    API --> CDN

    CDN --> Redis
    Redis --> Query
    Redis --> Session

    Query --> PG
    Session --> PG
```

#### Caching Levels

**Browser/PWA Caching:**

- **Static Assets**: 1 year cache with versioning
- **API Responses**: 5 minutes for item lists, 1 hour for categories
- **Images**: Permanent cache with URL-based invalidation
- **Offline Queue**: IndexedDB for offline actions

**CDN Caching:**

- **Static Assets**: Global distribution with edge caching
- **Images**: Optimized delivery with format negotiation
- **API Responses**: Regional caching for read-only endpoints

**Redis Caching:**

- **User Sessions**: 24-hour TTL with sliding expiration
- **Frequent Queries**: Category lists, user preferences
- **Search Results**: 15-minute TTL for common searches
- **Rate Limiting**: Request counting and throttling

### Database Optimization

**Query Optimization:**

- **Prepared Statements**: All queries use prepared statements
- **Connection Pooling**: Optimized connection management
- **Read Replicas**: Separation of read/write workloads (future)
- **Partitioning**: Date-based partitioning for history tables (future)

**Performance Monitoring:**

- **Query Performance**: Automatic slow query detection
- **Index Usage**: Regular index utilization analysis
- **Connection Metrics**: Pool utilization and wait times
- **Lock Monitoring**: Deadlock detection and resolution

---

## Security Architecture

### Authentication & Authorization

```mermaid
graph TB
    subgraph "Authentication Flow"
        Login[User Login]
        JWT[JWT Token]
        Refresh[Refresh Token]
        Validate[Token Validation]
    end

    subgraph "Authorization Layers"
        Route[Route Protection]
        Resource[Resource Access]
        Data[Data Isolation]
    end

    subgraph "Security Features"
        RBAC[Role-Based Access]
        Audit[Audit Logging]
        Encryption[Data Encryption]
    end

    Login --> JWT
    JWT --> Refresh
    Refresh --> Validate

    Validate --> Route
    Route --> Resource
    Resource --> Data

    RBAC --> Resource
    Audit --> Data
    Encryption --> Data
```

#### Security Implementation

**Authentication:**

- **OAuth Providers**: Google and GitHub authentication via Auth.js (NextAuth.js)
- **JWT Tokens**: Short-lived access tokens (15 minutes) for API access
- **Refresh Tokens**: Long-lived refresh tokens (7 days) with rotation
- **Secure Storage**: Auth.js handles secure session storage
- **No Passwords**: OAuth-only authentication, no password storage

**Authorization:**

- **Resource Ownership**: Users can only access their own data
- **Household Permissions**: Role-based access for shared households
- **API Rate Limiting**: Per-user request throttling
- **Input Validation**: Comprehensive request validation

**Data Protection:**

- **Encryption at Rest**: Database encryption for sensitive data
- **Encryption in Transit**: TLS 1.3 for all communications
- **Password Security**: bcrypt hashing with appropriate cost
- **PII Handling**: Minimal collection and secure processing

---

## Deployment Architecture

### Infrastructure Overview

```mermaid
graph TB
    subgraph "Production Environment"
        LB[Load Balancer]
        API1[API Server 1]
        API2[API Server 2]
        DB[(Primary DB)]
        Cache[(Redis)]
        Storage[Object Storage]
    end

    subgraph "CDN & Edge"
        CDN[Global CDN]
        Edge[Edge Functions]
    end

    subgraph "Monitoring"
        Metrics[Metrics Collection]
        Logs[Log Aggregation]
    end

    subgraph "CI/CD"
        Git[Git Repository]
        Build[Build Pipeline]
        Deploy[Deployment]
    end

    CDN --> LB
    LB --> API1
    LB --> API2
    API1 --> DB
    API2 --> DB
    API1 --> Cache
    API2 --> Cache
    API1 --> Storage
    API2 --> Storage

    Storage --> CDN

    API1 --> Metrics
    API2 --> Logs

    Git --> Build
    Build --> Deploy
    Deploy --> LB
```

#### Deployment Strategy

**Container Architecture:**

```dockerfile
# Multi-stage build for minimal production image
FROM node:18-alpine AS frontend-builder
FROM golang:1.21-alpine AS backend-builder
FROM alpine:latest AS runtime
```

**Environment Management:**

- **Development**: Local Docker Compose environment
- **Production**: Managed Kubernetes with auto-scaling

**CI/CD Pipeline:**

1. **Code Push**: Trigger on main branch changes
2. **Testing**: Unit tests, integration tests, security scans
3. **Building**: Docker image creation and optimization
4. **Deployment**: Blue-green deployment with health checks

---

## Monitoring & Observability

### Monitoring Stack

```mermaid
graph TB
    subgraph "Application Metrics"
        App[Application]
        Custom[Custom Metrics]
        Health[Health Checks]
    end

    subgraph "User Experience"
        RUM[Real User Monitoring]
        Performance[Performance Metrics]
        Errors[Error Tracking]
    end

    App --> Custom
    Custom --> Health

    RUM --> Performance
    Performance --> Errors
```

#### Key Metrics

**Performance Metrics:**

- **Response Time**: API endpoint response times (p50, p95, p99)
- **Page Load**: Frontend page load times
- **Database**: Query performance and connection metrics
- **Cache**: Hit rates and response times

**Business Metrics:**

- **User Activity**: Daily/monthly active users
- **Feature Usage**: Item creation, search usage, photo uploads
- **Performance Budget**: Mobile performance score tracking
- **Error Rates**: Application errors and user-reported issues

---

## Evolution & Migration Strategy

### Phase Evolution Architecture

```mermaid
graph TB
    subgraph "Phase 1: MVP"
        MVP[Single User]
        Basic[Basic Features]
        Simple[Simple Architecture]
    end

    subgraph "Phase 2: Enhanced"
        Enhanced[Enhanced Features]
        Perf[Performance Optimization]
        Search[Advanced Search]
    end

    subgraph "Phase 3: Community"
        Multi[Multi-User]
        Household[Household Features]
        Scale[Scaling Architecture]
    end

    MVP --> Enhanced
    Basic --> Perf
    Simple --> Search

    Enhanced --> Multi
    Perf --> Household
    Search --> Scale
```

#### Migration Strategies

**Database Evolution:**

- **Schema Migrations**: Automated, reversible database migrations
- **Data Migrations**: Careful data transformation with rollback plans
- **Performance Testing**: Load testing before and after migrations
- **Zero-Downtime**: Blue-green deployments for major changes

**Feature Flag Management:**

- **Gradual Rollout**: New features behind feature flags
- **Rollback Capability**: Instant feature disabling if needed

**Scaling Considerations:**

- **CDN Expansion**: Global content delivery optimization
- **Caching Layers**: Additional caching tiers for scale

---

## Technical Debt Management

### Code Quality Standards

**Frontend Standards:**

- **TypeScript**: Strict type checking enabled
- **ESLint/Prettier**: Automated code formatting and linting
- **Testing**: 80%+ test coverage requirement
- **Performance**: Lighthouse score monitoring

**Backend Standards:**

- **Go Modules**: Dependency management and versioning
- **golangci-lint**: Comprehensive Go linting
- **Testing**: Unit and integration test requirements
- **Documentation**: Godoc for all public APIs

**Architecture Debt Tracking:**

- **ADR Documentation**: Architectural Decision Records for major choices
- **Technical Debt Backlog**: Dedicated tracking and prioritization
- **Refactoring Cycles**: Regular technical debt reduction sprints
- **Performance Regression**: Automated detection and alerts

---

This system design provides a comprehensive foundation for building Tracktory according to the strategic vision while addressing the key architectural concerns around performance, scalability, and user experience. The design emphasizes mobile-first performance while planning for future community and household features.
