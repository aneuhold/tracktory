# Image Processing Implementation Specification

Authoritative implementation details for image storage and processing. Decisions are in [ADR-002](../technical-decisions/adr-002-image-storage.md). Database paths and DDL references are in the [database schema spec](./database-schema.md).

## Processing Pipeline

```go
type ImageProcessor struct {
    storage     ObjectStorage
    cdn         CDNProvider
    resolutions []Resolution
}

type Resolution struct {
    Name    string
    Width   int
    Height  int
    Quality int
}

func (p *ImageProcessor) ProcessUpload(image io.Reader) (*ProcessedImage, error) {
    // 1. Validate image type and size
    // 2. Generate multiple resolutions
    // 3. Optimize formats (WebP/AVIF)
    // 4. Upload to object storage
    // 5. Update CDN cache
    // 6. Return image metadata
}
```

## Object key schema (authoritative)

```
images/
    originals/{user_id}/{item_id}/{image_id}.{ext}
    thumbnails/{user_id}/{item_id}/{image_id}_thumb.webp
    display/{user_id}/{item_id}/{image_id}_800.webp
    detail/{user_id}/{item_id}/{image_id}_1600.webp
```

Notes:

- This schema is the single source of truth for naming and path structure.
- The top-level prefixes (originals, thumbnails, display, detail) can be targeted in CDN rules or IAM policies as needed.

Security & ACL:

- Originals: private by default; accessed via short-lived signed URLs from API
- Derived renditions (thumbnails/display/detail): public-read via CDN
- Do not include PII in keys; use UUIDs only

## Validation & Limits

- Max upload size: 10MB
- Max dimension: 2048px (longest side)
- Allowed inputs: JPEG, PNG, WebP
- Outputs: WebP/AVIF (+ JPEG fallback)

## CDN & Caching

- Use immutable URLs with digest/version to enable long-lived caching
- Set appropriate `Cache-Control` headers (e.g., `public, max-age=31536000, immutable`)
- Invalidate CDN on replacement or deletion

## Frontend Delivery

- Use `<img srcSet>`/`sizes` for responsive delivery
- Lazy-load below-the-fold images
- Preload critical images for detail pages

## Notes

- API endpoints for upload and deletion are defined in the [API specification](./api-specification.md).

## Upload Flow (Preferred: Direct-to-Storage)

1. Frontend requests a presigned URL from API: `POST /items/{id}/images/sign` with `contentType`, `fileName`, `size`
2. Frontend uploads file directly to object storage using returned URL/fields
3. Frontend calls `POST /items/{id}/images/confirm` with `objectKey` to register upload
4. API performs processing:
   - MVP: synchronous inside API request; respond when variants are ready
   - Future: enqueue job (e.g., Redis queue) and return 202 Accepted; client polls or receives webhook/WS update
5. API stores image metadata and returns URLs for derived assets

Error handling:

- Validate `size` ≤ 10MB and `contentType` in allowed set
- On confirm, return 400 if object not found; 403 if user not authorized for item
