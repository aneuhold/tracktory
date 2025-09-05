# Search Implementation Specification

Authoritative implementation details for search. Decisions are in [ADR-005](../technical-decisions/adr-005-search-architecture.md). API contracts are in the [API specification](./api-specification.md). Database schema is in the [database schema spec](./database-schema.md).

## Database: Search Vector and Triggers

```sql
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE OR REPLACE FUNCTION update_item_search_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.search_vector :=
        setweight(to_tsvector('english', COALESCE(NEW.name, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.description, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE((SELECT name FROM categories WHERE id = NEW.category_id), '')), 'C');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER item_search_vector_update
    BEFORE INSERT OR UPDATE ON items
    FOR EACH ROW EXECUTE FUNCTION update_item_search_vector();
```

## Indexing Strategy

```sql
-- Primary search index
CREATE INDEX idx_items_search_vector ON items USING gin(search_vector);

-- Supporting indexes for filters
CREATE INDEX idx_items_user_category ON items(user_id, category_id);
CREATE INDEX idx_items_user_location ON items(user_id, location_id);
CREATE INDEX idx_items_user_status ON items(user_id, status);

-- Composite index for common queries
CREATE INDEX idx_items_user_search_created ON items(user_id, created_at DESC)
    WHERE search_vector IS NOT NULL;
```

## Go Service Skeleton

```go
type SearchService struct { db *sql.DB }

type SearchRequest struct {
    Query      string   `json:"query"`
    Categories []string `json:"categories,omitempty"`
    Locations  []string `json:"locations,omitempty"`
    Status     []string `json:"status,omitempty"`
    Limit      int      `json:"limit"`
    Offset     int      `json:"offset"`
}

func (s *SearchService) SearchItems(userID string, req SearchRequest) (*SearchResponse, error) {
    query := `
        SELECT id, name, description, category_id, location_id,
               ts_rank(search_vector, plainto_tsquery($2)) as rank
        FROM items
        WHERE user_id = $1
          AND search_vector @@ plainto_tsquery($2)
          AND ($3::text[] IS NULL OR category_id = ANY($3))
          AND ($4::text[] IS NULL OR location_id = ANY($4))
          AND ($5::text[] IS NULL OR status = ANY($5))
        ORDER BY rank DESC, created_at DESC
        LIMIT $6 OFFSET $7
    `
    // Execute query and return results
}
```

## Caching

- Cache popular queries in Redis with 15-minute TTL
- Invalidate on item create/update/delete affecting search_vector

## Notes

- Keep SQL in sync with the [database schema spec](./database-schema.md).
- Endpoint payloads live in the [API specification](./api-specification.md).

## Query Behavior & UX Contracts

- Minimum query length: 2 characters; shorter queries return empty result quickly
- Debounce: 200–300ms client-side
- Cursor pagination preferred; see API spec for `cursor`/`nextCursor`

## Highlighting

Server may return HTML-escaped snippets with `<em>` around matches. Example shape:

```json
{
  "id": "uuid",
  "name": "Drill",
  "score": 0.87,
  "highlights": {
    "name": "<em>Drill</em>",
    "description": "Cordless <em>drill</em> with case"
  }
}
```

Implementation options:

- Use `ts_headline` for snippets:

```sql
ts_headline('english', name, plainto_tsquery($2), 'StartSel=<em>,StopSel=</em>')
```

## Prefix & Fuzzy Matching

- For partial word matching like "dri" → "drill", consider:
  - `plainto_tsquery($q || ':*')` for prefix matches
  - `pg_trgm` similarity for fuzzy matches with a threshold (e.g., 0.3–0.5)
- Trade-off: prefix/tri-gram can increase CPU; enable selectively when `length(q) >= 3`

Example hybrid WHERE clause:

```sql
WHERE user_id = $1 AND (
    search_vector @@ plainto_tsquery($2) OR
    search_vector @@ to_tsquery($3) OR
    (length($4) >= 3 AND similarity(name, $4) > 0.35)
)
```
