---
paths:
  - "**/app/api/**/*.ts"
  - "**/pages/api/**/*.ts"
---

# Next.js API Route Standards

## Structure (App Router)

```typescript
import { NextResponse } from 'next/server'
import { z } from 'zod'

const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1),
})

export async function POST(request: Request) {
  try {
    const body = await request.json()
    const data = createUserSchema.parse(body)

    // Business logic
    const user = await createUser(data)

    return NextResponse.json(user, { status: 201 })
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { errors: error.errors },
        { status: 400 }
      )
    }
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}
```

## Requirements

- Zod validation for all inputs
- Proper error handling
- Typed responses
- No secrets in responses
- Rate limiting consideration

## HTTP Methods

```typescript
// GET - Read
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url)
  const id = searchParams.get('id')
  // ...
}

// POST - Create
export async function POST(request: Request) {
  const body = await request.json()
  // ...
}

// PUT/PATCH - Update
export async function PATCH(
  request: Request,
  { params }: { params: { id: string } }
) {
  const body = await request.json()
  // ...
}

// DELETE - Remove
export async function DELETE(
  request: Request,
  { params }: { params: { id: string } }
) {
  // ...
}
```

## Error Handling Pattern

```typescript
import { NextResponse } from 'next/server'
import { z } from 'zod'

class ApiError extends Error {
  constructor(
    message: string,
    public statusCode: number,
    public details?: unknown
  ) {
    super(message)
  }
}

function handleError(error: unknown) {
  if (error instanceof z.ZodError) {
    return NextResponse.json(
      { error: 'Validation error', details: error.errors },
      { status: 400 }
    )
  }
  if (error instanceof ApiError) {
    return NextResponse.json(
      { error: error.message, details: error.details },
      { status: error.statusCode }
    )
  }
  console.error('Unexpected error:', error)
  return NextResponse.json(
    { error: 'Internal server error' },
    { status: 500 }
  )
}
```

## Forbidden Patterns

- Unvalidated inputs
- Exposing stack traces
- Hardcoded secrets
- Missing error handling
- Any type in request/response
