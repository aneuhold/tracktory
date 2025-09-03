# ADR-006: Offline Support and Data Synchronization

**Date**: September 3, 2025  
**Status**: Accepted  
**Context**: Need offline capability for asset tracking in environments with poor connectivity.

## Decision

**Strategy**: Offline-first PWA with conflict resolution  
**Storage**: IndexedDB for client-side data persistence  
**Sync**: Queue-based synchronization with conflict detection  
**Resolution**: Last-write-wins with user notification for conflicts

## Architecture

```mermaid
graph TB
    subgraph "Online Operations"
        API[API Request]
        Server[Server Update]
        Success[Success Response]
    end

    subgraph "Offline Operations"
        LocalDB[IndexedDB]
        Queue[Sync Queue]
        Cache[Service Worker Cache]
    end

    subgraph "Synchronization"
        Detect[Connectivity Detection]
        Process[Queue Processing]
        Conflict[Conflict Resolution]
    end

    API --> Server
    Server --> Success

    API -.-> LocalDB
    LocalDB --> Queue
    Queue --> Cache

    Detect --> Process
    Process --> Conflict
    Conflict --> Server
```

## Implementation

### Offline Data Model

```typescript
interface OfflineAction {
  id: string;
  type: "CREATE" | "UPDATE" | "DELETE";
  resource: "item" | "image" | "category";
  data: any;
  timestamp: number;
  synced: boolean;
  retryCount: number;
}

class OfflineManager {
  private db: IDBDatabase;
  private syncQueue: OfflineAction[] = [];

  async addAction(
    action: Omit<OfflineAction, "id" | "timestamp" | "synced" | "retryCount">
  ) {
    const offlineAction: OfflineAction = {
      ...action,
      id: generateId(),
      timestamp: Date.now(),
      synced: false,
      retryCount: 0,
    };

    await this.storeAction(offlineAction);
    this.syncQueue.push(offlineAction);

    if (navigator.onLine) {
      await this.processSyncQueue();
    }
  }

  async processSyncQueue() {
    for (const action of this.syncQueue) {
      try {
        await this.syncAction(action);
        action.synced = true;
      } catch (error) {
        action.retryCount++;
        if (action.retryCount > 3) {
          // Handle failed sync
        }
      }
    }
  }
}
```

### Service Worker Caching

```javascript
const CACHE_NAME = "tracktory-v1";
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
  if (event.request.method === "GET") {
    event.respondWith(
      caches
        .match(event.request)
        .then((response) => response || fetch(event.request))
        .catch(() => caches.match("/offline.html"))
    );
  }
});
```

## Conflict Resolution Strategy

### Conflict Detection

- **Version Timestamps**: Compare client and server timestamps
- **Checksum Comparison**: Detect concurrent modifications
- **User Notification**: Alert users to conflicts requiring resolution

### Resolution Approaches

```typescript
enum ConflictResolution {
  LAST_WRITE_WINS = "last_write_wins",
  USER_CHOICE = "user_choice",
  MERGE_CHANGES = "merge_changes",
}

interface ConflictData {
  clientVersion: any;
  serverVersion: any;
  conflictFields: string[];
  resolution: ConflictResolution;
}
```

## Rationale

### Offline-First Benefits

- **User Experience**: Seamless operation regardless of connectivity
- **Performance**: Immediate feedback for user actions
- **Reliability**: Data preserved during network outages
- **Mobile Optimization**: Reduced data usage and battery drain

### IndexedDB Choice

- **Storage Capacity**: Large storage limits compared to localStorage
- **Structured Data**: Support for complex data types and queries
- **Asynchronous**: Non-blocking database operations
- **Browser Support**: Excellent support across modern browsers

## Implementation Phases

### Phase 1: Basic offline support

- Cache static assets and core pages
- Store new items locally when offline
- Simple sync when connection restored

### Phase 2: Advanced synchronization

- Conflict detection and resolution
- Optimistic updates with rollback
- Background sync for failed operations

### Phase 3: Collaborative features

- Real-time sync for household sharing
- Operational transformation for concurrent edits
- Conflict resolution UI for complex scenarios

## Alternatives Considered

- **Full Online-Only**: Rejected due to mobile usage patterns and unreliable connectivity
- **Native Mobile Apps**: Rejected due to development complexity and web-first strategy
- **Third-Party Sync Services**: Rejected due to cost and vendor lock-in concerns

## Consequences

### Positive

- Excellent user experience in offline scenarios
- Reduced server load through local caching
- Improved mobile performance and battery life
- Foundation for real-time collaborative features

### Negative

- Increased client-side complexity
- Potential data consistency challenges
- Storage management requirements
- Conflict resolution UX complexity

## Implementation Notes

- Implement robust service worker for caching strategy
- Set up IndexedDB with proper schema for offline data
- Create conflict resolution UI for user choices
- Monitor offline usage patterns and sync performance
- Test extensively with various connectivity scenarios
