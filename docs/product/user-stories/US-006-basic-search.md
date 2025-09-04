# US-006: Basic Search

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

## Technical Notes

- PostgreSQL full-text search for server-side queries
- Client-side filtering for offline/cached items
- Debounced input to prevent excessive API calls

## Status & Metadata

- **Status**: Ready
- **Priority**: Medium
- **Estimate**: 5 points
- **Dependencies**: US-004 (item list to search within)
- **API Endpoints**: `GET /search`
