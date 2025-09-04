# US-001: User Authentication

**As a** new user  
**I want** to create an account and log in securely  
**So that** I can start tracking my personal items with data privacy

## Acceptance Criteria

- [ ] User can sign up using Google OAuth
- [ ] User can sign up using GitHub OAuth
- [ ] User receives immediate access after OAuth approval (no email verification)
- [ ] User session persists across browser sessions
- [ ] User can log out and session is properly terminated
- [ ] OAuth failures show clear error messages
- [ ] User profile shows basic info (name, email, avatar from OAuth provider)
- [ ] No password storage or management required

## Technical Notes

- Uses Auth.js (NextAuth.js) for OAuth flows
- JWT tokens for API authentication
- Backend validates JWT and extracts user context
- Database stores user profile from OAuth provider

## Status & Metadata

- **Status**: Ready
- **Priority**: High
- **Estimate**: 5 points
- **Dependencies**: None (foundational)
- **API Endpoints**: `/auth/oauth/google`, `/auth/oauth/github`, `/auth/user`
