# US-009: Basic Search

**As a** user with multiple items  
**I want** to search for specific items by name  
**So that** I can quickly find what I'm looking for without scrolling

## Acceptance Criteria

- [ ] Search box prominently displayed at top of item list
- [ ] Real-time search as user types (debounced)
- [ ] Search matches item names and descriptions
- [ ] Search results highlight matching text
- [ ] Search works offline with locally cached items
- [ ] Clear search button to return to full list
- [ ] Search maintains performance with 100+ items
- [ ] Empty search results show helpful message

## Search Behavior

- [ ] Minimum 2 characters before search activates
- [ ] Case-insensitive matching
- [ ] Partial word matching (e.g., "dri" matches "drill")
- [ ] Search results maintain grid layout consistency
- [ ] Search state preserved during navigation

## Performance Requirements

- [ ] Search results appear < 300ms after typing stops
- [ ] Smooth typing experience (no input lag)
- [ ] Efficient client-side filtering for small collections
- [ ] Server-side search for large collections

## Technical Implementation

- **Architecture Decision**: PostgreSQL FTS per [ADR-005: Search Architecture](../../architecture/technical-decisions/adr-005-search-architecture.md)
- **Implementation Details**: Search queries in [search implementation spec](../../architecture/implementation-specs/search.md)
- **API Contracts**: Search endpoints in [API specification](../../architecture/implementation-specs/api-specification.md#search)
- **Database Schema**: Search vector setup in [database schema spec](../../architecture/implementation-specs/database-schema.md)
- **Offline Support**: Client filtering per [offline support spec](../../architecture/implementation-specs/offline-support.md)

## Technical Notes

- PostgreSQL full-text search for server-side queries
- Client-side filtering for offline/cached items
- Debounced input to prevent excessive API calls

## Status & Metadata

- **Status**: Ready
- **Priority**: Medium
- **Estimate**: 5 points
- **Dependencies**: US-007 (item list to search within)
- **API Endpoints**: `GET /search`
