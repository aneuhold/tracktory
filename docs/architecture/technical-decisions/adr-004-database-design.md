# ADR-004: Database Schema Design for Multi-Tenancy

**Date**: September 3, 2025  
**Status**: Accepted  
**Context**: Design database schema that supports individual users initially but can evolve to household sharing.

## Decision

**Strategy**: Single database with row-level security and foreign key relationships  
**User Model**: Individual users with optional household relationships  
**Data Isolation**: User ID and Household ID based access control  
**Future-Proofing**: Schema designed for multi-tenant evolution

## Schema Design

```sql
-- Core user table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    preferences JSONB DEFAULT '{}'::jsonb
);

-- Household support (Phase 3)
CREATE TABLE households (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    owner_id UUID NOT NULL REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    settings JSONB DEFAULT '{}'::jsonb
);

-- User-household relationships
CREATE TABLE household_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    household_id UUID NOT NULL REFERENCES households(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL DEFAULT 'member', -- owner, admin, member, viewer
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(household_id, user_id)
);

-- Main items table with multi-tenancy support
CREATE TABLE items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    household_id UUID REFERENCES households(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category_id UUID REFERENCES categories(id),
    location_id UUID REFERENCES locations(id),
    purchase_price DECIMAL(10,2),
    purchase_date DATE,
    status VARCHAR(20) DEFAULT 'active', -- active, sold, lost, donated
    condition VARCHAR(20) DEFAULT 'excellent', -- excellent, good, fair, poor
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    search_vector tsvector
);
```

## Row Level Security

```sql
-- Enable RLS on items table
ALTER TABLE items ENABLE ROW LEVEL SECURITY;

-- Policy for individual user access
CREATE POLICY items_user_policy ON items
    FOR ALL TO authenticated_users
    USING (user_id = current_user_id());

-- Policy for household member access (Phase 3)
CREATE POLICY items_household_policy ON items
    FOR ALL TO authenticated_users
    USING (
        household_id IN (
            SELECT household_id
            FROM household_members
            WHERE user_id = current_user_id()
        )
    );
```

## Rationale

### Single Database Benefits

- **Simplicity**: Easier to manage than multiple databases
- **Consistency**: ACID transactions across user data
- **Performance**: Efficient joins and queries
- **Cost**: Lower operational overhead

### Row Level Security

- **Data Isolation**: Automatic enforcement of access controls
- **Security**: Database-level protection against data leaks
- **Flexibility**: Policy-based access control
- **Audit**: Built-in access logging

### Evolution Strategy

- **Phase 1**: Individual users only (household_id NULL)
- **Phase 2**: Optional location sharing
- **Phase 3**: Full household collaboration

## Alternatives Considered

- **Database-per-User**: Rejected due to operational complexity and cost
- **Shared Schema**: Rejected due to data isolation concerns
- **Application-Level Filtering**: Rejected due to security risks

## Consequences

### Positive

- Clean evolution path from individual to household usage
- Strong data isolation with database-level enforcement
- Efficient queries with proper indexing
- Simplified backup and maintenance

### Negative

- PostgreSQL RLS learning curve
- Potential performance impact with complex policies
- Migration complexity for existing users

## Implementation Notes

- Implement proper indexing strategy for RLS policies
- Set up database migrations for schema evolution
- Test RLS policies thoroughly with different user scenarios
- Monitor query performance with RLS enabled
- Plan migration strategy for converting individual users to households
