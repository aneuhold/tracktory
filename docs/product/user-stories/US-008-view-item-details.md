# US-008: View Item Details

**As a** user  
**I want** to see full details of a specific item  
**So that** I can review all information and photos I've recorded

## Acceptance Criteria

- [ ] User can access item details from list view
- [ ] Details page shows all item information: name, description, category, location, price, date, condition
- [ ] Full-size images display with swipe/navigation between multiple photos
- [ ] Images load progressively (thumbnail → full resolution)
- [ ] Page loads quickly (< 1 second) from list view
- [ ] Back navigation returns to previous list position
- [ ] Deep linking works (can share/bookmark item URLs)
- [ ] Timestamps show when item was created/last updated
- [ ] Missing information shows appropriate placeholders

## Image Handling

- [ ] Main image displays prominently at top
- [ ] Multiple images browsable with swipe gestures (mobile) or arrows (desktop)
- [ ] Tap image for full-screen view
- [ ] Image loading states with skeleton placeholders
- [ ] Fallback for items without photos

## Mobile Optimization

- [ ] Touch-friendly interface elements
- [ ] Optimized image sizes for mobile bandwidth
- [ ] Smooth transitions between views
- [ ] Readable text at mobile sizes

## Technical Implementation

- **API Contracts**: Item detail endpoint in [API specification](../../architecture/implementation-specs/api-specification.md#items)
- **Database Schema**: Item queries in [database schema spec](../../architecture/implementation-specs/database-schema.md)
- **Image Delivery**: Progressive loading per [image processing spec](../../architecture/implementation-specs/image-processing.md)
- **Architecture Decision**: Image formats per [ADR-002: Image Storage](../../architecture/technical-decisions/adr-002-image-storage.md)

## Technical Notes

- Progressive image loading (WebP/AVIF with JPEG fallback)
- Client-side routing for smooth navigation
- Image gallery component with touch gestures

## Status & Metadata

- **Status**: Ready
- **Priority**: High
- **Estimate**: 5 points
- **Dependencies**: US-006 (items), US-007 (navigation from list)
- **API Endpoints**: `GET /items/{id}`, `GET /images/{id}`
