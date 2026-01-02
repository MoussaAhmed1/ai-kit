---
name: route-create
description: Create a new Hono route with handlers, validators, and types
---

# Create Hono Route

Create a new Hono route following project conventions.

## Workflow

### Step 1: Gather Requirements

Ask the user:
1. **Resource name** (e.g., "users", "posts", "orders")
2. **Operations needed** (GET list, GET single, POST, PUT, DELETE)
3. **Fields/schema** for the resource
4. **Relationships** to other resources
5. **Authentication** requirements

### Step 2: Create Zod Schema

Create validator file first:

```typescript
// validators/{resource}.schema.ts
import { z } from 'zod'

export const create{Resource}Schema = z.object({
  // Fields based on user requirements
})

export const update{Resource}Schema = create{Resource}Schema.partial()

export const {resource}ParamsSchema = z.object({
  id: z.string().uuid(),
})

export const {resource}QuerySchema = z.object({
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
})

// Export types
export type Create{Resource} = z.infer<typeof create{Resource}Schema>
export type Update{Resource} = z.infer<typeof update{Resource}Schema>
```

### Step 3: Create Route File

```typescript
// routes/{resource}.ts
import { Hono } from 'hono'
import { zValidator } from '@hono/zod-validator'
import type { Env } from '../types/bindings'
import {
  create{Resource}Schema,
  update{Resource}Schema,
  {resource}ParamsSchema,
  {resource}QuerySchema
} from '../validators/{resource}.schema'

const {resource} = new Hono<Env>()

// GET /{resource} - List
{resource}.get('/',
  zValidator('query', {resource}QuerySchema),
  async (c) => {
    const { page, limit } = c.req.valid('query')
    // Implementation
    return c.json({ data: [], meta: { page, limit } })
  }
)

// GET /{resource}/:id - Get single
{resource}.get('/:id',
  zValidator('param', {resource}ParamsSchema),
  async (c) => {
    const { id } = c.req.valid('param')
    // Implementation
    return c.json({ id })
  }
)

// POST /{resource} - Create
{resource}.post('/',
  zValidator('json', create{Resource}Schema),
  async (c) => {
    const data = c.req.valid('json')
    // Implementation
    return c.json({ id: crypto.randomUUID(), ...data }, 201)
  }
)

// PUT /{resource}/:id - Update
{resource}.put('/:id',
  zValidator('param', {resource}ParamsSchema),
  zValidator('json', update{Resource}Schema),
  async (c) => {
    const { id } = c.req.valid('param')
    const data = c.req.valid('json')
    // Implementation
    return c.json({ id, ...data })
  }
)

// DELETE /{resource}/:id - Delete
{resource}.delete('/:id',
  zValidator('param', {resource}ParamsSchema),
  async (c) => {
    const { id } = c.req.valid('param')
    // Implementation
    return c.body(null, 204)
  }
)

export { {resource} }
```

### Step 4: Mount Route

Update `src/index.ts`:

```typescript
import { {resource} } from './routes/{resource}'

// Mount route
app.route('/api/{resource}', {resource})
```

### Step 5: Update Types (if using RPC)

```typescript
// Ensure AppType is exported for RPC client
export type AppType = typeof app
```

## Generated Files

1. `validators/{resource}.schema.ts` - Zod schemas
2. `routes/{resource}.ts` - Route handlers
3. Updated `src/index.ts` - Route mounting

## Quality Checklist

- [ ] All handlers have Zod validation
- [ ] Proper HTTP status codes (200, 201, 204, 400, 404)
- [ ] Types exported for RPC
- [ ] Consistent response format
- [ ] Error handling included
- [ ] Route mounted in main app

Now ask the user what route they want to create!
