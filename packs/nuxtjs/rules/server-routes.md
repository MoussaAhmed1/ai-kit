---
paths:
  - "**/server/api/**/*.ts"
  - "**/server/routes/**/*.ts"
---

# Nuxt.js Server Routes Standards

## Structure

```typescript
import { z } from 'zod'

const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1),
})

export default defineEventHandler(async (event) => {
  // Read and validate body
  const body = await readBody(event)
  const result = createUserSchema.safeParse(body)

  if (!result.success) {
    throw createError({
      statusCode: 400,
      message: 'Validation error',
      data: result.error.issues,
    })
  }

  // Business logic
  const user = await createUser(result.data)

  // Return response
  return user
})
```

## Requirements

- Zod validation for inputs
- Proper error handling with createError
- TypeScript types
- No secrets in responses

## Event Handlers

```typescript
// GET /api/users
export default defineEventHandler(async (event) => {
  const query = getQuery(event)
  return await getUsers(query)
})

// POST /api/users
export default defineEventHandler(async (event) => {
  const body = await readBody(event)
  return await createUser(body)
})

// GET /api/users/[id]
export default defineEventHandler(async (event) => {
  const id = getRouterParam(event, 'id')
  return await getUser(id)
})

// PATCH /api/users/[id]
export default defineEventHandler(async (event) => {
  const id = getRouterParam(event, 'id')
  const body = await readBody(event)
  return await updateUser(id, body)
})

// DELETE /api/users/[id]
export default defineEventHandler(async (event) => {
  const id = getRouterParam(event, 'id')
  await deleteUser(id)
  return { success: true }
})
```

## Error Handling

```typescript
export default defineEventHandler(async (event) => {
  const id = getRouterParam(event, 'id')

  const user = await getUser(id)

  if (!user) {
    throw createError({
      statusCode: 404,
      message: `User ${id} not found`,
    })
  }

  return user
})
```

## Authentication

```typescript
export default defineEventHandler(async (event) => {
  // Check session/auth
  const session = await getUserSession(event)

  if (!session) {
    throw createError({
      statusCode: 401,
      message: 'Unauthorized',
    })
  }

  // Proceed with authenticated request
  return await getProtectedData(session.user.id)
})
```

## Forbidden Patterns

- Unvalidated inputs
- Exposing stack traces
- Hardcoded secrets
- Missing error handling
- Any type
