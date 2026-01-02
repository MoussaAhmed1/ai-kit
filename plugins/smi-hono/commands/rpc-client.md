---
name: rpc-client
description: Generate type-safe RPC client from Hono server routes
---

# Generate Hono RPC Client

Create a type-safe client for your Hono API using the `hc` client.

## Workflow

### Step 1: Verify Server Setup

Check that the server exports the app type:

```typescript
// src/index.ts
import { Hono } from 'hono'

const app = new Hono()

// ... routes ...

export default app

// REQUIRED: Export type for RPC client
export type AppType = typeof app
```

### Step 2: Create Client Package

For monorepo or separate client package:

```bash
# If using monorepo with workspaces
mkdir -p packages/api-client
cd packages/api-client
bun init -y
bun add hono
```

**packages/api-client/package.json:**
```json
{
  "name": "@{project}/api-client",
  "version": "1.0.0",
  "main": "src/index.ts",
  "types": "src/index.ts",
  "exports": {
    ".": "./src/index.ts"
  },
  "dependencies": {
    "hono": "^4.0.0"
  }
}
```

### Step 3: Create Client

**packages/api-client/src/index.ts:**
```typescript
import { hc } from 'hono/client'
import type { AppType } from '@{project}/api/src/index'

// Create typed client
export const createApiClient = (baseUrl: string) => {
  return hc<AppType>(baseUrl)
}

// Default client for common use
export const api = createApiClient(
  process.env.API_URL || 'http://localhost:8787'
)

// Re-export types for consumers
export type { AppType }

// Export inferred types for convenience
export type ApiClient = ReturnType<typeof createApiClient>
```

### Step 4: Usage Examples

**Basic Usage:**
```typescript
import { api } from '@{project}/api-client'

// GET request
const users = await api.api.users.$get()
const data = await users.json()

// POST request with body
const newUser = await api.api.users.$post({
  json: {
    email: 'user@example.com',
    name: 'New User'
  }
})

// GET with query params
const searchResults = await api.api.users.$get({
  query: {
    page: 1,
    limit: 10,
    search: 'john'
  }
})

// GET with path params
const user = await api.api.users[':id'].$get({
  param: { id: 'user-uuid' }
})

// PUT with params and body
const updated = await api.api.users[':id'].$put({
  param: { id: 'user-uuid' },
  json: { name: 'Updated Name' }
})

// DELETE
await api.api.users[':id'].$delete({
  param: { id: 'user-uuid' }
})
```

**With Error Handling:**
```typescript
import { api } from '@{project}/api-client'

async function getUser(id: string) {
  const res = await api.api.users[':id'].$get({
    param: { id }
  })

  if (!res.ok) {
    if (res.status === 404) {
      throw new Error('User not found')
    }
    throw new Error(`API error: ${res.status}`)
  }

  return res.json()
}
```

**With Headers:**
```typescript
import { hc } from 'hono/client'
import type { AppType } from '@{project}/api/src/index'

const api = hc<AppType>('http://localhost:8787', {
  headers: {
    Authorization: `Bearer ${token}`
  }
})

// Or per-request headers
const res = await api.api.users.$get({
  headers: {
    'X-Custom-Header': 'value'
  }
})
```

**React Query Integration:**
```typescript
import { useQuery, useMutation } from '@tanstack/react-query'
import { api } from '@{project}/api-client'

// Query hook
export function useUsers(page = 1) {
  return useQuery({
    queryKey: ['users', page],
    queryFn: async () => {
      const res = await api.api.users.$get({
        query: { page, limit: 20 }
      })
      if (!res.ok) throw new Error('Failed to fetch users')
      return res.json()
    }
  })
}

// Mutation hook
export function useCreateUser() {
  return useMutation({
    mutationFn: async (data: { email: string; name: string }) => {
      const res = await api.api.users.$post({ json: data })
      if (!res.ok) throw new Error('Failed to create user')
      return res.json()
    }
  })
}
```

### Step 5: TypeScript Configuration

Ensure both server and client have matching TypeScript settings:

**tsconfig.json (both projects):**
```json
{
  "compilerOptions": {
    "strict": true,
    "moduleResolution": "bundler"
  }
}
```

## Type Inference

The client automatically infers:
- Request body types from Zod validators
- Response types from handler return values
- Query parameter types
- Path parameter types

```typescript
// Server: defines the contract
app.post('/users',
  zValidator('json', z.object({
    email: z.string().email(),
    name: z.string()
  })),
  async (c) => {
    const data = c.req.valid('json')
    return c.json({ id: '123', ...data }, 201)
  }
)

// Client: types are inferred!
const res = await api.api.users.$post({
  json: {
    email: 'user@example.com',  // typed as string
    name: 'User'                 // typed as string
  }
})
const user = await res.json()
// user is typed as { id: string; email: string; name: string }
```

## URL Generation

```typescript
import { api } from '@{project}/api-client'

// Generate URL without making request
const url = api.api.users[':id'].$url({
  param: { id: 'user-123' }
})
// url = 'http://localhost:8787/api/users/user-123'
```

## Quality Checklist

- [ ] Server exports `AppType`
- [ ] `strict: true` in both tsconfigs
- [ ] Client properly typed
- [ ] Error handling implemented
- [ ] Headers configured (auth, etc.)
- [ ] Works with React Query (if using)

Now set up the RPC client for your project!
