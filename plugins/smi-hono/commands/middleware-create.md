---
name: middleware-create
description: Create custom Hono middleware with proper typing
---

# Create Hono Middleware

Create a new custom middleware following Hono best practices.

## Workflow

### Step 1: Gather Requirements

Ask the user:
1. **Middleware name** (e.g., "auth", "rateLimit", "logger")
2. **Purpose** - What should this middleware do?
3. **Configuration options** - Any parameters needed?
4. **Variables to set** - What data to pass to handlers?
5. **When to apply** - Which routes need this?

## Middleware Patterns

### Basic Middleware

```typescript
// middleware/{name}.ts
import { createMiddleware } from 'hono/factory'
import type { Env } from '../types/bindings'

export const {name}Middleware = createMiddleware<Env>(async (c, next) => {
  // Pre-handler logic
  console.log(`[${c.req.method}] ${c.req.url}`)

  await next()

  // Post-handler logic (runs after handler)
  console.log(`Response status: ${c.res.status}`)
})
```

### Middleware with Variables

```typescript
// middleware/auth.ts
import { createMiddleware } from 'hono/factory'
import { HTTPException } from 'hono/http-exception'
import { verify } from 'hono/jwt'
import type { Env } from '../types/bindings'

// First, update types/bindings.ts to include the variable:
// Variables: {
//   user: { id: string; email: string; role: string }
// }

export const authMiddleware = createMiddleware<Env>(async (c, next) => {
  const authHeader = c.req.header('Authorization')

  if (!authHeader?.startsWith('Bearer ')) {
    throw new HTTPException(401, { message: 'Missing authorization token' })
  }

  const token = authHeader.slice(7)

  try {
    const payload = await verify(token, c.env.JWT_SECRET)

    // Set variable for downstream handlers
    c.set('user', {
      id: payload.sub as string,
      email: payload.email as string,
      role: payload.role as string
    })

    await next()
  } catch {
    throw new HTTPException(401, { message: 'Invalid or expired token' })
  }
})
```

### Configurable Middleware Factory

```typescript
// middleware/rateLimit.ts
import { createMiddleware } from 'hono/factory'
import { HTTPException } from 'hono/http-exception'
import type { Env } from '../types/bindings'

interface RateLimitOptions {
  windowMs: number  // Time window in milliseconds
  max: number       // Max requests per window
  keyGenerator?: (c: Context) => string
}

export const rateLimit = (options: RateLimitOptions) => {
  const { windowMs, max, keyGenerator } = options

  return createMiddleware<Env>(async (c, next) => {
    const key = keyGenerator
      ? keyGenerator(c)
      : c.req.header('CF-Connecting-IP') || 'unknown'

    const cacheKey = `ratelimit:${key}`
    const kv = c.env.KV

    const current = parseInt(await kv.get(cacheKey) || '0')

    if (current >= max) {
      throw new HTTPException(429, {
        message: 'Too many requests, please try again later'
      })
    }

    await kv.put(cacheKey, String(current + 1), {
      expirationTtl: Math.ceil(windowMs / 1000)
    })

    // Add rate limit headers
    c.header('X-RateLimit-Limit', String(max))
    c.header('X-RateLimit-Remaining', String(max - current - 1))

    await next()
  })
}

// Usage:
// app.use('/api/*', rateLimit({ windowMs: 60000, max: 100 }))
```

### Request Validation Middleware

```typescript
// middleware/validateRequest.ts
import { createMiddleware } from 'hono/factory'
import type { Env } from '../types/bindings'

export const requestIdMiddleware = createMiddleware<Env>(async (c, next) => {
  const requestId = c.req.header('X-Request-ID') || crypto.randomUUID()

  c.set('requestId', requestId)
  c.header('X-Request-ID', requestId)

  await next()
})
```

### Response Timing Middleware

```typescript
// middleware/timing.ts
import { createMiddleware } from 'hono/factory'
import type { Env } from '../types/bindings'

export const timingMiddleware = createMiddleware<Env>(async (c, next) => {
  const start = Date.now()

  await next()

  const duration = Date.now() - start
  c.header('X-Response-Time', `${duration}ms`)
})
```

### Error Handling Middleware

```typescript
// middleware/errorHandler.ts
import { createMiddleware } from 'hono/factory'
import { HTTPException } from 'hono/http-exception'
import type { Env } from '../types/bindings'

export const errorHandler = createMiddleware<Env>(async (c, next) => {
  try {
    await next()
  } catch (error) {
    if (error instanceof HTTPException) {
      return c.json(
        { error: error.message, status: error.status },
        error.status
      )
    }

    console.error('Unhandled error:', error)
    return c.json(
      { error: 'Internal server error', status: 500 },
      500
    )
  }
})
```

## Generated Files

1. `middleware/{name}.ts` - Middleware implementation
2. Updated `types/bindings.ts` - Add Variables if needed
3. Updated `middleware/index.ts` - Barrel export

## Usage Examples

```typescript
// Apply to all routes
app.use('*', timingMiddleware)

// Apply to specific path
app.use('/api/*', authMiddleware)

// Apply to specific routes
app.use('/api/admin/*', roleMiddleware('admin'))

// Chain multiple middleware
app.use('/api/*', timingMiddleware, requestIdMiddleware, authMiddleware)
```

## Quality Checklist

- [ ] Uses `createMiddleware` for type safety
- [ ] Properly typed with `Env`
- [ ] Calls `await next()` appropriately
- [ ] Handles errors with HTTPException
- [ ] Variables added to bindings type
- [ ] Exported from barrel file

Now ask the user what middleware they want to create!
