# US-002: Create New Item

**As a** logged-in user  
**I want** to quickly add a new item to my inventory  
**So that** I can track my belongings with basic details and photos

## Acceptance Criteria

- [ ] User can access "Add Item" from main navigation
- [ ] Form includes essential fields: name (required), description, category, location
- [ ] User can take photo directly with mobile camera
- [ ] User can upload photo from device gallery
- [ ] Photo is automatically compressed for optimal performance
- [ ] User can add optional purchase price and date
- [ ] User can set item condition (excellent, good, fair, poor)
- [ ] Form validates required fields before submission
- [ ] Success message shows after item creation
- [ ] User is redirected to item detail view after creation
- [ ] Form works offline and syncs when connection restored
- [ ] Creation takes < 30 seconds on mobile device

## Error Handling

- [ ] Clear validation errors for missing required fields
- [ ] Image upload failures show retry option
- [ ] Network errors queue item for offline sync
- [ ] Large image files are rejected with helpful message

## Technical Notes

- Mobile-first form design with touch-optimized inputs
- Image processing pipeline generates multiple resolutions
- Offline support via IndexedDB queue
- Uses multipart form upload for images

## Status & Metadata

- **Status**: Ready
- **Priority**: High
- **Estimate**: 8 points
- **Dependencies**: US-001 (authentication), US-003 (categories)
- **API Endpoints**: `POST /items`, `POST /items/{id}/images`
