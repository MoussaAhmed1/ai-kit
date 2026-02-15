---
paths:
  - "**/hooks/**/*.ts"
  - "**/hooks/**/*.tsx"
  - "**/use*.ts"
  - "**/use*.tsx"
---

# Next.js Custom Hooks Standards

## Structure

```typescript
import { useState, useEffect, useCallback } from 'react'

interface UseUserOptions {
  enabled?: boolean
}

interface UseUserReturn {
  user: User | null
  isLoading: boolean
  error: Error | null
  refetch: () => Promise<void>
}

export function useUser(userId: string, options: UseUserOptions = {}): UseUserReturn {
  const { enabled = true } = options
  const [user, setUser] = useState<User | null>(null)
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<Error | null>(null)

  const fetchUser = useCallback(async () => {
    if (!enabled) return
    setIsLoading(true)
    try {
      const response = await fetch(`/api/users/${userId}`)
      if (!response.ok) throw new Error('Failed to fetch user')
      const data = await response.json()
      setUser(data)
      setError(null)
    } catch (e) {
      setError(e instanceof Error ? e : new Error('Unknown error'))
    } finally {
      setIsLoading(false)
    }
  }, [userId, enabled])

  useEffect(() => {
    fetchUser()
  }, [fetchUser])

  return { user, isLoading, error, refetch: fetchUser }
}
```

## Requirements

- TypeScript with proper types
- Return type interface defined
- Memoized callbacks with useCallback
- Proper dependency arrays
- Error state handling
- Loading state handling

## Naming Convention

- Prefix with `use`
- Descriptive name: `useUser`, `useAuth`, `useLocalStorage`
- Options parameter for configuration
- Return object with named properties

## TanStack Query Pattern

```typescript
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'

export function useUser(userId: string) {
  return useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
    enabled: !!userId,
  })
}

export function useUpdateUser() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: updateUser,
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: ['user', data.id] })
    },
  })
}
```

## Common Hooks

### useLocalStorage

```typescript
export function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    if (typeof window === 'undefined') return initialValue
    try {
      const item = window.localStorage.getItem(key)
      return item ? JSON.parse(item) : initialValue
    } catch {
      return initialValue
    }
  })

  const setValue = useCallback((value: T | ((val: T) => T)) => {
    setStoredValue(prev => {
      const newValue = value instanceof Function ? value(prev) : value
      window.localStorage.setItem(key, JSON.stringify(newValue))
      return newValue
    })
  }, [key])

  return [storedValue, setValue] as const
}
```

## Forbidden Patterns

- Missing dependency arrays
- Non-memoized callbacks
- Any type
- Missing error handling
- Side effects outside useEffect
