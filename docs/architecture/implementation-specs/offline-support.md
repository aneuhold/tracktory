# Offline Support Implementation Specification

This document is the single source of truth for Tracktory's offline-first implementation. Architectural decisions are captured in [ADR-006](../technical-decisions/adr-006-offline-support.md). High-level references are in [system-design.md](../system-design.md).

## Scope

- Client-side data persistence model (IndexedDB)
- Sync queue processing and retry strategy
- Service Worker caching strategies
- Conflict detection and resolution mechanics
- Background sync and idempotency guidance

## Offline Data Model

TypeScript types for queued actions and sync state.

```typescript
export interface OfflineAction {
  id: string;
  type: "CREATE" | "UPDATE" | "DELETE";
  resource: "item" | "image" | "category" | "location";
  data: any;
  timestamp: number;
  synced: boolean;
  retryCount: number;
  idempotencyKey?: string;
}

export interface SyncState {
  lastSyncAt?: number;
  isSyncing: boolean;
  pendingCount: number;
}
```

Minimal manager (example skeleton):

```typescript
export class OfflineManager {
  private db!: IDBDatabase;
  private queue: OfflineAction[] = [];

  async init() {
    this.db = await openDB();
    this.queue = await this.loadQueue();
  }

  async add(
    action: Omit<OfflineAction, "id" | "timestamp" | "synced" | "retryCount">
  ) {
    const entry: OfflineAction = {
      ...action,
      id: crypto.randomUUID(),
      timestamp: Date.now(),
      synced: false,
      retryCount: 0,
      idempotencyKey: crypto.randomUUID(),
    };
    await this.store(entry);
    this.queue.push(entry);
    if (navigator.onLine) await this.process();
  }

  async process() {
    for (const action of this.queue) {
      if (action.synced) continue;
      try {
        await this.syncAction(action);
        action.synced = true;
        await this.update(action);
      } catch (e) {
        action.retryCount++;
        await this.update(action);
        if (action.retryCount > 3) {
          // TODO: surface to UI
        }
      }
    }
  }

  private async syncAction(action: OfflineAction) {
    // send with Idempotency-Key header; map resource to API endpoints
  }

  // ... openDB(), loadQueue(), store(), update() helpers
}
```

## IndexedDB Schema

- Database name: `tracktory`
- Version: 1
- Object stores:
  - `offlineQueue` (key: `id`, index: `synced`)
  - `itemsCache` (key: `id`, index: `updatedAt`)
  - `categoriesCache` (key: `id`)
  - `locationsCache` (key: `id`)
  - `meta` (key: `key`) for small state such as `lastSyncAt`

## Service Worker Caching

- Cache name pattern: `tracktory-static-v{N}`
- Precache routes (example): `/`, `/dashboard`, `/add-item`, `/search`, `/offline.html`
- Strategies:
  - HTML: network-first with fallback to cache and `/offline.html`
  - Static assets: cache-first with versioned filenames
  - API (GET): stale-while-revalidate for list/read endpoints; bypass for mutating
  - Images: cache-first with URL-based versioning

Example (simplified):

```javascript
const CACHE_NAME = "tracktory-static-v1";
const OFFLINE_URLS = [
  "/",
  "/dashboard",
  "/add-item",
  "/search",
  "/offline.html",
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(OFFLINE_URLS))
  );
});

self.addEventListener("fetch", (event) => {
  const { request } = event;
  if (request.method !== "GET") return;

  const url = new URL(request.url);
  if (url.pathname.startsWith("/api/") && request.method === "GET") {
    event.respondWith(staleWhileRevalidate(request));
    return;
  }

  event.respondWith(
    caches
      .match(request)
      .then((cached) => cached || fetch(request))
      .catch(() => caches.match("/offline.html"))
  );
});
```

## Sync Algorithm

1. Detect connectivity changes (`online`/`offline` events)
2. When online, process `offlineQueue` in FIFO order
3. Send requests with `Idempotency-Key` header (UUID v4). Persist the key alongside action in IndexedDB
4. Handle 409 CONFLICT by triggering conflict resolution
5. On transient errors, retry with exponential backoff (e.g., 1s, 2s, 4s, 8s), jitter ±20%, max 5 attempts, then surface to UI
6. Mark entries as `synced` on success and persist state

## Conflict Detection & Resolution

Detection:

- Compare record `updatedAt` timestamps (client vs server)
- Optionally compute checksums of relevant fields

Resolution options:

- Last-write-wins (default)
- User choice (present diff to user)
- Field-level merge (where applicable)

Types:

```typescript
enum ConflictResolution {
  LAST_WRITE_WINS = "last_write_wins",
  USER_CHOICE = "user_choice",
  MERGE_CHANGES = "merge_changes",
}

interface ConflictData<T = any> {
  clientVersion: T;
  serverVersion: T;
  conflictFields: string[];
  resolution: ConflictResolution;
}
```

## Background Sync (Optional)

- Use Background Sync / Periodic Background Sync (where supported) to resume `offlineQueue` processing
- iOS PWA limitation: Background Sync is unreliable. Provide a visible "Sync now" action and run sync on app foreground/resume events
- Fallback: schedule retries via `setTimeout` while app is open

## Security Considerations

- Never cache sensitive API responses in SW unless encrypted or public
- Validate JWT expiry before sending queued requests; refresh tokens proactively. If refresh fails, pause queue and prompt re-auth
- Respect per-user/household isolation; include user scoping in cache keys

## Testing Matrix

- Airplane mode toggle during create/update flows
- Large image uploads queued offline
- Token expiry mid-queue; ensure refresh + resume
- Conflict scenarios with concurrent edits
- Cache busting on deployment (bump `CACHE_NAME`)

## Changelog

- 2025-09-03: Initial specification
