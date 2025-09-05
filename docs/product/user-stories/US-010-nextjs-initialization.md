# US-010: Next.js Frontend Initialization

**As a** developer  
**I want** a Next.js PWA project with authentication setup  
**So that** I can begin implementing the frontend user interface

## Acceptance Criteria

- [ ] Next.js 14+ project initialized with App Router
- [ ] TypeScript configuration with strict mode
- [ ] Auth.js (NextAuth.js) configured for Google/GitHub OAuth
- [ ] PWA configuration with service worker
- [ ] Tailwind CSS for styling
- [ ] ESLint and Prettier for code quality
- [ ] Basic layout with navigation and auth state
- [ ] Environment configuration for different stages
- [ ] Integration with backend API endpoints

## Project Structure

```
app/
├── (auth)/
│   ├── login/
│   └── register/
├── dashboard/
│   ├── page.tsx          # Item grid view
│   ├── add/page.tsx      # Add item form
│   └── [id]/page.tsx     # Item detail
├── api/
│   └── auth/[...nextauth]/route.ts
├── globals.css
└── layout.tsx            # Root layout with PWA manifest
components/
├── ui/                   # Reusable UI components
├── forms/                # Form components
└── layout/               # Layout components
lib/
├── auth.ts               # Auth.js configuration
├── api.ts                # API client utilities
└── utils.ts              # Utility functions
public/
├── manifest.json         # PWA manifest
└── icons/                # PWA icons
```

## Technical Requirements

- [ ] Next.js 14+ with App Router and React 18+
- [ ] Auth.js with Google and GitHub providers
- [ ] PWA with offline capability framework
- [ ] Responsive design with mobile-first approach
- [ ] TypeScript with strict configuration
- [ ] API client with authentication headers
- [ ] Environment variable configuration

## Integration Points

- [ ] OAuth callback handling with backend
- [ ] JWT token management and refresh
- [ ] API base URL configuration for different environments
- [ ] Image upload integration with backend endpoints
- [ ] Offline support preparation (IndexedDB, service worker)

## Technical Implementation

- **Technology Stack**: Next.js per [ADR-001: Technology Stack](../../architecture/technical-decisions/adr-001-technology-stack.md)
- **Authentication**: Auth.js setup per [authentication spec](../../architecture/implementation-specs/authentication.md)
- **API Integration**: Endpoints per [API specification](../../architecture/implementation-specs/api-specification.md)
- **Offline Architecture**: PWA setup per [ADR-006: Offline Support](../../architecture/technical-decisions/adr-006-offline-support.md)

## Status & Metadata

- **Status**: Ready
- **Priority**: High (frontend foundation)
- **Estimate**: 5 points
- **Dependencies**: US-004 (backend auth endpoints)
- **Deliverable**: Runnable Next.js app with authentication flow
