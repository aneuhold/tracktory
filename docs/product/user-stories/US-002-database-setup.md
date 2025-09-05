# US-002: Database Setup & Migrations

**As a** developer  
**I want** a PostgreSQL database with proper schema and migration system  
**So that** I can store and retrieve application data reliably

## Acceptance Criteria

- [ ] PostgreSQL database running locally via Docker
- [ ] Database migration system implemented (using golang-migrate or similar)
- [ ] All tables from database schema spec created via migrations
- [ ] Row Level Security (RLS) policies implemented
- [ ] Database indexes created for performance
- [ ] Seed data for default categories inserted
- [ ] Database connection pooling configured
- [ ] Migration rollback capability working

## Database Components

### Tables to Create

- [ ] `users` table with OAuth fields
- [ ] `categories` table with default data
- [ ] `items` table with search vector
- [ ] `images` table for item photos
- [ ] `locations` table (basic structure)
- [ ] `households` and `household_members` (for future)

### Indexes & Performance

- [ ] Search vector GIN index on items
- [ ] User/household filtering indexes
- [ ] Foreign key indexes for joins

### Security

- [ ] Row Level Security enabled on sensitive tables
- [ ] Policies for user data isolation
- [ ] Database user with minimal required permissions

## Technical Implementation

- **Database Schema**: Authoritative DDL in [database schema spec](../../architecture/implementation-specs/database-schema.md)
- **Architecture Decision**: Based on [ADR-004: Database Design](../../architecture/technical-decisions/adr-004-database-design.md)
- **Technology Stack**: PostgreSQL per [ADR-001](../../architecture/technical-decisions/adr-001-technology-stack.md)
- **Search Setup**: Indexes per [search implementation spec](../../architecture/implementation-specs/search.md)

## Status & Metadata

- **Status**: Ready
- **Priority**: High (foundational)
- **Estimate**: 5 points
- **Dependencies**: US-001 (project structure)
- **Deliverable**: Fully migrated database ready for application use
