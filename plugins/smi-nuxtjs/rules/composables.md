---
paths:
  - "**/composables/**/*.ts"
  - "**/composables/**/*.js"
---

# Nuxt.js Composables Standards

## Structure

```typescript
interface UseUserOptions {
  immediate?: boolean
}

interface UseUserReturn {
  user: Ref<User | null>
  isLoading: Ref<boolean>
  error: Ref<Error | null>
  refresh: () => Promise<void>
}

export function useUser(userId: string, options: UseUserOptions = {}): UseUserReturn {
  const { immediate = true } = options

  const user = ref<User | null>(null)
  const isLoading = ref(false)
  const error = ref<Error | null>(null)

  async function refresh() {
    isLoading.value = true
    try {
      const { data } = await useFetch<User>(`/api/users/${userId}`)
      user.value = data.value
      error.value = null
    } catch (e) {
      error.value = e instanceof Error ? e : new Error('Unknown error')
    } finally {
      isLoading.value = false
    }
  }

  if (immediate) {
    refresh()
  }

  return { user, isLoading, error, refresh }
}
```

## Naming Convention

- File: `use{Name}.ts`
- Function: `use{Name}`
- Always export named function
- Located in `~/composables/`

## Auto-Import Behavior

Composables in `~/composables/` are auto-imported:

```typescript
// In any component - no import needed
const { user, isLoading } = useUser('123')
```

## Data Fetching Pattern

```typescript
// Using useFetch (auto-imported)
export function useProducts() {
  const { data, pending, error, refresh } = useFetch<Product[]>('/api/products', {
    key: 'products',
    default: () => [],
  })

  return {
    products: data,
    isLoading: pending,
    error,
    refresh,
  }
}

// Using useAsyncData with custom fetch
export function useProduct(id: string) {
  return useAsyncData(`product-${id}`, () => {
    return $fetch<Product>(`/api/products/${id}`)
  })
}
```

## State Management Pattern

```typescript
// Shared state across components
export function useCounter() {
  // useState is auto-imported and persists across navigation
  const count = useState('counter', () => 0)

  function increment() {
    count.value++
  }

  function decrement() {
    count.value--
  }

  return { count, increment, decrement }
}
```

## Forbidden Patterns

- Options API style composables
- Explicit import of auto-imported functions
- Mutable shared state without useState
- Missing TypeScript types
