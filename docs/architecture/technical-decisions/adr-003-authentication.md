See the [technical decision index for all ADRs](../technical-decisions.md)

# ADR-003: Authentication and Session Management

**Date**: September 3, 2025  
**Status**: Accepted  
**Context**: Need secure, mobile-friendly authentication with offline capability support for Next.js frontend and Go backend.

## Decision

**Frontend**: Auth.js (NextAuth.js) for OAuth session management  
**Backend**: Custom Go JWT validation with shared secret  
**Token Strategy**: JWT access tokens from OAuth providers with refresh token rotation  
**Storage**: Auth.js handles secure storage, Go validates tokens  
**OAuth Providers**: Google and GitHub for authentication (no password storage)

## Architecture

```mermaid
sequenceDiagram
    participant User
    participant NextJS as Next.js + Auth.js
    participant OAuth as OAuth Provider
    participant GoAPI as Go API
    participant Database

    User->>NextJS: Login Request
    NextJS->>OAuth: Redirect to OAuth Provider
    OAuth->>User: Login Form
    User->>OAuth: Credentials
    OAuth->>NextJS: Authorization Code
    NextJS->>OAuth: Exchange for Tokens
    OAuth->>NextJS: Access Token + User Info
    NextJS->>GoAPI: POST /auth/oauth-callback
    GoAPI->>Database: Create/Update User
    GoAPI->>NextJS: Internal JWT
    NextJS->>NextJS: Store in Auth.js Session
    NextJS->>User: Authenticated State

    Note over User,GoAPI: API Requests
    NextJS->>GoAPI: Request + JWT Header
    GoAPI->>GoAPI: Validate JWT
    GoAPI->>NextJS: Protected Resource

    Note over User,GoAPI: Token Refresh
    NextJS->>GoAPI: Refresh Request
    GoAPI->>NextJS: New JWT
    NextJS->>NextJS: Update Session
```

## Implementation Strategy

See the [API specification](../implementation-specs/api-specification.md) for the exact auth-related endpoints, JWT structure expectations, and error formats. ADR-003 defines the decision and architecture; the spec defines the contracts.

### Frontend (Next.js + Auth.js)

```typescript
// app/api/auth/[...nextauth]/route.ts
import NextAuth from "next-auth";
import GoogleProvider from "next-auth/providers/google";
import GitHubProvider from "next-auth/providers/github";

const handler = NextAuth({
  providers: [
    GoogleProvider({
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    }),
    GitHubProvider({
      clientId: process.env.GITHUB_ID!,
      clientSecret: process.env.GITHUB_SECRET!,
    }),
  ],
  callbacks: {
    async signIn({ user, account, profile }) {
      // Send user info to our Go API for user creation/update
      const response = await fetch(
        `${process.env.API_URL}/auth/oauth-callback`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            provider: account?.provider,
            providerId: account?.providerAccountId,
            email: user.email,
            name: user.name,
            image: user.image,
          }),
        }
      );

      if (response.ok) {
        const data = await response.json();
        // Store our internal JWT for API calls
        user.accessToken = data.access_token;
        user.id = data.user.id;
        return true;
      }
      return false;
    },
    async jwt({ token, user, account }) {
      if (user) {
        token.accessToken = user.accessToken;
        token.userId = user.id;
      }
      return token;
    },
    async session({ session, token }) {
      session.accessToken = token.accessToken;
      session.userId = token.userId;
      return session;
    },
  },
  session: { strategy: "jwt" },
  pages: {
    signIn: "/auth/signin",
    error: "/auth/error",
  },
});

export { handler as GET, handler as POST };
```

### Backend (Go) - OAuth Callback Handler

```go
type AuthService struct {
    db  *sql.DB
    jwt *JWTManager
}

type OAuthCallbackRequest struct {
    Provider   string `json:"provider" validate:"required"`
    ProviderID string `json:"providerId" validate:"required"`
    Email      string `json:"email" validate:"required,email"`
    Name       string `json:"name" validate:"required"`
    Image      string `json:"image"`
}

type AuthResponse struct {
    User        User   `json:"user"`
    AccessToken string `json:"access_token"`
    ExpiresIn   int    `json:"expires_in"`
}

func (s *AuthService) OAuthCallback(c *gin.Context) {
    var req OAuthCallbackRequest
    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(400, gin.H{"error": "Invalid request"})
        return
    }

    // Find or create user based on OAuth provider info
    user, err := s.findOrCreateUserFromOAuth(req)
    if err != nil {
        c.JSON(500, gin.H{"error": "User creation failed"})
        return
    }

    // Generate internal JWT for API access
    accessToken, err := s.jwt.GenerateAccessToken(user.ID)
    if err != nil {
        c.JSON(500, gin.H{"error": "Token generation failed"})
        return
    }

    c.JSON(200, AuthResponse{
        User:        *user,
        AccessToken: accessToken,
        ExpiresIn:   3600, // 1 hour
    })
}

func (s *AuthService) findOrCreateUserFromOAuth(req OAuthCallbackRequest) (*User, error) {
    // Try to find existing user by OAuth provider info
    user, err := s.findUserByOAuthProvider(req.Provider, req.ProviderID)
    if err == nil {
        // Update user info in case it changed
        user.Email = req.Email
        user.Name = req.Name
        user.Image = req.Image
        return s.updateUser(user)
    }

    // User doesn't exist, create new one
    newUser := &User{
        ID:           generateUUID(),
        Email:        req.Email,
        Name:         req.Name,
        Image:        req.Image,
        OAuthProvider: req.Provider,
        OAuthProviderID: req.ProviderID,
        CreatedAt:    time.Now(),
        UpdatedAt:    time.Now(),
    }

    return s.createUser(newUser)
}
```

### User Database Schema

```go
type User struct {
    ID              string    `json:"id" db:"id"`
    Email           string    `json:"email" db:"email"`
    Name            string    `json:"name" db:"name"`
    Image           string    `json:"image" db:"image"`
    OAuthProvider   string    `json:"oauth_provider" db:"oauth_provider"`
    OAuthProviderID string    `json:"oauth_provider_id" db:"oauth_provider_id"`
    CreatedAt       time.Time `json:"created_at" db:"created_at"`
    UpdatedAt       time.Time `json:"updated_at" db:"updated_at"`
}

// Database migration for OAuth-only users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    image TEXT,
    oauth_provider VARCHAR(50) NOT NULL,
    oauth_provider_id VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(oauth_provider, oauth_provider_id),
    UNIQUE(email)
);

CREATE INDEX idx_users_oauth ON users(oauth_provider, oauth_provider_id);
CREATE INDEX idx_users_email ON users(email);
```

### JWT Validation Middleware

```go
func (s *AuthService) JWTMiddleware() gin.HandlerFunc {
    return func(c *gin.Context) {
        token := extractTokenFromHeader(c.GetHeader("Authorization"))
        if token == "" {
            c.JSON(401, gin.H{"error": "Missing authorization token"})
            c.Abort()
            return
        }

        claims, err := s.jwt.ValidateToken(token)
        if err != nil {
            c.JSON(401, gin.H{"error": "Invalid token"})
            c.Abort()
            return
        }

        // Set user context for downstream handlers
        c.Set("user_id", claims.UserID)
        c.Next()
    }
}
```

## Rationale

### OAuth-Only Benefits

- **No Password Storage**: Eliminates password-related security risks entirely
- **Reduced Attack Surface**: No password reset flows, hash management, or credential validation
- **Better User Experience**: Users can use existing accounts they trust
- **Simplified Implementation**: No need for password validation, hashing, or reset flows
- **Enterprise Ready**: Many organizations prefer OAuth for SSO integration

### Auth.js Benefits

- **Production Ready**: Battle-tested authentication library
- **Developer Experience**: Excellent TypeScript support and documentation
- **Security**: Built-in CSRF protection, secure session handling
- **Next.js Integration**: First-class App Router support

### Hybrid Approach Benefits

- **Frontend Simplicity**: Auth.js handles complex auth flows
- **Backend Control**: Go API maintains full control over business logic
- **Scalability**: JWT tokens work across multiple backend instances
- **Security**: Shared secret validation with token expiration

### Custom JWT Claims

```go
type TracktoryJWTClaims struct {
    UserID string `json:"user_id"`
    Email  string `json:"email"`
    jwt.RegisteredClaims
}
```

## Implementation Simplifications

### What We Don't Need to Build

- **Password Hashing**: No bcrypt, Argon2, or other password hashing logic
- **Password Reset Flow**: No forgot password emails or reset tokens
- **Password Validation**: No complexity requirements or validation rules
- **Account Registration**: No email verification or account creation forms
- **Credential Storage**: No secure password storage in database
- **Rate Limiting**: OAuth providers handle brute force protection
- **Session Management**: Simplified token-only approach

## Alternative Authentication Solutions Considered

### Self-Hosted Solutions

- **Ory Kratos**: Rejected due to operational complexity for MVP
- **Keycloak**: Rejected due to heavyweight setup and Java dependency
- **Custom Password Auth**: Rejected due to security complexity and OAuth simplicity

### SaaS Solutions

- **Clerk**: Rejected due to vendor lock-in and cost concerns
- **Auth0**: Rejected due to complexity and pricing for our scale
- **Firebase Auth**: Rejected due to Google ecosystem dependency
- **Supabase Auth**: Considered but rejected due to vendor lock-in concerns and desire for infrastructure control

### Authentication Methods

- **Email/Password**: Rejected in favor of OAuth-only for security and simplicity
- **Magic Links**: Considered but OAuth provides better UX
- **Session-Only Auth**: Rejected due to mobile compatibility issues

## Consequences

### Positive

- **Reduced Development Time**: Auth.js handles complex authentication flows
- **Better Security**: Leverages battle-tested authentication patterns
- **Enhanced UX**: Seamless authentication with proper session management
- **Future-Proof**: Easy to add OAuth providers and advanced features
- **Mobile Compatible**: JWT tokens work well with PWA and future mobile apps
- **Scalable**: Stateless token validation across multiple API instances
- **Infrastructure Control**: Full control over database and backend logic
- **Cost Predictable**: No vendor lock-in or usage-based pricing concerns

### Negative

- **Additional Dependency**: Reliance on Auth.js for frontend authentication
- **Learning Curve**: Team needs to understand Auth.js patterns and configuration
- **Token Management**: Need to handle token refresh and storage properly
- **Complexity**: More moving parts than simple session-based authentication
- **Initial Setup Time**: Requires more upfront development compared to BaaS solutions

## Implementation Notes

### Required Environment Variables

```bash
# Next.js (Auth.js)
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-secret-here
API_URL=http://localhost:8080

# Go Backend
JWT_SECRET=shared-secret-with-nextjs
REDIS_URL=redis://localhost:6379
DATABASE_URL=postgresql://user:pass@localhost:5432/tracktory
```

### Security Considerations

- **Shared Secret Management**: Use strong, randomly generated secrets
- **Token Expiration**: Keep access tokens short-lived (15 minutes)
- **Refresh Token Rotation**: Issue new refresh tokens on each use
- **Rate Limiting**: Implement login attempt throttling
- **HTTPS Only**: Always use HTTPS in production for token security

### Testing Strategy

- **Unit Tests**: Test JWT generation and validation logic
- **Integration Tests**: Test full authentication flows
- **Security Tests**: Test token expiration and revocation
- **E2E Tests**: Test user authentication journeys

## Decision Summary

After evaluating multiple authentication solutions including Supabase, the decision was made to proceed with **Auth.js + Go + PostgreSQL** to maintain:

- **Infrastructure Control**: Full control over database and backend logic
- **Cost Predictability**: No vendor lock-in or usage-based pricing concerns
- **Scalability**: Flexibility to optimize for our specific use cases
- **Team Learning**: Building expertise in foundational technologies

This approach provides the right balance of development efficiency through Auth.js while maintaining the flexibility and control needed for a growing asset tracking platform.
