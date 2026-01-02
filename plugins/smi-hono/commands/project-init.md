---
name: project-init
description: Initialize a new Hono project with Bun or Cloudflare Workers
---

# Initialize Hono Project

Create a new Hono project with proper structure and configuration.

## Workflow

### Step 1: Choose Template

Ask the user which template to use:

1. **Bun + Cloudflare Workers** (Recommended)
   - Development with Bun's hot reload
   - Deployment to Cloudflare Workers
   - D1 database, KV, R2 support

2. **Bun Standalone**
   - Pure Bun runtime
   - Local development and deployment
   - Bun SQLite for database

3. **Cloudflare Workers Only**
   - Wrangler for dev and deploy
   - Full CF ecosystem

### Step 2: Create Project

#### Template: Bun + Cloudflare Workers

```bash
# Create project directory
mkdir {project-name} && cd {project-name}

# Initialize with Bun
bun init -y

# Install dependencies
bun add hono @hono/zod-validator zod
bun add -d @cloudflare/workers-types wrangler typescript
```

**package.json:**
```json
{
  "name": "{project-name}",
  "scripts": {
    "dev": "bun run --hot src/index.ts",
    "dev:cf": "wrangler dev src/index.ts",
    "deploy": "wrangler deploy",
    "test": "bun test",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "hono": "^4.0.0",
    "@hono/zod-validator": "^0.4.0",
    "zod": "^3.23.0"
  },
  "devDependencies": {
    "@cloudflare/workers-types": "^4.0.0",
    "typescript": "^5.0.0",
    "wrangler": "^3.0.0"
  }
}
```

**tsconfig.json:**
```json
{
  "compilerOptions": {
    "target": "ESNext",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "skipLibCheck": true,
    "lib": ["ESNext"],
    "types": ["@cloudflare/workers-types", "bun-types"],
    "jsx": "react-jsx",
    "jsxImportSource": "hono/jsx",
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  },
  "include": ["src/**/*", "tests/**/*"],
  "exclude": ["node_modules"]
}
```

**wrangler.toml:**
```toml
name = "{project-name}"
main = "src/index.ts"
compatibility_date = "2024-01-01"

[vars]
ENVIRONMENT = "production"

# Uncomment to enable D1
# [[d1_databases]]
# binding = "DB"
# database_name = "{project-name}-db"
# database_id = "your-database-id"

# Uncomment to enable KV
# [[kv_namespaces]]
# binding = "KV"
# id = "your-kv-id"

# Uncomment to enable R2
# [[r2_buckets]]
# binding = "BUCKET"
# bucket_name = "{project-name}-bucket"
```

### Step 3: Create Directory Structure

```
{project-name}/
├── src/
│   ├── routes/
│   │   └── index.ts
│   ├── middleware/
│   │   └── index.ts
│   ├── validators/
│   │   └── index.ts
│   ├── types/
│   │   └── bindings.ts
│   ├── lib/
│   │   └── errors.ts
│   └── index.ts
├── tests/
│   └── index.test.ts
├── .dev.vars
├── .gitignore
├── package.json
├── tsconfig.json
└── wrangler.toml
```

### Step 4: Create Core Files

**src/types/bindings.ts:**
```typescript
export type Env = {
  Bindings: {
    // Cloudflare bindings (uncomment as needed)
    // DB: D1Database
    // KV: KVNamespace
    // BUCKET: R2Bucket

    // Environment variables
    ENVIRONMENT: string
    // JWT_SECRET: string
  }
  Variables: {
    // Request-scoped variables
    requestId: string
  }
}
```

**src/index.ts:**
```typescript
import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { logger } from 'hono/logger'
import { secureHeaders } from 'hono/secure-headers'
import type { Env } from './types/bindings'

const app = new Hono<Env>()

// Global middleware
app.use('*', logger())
app.use('*', secureHeaders())
app.use('*', cors({
  origin: ['http://localhost:3000'],
  allowMethods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowHeaders: ['Content-Type', 'Authorization'],
}))

// Request ID middleware
app.use('*', async (c, next) => {
  c.set('requestId', crypto.randomUUID())
  await next()
})

// Health check
app.get('/health', (c) => {
  return c.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    requestId: c.get('requestId')
  })
})

// 404 handler
app.notFound((c) => {
  return c.json({ error: 'Not found' }, 404)
})

// Error handler
app.onError((err, c) => {
  console.error(`Error: ${err.message}`)
  return c.json({ error: 'Internal server error' }, 500)
})

export default app

// Export type for RPC client
export type AppType = typeof app
```

**src/lib/errors.ts:**
```typescript
import { HTTPException } from 'hono/http-exception'

export class NotFoundError extends HTTPException {
  constructor(resource: string) {
    super(404, { message: `${resource} not found` })
  }
}

export class UnauthorizedError extends HTTPException {
  constructor(message = 'Unauthorized') {
    super(401, { message })
  }
}

export class ValidationError extends HTTPException {
  constructor(message: string) {
    super(400, { message })
  }
}
```

**tests/index.test.ts:**
```typescript
import { describe, it, expect } from 'bun:test'
import app from '../src/index'

describe('Health Check', () => {
  it('returns ok status', async () => {
    const res = await app.request('/health')

    expect(res.status).toBe(200)

    const data = await res.json()
    expect(data.status).toBe('ok')
    expect(data.requestId).toBeDefined()
  })
})

describe('404 Handler', () => {
  it('returns 404 for unknown routes', async () => {
    const res = await app.request('/unknown-route')

    expect(res.status).toBe(404)
  })
})
```

**.dev.vars:**
```
# Local development secrets (not committed)
# JWT_SECRET=your-secret-here
```

**.gitignore:**
```
node_modules/
.wrangler/
.dev.vars
*.log
dist/
.DS_Store
```

### Step 5: Verify Setup

```bash
# Run tests
bun test

# Start development server
bun run dev

# Test health endpoint
curl http://localhost:3000/health
```

## Quality Checklist

- [ ] Dependencies installed
- [ ] TypeScript configured with strict mode
- [ ] Wrangler configured for deployment
- [ ] Basic middleware set up
- [ ] Error handling configured
- [ ] Health endpoint working
- [ ] Tests passing
- [ ] Git initialized with .gitignore

Now ask the user what project they want to create!
