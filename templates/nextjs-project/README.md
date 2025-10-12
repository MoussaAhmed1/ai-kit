# Smicolon Next.js Project Template

This template includes all Smicolon conventions for Next.js development.

## Conventions Included

### 1. TypeScript Strict Mode
```typescript
// ✅ CORRECT - Properly typed
interface User {
  id: string
  email: string
  firstName: string
}

function getUser(id: string): Promise<User> {
  // Implementation
}

// ❌ WRONG - No types
function getUser(id) {
  // Implementation
}
```

### 2. Form Validation with Zod
```typescript
import { z } from 'zod'
import { zodResolver } from '@hookform/resolvers/zod'

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
})

type FormData = z.infer<typeof schema>

export function Form() {
  const { register, handleSubmit } = useForm<FormData>({
    resolver: zodResolver(schema),
  })
  // ...
}
```

### 3. API Client with TanStack Query
```typescript
import { useQuery } from '@tanstack/react-query'

export function useUser(id: string) {
  return useQuery({
    queryKey: ['user', id],
    queryFn: () => apiClient<User>(`/users/${id}`),
  })
}
```

### 4. Project Structure
```
src/
├── app/                    # Next.js App Router
│   ├── (auth)/
│   │   └── login/
│   ├── (dashboard)/
│   │   └── dashboard/
│   └── api/
├── components/
│   ├── ui/
│   ├── forms/
│   └── layouts/
├── lib/
│   ├── api/
│   ├── utils/
│   └── validations/
├── hooks/
└── types/
```

## Quick Start

1. Install Smicolon conventions:
   ```bash
   bash scripts/install.sh
   ```

2. Start building:
   ```bash
   claude
   /nextjs-architect "Design a user dashboard"
   ```

## Commands Available

- `/nextjs-architect` - Frontend architecture and design

## Enforced by Hooks

The post-write hook automatically checks for:
- ✅ TypeScript strict mode
- ✅ No 'any' types
- ✅ Zod validation on forms
- ✅ Proper error handling

Violations will be flagged immediately.
