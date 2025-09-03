# Authentication Implementation Specification

Authoritative implementation details for authentication. Decisions are in [ADR-003](../technical-decisions/adr-003-authentication.md). API contracts are in the [API specification](./api-specification.md). Database schema is in the [database schema spec](./database-schema.md).

## Overview

- Frontend: Auth.js (NextAuth.js) with Google/GitHub OAuth providers
- Backend: Go API validates internal JWTs
- Tokens: Short-lived access tokens (15m), refresh rotation (7d)

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
