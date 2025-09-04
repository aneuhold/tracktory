# US-005: View Item Details

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

## Technical Notes

- Progressive image loading (WebP/AVIF with JPEG fallback)
- Client-side routing for smooth navigation
- Image gallery component with touch gestures

## Status & Metadata

- **Status**: Ready
- **Priority**: High
- **Estimate**: 5 points
- **Dependencies**: US-002 (items), US-004 (navigation from list)
- **API Endpoints**: `GET /items/{id}`, `GET /images/{id}`
