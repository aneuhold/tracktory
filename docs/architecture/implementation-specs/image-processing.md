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

## Storage Layout

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
