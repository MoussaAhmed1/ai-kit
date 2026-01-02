# smi-hono

Claude Code plugin for **Hono** - the ultrafast web framework for the Edge. Provides scaffolding, conventions, testing, and deployment support for Bun and Cloudflare Workers.

## Features

- **4 Specialized Agents** for architecture, building, testing, and code review
- **4 Commands** for scaffolding routes, middleware, projects, and RPC clients
- **4 Auto-activating Skills** for Hono patterns, CF Workers bindings, Zod validation, and RPC
- **Convention Enforcement** via hooks

## Installation

```bash
# Add Smicolon marketplace (if not already added)
/plugin marketplace add https://github.com/smicolon/claude-infra

# Install the plugin
/plugin install smi-hono
```

## Agents

| Agent | Description |
|-------|-------------|
| `@hono-architect` | Design API architecture, project structure, routing organization |
| `@hono-builder` | Implement features, routes, middleware, handlers |
| `@hono-tester` | Write tests using Bun test or Vitest for CF Workers |
| `@hono-reviewer` | Security review, best practices, performance audit |

### Usage

```bash
@hono-architect "Design a REST API for user management with authentication"
@hono-builder "Implement the /users routes with CRUD operations"
@hono-tester "Write tests for the user service"
@hono-reviewer "Review the authentication middleware for security issues"
```

## Commands

| Command | Description |
|---------|-------------|
| `/route-create` | Create new routes with handlers, validators, and types |
| `/middleware-create` | Create custom middleware with proper typing |
| `/project-init` | Initialize a new Hono project (Bun/CF Workers) |
| `/rpc-client` | Generate type-safe RPC client from server routes |

### Usage

```bash
/route-create
/middleware-create
/project-init
/rpc-client
```

## Skills (Auto-activating)

These skills automatically activate based on context:

| Skill | Triggers When |
|-------|---------------|
| `hono-patterns` | Writing Hono routes, handlers, middleware |
| `cloudflare-bindings` | Working with KV, D1, R2, Durable Objects |
| `zod-validation` | Form/JSON validation in Hono handlers |
| `rpc-typesafe` | Setting up type-safe client-server communication |

## Conventions Enforced

### Project Structure

```
src/
├── routes/           # Route handlers organized by resource
│   ├── users.ts
│   └── posts.ts
├── middleware/       # Custom middleware
│   ├── auth.ts
│   └── logger.ts
├── validators/       # Zod schemas
│   └── user.schema.ts
├── types/            # TypeScript types
│   └── bindings.ts
├── lib/              # Shared utilities
└── index.ts          # App entry point
```

### Import Pattern

```typescript
// Named imports (standard Hono style)
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import { cors } from 'hono/cors'
```

### Handler Pattern

```typescript
// Use factory pattern for typed handlers
import { createFactory } from 'hono/factory'

const factory = createFactory<{ Bindings: Env }>()

export const getUser = factory.createHandlers(
  zValidator('param', z.object({ id: z.string().uuid() })),
  async (c) => {
    const { id } = c.req.valid('param')
    // ...
  }
)
```

### Type-Safe Bindings

```typescript
// types/bindings.ts
export type Env = {
  Bindings: {
    DB: D1Database
    KV: KVNamespace
    BUCKET: R2Bucket
    API_KEY: string
  }
  Variables: {
    user: User
  }
}
```

## Supported Platforms

- **Bun** (primary development runtime)
- **Cloudflare Workers** (primary deployment target)
- **Deno**
- **Node.js**

## Requirements

- Bun >= 1.0
- TypeScript >= 5.0
- Wrangler (for Cloudflare Workers deployment)
