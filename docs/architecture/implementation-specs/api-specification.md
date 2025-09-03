# Tracktory API Specification (v1)

This document is the single source of truth for API contracts. System design and ADRs should reference this file for endpoint details.

- Base Path: `/api`
- Versioning: URI-based (`/api/...`) with semantic changes tracked here; add `/v2` when breaking changes occur
- Auth: OAuth via Auth.js (frontend). API requests to the Go backend use JWT in `Authorization: Bearer <token>`
- Content-Type: `application/json` unless noted

## Conventions

- IDs are UUIDv4 strings
- Times are ISO-8601 UTC strings, e.g., `2025-09-03T10:00:00Z`
- Request/response fields use `camelCase`
- Pagination: offset-based with `page` (1-based) and `limit` (default 20, max 100)
- Sorting: `sortBy` and `sortDir` (asc|desc)
- Idempotency: Supported for create/update via `Idempotency-Key` header (recommended for offline sync)

## Standard Responses

Success:

```json
{
  "success": true,
  "data": {},
  "meta": {
    "timestamp": "2025-09-03T10:00:00Z",
    "version": "1.0",
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 150,
      "hasMore": true
    }
  }
}
```

Error:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid item data provided",
    "details": {
      "name": ["Name is required"],
      "categoryId": ["Invalid category ID"]
    }
  },
  "meta": {
    "timestamp": "2025-09-03T10:00:00Z",
    "requestId": "req_123456789"
  }
}
```

Common Error Codes: `UNAUTHORIZED`, `FORBIDDEN`, `NOT_FOUND`, `RATE_LIMITED`, `VALIDATION_ERROR`, `CONFLICT`, `INTERNAL_ERROR`

Rate Limiting: Responses may include `X-RateLimit-Limit`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`

## Authentication

Auth is handled via Auth.js on the frontend. The API accepts JWTs. Some auth-related endpoints are exposed for integration.

Endpoints:

```
POST   /auth/oauth/google           # Google OAuth login (Auth.js route)
POST   /auth/oauth/github           # GitHub OAuth login (Auth.js route)
POST   /auth/oauth/callback         # OAuth callback processing (Auth.js route)
POST   /auth/refresh                # Refresh API token
POST   /auth/logout                 # Logout current session
GET    /auth/user                   # Current user info
```

Current user response:

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "User Name",
    "avatarUrl": "https://...",
    "provider": "google"
  },
  "meta": { "timestamp": "2025-09-03T10:00:00Z" }
}
```

## Items

Resource representing a user- or household-owned item.

Schema (response):

```json
{
  "id": "uuid",
  "userId": "uuid",
  "householdId": "uuid|null",
  "name": "string",
  "description": "string|null",
  "categoryId": "uuid|null",
  "locationId": "uuid|null",
  "purchasePrice": 12.34,
  "purchaseDate": "2025-01-01",
  "status": "active|sold|lost|donated",
  "condition": "excellent|good|fair|poor",
  "createdAt": "2025-09-03T10:00:00Z",
  "updatedAt": "2025-09-03T10:00:00Z",
  "images": [
    {
      "id": "uuid",
      "thumbnailUrl": "...",
      "optimizedUrl": "...",
      "createdAt": "..."
    }
  ]
}
```

Endpoints:

```
GET    /items                         # List items (filters supported)
POST   /items                         # Create item
GET    /items/{id}                    # Get item
PUT    /items/{id}                    # Update item (full)
PATCH  /items/{id}                    # Update item (partial)
DELETE /items/{id}                    # Delete item
POST   /items/{id}/images             # Upload image (multipart/form-data)
```

List filters (query params):

- `page`, `limit`
- `q` (search), `categoryId`, `locationId`, `status[]`, `condition[]`
- `sortBy` (createdAt|updatedAt|name), `sortDir` (asc|desc)

Create/Update request (partial example):

```json
{
  "name": "Drill",
  "description": "Cordless",
  "categoryId": "uuid",
  "locationId": "uuid",
  "purchasePrice": 99.99,
  "purchaseDate": "2024-08-20",
  "status": "active",
  "condition": "good"
}
```

Image upload (multipart):

- `file`: image file
- Optional: `altText`, `tags[]`

## Search

Endpoints:

```
GET    /search                        # Full-text search over items
GET    /search/suggestions            # Autocomplete suggestions
GET    /search/filters                # Available filters (categories, locations)
```

`GET /search` query params:

- `q` (string), `page`, `limit`, `categoryId`, `locationId`, `status[]`, `condition[]`

Response (items array with ranking):

```json
{
  "success": true,
  "data": {
    "items": [{ "id": "uuid", "name": "Drill", "score": 0.87 }]
  },
  "meta": {
    "timestamp": "2025-09-03T10:00:00Z",
    "pagination": { "page": 1, "limit": 20, "hasMore": false }
  }
}
```

## Categories

Endpoints:

```
GET    /categories                    # List categories
POST   /categories                    # Create category
PUT    /categories/{id}               # Update category
DELETE /categories/{id}               # Delete category
```

Schema:

```json
{
  "id": "uuid",
  "name": "string",
  "icon": "string|null",
  "parentId": "uuid|null",
  "sortOrder": 0
}
```

## Locations

Endpoints:

```
GET    /locations                     # List locations
POST   /locations                     # Create location
PUT    /locations/{id}                # Update location
DELETE /locations/{id}                # Delete location
```

Schema:

```json
{
  "id": "uuid",
  "name": "string",
  "description": "string|null",
  "parentId": "uuid|null"
}
```

## Images

Endpoints:

```
GET    /images/{id}                   # Get image metadata
DELETE /images/{id}                   # Delete image
```

Schema:

```json
{
  "id": "uuid",
  "itemId": "uuid",
  "originalUrl": "string",
  "optimizedUrl": "string|null",
  "thumbnailUrl": "string|null",
  "createdAt": "..."
}
```

## Households (Phase 3)

Endpoints (subject to change):

```
GET    /households                    # List households
POST   /households                    # Create household
POST   /households/{id}/invite        # Invite member
GET    /households/{id}/members       # List members
```

## Security

- All endpoints require `Authorization: Bearer <token>` unless explicitly public
- Per-user/household data isolation enforced via RLS in PostgreSQL
- Input validation with detailed error messages (see Standard Responses)
- Offline/Idempotency: Clients should send `Idempotency-Key` for retried POST/PUT

## Changelog

- 2025-09-03: Initial v1 specification
