# Authentication Implementation Specification

Authoritative implementation details for authentication. Decisions are in [ADR-003](../technical-decisions/adr-003-authentication.md). API contracts are in the [API specification](./api-specification.md). Database schema is in the [database schema spec](./database-schema.md).

## Overview

- Frontend: Auth.js (NextAuth.js) with Google/GitHub OAuth providers
- Backend: Go API validates internal JWTs
- Tokens: Short-lived access tokens (15m), refresh rotation (7d)

## JWT Contract (MVP)

- Algorithm: HS256 (symmetric). Shared secret between Auth.js and Go API
- Issuer (iss): `tracktory-auth`
- Audience (aud): `tracktory-api`
- Clock skew tolerance: ±60s
- Access token lifetime: 15 minutes; refresh handled by Auth.js session rotation (7 days)

Claims (example):

```json
{
  "iss": "tracktory-auth",
  "aud": "tracktory-api",
  "sub": "<user-uuid>",
  "user_id": "<user-uuid>",
  "email": "user@example.com",
  "iat": 1693843200,
  "exp": 1693844100
}
```

Notes:

- `sub` and `user_id` are both set to the UUID for convenience
- No roles/scopes in MVP; authorization is resource ownership + RLS
- Future: move to RS256/ES256 with JWKS (no shared secret). Document JWKS URL and key rotation in ADR when adopted

## Next.js (Auth.js) Setup

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
  // MVP: issue HS256 tokens using NEXTAUTH_SECRET as signing key
  // Keep tokens short-lived; rotate NEXTAUTH_SECRET on a schedule
  callbacks: {
    async signIn({ user, account }) {
      const res = await fetch(`${process.env.API_URL}/auth/oauth-callback`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          provider: account?.provider,
          providerId: account?.providerAccountId,
          email: user.email,
          name: user.name,
          image: user.image,
        }),
      });
      if (!res.ok) return false;
      const data = await res.json();
      (user as any).accessToken = data.access_token;
      (user as any).id = data.user.id;
      return true;
    },
    async jwt({ token, user }) {
      if (user) {
        token.accessToken = (user as any).accessToken;
        token.userId = (user as any).id;
      }
      return token;
    },
    async session({ session, token }) {
      (session as any).accessToken = token.accessToken;
      (session as any).userId = token.userId;
      return session;
    },
  },
  session: { strategy: "jwt" },
  pages: { signIn: "/auth/signin", error: "/auth/error" },
});

export { handler as GET, handler as POST };
```

## Go Backend

### OAuth Callback Handler

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

    user, err := s.findOrCreateUserFromOAuth(req)
    if err != nil {
        c.JSON(500, gin.H{"error": "User creation failed"})
        return
    }

    accessToken, err := s.jwt.GenerateAccessToken(user.ID)
    if err != nil {
        c.JSON(500, gin.H{"error": "Token generation failed"})
        return
    }

    c.JSON(200, AuthResponse{User: *user, AccessToken: accessToken, ExpiresIn: 3600})
}
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

        c.Set("user_id", claims.UserID)
        c.Next()
    }
}
```

### Custom JWT Claims

```go
type TracktoryJWTClaims struct {
    UserID string `json:"user_id"`
    Email  string `json:"email"`
    jwt.RegisteredClaims
}
```

### Token Verification (Go) — HS256

```go
type JWTManager struct {
  secret []byte
}

func NewJWTManager(secret string) *JWTManager { return &JWTManager{secret: []byte(secret)} }

func (j *JWTManager) ValidateToken(raw string) (*TracktoryJWTClaims, error) {
  token, err := jwt.ParseWithClaims(raw, &TracktoryJWTClaims{}, func(token *jwt.Token) (interface{}, error) {
    if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
      return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])}
    return j.secret, nil
  })
  if err != nil || !token.Valid { return nil, fmt.Errorf("invalid token: %w", err) }

  claims := token.Claims.(*TracktoryJWTClaims)
  if claims.Issuer != "tracktory-auth" || !claims.VerifyAudience("tracktory-api", true) {
    return nil, fmt.Errorf("invalid iss/aud")
  }
  return claims, nil
}
```

## Environment Variables

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

## Notes

- Database user table DDL is in the [database schema spec](./database-schema.md) (OAuth-only).
- Endpoint contracts live in the [API specification](./api-specification.md).

## CORS Policy (API)

- Allowed origins: `https://tracktory.tonyneuhold.com`, `http://localhost:3000`
- Allowed methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
- Allowed headers: Authorization, Content-Type, Idempotency-Key
- Credentials: not required (use Bearer tokens)
