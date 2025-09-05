# US-007: View Item List

**As a** user with tracked items  
**I want** to see an overview of all my belongings  
**So that** I can quickly browse and find specific items

## Acceptance Criteria

- [ ] User sees grid layout of items with thumbnail photos
- [ ] Each item card shows: name, category, thumbnail image
- [ ] Grid layout responsive (2 columns mobile, 3+ columns desktop)
- [ ] Items load in reasonable time (< 2 seconds on 3G)
- [ ] List shows most recently added items first by default
- [ ] Empty state shows helpful message for new users
- [ ] Infinite scroll or pagination for large collections
- [ ] Tap/click item to view full details
- [ ] Visual indicators for items without photos

## Performance Requirements

- [ ] Initial page load < 2 seconds on mobile 3G
- [ ] Smooth scrolling with virtual scrolling for 100+ items
- [ ] Images lazy-load as user scrolls
- [ ] Offline browsing of previously loaded items

## Empty States

- **No items yet**: "Start by adding your first item!" with prominent add button
- **No search results**: "No items found. Try different search terms."
- **Loading**: Skeleton grid showing placeholder cards

## Technical Implementation

- **API Contracts**: Item listing in [API specification](../../architecture/implementation-specs/api-specification.md#items)
- **Database Schema**: Items queries in [database schema spec](../../architecture/implementation-specs/database-schema.md)
- **Image Delivery**: CDN strategy per [image processing spec](../../architecture/implementation-specs/image-processing.md)
- **Offline Support**: Cached browsing per [offline support spec](../../architecture/implementation-specs/offline-support.md)

## Technical Notes

- Virtual scrolling for performance with large collections
- Image lazy loading with intersection observer
- Optimized thumbnail generation and caching

## Status & Metadata

- **Status**: Ready
- **Priority**: High
- **Estimate**: 5 points
- **Dependencies**: US-006 (items must exist to display)
- **API Endpoints**: `GET /items`
