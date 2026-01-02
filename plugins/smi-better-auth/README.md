# smi-better-auth

Better Auth integration with MCP server for comprehensive authentication.

## Overview

This plugin provides comprehensive authentication support using Better Auth, a framework-agnostic TypeScript authentication library. Includes MCP server integration for AI-assisted auth implementation.

## Installation

```bash
/plugin install smi-better-auth
```

## Features

### Core Authentication
- Email/password authentication
- Session management
- Password reset flows

### Social Providers
- Google, GitHub, Discord, etc.
- OAuth 2.0 / OpenID Connect

### Advanced Security
- Two-factor authentication (2FA)
- Passkeys / WebAuthn
- Rate limiting

### Enterprise
- Multi-tenancy
- Single Sign-On (SSO)
- Organization management

## MCP Server

This plugin configures the official Better Auth MCP server for AI-assisted development.

### Required Environment Variables
```bash
# Add to your environment
BETTER_AUTH_SECRET=your-secret-key
DATABASE_URL=your-database-url
```

### MCP Tools Available
- Auth configuration generation
- Provider setup assistance
- Security best practices

## Agents

| Agent | Purpose |
|-------|---------|
| `auth-architect` | Design authentication architecture and flows |

## Commands

| Command | Description |
|---------|-------------|
| `/auth-setup` | Initialize Better Auth with config and optional pages |
| `/auth-provider-add` | Add a new authentication provider |

## Usage

### Basic Setup
```bash
/auth-setup
```

Options:
- `--with-pages` - Include login/register/forgot-password pages
- `--providers google,github` - Pre-configure social providers
- `--2fa` - Enable two-factor authentication
- `--passkeys` - Enable passkey support

### Add Provider
```bash
/auth-provider-add google
/auth-provider-add github --scopes "user:email,read:org"
```

## Configuration Example

```typescript
// auth.ts
import { betterAuth } from 'better-auth'

export const auth = betterAuth({
  database: {
    provider: 'postgresql',
    url: process.env.DATABASE_URL,
  },
  emailAndPassword: {
    enabled: true,
  },
  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    },
  },
  plugins: [
    twoFactor(),
    passkey(),
  ],
})
```

## Integration with TanStack

Works seamlessly with `smi-tanstack-router`:

```typescript
// routes/__root.tsx
import { auth } from '@/lib/auth'

export const Route = createRootRoute({
  beforeLoad: async () => {
    const session = await auth.getSession()
    return { session }
  },
})
```
